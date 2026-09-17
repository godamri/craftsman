package main

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"sync"
	"time"
)

// --- Domain Errors & Invariants ---

var (
	ErrInvalidAmount          = errors.New("invalid amount: must be positive")
	ErrCurrencyMismatch       = errors.New("currency mismatch")
	ErrInsufficientFunds      = errors.New("insufficient funds")
	ErrAccountInactive        = errors.New("account is inactive")
	ErrAccountNotFound        = errors.New("account not found")
	ErrConcurrentModification = errors.New("concurrent modification detected (stale version)")
	ErrIdempotencyConflict    = errors.New("idempotency key conflict: payload fingerprint mismatch")
)

type Money struct {
	AmountCents int64
	Currency    string
}

type Account struct {
	ID       string
	Balance  Money
	IsActive bool
	Version  int64 // Monotonic version fencing against lost updates
}

func (a *Account) Withdraw(amount Money) error {
	if amount.AmountCents <= 0 {
		return ErrInvalidAmount
	}
	if a.Balance.Currency != amount.Currency {
		return fmt.Errorf("%w: account uses %s, requested %s", ErrCurrencyMismatch, a.Balance.Currency, amount.Currency)
	}
	if !a.IsActive {
		return ErrAccountInactive
	}
	if a.Balance.AmountCents < amount.AmountCents {
		return ErrInsufficientFunds
	}
	a.Balance.AmountCents -= amount.AmountCents
	a.Version++
	return nil
}

// --- Outbox Event ---

type OutboxEvent struct {
	ID        string
	EventType string
	Payload   string
	CreatedAt time.Time
}

// --- Idempotency Record ---

type IdempotencyRecord struct {
	Key          string
	PayloadHash  string
	ResponseCode int
	CreatedAt    time.Time
}

// --- Debit Request & Response ---

type DebitRequest struct {
	IdempotencyKey string
	AccountID      string
	Amount         Money
}

type DebitResponse struct {
	AccountID     string
	RemainingCent int64
	Version       int64
}

// --- Repository Interface ---

type AccountRepository interface {
	Get(ctx context.Context, id string) (*Account, error)
	GetIdempotency(ctx context.Context, key string) (*IdempotencyRecord, *DebitResponse, error)
	ExecuteDebit(ctx context.Context, acc *Account, expectedVersion int64, event *OutboxEvent, idemp *IdempotencyRecord, resp *DebitResponse) error
}

// --- Application Service ---

type TransferService struct {
	repo AccountRepository
}

func NewTransferService(repo AccountRepository) *TransferService {
	return &TransferService{repo: repo}
}

func (s *TransferService) Debit(ctx context.Context, req DebitRequest) (*DebitResponse, error) {
	if req.Amount.AmountCents <= 0 {
		return nil, ErrInvalidAmount
	}
	if req.IdempotencyKey == "" {
		return nil, errors.New("idempotency key is required for mutating operations")
	}

	payloadHash := hashPayload(req.AccountID, req.Amount)

	// 1. Check idempotency record first
	existingRecord, existingResp, err := s.repo.GetIdempotency(ctx, req.IdempotencyKey)
	if err != nil && !errors.Is(err, ErrNotFound) {
		return nil, fmt.Errorf("checking idempotency: %w", err)
	}
	if existingRecord != nil {
		if existingRecord.PayloadHash != payloadHash {
			// Same key used with different payload: Deterministic conflict
			return nil, fmt.Errorf("%w: key %s already used for different request", ErrIdempotencyConflict, req.IdempotencyKey)
		}
		// Idempotent replay: return identical saved response
		return existingResp, nil
	}

	// 2. Fetch authoritative account state
	acc, err := s.repo.Get(ctx, req.AccountID)
	if err != nil {
		return nil, fmt.Errorf("retrieving account: %w", err)
	}

	expectedVersion := acc.Version
	if err := acc.Withdraw(req.Amount); err != nil {
		return nil, fmt.Errorf("withdrawing funds: %w", err)
	}

	event := &OutboxEvent{
		ID:        fmt.Sprintf("evt_%s_%d", acc.ID, acc.Version),
		EventType: "AccountDebited",
		Payload:   fmt.Sprintf("{\"amount\": %d, \"currency\": \"%s\"}", req.Amount.AmountCents, req.Amount.Currency),
		CreatedAt: time.Now().UTC(),
	}

	resp := &DebitResponse{
		AccountID:     acc.ID,
		RemainingCent: acc.Balance.AmountCents,
		Version:       acc.Version,
	}

	idempRecord := &IdempotencyRecord{
		Key:          req.IdempotencyKey,
		PayloadHash:  payloadHash,
		ResponseCode: 200,
		CreatedAt:    time.Now().UTC(),
	}

	// 3. Atomically persist Account mutation + Outbox Event + Idempotency Record
	if err := s.repo.ExecuteDebit(ctx, acc, expectedVersion, event, idempRecord, resp); err != nil {
		return nil, fmt.Errorf("persisting atomic debit: %w", err)
	}

	return resp, nil
}

func hashPayload(accountID string, m Money) string {
	h := sha256.New()
	_, _ = h.Write([]byte(fmt.Sprintf("%s:%d:%s", accountID, m.AmountCents, m.Currency)))
	return hex.EncodeToString(h.Sum(nil))
}

var ErrNotFound = errors.New("record not found")

// --- In-Memory Test Double (Demonstrates Version Fencing & Outbox / Inbox Mechanics) ---
// NOTE: FakeAccountRepository is an in-memory double illustrating version fencing and outbox
// mechanics in tests. In production PostgreSQL, enforce transaction boundaries via BEGIN/COMMIT,
// table unique constraints on idempotency_key, and atomic SQL statements.

type FakeAccountRepository struct {
	mu          sync.RWMutex
	accounts    map[string]*Account
	outbox      []OutboxEvent
	idempotency map[string]struct {
		record   IdempotencyRecord
		response DebitResponse
	}
}

func NewFakeAccountRepository() *FakeAccountRepository {
	return &FakeAccountRepository{
		accounts: make(map[string]*Account),
		outbox:   make([]OutboxEvent, 0),
		idempotency: make(map[string]struct {
			record   IdempotencyRecord
			response DebitResponse
		}),
	}
}

func (f *FakeAccountRepository) Get(ctx context.Context, id string) (*Account, error) {
	f.mu.RLock()
	defer f.mu.RUnlock()

	acc, exists := f.accounts[id]
	if !exists {
		return nil, ErrAccountNotFound
	}
	copied := *acc
	return &copied, nil
}

func (f *FakeAccountRepository) GetIdempotency(ctx context.Context, key string) (*IdempotencyRecord, *DebitResponse, error) {
	f.mu.RLock()
	defer f.mu.RUnlock()

	entry, exists := f.idempotency[key]
	if !exists {
		return nil, nil, ErrNotFound
	}
	recCopy := entry.record
	respCopy := entry.response
	return &recCopy, &respCopy, nil
}

func (f *FakeAccountRepository) ExecuteDebit(
	ctx context.Context,
	acc *Account,
	expectedVersion int64,
	event *OutboxEvent,
	idemp *IdempotencyRecord,
	resp *DebitResponse,
) error {
	f.mu.Lock()
	defer f.mu.Unlock()

	current, exists := f.accounts[acc.ID]
	if !exists {
		return ErrAccountNotFound
	}
	if current.Version != expectedVersion {
		// Version fence breach: race detected, prevent lost update!
		return ErrConcurrentModification
	}

	copied := *acc
	f.accounts[acc.ID] = &copied

	if event != nil {
		f.outbox = append(f.outbox, *event)
	}
	if idemp != nil && resp != nil {
		f.idempotency[idemp.Key] = struct {
			record   IdempotencyRecord
			response DebitResponse
		}{record: *idemp, response: *resp}
	}
	return nil
}

func (f *FakeAccountRepository) SeedAccount(acc *Account) {
	f.mu.Lock()
	defer f.mu.Unlock()
	copied := *acc
	f.accounts[acc.ID] = &copied
}

func main() {
	ctx := context.Background()
	repo := NewFakeAccountRepository()

	repo.SeedAccount(&Account{
		ID:       "acc_123",
		Balance:  Money{AmountCents: 10000, Currency: "USD"},
		IsActive: true,
		Version:  1,
	})

	service := NewTransferService(repo)

	// First execution
	resp1, err := service.Debit(ctx, DebitRequest{
		IdempotencyKey: "idemp_req_001",
		AccountID:      "acc_123",
		Amount:         Money{AmountCents: 2500, Currency: "USD"},
	})
	if err != nil {
		panic(err)
	}

	// Idempotent duplicate replay
	resp2, err := service.Debit(ctx, DebitRequest{
		IdempotencyKey: "idemp_req_001",
		AccountID:      "acc_123",
		Amount:         Money{AmountCents: 2500, Currency: "USD"},
	})
	if err != nil {
		panic(err)
	}

	fmt.Printf("Resp1 Remaining: %d, Resp2 Remaining: %d, Version: %d, Outbox Events: %d\n",
		resp1.RemainingCent, resp2.RemainingCent, resp2.Version, len(repo.outbox))
}
