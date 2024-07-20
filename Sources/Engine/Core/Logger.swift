import Foundation

struct PerformanceTracker {
  var ticks: Int = 0
  var loops: Int = 0
  private var frameTimes: [Double] = []
  private let trackingInterval: Int = 100

  mutating func update(delta: Double, currentTime: Double) {
    ticks += Int(delta * 1000)
    loops += 1

    // Record frame time
    frameTimes.append(delta)

    if frameTimes.count > trackingInterval {
      frameTimes.removeFirst()
    }
  }

  func averageFrameRate() -> Double {
    let elapsedTimeInSeconds = Double(ticks) / 1000.0
    guard elapsedTimeInSeconds > 0 else {
      return 0.0
    }
    return (Double(loops) / elapsedTimeInSeconds).rounded()
  }

  func averageFrameRateOverInterval() -> Double {
    let elapsedTimeInSeconds = frameTimes.reduce(0, +)
    guard elapsedTimeInSeconds > 0 else {
      return 0.0
    }
    return (Double(frameTimes.count) / elapsedTimeInSeconds).rounded()
  }
}

//TODO: Only log "novel" messages, keep a set of messages that have been logged,
// and check if they are the same, if they are, don't log them.
// If nothing has been "logged" between Indent Start and End, don't output either of those.
// Be able to turn on/off logging of certain subsystems (ie. Object creation, etc.)
class Logger {
  enum LogLevel {
    case info
    case warning
    case error
  }
  var loops = 0
  var ticks = 0
  var startTime = 0

  var timeLast = 0
  var timeNow = 0

  var level = 0

  var pt: PerformanceTracker = PerformanceTracker()

  let logLevel: LogLevel

  init(_ level: LogLevel = .info) {
    self.logLevel = level
  }

  func start(time: Int) {
    // if writing to a file, open the file here
    startTime = time
  }

  func loop(ticks: Int, time: Int, delta: Double) {
    loops += 1
    self.ticks = ticks
    self.timeLast = timeNow
    self.timeNow = time

    pt.update(delta: delta, currentTime: Double(ticks))

    let frameRate = (1 / delta).rounded()

    if logLevel == .info {
      print("\u{001B}[2J")
      log(
        "--- [Frame #\(loops)][\((frameRate))fps][\("\(ticks)".colorize(.green))ms] (avg fps: \(pt.averageFrameRate())) | recent avg:\(pt.averageFrameRateOverInterval()) ---",
        indent: false
      )
    }
  }

  func indent(_ name: String? = nil) {
    if let name = name {
      logIndentStart(name)
    }
    level += 1
  }

  func dedent(_ name: String = "end") {
    level -= 1
    logIndentEnd(name)
  }

  func logIndentStart(_ name: String) {
    if logLevel == .info {
      // log("--- \(name) {")
    }
  }

  func logIndentEnd(_ name: String) {
    if logLevel == .info {
      // log("--- } \(name)")
    }
  }

  func log(_ message: String, indent: Bool = true) {
    let indent = String(repeating: "  ", count: level)
    print("\(indent)\(message)")
  }
}
