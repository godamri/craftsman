package main

import (
	"context"
	"fmt"
	"sync"
	"time"
)

type Job struct {
	ID    int
	Input string
}

type Result struct {
	JobID    int
	Output   string
	Duration time.Duration
	Err      error
}

func Worker(ctx context.Context, id int, jobs <-chan Job, results chan<- Result, wg *sync.WaitGroup) {
	defer wg.Done()
	for {
		select {
		case <-ctx.Done():
			return // Exit cleanly on cancellation
		case job, ok := <-jobs:
			if !ok {
				return // Channel closed, terminate worker
			}

			res := processJobSafely(ctx, job)
			select {
			case <-ctx.Done():
				return
			case results <- res:
			}
		}
	}
}

func processJobSafely(ctx context.Context, job Job) (res Result) {
	start := time.Now()
	res.JobID = job.ID

	// Recover worker panics to prevent process crashes
	defer func() {
		if r := recover(); r != nil {
			res.Err = fmt.Errorf("worker panicked: %v", r)
			res.Duration = time.Since(start)
		}
	}()

	if job.Input == "poison_pill" {
		panic("simulated fatal payload panic")
	}

	// Simulate work
	time.Sleep(5 * time.Millisecond)
	res.Output = fmt.Sprintf("PROCESSED(%s)", job.Input)
	res.Duration = time.Since(start)
	return res
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	const numWorkers = 3
	const totalJobs = 10

	// Bounded channels enforcing backpressure
	jobs := make(chan Job, 5)
	results := make(chan Result, totalJobs)

	var wg sync.WaitGroup
	for w := 1; w <= numWorkers; w++ {
		wg.Add(1)
		go Worker(ctx, w, jobs, results, &wg)
	}

	// Producer
	go func() {
		defer close(jobs)
		for j := 1; j <= totalJobs; j++ {
			input := fmt.Sprintf("task_%d", j)
			if j == 7 {
				input = "poison_pill" // Test panic isolation
			}
			select {
			case <-ctx.Done():
				return
			case jobs <- Job{ID: j, Input: input}:
			}
		}
	}()

	// Wait and close results
	go func() {
		wg.Wait()
		close(results)
	}()

	var successes, failures int
	for res := range results {
		if res.Err != nil {
			failures++
			fmt.Printf("❌ Job %d failed: %v\n", res.JobID, res.Err)
		} else {
			successes++
			fmt.Printf("✅ Job %d completed in %v: %s\n", res.JobID, res.Duration, res.Output)
		}
	}
	fmt.Printf("Pipeline complete: %d successes, %d failures\n", successes, failures)
}
