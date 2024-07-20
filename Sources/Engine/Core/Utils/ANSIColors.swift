extension String {
  private static let ESC = "\u{001B}[0;"
  enum ANSIColors: String {
    case black = "30m"
    case red = "31m"
    case green = "32m"
    case yellow = "33m"
    case blue = "34m"
    case magenta = "35m"
    case cyan = "36m"
    case white = "37m"
  }

  func colorize(_ color: ANSIColors) -> String {
    return "\(String.ESC)\(color.rawValue)\(self)\(String.ESC)0m"
  }
}
