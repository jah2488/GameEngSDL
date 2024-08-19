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
}

struct Text: UIComponent {
  @UIBuilder var body: [any UIComponent]
  var x: Int = 0
  var y: Int = 0
  let text: String
  var fontSize: RendererManager.FontSize
  var width: Int
  var height: Int

  var _color = UIAttr<Color>.unset
  func color(_ color: Color) -> Self {
    var copy = self
    copy._color = .set(color)
    return self
  }

  init(_ text: String, fontSize: RendererManager.FontSize = .Body) {
    self.body = []
    self.text = text
    self.fontSize = fontSize
    self.width = Int(World.shared.r!.measureText(text: text, fontSize: fontSize).0)
    self.height = Int(World.shared.r!.measureText(text: text, fontSize: fontSize).1)
  }

  func render(offsetX: Int = 0, offsetY: Int = 0) {
    let rect = Rect<Float>(
      x: Float(x + offsetX), y: Float(y + offsetY), width: Float(width), height: Float(height))
    if World.shared.mouseOverRect(rect) {
    }
    World.shared.r!.drawText(
      text: text,
      size: fontSize,
      tint: World.shared.mouseOverRect(rect)
        ? World.shared.m.left == .down ? .green : .red : .white,
      x: Float(x + offsetX),
      y: Float(y + offsetY),
      width: Float(width),
      height: Float(height)
    )
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

struct Button: UIComponent {
  @UIBuilder var body: [any UIComponent]
  var x: Int = 0
  var y: Int = 0
  var width: Int = 0
  var height: Int = 0
  var action: () -> Void = {}

  func getWidth() -> Int {
    if let label = label.value {
      return Int(World.shared.r!.measureText(text: label, fontSize: .Body).0)
    }
    var w = 0
    for component in body {
      if component.width > w {
        w = component.width
      }
    }
    return w
  }

  func getHeight() -> Int {
    if let label = label.value {
      return Int(World.shared.r!.measureText(text: label, fontSize: .Body).1)
    }
    var h = 0
    for component in body {
      if component.height > h {
        h = component.height
      }
    }
    return h
  }

  let label: UIAttr<String>

  init(_ label: String, _ action: @escaping () -> Void = {}) {
    self.body = []
    self.label = .set(label)
    self.action = action
  }

  init() {
    self.body = []
    self.label = .unset
  }

  init(@UIBuilder content: () -> [any UIComponent]) {
    self.init()
    body = content()
  }

  func render(offsetX: Int = 0, offsetY: Int = 0) {
    switch label {
    case .unset:
      var lastOffsetX = offsetX
      var lastOffsetY = offsetY
      for component in body {
        component.render(offsetX: lastOffsetX, offsetY: offsetY)
        World.shared.r!.drawRect(
          x: Float(component.x + lastOffsetX),
          y: Float(component.y + offsetY),
          width: Float(component.width),
          height: Float(component.height),
          tint: .random(component)
        )
        lastOffsetX += component.width
        lastOffsetY += component.height
      }
      break
    case .set(let label):
      Text(label).render(offsetX: offsetX, offsetY: offsetY)
    }

    if World.shared.mouseOverRect(
      Rect<Float>(
        x: Float(x + offsetX), y: Float(y + offsetY), width: Float(getWidth()),
        height: Float(getHeight())
      )
    ) {
      if World.shared.m.left == .released {
        //TODO: This needs to be on release
        action()
      }
    }
  }
}

struct HStack: UIComponent {
  @UIBuilder var body: [any UIComponent]
  var x: Int = 0
  var y: Int = 0
  var width: Int = 0
  var height: Int {
    var h = 0
    for component in body {
      //TODO: This is probably wrong. We need the combined height of all the components
      if component.height > h {
        h = component.height
      }
    }
    return h
  }

  public var border: Bool = false

  init(width: Int, @UIBuilder content: () -> [any UIComponent]) {
    self.body = content()
    self.width = width
  }

  init(@UIBuilder content: () -> [any UIComponent]) {
    self.body = content()
    self.width = World.shared.width
  }

  func render(offsetX: Int = 0, offsetY: Int = 0) {
    var lastOffsetX = offsetX
    var lastOffsetY = offsetY
    for component in body {
      component.render(offsetX: lastOffsetX, offsetY: offsetY)
      World.shared.r!.drawRect(
        x: Float(component.x + lastOffsetX),
        y: Float(component.y + offsetY),
        width: Float(component.width),
        height: Float(component.height),
        tint: .random(component)
      )
      lastOffsetX += component.width
      lastOffsetY += component.height
    }
    World.shared.r!.drawRect(
      x: Float(x + offsetX),
      y: Float(y + offsetY),
      width: Float(width),
      height: Float(height),
      tint: .white
    )
  }
}

enum UIDimension {
  case auto
  case fixed(Int)
}

struct VStack: UIComponent {
  @UIBuilder var body: [any UIComponent]
  var x: Int = 0
  var y: Int = 0

  var _width: UIDimension = .auto
  var width: Int {
    switch _width {
    case .fixed(let w):
      return w
    case .auto:
      var w = 0
      for component in body {
        if component.width > w {
          w = component.width
        }
      }
      return w
    }
  }

  var _height: UIDimension = .auto
  var height: Int {
    switch _height {
    case .fixed(let h):
      return h
    case .auto:
      var h = 0
      for component in body {
        h += component.height
      }
      return h
    }
  }

  let border: Bool = false

  init(
    width: UIDimension = .auto, height: UIDimension = .auto,
    @UIBuilder content: () -> [any UIComponent]
  ) {
    self.body = content()
    self._width = width
    self._height = height
  }

  init(@UIBuilder content: () -> [any UIComponent]) {
    self.body = content()
  }

  func render(offsetX: Int = 0, offsetY: Int = 0) {
    var lastOffsetX = offsetX
    var lastOffsetY = offsetY
    for component in body {
      component.render(offsetX: offsetX, offsetY: lastOffsetY)
      World.shared.r!.drawRect(
        x: Float(component.x + offsetX),
        y: Float(component.y + lastOffsetY),
        width: Float(component.width),
        height: Float(component.height),
        tint: .random(component)
      )
      lastOffsetX += component.width
      lastOffsetY += component.height
    }
    World.shared.r!.drawRect(
      x: Float(x + offsetX),
      y: Float(y + offsetY),
      width: Float(width),
      height: Float(height),
      tint: .white
    )
  }
}

struct Spacer: UIComponent {
  @UIBuilder var body: [any UIComponent]
  var x: Int = 0
  var y: Int = 0
  var width: Int = 0
  var height: Int = 0

  let size: Int

  init(size: Int = 1) {
    self.body = []
    self.size = size
    self.width = size
    self.height = size
  }

  func render(offsetX: Int = 0, offsetY: Int = 0) {}
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
