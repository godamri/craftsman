"""Minimal async task execution with TaskGroup and bounded Semaphore."""

from __future__ import annotations

import asyncio


async def fetch_item(item_id: int, sem: asyncio.Semaphore) -> str:
    async with sem:
        async with asyncio.timeout(1.0):
            await asyncio.sleep(0.01)
            return f"item_{item_id}"


async def main() -> None:
    sem = asyncio.Semaphore(2)
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_item(i, sem)) for i in range(5)]

    results = [t.result() for t in tasks]
    assert len(results) == 5
    print(f"Async pipeline verified with results: {results}")


if __name__ == "__main__":
    asyncio.run(main())
