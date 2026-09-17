package main

import (
	"context"
	"errors"
	"fmt"
	"time"
)

// ==============================================================================
// 1. PURE DOMAIN CORE (Zero dependencies on external delivery or database)
// ==============================================================================

type OrderID string
type Money int64 // Amount in cents

var (
	ErrInvalidOrderAmount = errors.New("order amount must be greater than zero")
	ErrOrderAlreadyPaid   = errors.New("order has already been paid")
)

type Order struct {
	ID        OrderID
	Total     Money
	IsPaid    bool
	CreatedAt time.Time
}

func NewOrder(id OrderID, total Money) (*Order, error) {
	if total <= 0 {
		return nil, ErrInvalidOrderAmount
	}
	return &Order{
		ID:        id,
		Total:     total,
		IsPaid:    false,
		CreatedAt: time.Now().UTC(),
	}, nil
}

func (o *Order) MarkPaid() error {
	if o.IsPaid {
		return ErrOrderAlreadyPaid
	}
	o.IsPaid = true
	return nil
}

// ==============================================================================
// 2. PORTS / CONSUMER INTERFACES (Owned by domain / application layer)
// ==============================================================================

type OrderRepository interface {
	Get(ctx context.Context, id OrderID) (*Order, error)
	Save(ctx context.Context, order *Order) error
}

type PaymentGateway interface {
	Charge(ctx context.Context, orderID OrderID, amount Money) (string, error)
}

// ==============================================================================
// 3. APPLICATION SERVICE (Coordinates domain rules and ports)
// ==============================================================================

type OrderService struct {
	repo    OrderRepository
	gateway PaymentGateway
}

func NewOrderService(repo OrderRepository, gateway PaymentGateway) *OrderService {
	return &OrderService{
		repo:    repo,
		gateway: gateway,
	}
}

func (s *OrderService) PayOrder(ctx context.Context, id OrderID) error {
	order, err := s.repo.Get(ctx, id)
	if err != nil {
		return fmt.Errorf("retrieving order: %w", err)
	}

	if err := order.MarkPaid(); err != nil {
		return err
	}

	// Charge external gateway
	paymentRef, err := s.gateway.Charge(ctx, order.ID, order.Total)
	if err != nil {
		return fmt.Errorf("charging payment gateway: %w", err)
	}

	if err := s.repo.Save(ctx, order); err != nil {
		return fmt.Errorf("persisting paid order %s (payment ref: %s): %w", order.ID, paymentRef, err)
	}

	return nil
}

// ==============================================================================
// 4. INFRASTRUCTURE ADAPTERS (Outer Ring - Implements Ports)
// ==============================================================================

type InMemoryOrderRepository struct {
	orders map[OrderID]*Order
}

func NewInMemoryOrderRepository() *InMemoryOrderRepository {
	return &InMemoryOrderRepository{orders: make(map[OrderID]*Order)}
}

func (r *InMemoryOrderRepository) Get(ctx context.Context, id OrderID) (*Order, error) {
	o, exists := r.orders[id]
	if !exists {
		return nil, errors.New("order not found")
	}
	copied := *o
	return &copied, nil
}

func (r *InMemoryOrderRepository) Save(ctx context.Context, order *Order) error {
	copied := *order
	r.orders[order.ID] = &copied
	return nil
}

type MockPaymentGateway struct{}

func (m *MockPaymentGateway) Charge(ctx context.Context, orderID OrderID, amount Money) (string, error) {
	// Simulate external call
	return fmt.Sprintf("txn_charge_%s_%d", orderID, amount), nil
}

func main() {
	ctx := context.Background()
	repo := NewInMemoryOrderRepository()
	gateway := &MockPaymentGateway{}

	order, _ := NewOrder("ord_001", 5000)
	_ = repo.Save(ctx, order)

	service := NewOrderService(repo, gateway)
	if err := service.PayOrder(ctx, "ord_001"); err != nil {
		panic(err)
	}

	paidOrder, _ := repo.Get(ctx, "ord_001")
	fmt.Printf("✅ Order %s successfully paid: IsPaid=%v, Amount=%d cents\n",
		paidOrder.ID, paidOrder.IsPaid, paidOrder.Total)
}
