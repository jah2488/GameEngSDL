struct HStack: UIComponent {
  enum VerticalAlignment {
    case top
    case center
    case bottom
    case custom(() -> Int)
  }
  @UIBuilder var body: [any UIComponent]
  var x: Int = 0
  var y: Int = 0
  var alignment: VerticalAlignment = .top
  var spacing: Int = 0
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

  init(
    alignment: VerticalAlignment = .top, spacing: Int = 0,
    @UIBuilder content: () -> [any UIComponent]
  ) {
    self.body = content()
    self.alignment = alignment
    self.width = World.shared.width
    self.spacing = spacing
  }

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
      switch alignment {
      case .top:
        lastOffsetY = offsetY
      case .center:
        lastOffsetY = offsetY + (height - component.height) / 2
      case .bottom:
        lastOffsetY = offsetY + height - component.height
      case .custom(let custom):
        lastOffsetY = offsetY + custom()
      }
      component.render(offsetX: lastOffsetX, offsetY: lastOffsetY)
      // World.shared.r!.drawRect( x: Float(component.x + lastOffsetX), y: Float(component.y + offsetY), width: Float(component.width), height: Float(component.height), tint: .random(component))
      lastOffsetX += component.width + spacing
      lastOffsetY += 0
    }
    // World.shared.r!.drawRect( x: Float(x + offsetX), y: Float(y + offsetY), width: Float(width), height: Float(height), tint: .init(r: 255, g: 255, b: 255, a: 10))
  }
}
