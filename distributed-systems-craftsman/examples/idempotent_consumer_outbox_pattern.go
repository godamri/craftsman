package main

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"sync"
)

// ==============================================================================
// 1. DOMAIN & INBOX MODELS
// ==============================================================================

type InboxRecord struct {
	IdempotencyKey string
	PayloadHash    string
	Response       string
}

type InMemoryDatabase struct {
	mu          sync.Mutex
	accounts    map[string]int64
	inbox       map[string]InboxRecord
	outboxQueue []string
}

func NewInMemoryDatabase() *InMemoryDatabase {
	return &InMemoryDatabase{
		accounts:    map[string]int64{"acc_100": 10000},
		inbox:       make(map[string]InboxRecord),
		outboxQueue: make([]string, 0),
	}
}

var (
	ErrIdempotencyConflict = errors.New("idempotency key reused with conflicting payload")
	ErrInsufficientBalance = errors.New("insufficient balance")
)

func hashPayload(payload string) string {
	sum := sha256.Sum256([]byte(payload))
	return hex.EncodeToString(sum[:])
}

// ProcessTransferAtomic performs idempotent execution with inbox deduplication.
func (db *InMemoryDatabase) ProcessTransferAtomic(idempotencyKey string, accountID string, amount int64) (string, error) {
	db.mu.Lock()
	defer db.mu.Unlock()

	payloadSignature := fmt.Sprintf("%s:%d", accountID, amount)
	currentHash := hashPayload(payloadSignature)

	// 1. INBOX DEDUPLICATION CHECK
	if existing, found := db.inbox[idempotencyKey]; found {
		if existing.PayloadHash != currentHash {
			return "", ErrIdempotencyConflict
		}
		// Idempotent replay: return cached successful response
		return fmt.Sprintf("[IDEMPOTENT REPLAY] %s", existing.Response), nil
	}

	// 2. DOMAIN INVARIANT CHECK
	balance, exists := db.accounts[accountID]
	if !exists || balance < amount {
		return "", ErrInsufficientBalance
	}

	// 3. MUTATE STATE & PERSIST OUTBOX ATOMICALLY
	db.accounts[accountID] = balance - amount
	responseMsg := fmt.Sprintf("Debited %d cents. New balance: %d cents", amount, db.accounts[accountID])

	// Record in Inbox
	db.inbox[idempotencyKey] = InboxRecord{
		IdempotencyKey: idempotencyKey,
		PayloadHash:    currentHash,
		Response:       responseMsg,
	}

	// Append to Outbox
	outboxEvent := fmt.Sprintf("Event:AccountDebited:{account:%s,amount:%d}", accountID, amount)
	db.outboxQueue = append(db.outboxQueue, outboxEvent)

	return responseMsg, nil
}

func main() {
	db := NewInMemoryDatabase()

	key := "req_tx_abc_123"

	// 1. Initial Request
	resp1, err := db.ProcessTransferAtomic(key, "acc_100", 2500)
	if err != nil {
		panic(err)
	}
	fmt.Printf("1. First Execution: %s\n", resp1)

	// 2. Duplicate Delivery (Simulating network retry)
	resp2, err := db.ProcessTransferAtomic(key, "acc_100", 2500)
	if err != nil {
		panic(err)
	}
	fmt.Printf("2. Duplicate Replay: %s\n", resp2)

	// 3. Conflicting Payload with same Key
	_, err = db.ProcessTransferAtomic(key, "acc_100", 9999)
	if errors.Is(err, ErrIdempotencyConflict) {
		fmt.Println("3. Conflicting Payload: Successfully rejected with 409 Conflict!")
	} else {
		panic("Expected idempotency conflict error")
	}

	fmt.Printf("Final Account Balance: %d cents (Correct: Deducted exactly once!)\n", db.accounts["acc_100"])
}
