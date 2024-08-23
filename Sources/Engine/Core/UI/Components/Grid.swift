struct Grid: UIComponent {
  @UIBuilder var body: [any UIComponent]
  var x: Int = 0
  var y: Int = 0
  var vSpacing: Int = 0
  var hSpacing: Int = 0
  var width: Int = 0
  var height: Int = 0

  init(vSpacing: Int = 0, hSpacing: Int = 0, @UIBuilder content: () -> [any UIComponent]) {
    self.body = content()
    self.vSpacing = vSpacing
    self.hSpacing = hSpacing
    self.width = World.shared.width
  }

  func render(offsetX: Int, offsetY: Int) {
    var lastOffsetX = offsetX
    var lastOffsetY = offsetY
    for component in body {
      if component is GridRow {
        var c = (component as! GridRow)
        c.setSpacing(vSpacing)
      }
      component.render(offsetX: lastOffsetX, offsetY: lastOffsetY)
      // World.shared.r!.drawRect( x: Float(component.x + lastOffsetX), y: Float(component.y + offsetY), width: Float(component.width), height: Float(component.height), tint: .random(component))
      lastOffsetX += component.width + vSpacing
      lastOffsetY += component.height + hSpacing
    }
    // World.shared.r!.drawRect( x: Float(x + offsetX), y: Float(y + offsetY), width: Float(width), height: Float(height), tint: .init(r: 255, g: 255, b: 255, a: 10))
  }
}

struct GridRow: UIComponent {
  @UIBuilder var body: [any UIComponent]
  var x: Int = 0
  var y: Int = 0
  var spacing: Int = 0
  var width: Int {
    var w = 0
    for component in body {
      w += component.width
    }
    return w
  }
  var height: Int {
    var h = 0
    for component in body {
      if component.height > h {
        h = component.height
      }
    }
    return h
  }

  mutating func setSpacing(_ spacing: Int) {
    self.spacing = spacing
    print("set spacing to \(spacing)")
  }

  init(spacing: Int = 0, @UIBuilder content: () -> [any UIComponent]) {
    self.body = content()
    self.spacing = spacing
  }

  func render(offsetX: Int, offsetY: Int) {
    var lastOffsetX = offsetX
    var lastOffsetY = offsetY
    for component in body {
      component.render(offsetX: lastOffsetX, offsetY: lastOffsetY)
      lastOffsetX += component.width + (spacing * 100)
      lastOffsetY += 0  //component.height + spacing
    }
  }
}
