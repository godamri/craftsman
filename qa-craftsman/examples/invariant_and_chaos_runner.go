package main

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"sync/atomic"
	"time"
)

// ==============================================================================
// 1. SUT: ATOMIC WALLET SERVICE
// ==============================================================================

type Wallet struct {
	mu      sync.Mutex
	balance int64
}

func NewWallet(initial int64) *Wallet {
	return &Wallet{balance: initial}
}

func (w *Wallet) Balance() int64 {
	w.mu.Lock()
	defer w.mu.Unlock()
	return w.balance
}

func (w *Wallet) Withdraw(amount int64) error {
	w.mu.Lock()
	defer w.mu.Unlock()

	if amount <= 0 {
		return errors.New("amount must be positive")
	}
	if w.balance < amount {
		return errors.New("insufficient balance")
	}
	w.balance -= amount
	return nil
}

// ==============================================================================
// 2. ADVERSARIAL QA TEST SUITE (Runnable verification demonstration)
// ==============================================================================

func runTableBoundaryTests() {
	wallet := NewWallet(100)

	testCases := []struct {
		name        string
		amount      int64
		expectError bool
	}{
		{"Valid withdrawal", 50, false},
		{"Zero amount rejected", 0, true},
		{"Negative amount rejected", -10, true},
		{"Exact remaining balance", 50, false},
		{"Exceeding balance rejected", 1, true},
	}

	for _, tc := range testCases {
		err := wallet.Withdraw(tc.amount)
		if (err != nil) != tc.expectError {
			panic(fmt.Sprintf("FAILED test %s: expected err=%v, got=%v", tc.name, tc.expectError, err))
		}
	}
	fmt.Println("✅ 1. Boundary & Negative Tests Passed")
}

func runConcurrencyBarrierRaceTest() {
	const initialBalance int64 = 1000
	const numWorkers = 50
	const debitAmount int64 = 20 // 50 * 20 = 1000 total

	wallet := NewWallet(initialBalance)
	startGate := make(chan struct{})
	var wg sync.WaitGroup

	var successfulDebits atomic.Int64
	var failedDebits atomic.Int64

	for i := 0; i < numWorkers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			<-startGate // Synchronized release barrier

			if err := wallet.Withdraw(debitAmount); err == nil {
				successfulDebits.Add(1)
			} else {
				failedDebits.Add(1)
			}
		}()
	}

	// Release all workers simultaneously
	close(startGate)
	wg.Wait()

	// INVARIANT VERIFICATION
	finalBalance := wallet.Balance()
	if finalBalance < 0 {
		panic(fmt.Sprintf("INVARIANT VIOLATED: Negative balance %d", finalBalance))
	}

	expectedBalance := initialBalance - (successfulDebits.Load() * debitAmount)
	if finalBalance != expectedBalance {
		panic(fmt.Sprintf("INVARIANT VIOLATED: Expected %d, got %d", expectedBalance, finalBalance))
	}

	fmt.Printf("✅ 2. Concurrency Barrier Test Passed: %d successful, %d failed, final balance=%d\n",
		successfulDebits.Load(), failedDebits.Load(), finalBalance)
}

func runFailureInjectionTest() {
	// Fault-injecting external adapter
	var attempts atomic.Int64
	callExternalAPI := func(ctx context.Context) error {
		count := attempts.Add(1)
		if count < 3 {
			return errors.New("transient HTTP 503 network drop")
		}
		return nil
	}

	// Resilient retry runner
	var err error
	for i := 0; i < 5; i++ {
		err = callExternalAPI(context.Background())
		if err == nil {
			break
		}
		time.Sleep(5 * time.Millisecond) // Backoff
	}

	if err != nil || attempts.Load() != 3 {
		panic("Failure injection retry test failed")
	}

	fmt.Printf("✅ 3. Failure Injection Test Passed: Recovered after %d transient attempts\n", attempts.Load())
}

func main() {
	fmt.Println("=== QA CRAFTSMAN: ADVERSARIAL VERIFICATION RUNNER ===")
	runTableBoundaryTests()
	runConcurrencyBarrierRaceTest()
	runFailureInjectionTest()
	fmt.Println("=== ALL VERIFICATION GATES PASSED (100% Deterministic) ===")
}
