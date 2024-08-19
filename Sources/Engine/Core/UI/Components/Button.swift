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
