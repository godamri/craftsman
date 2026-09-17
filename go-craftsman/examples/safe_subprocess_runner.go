package main

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

type SubprocessResult struct {
	Stdout   string
	Stderr   string
	Duration time.Duration
}

const maxOutputBytes = 1 << 20 // 1 MB strict buffer limit

// RunSubprocess executes an external binary safely with process group isolation,
// concurrent pipe reading, strict memory limits, and cancellation propagation.
func RunSubprocess(parentCtx context.Context, timeout time.Duration, binary string, args ...string) (*SubprocessResult, error) {
	ctx, cancel := context.WithTimeout(parentCtx, timeout)
	defer cancel()

	cmd := exec.CommandContext(ctx, binary, args...)
	// Place child into a new process group on Unix systems so all descendants can be killed
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}

	stdoutPipe, err := cmd.StdoutPipe()
	if err != nil {
		return nil, fmt.Errorf("creating stdout pipe: %w", err)
	}
	stderrPipe, err := cmd.StderrPipe()
	if err != nil {
		return nil, fmt.Errorf("creating stderr pipe: %w", err)
	}

	start := time.Now()
	if err := cmd.Start(); err != nil {
		return nil, fmt.Errorf("starting command %s: %w", binary, err)
	}

	var stdoutBuf, stderrBuf bytes.Buffer
	var limitExceeded bool
	var limitMu sync.Mutex

	// Bounded concurrent reader: reads at most maxOutputBytes+1 to detect overflow
	readPipe := func(r io.Reader, buf *bytes.Buffer) error {
		// Read up to limit + 1
		lr := io.LimitReader(r, maxOutputBytes+1)
		n, err := io.Copy(buf, lr)
		if n > maxOutputBytes {
			limitMu.Lock()
			limitExceeded = true
			limitMu.Unlock()
			// Kill process group immediately on buffer overflow
			if cmd.Process != nil {
				_ = syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL)
			}
			return ErrOutputLimitExceeded
		}
		return err
	}

	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()
		_ = readPipe(stdoutPipe, &stdoutBuf)
	}()
	go func() {
		defer wg.Done()
		_ = readPipe(stderrPipe, &stderrBuf)
	}()

	// Wait for readers to finish reading pipes
	wg.Wait()

	// Wait for process termination to reap process and prevent zombies
	waitErr := cmd.Wait()

	limitMu.Lock()
	exceeded := limitExceeded
	limitMu.Unlock()

	if exceeded {
		return nil, fmt.Errorf("command %s: %w (%d bytes limit)", binary, ErrOutputLimitExceeded, maxOutputBytes)
	}

	if ctx.Err() == context.DeadlineExceeded {
		// Ensure entire process group is reaped on timeout
		if cmd.Process != nil {
			_ = syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL)
		}
		return nil, fmt.Errorf("command %s: %w after %v", binary, ErrSubprocessTimeout, timeout)
	}

	if waitErr != nil {
		return nil, fmt.Errorf("command %s failed: stderr=%q: %w", binary, stderrBuf.String(), waitErr)
	}

	return &SubprocessResult{
		Stdout:   stdoutBuf.String(),
		Stderr:   stderrBuf.String(),
		Duration: time.Since(start),
	}, nil
}

func main() {
	ctx := context.Background()

	// 1. Normal execution
	res, err := RunSubprocess(ctx, 2*time.Second, "echo", "hello", "from", "hardened", "go-craftsman")
	if err != nil {
		panic(err)
	}
	fmt.Printf("✅ Subprocess output: %sExecution time: %v\n", res.Stdout, res.Duration)

	// 2. Demonstration: Testing that buffer limit overflow is detected and rejected
	_, err = RunSubprocess(ctx, 2*time.Second, "head", "-c", "2000000", "/dev/zero")
	if errors.Is(err, ErrOutputLimitExceeded) {
		fmt.Println("✅ Successfully detected and aborted output exceeding buffer limit!")
	} else if err != nil {
		fmt.Printf("Subprocess ended with: %v\n", err)
	}
}
