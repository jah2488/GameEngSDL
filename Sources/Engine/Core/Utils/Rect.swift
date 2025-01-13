import simd

struct Rect<T: Numeric & Comparable & BinaryFloatingPoint> {
  var x: T
  var y: T
  var width: T
  var height: T
  // Convenience properties for readability
  var left: T { return x }
  var right: T { return x + width }
  var top: T { return y }
  var bottom: T { return y + height }

  var minX: T { return x }
  var midX: T { return x + width / 2 }  //(0.5 as! T) }
  var maxX: T { return x + width }

  var center: simd_float2 { return simd_float2(Float(midX), Float(midY)) }

  var minY: T { return y }
  var midY: T { return y + height / 2 }
  var maxY: T { return y + height }

  // Method to check overlap with another rectangle
  @inlinable
  func overlaps(with other: Rect) -> Bool {
    return
      !(left >= other.right || right <= other.left || top >= other.bottom || bottom <= other.top)
  }
}
