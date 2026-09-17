"""Minimal domain entity, value object, and service example."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True)
class Money:
    amount_cents: int
    currency: str = "USD"


@dataclass
class Account:
    id: uuid.UUID
    balance: Money
    is_active: bool = True

    def withdraw(self, amount: Money) -> None:
        if not self.is_active:
            raise RuntimeError(f"Account {self.id} is inactive.")
        if self.balance.amount_cents < amount.amount_cents:
            raise ValueError(f"Insufficient funds in account {self.id}.")
        self.balance = Money(self.balance.amount_cents - amount.amount_cents, self.balance.currency)


class AccountRepository(Protocol):
    def get(self, account_id: uuid.UUID) -> Account | None: ...
    def save(self, account: Account) -> None: ...


class FakeAccountRepository:
    def __init__(self) -> None:
        self.accounts: dict[uuid.UUID, Account] = {}

    def get(self, account_id: uuid.UUID) -> Account | None:
        return self.accounts.get(account_id)

    def save(self, account: Account) -> None:
        self.accounts[account.id] = account


if __name__ == "__main__":
    repo = FakeAccountRepository()
    acc_id = uuid.uuid4()
    acc = Account(id=acc_id, balance=Money(1000))
    repo.save(acc)
    acc.withdraw(Money(400))
    assert acc.balance.amount_cents == 600
    print("Minimal domain example verified successfully.")
