# Subprocess & OS Boundaries

Subprocesses (such as `ffmpeg`, `ffprobe`, and external worker utilities) require strict isolation and safety boundaries.

---

## 1. Safe Execution Pattern

Always pass arguments as a list of strings (`shell=False`). Validate executable existence and enforce explicit timeouts.

```python
import subprocess
import shutil
from pathlib import Path

class SubprocessError(Exception):
    """Raised when an external subprocess fails or times out."""

def probe_media_file(media_path: Path, timeout_seconds: float = 10.0) -> str:
    # 1. Validate binary availability
    if not shutil.which("ffprobe"):
        raise SubprocessError("ffprobe executable not found on system PATH.")

    # 2. Argument list execution with timeout and bounded capture
    cmd = ["ffprobe", "-v", "error", "-show_format", str(media_path)]
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout_seconds,
            check=False,
        )
    except subprocess.TimeoutExpired as err:
        raise SubprocessError(f"ffprobe timed out after {timeout_seconds}s on {media_path}") from err

    # 3. Explicit exit status validation
    if result.returncode != 0:
        error_msg = result.stderr.strip() or f"Exited with code {result.returncode}"
        raise SubprocessError(f"ffprobe failed: {error_msg}")

    return result.stdout
```

---

## 2. Child Process Cleanup on Cancellation

In asynchronous environments, ensure child processes are terminated when a task is cancelled:

```python
import asyncio

async def run_async_subprocess(cmd: list[str], timeout_sec: float) -> str:
    proc = await asyncio.create_subprocess_exec(
        *cmd,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    try:
        async with asyncio.timeout(timeout_sec):
            stdout, stderr = await proc.communicate()
            if proc.returncode != 0:
                raise RuntimeError(f"Command failed: {stderr.decode()}")
            return stdout.decode()
    except (TimeoutError, asyncio.CancelledError):
        # Prevent orphaned processes
        try:
            proc.kill()
        except ProcessLookupError:
            pass
        await proc.wait()
        raise
```
