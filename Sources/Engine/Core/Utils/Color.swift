struct Color {
  var r: UInt8
  var g: UInt8
  var b: UInt8
  var a: UInt8

  static let red = Color(r: 255, g: 0, b: 0, a: 255)
  static let black = Color(r: 0, g: 0, b: 0, a: 255)
  static let white = Color(r: 255, g: 255, b: 255, a: 255)
  static let green = Color(r: 0, g: 255, b: 0, a: 255)
  static let blue = Color(r: 0, g: 0, b: 255, a: 255)

  static func random(_ obj: any Hashable) -> Color {
    let seed = abs(obj.hashValue)
    var generator = SeededGenerator(seed: UInt64(seed))
    let r = UInt8.random(in: 0...255, using: &generator)
    let g = UInt8.random(in: 0...255, using: &generator)
    let b = UInt8.random(in: 0...255, using: &generator)
    return Color(r: r, g: g, b: b, a: 255)
  }
  static func random() -> Color {
    let r = UInt8.random(in: 0...255)
    let g = UInt8.random(in: 0...255)
    let b = UInt8.random(in: 0...255)
    return Color(r: r, g: g, b: b, a: 255)
  }
}
