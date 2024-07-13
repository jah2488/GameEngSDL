import CSDL3
import CSDL3_image
import Foundation

struct Angle {
  let value: Double
  var valueInDegrees: Double {
    return value * 180 / Double.pi
  }
  private static let twoPi = Double.pi * 2

  init(_ value: Double, inDegrees: Bool = false) {
    if inDegrees {
      let normalized = value.truncatingRemainder(dividingBy: 360)
      if normalized < 0 {
        self.value = 360 + normalized
      } else {
        self.value = normalized
      }
    } else {
      let normalized = value.truncatingRemainder(dividingBy: Angle.twoPi)
      if normalized < 0 {
        self.value = Angle.twoPi + normalized
      } else {
        self.value = normalized
      }
    }
  }

  static func += (lhs: inout Angle, rhs: Double) {
    _ = Angle(lhs.value + rhs)
  }

  static func + (lhs: Angle, rhs: Double) -> Angle {
    Angle(lhs.value + rhs)
  }

  static func + (lhs: Angle, rhs: Angle) -> Angle {
    Angle(lhs.value + rhs.value)
  }

  static func - (lhs: Angle, rhs: Double) -> Angle {
    Angle(lhs.value - rhs)
  }

  static func - (lhs: Angle, rhs: Angle) -> Angle {
    Angle(lhs.value - rhs.value)
  }

  static func * (lhs: Angle, rhs: Angle) -> Angle {
    Angle(lhs.value * rhs.value)
  }

  static func / (lhs: Angle, rhs: Angle) -> Angle {
    Angle(lhs.value / rhs.value)
  }

}

func clamp(_ value: inout Double, min: Double, max: Double) {
  if value < min {
    value = min
  }

  if value > max {
    value = max
  }
}

struct Vector2 {
  var x: Double
  var y: Double
}
