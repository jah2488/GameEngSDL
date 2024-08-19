import CSDL3_ttf
import Foundation

protocol UIComponent: Hashable {
  @UIBuilder var body: [any UIComponent] { get }
  var x: Int { get set }
  var y: Int { get set }
  var width: Int { get }
  var height: Int { get }

  func render(offsetX: Int, offsetY: Int)
}

extension UIComponent {
  func hash(into hasher: inout Hasher) {
    hasher.combine(body.description)
    hasher.combine(x)
    hasher.combine(y)
    hasher.combine(width)
    hasher.combine(height)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.body.description == rhs.body.description && lhs.x == rhs.x && lhs.y == rhs.y
      && lhs.width == rhs.width
      && lhs.height == rhs.height
  }

  func with(_ fn: (inout Self) -> Void) -> some UIComponent {
    var copy = self
    fn(&copy)
    return copy
  }
}

enum UIAttr<T> {
  case unset
  case set(T)

  var value: T? {
    switch self {
    case .unset:
      return nil
    case .set(let value):
      return value
    }
  }
}

enum UIDimension {
  case auto
  case fixed(Int)
}

@resultBuilder
struct UIBuilder {
  typealias Component = [any UIComponent]
  typealias Expression = UIComponent

  static func buildExpression(_ element: any Expression) -> Component {
    return [element]
  }

  static func buildOptional(_ component: Component?) -> Component {
    guard let component = component else { return [] }
    return component
  }
  static func buildEither(first component: Component) -> Component {
    return component
  }
  static func buildEither(second component: Component) -> Component {
    return component
  }
  static func buildArray(_ components: [Component]) -> Component {
    return Array(components.joined())
  }
  static func buildBlock(_ components: Component...) -> Component {
    return components.compactMap({ $0 }).flatMap({ $0 })
  }

  static func buildPartialBlock(first: Component) -> Component {
    return first
  }

  static func buildPartialBlock(accumulated: Component, next: Component) -> Component {
    return accumulated + next
  }

  // static func buildFinalResult(_ component: Component) -> Result<any UIComponent, Error> {
  // return .success(VStack(content: { component} ))
  // }
}

struct menuUI {
  var gui: some UIComponent {
    HStack {
      Spacer(size: 10)
      VStack {
        Text("Sokoban")
        Spacer(size: 1)
        Button("New Game")
        Spacer(size: 1)
        Button("Options")
        Spacer(size: 1)
        Button("Quit")
        Spacer(size: 10)
      }
      // Spacer(size: 10)
    }
  }
}
