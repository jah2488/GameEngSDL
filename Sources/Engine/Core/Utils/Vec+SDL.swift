import CSDL3

extension Vector2 {
  public init(_ point: SDL_FPoint) {
    self.init(x: point.x, y: point.y)
  }

}
struct Foo: ExpressibleByStringLiteral {
  typealias StringLiteralType = String

  init(stringLiteral value: StringLiteralType) {

  }

  typealias ExtendedGraphemeClusterLiteralType = String

  init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {

  }

  typealias UnicodeScalarLiteralType = String

  init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {

  }

}
