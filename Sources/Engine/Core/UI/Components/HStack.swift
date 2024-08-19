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
    // World.shared.r!.drawRect( x: Float(x + offsetX), y: Float(y + offsetY), width: Float(width), height: Float(height), tint: .init(r: 255, g: 255, b: 255, a: 10))
  }
}
