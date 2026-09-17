# Subprocess & OS Boundaries

Subprocesses are untrusted system boundaries. In Go, `exec.CommandContext` kills only the top-level spawned process upon cancellation; it does NOT automatically terminate descendant child processes unless process groups are configured.

---

## 1. Process Group Termination & Output Overflow Detection

```go
package subprocess

import (
    "bytes"
    "context"
    "errors"
    "fmt"
    "io"
    "os/exec"
    "sync"
    "syscall"
    "time"
)

var (
    ErrOutputLimitExceeded = errors.New("subprocess output exceeded maximum buffer limit")
    ErrSubprocessTimeout   = errors.New("subprocess timed out")
)

const maxOutputBytes = 1 << 20 // 1 MB limit

func RunIsolatedSubprocess(parentCtx context.Context, timeout time.Duration, binary string, args ...string) (string, error) {
    ctx, cancel := context.WithTimeout(parentCtx, timeout)
    defer cancel()

    cmd := exec.CommandContext(ctx, binary, args...)
    // Place child process into its own process group on Unix so all descendants can be killed
    cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}

    stdoutPipe, err := cmd.StdoutPipe()
    if err != nil {
        return "", fmt.Errorf("creating stdout pipe: %w", err)
    }
    stderrPipe, err := cmd.StderrPipe()
    if err != nil {
        return "", fmt.Errorf("creating stderr pipe: %w", err)
    }

    if err := cmd.Start(); err != nil {
        return "", fmt.Errorf("starting binary %s: %w", binary, err)
    }

    var stdoutBuf, stderrBuf bytes.Buffer
    var limitExceeded bool
    var limitMu sync.Mutex

    readPipe := func(r io.Reader, buf *bytes.Buffer) error {
        // Read up to limit + 1 byte to detect overflow deterministically
        n, err := io.Copy(buf, io.LimitReader(r, maxOutputBytes+1))
        if n > maxOutputBytes {
            limitMu.Lock()
            limitExceeded = true
            limitMu.Unlock()
            // Kill process group immediately on overflow
            if cmd.Process != nil {
                _ = syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL)
            }
            return ErrOutputLimitExceeded
        }
        return err
    }

    var wg sync.WaitGroup
    wg.Add(2)
    go func() { defer wg.Done(); _ = readPipe(stdoutPipe, &stdoutBuf) }()
    go func() { defer wg.Done(); _ = readPipe(stderrPipe, &stderrBuf) }()

    wg.Wait()
    waitErr := cmd.Wait()

    limitMu.Lock()
    exceeded := limitExceeded
    limitMu.Unlock()

    if exceeded {
        return "", fmt.Errorf("binary %s: %w", binary, ErrOutputLimitExceeded)
    }

    if ctx.Err() == context.DeadlineExceeded {
        if cmd.Process != nil {
            _ = syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL)
        }
        return "", fmt.Errorf("subprocess %s: %w after %v", binary, ErrSubprocessTimeout, timeout)
    }

    if waitErr != nil {
        return "", fmt.Errorf("subprocess %s failed (stderr: %q): %w", binary, stderrBuf.String(), waitErr)
    }

    return stdoutBuf.String(), nil
}
```
