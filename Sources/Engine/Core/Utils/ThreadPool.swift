import Foundation

class ThreadPool {
  private var threads: [Thread] = []
  private let jobQueue = DispatchQueue(label: "jobQueue", attributes: .concurrent)
  private var jobs: [() -> Void] = []
  private let lock = NSLock()

  init(threadsCount: Int) {
    print("Creating thread pool with \(threadsCount) threads")
    for _ in 0..<threadsCount {
      let thread = Thread {
        self.workerLoop()
      }
      self.threads.append(thread)
      thread.start()
    }
  }

  private func workerLoop() {
    while true {
      var job: (() -> Void)?
      lock.lock()
      if !jobs.isEmpty {
        job = jobs.removeFirst()
      }
      lock.unlock()

      if let job = job {
        job()
      } else {
        Thread.sleep(forTimeInterval: 0.01)
      }
    }
  }

  func addJob(_ job: @escaping () -> Void) {
    lock.lock()
    jobs.append(job)
    lock.unlock()
  }
}
