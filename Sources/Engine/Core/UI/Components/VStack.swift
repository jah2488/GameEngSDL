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
    // World.shared.r!.drawRect( x: Float(x + offsetX), y: Float(y + offsetY), width: Float(width), height: Float(height), tint: .init(r: 255, g: 255, b: 255, a: 10))
  }
}
