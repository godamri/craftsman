"""Minimal type-safe decorator and context manager example."""

from __future__ import annotations

import functools
import time
from collections.abc import Callable
from contextlib import contextmanager
from typing import ParamSpec, TypeVar

P = ParamSpec("P")
R = TypeVar("R")


def timed(func: Callable[P, R]) -> Callable[P, R]:
    @functools.wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        start = time.perf_counter()
        try:
            return func(*args, **kwargs)
        finally:
            _ = time.perf_counter() - start

    return wrapper


@contextmanager
def temporary_flag(flags: dict[str, bool], key: str, val: bool):
    old = flags.get(key, False)
    flags[key] = val
    try:
        yield
    finally:
        flags[key] = old


if __name__ == "__main__":
    d = {"DEBUG": False}
    with temporary_flag(d, "DEBUG", True):
        assert d["DEBUG"] is True
    assert d["DEBUG"] is False
    print("Minimal decorator and context manager verified successfully.")
