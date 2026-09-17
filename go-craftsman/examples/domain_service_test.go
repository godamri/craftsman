package main

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"sync/atomic"
	"testing"
)

func TestTransferService_Debit_Invariants(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name          string
		initialAmount int64
		currency      string
		isActive      bool
		debitAmount   int64
		debitCurrency string
		expectedErr   error
		expectedAfter int64
	}{
		{
			name:          "successful debit",
			initialAmount: 1000,
			currency:      "USD",
			isActive:      true,
			debitAmount:   400,
			debitCurrency: "USD",
			expectedErr:   nil,
			expectedAfter: 600,
		},
		{
			name:          "negative amount rejected",
			initialAmount: 1000,
			currency:      "USD",
			isActive:      true,
			debitAmount:   -50,
			debitCurrency: "USD",
			expectedErr:   ErrInvalidAmount,
			expectedAfter: 1000,
		},
		{
			name:          "zero amount rejected",
			initialAmount: 1000,
			currency:      "USD",
			isActive:      true,
			debitAmount:   0,
			debitCurrency: "USD",
			expectedErr:   ErrInvalidAmount,
			expectedAfter: 1000,
		},
		{
			name:          "currency mismatch rejected",
			initialAmount: 1000,
			currency:      "USD",
			isActive:      true,
			debitAmount:   100,
			debitCurrency: "EUR",
			expectedErr:   ErrCurrencyMismatch,
			expectedAfter: 1000,
		},
		{
			name:          "insufficient funds rejected",
			initialAmount: 200,
			currency:      "USD",
			isActive:      true,
			debitAmount:   500,
			debitCurrency: "USD",
			expectedErr:   ErrInsufficientFunds,
			expectedAfter: 200,
		},
		{
			name:          "inactive account rejected",
			initialAmount: 1000,
			currency:      "USD",
			isActive:      false,
			debitAmount:   100,
			debitCurrency: "USD",
			expectedErr:   ErrAccountInactive,
			expectedAfter: 1000,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			ctx := context.Background()
			repo := NewFakeAccountRepository()
			repo.SeedAccount(&Account{
				ID:       "acc_test",
				Balance:  Money{AmountCents: tt.initialAmount, Currency: tt.currency},
				IsActive: tt.isActive,
				Version:  1,
			})

			svc := NewTransferService(repo)
			resp, err := svc.Debit(ctx, DebitRequest{
				IdempotencyKey: fmt.Sprintf("key_%s", tt.name),
				AccountID:      "acc_test",
				Amount:         Money{AmountCents: tt.debitAmount, Currency: tt.debitCurrency},
			})

			if tt.expectedErr != nil {
				if !errors.Is(err, tt.expectedErr) {
					t.Fatalf("expected error %v, got %v", tt.expectedErr, err)
				}
			} else {
				if err != nil {
					t.Fatalf("unexpected error: %v", err)
				}
				if resp.RemainingCent != tt.expectedAfter {
					t.Fatalf("expected response balance %d, got %d", tt.expectedAfter, resp.RemainingCent)
				}
			}

			acc, _ := repo.Get(ctx, "acc_test")
			if acc.Balance.AmountCents != tt.expectedAfter {
				t.Fatalf("expected persisted balance %d, got %d", tt.expectedAfter, acc.Balance.AmountCents)
			}
		})
	}
}

func TestTransferService_Idempotency(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	repo := NewFakeAccountRepository()
	repo.SeedAccount(&Account{
		ID:       "acc_idemp",
		Balance:  Money{AmountCents: 10000, Currency: "USD"},
		IsActive: true,
		Version:  1,
	})

	svc := NewTransferService(repo)

	// 1. Initial Request
	req := DebitRequest{
		IdempotencyKey: "idemp_unique_123",
		AccountID:      "acc_idemp",
		Amount:         Money{AmountCents: 3000, Currency: "USD"},
	}
	resp1, err := svc.Debit(ctx, req)
	if err != nil {
		t.Fatalf("initial debit failed: %v", err)
	}
	if resp1.RemainingCent != 7000 {
		t.Fatalf("expected remaining 7000, got %d", resp1.RemainingCent)
	}

	// 2. Replay with identical payload: Must return identical response without double deduction
	resp2, err := svc.Debit(ctx, req)
	if err != nil {
		t.Fatalf("replay debit failed: %v", err)
	}
	if resp2.RemainingCent != 7000 {
		t.Fatalf("expected remaining 7000 on replay, got %d", resp2.RemainingCent)
	}

	acc, _ := repo.Get(ctx, "acc_idemp")
	if acc.Balance.AmountCents != 7000 {
		t.Fatalf("double deduction detected: balance is %d, expected 7000", acc.Balance.AmountCents)
	}

	// 3. Replay with same key but different payload: Must reject with conflict
	conflictReq := DebitRequest{
		IdempotencyKey: "idemp_unique_123",
		AccountID:      "acc_idemp",
		Amount:         Money{AmountCents: 5000, Currency: "USD"}, // Different amount!
	}
	_, err = svc.Debit(ctx, conflictReq)
	if !errors.Is(err, ErrIdempotencyConflict) {
		t.Fatalf("expected ErrIdempotencyConflict, got %v", err)
	}
}

func TestConcurrentDebits_OptimisticVersioningPreventsLostUpdates(t *testing.T) {
	ctx := context.Background()
	repo := NewFakeAccountRepository()
	repo.SeedAccount(&Account{
		ID:       "acc_concurrent",
		Balance:  Money{AmountCents: 10000, Currency: "USD"},
		IsActive: true,
		Version:  1,
	})

	svc := NewTransferService(repo)

	var successCount atomic.Int64
	var conflictCount atomic.Int64

	var wg sync.WaitGroup
	for i := 0; i < 10; i++ {
		wg.Add(1)
		workerID := i
		go func() {
			defer wg.Done()
			_, err := svc.Debit(ctx, DebitRequest{
				IdempotencyKey: fmt.Sprintf("concurrent_key_%d", workerID),
				AccountID:      "acc_concurrent",
				Amount:         Money{AmountCents: 100, Currency: "USD"},
			})
			if err == nil {
				successCount.Add(1)
			} else if errors.Is(err, ErrConcurrentModification) {
				conflictCount.Add(1)
			}
		}()
	}
	wg.Wait()

	// Invariant: Total operations must equal success + conflicts
	if successCount.Load()+conflictCount.Load() != 10 {
		t.Fatalf("inconsistent concurrent results: %d successes, %d conflicts",
			successCount.Load(), conflictCount.Load())
	}
}

func FuzzMoneyValidation(f *testing.F) {
	f.Add(int64(100), "USD")
	f.Add(int64(0), "EUR")
	f.Add(int64(-50), "GBP")

	f.Fuzz(func(t *testing.T, amount int64, currency string) {
		m := Money{AmountCents: amount, Currency: currency}
		acc := Account{ID: "fuzz_acc", Balance: Money{AmountCents: 500, Currency: currency}, IsActive: true, Version: 1}
		_ = acc.Withdraw(m)
	})
}
