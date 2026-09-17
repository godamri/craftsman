use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::mpsc::{sync_channel, SyncSender};
use std::sync::Arc;
use std::thread;

// ==============================================================================
// 1. BOUNDED PRODUCER-CONSUMER PIPELINE WITH GRACEFUL DRAIN SHUTDOWN
// ==============================================================================

#[derive(Debug)]
pub struct Job {
    pub id: usize,
    pub payload: String,
}

pub struct WorkerPool {
    sender: Option<SyncSender<Job>>,
    workers: Vec<thread::JoinHandle<()>>,
    processed_count: Arc<AtomicUsize>,
}

impl WorkerPool {
    pub fn new(worker_count: usize, bound_capacity: usize) -> Self {
        let (sender, receiver) = sync_channel::<Job>(bound_capacity);
        let receiver = Arc::new(std::sync::Mutex::new(receiver));
        let processed_count = Arc::new(AtomicUsize::new(0));

        let mut workers = Vec::with_capacity(worker_count);

        for worker_id in 0..worker_count {
            let rx = Arc::clone(&receiver);
            let processed = Arc::clone(&processed_count);

            let handle = thread::spawn(move || {
                loop {
                    // Fetch job or break when channel is closed (all senders dropped)
                    let job_res = {
                        let locked_rx = rx.lock().unwrap();
                        locked_rx.recv()
                    };

                    match job_res {
                        Ok(job) => {
                            // Process job
                            processed.fetch_add(1, Ordering::SeqCst);
                            println!("⚙️ Worker {} processed job #{}", worker_id, job.id);
                        }
                        Err(_) => {
                            // Channel disconnected and drained: terminate worker cleanly
                            break;
                        }
                    }
                }
                println!("🛑 Worker {} finished and exited", worker_id);
            });

            workers.push(handle);
        }

        WorkerPool {
            sender: Some(sender),
            workers,
            processed_count,
        }
    }

    pub fn submit(&self, job: Job) -> Result<(), std::sync::mpsc::SendError<Job>> {
        if let Some(ref s) = self.sender {
            s.send(job)
        } else {
            panic!("Cannot submit to stopped worker pool");
        }
    }

    /// Graceful shutdown:
    /// 1. Drops the sender (closing the channel)
    /// 2. Workers drain all queued jobs until disconnected
    /// 3. Joins all worker threads
    pub fn graceful_shutdown(mut self) -> usize {
        // Drop sender to signal no more new work
        self.sender.take();

        // Await all workers draining the queue
        for handle in self.workers {
            let _ = handle.join();
        }

        self.processed_count.load(Ordering::SeqCst)
    }
}

// ==============================================================================
// 2. MAIN RUNNER & VERIFICATION
// ==============================================================================

fn main() {
    println!("=== RUST CRAFTSMAN: CONCURRENCY & GRACEFUL DRAIN DEMO ===");

    let pool = WorkerPool::new(4, 10);

    for i in 1..=8 {
        pool.submit(Job {
            id: i,
            payload: format!("task_payload_{}", i),
        })
        .expect("channel send succeeded");
    }

    // Gracefully shut down and drain all submitted jobs
    let processed = pool.graceful_shutdown();
    println!("✅ All workers gracefully drained and stopped. Total processed jobs: {}", processed);

    // Guaranteed by channel drain semantics
    assert_eq!(processed, 8, "All submitted jobs must be processed before shutdown");

    println!("=== CONCURRENCY & DRAIN PIPELINE VERIFIED ===");
}
