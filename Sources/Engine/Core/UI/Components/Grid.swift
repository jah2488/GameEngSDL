struct Grid: UIComponent {
  @UIBuilder var body: [any UIComponent]
  var x: Int = 0
  var y: Int = 0
  var vSpacing: Int = 0
  var hSpacing: Int = 0
  var width: Int {
    var w = hSpacing
    for component in body {
      w += component.width + hSpacing
    }
    return w
  }
  var height: Int {
    var h = vSpacing
    for component in body {
      h += component.height + vSpacing
    }
    return h
  }

  init(vSpacing: Int = 0, hSpacing: Int = 0, @UIBuilder content: () -> [any UIComponent]) {
    self.vSpacing = vSpacing
    self.hSpacing = hSpacing

    let components = content()
    var _body = [any UIComponent]()

    for i in 0..<components.count {
      if var gridRow = components[i] as? GridRow {
        gridRow.setSpacing(hSpacing)
        _body.append(gridRow)
      } else {
        _body.append(components[i])
      }
    }
    self.body = _body
  }

  func render(offsetX: Int, offsetY: Int) {
    var lastOffsetX = offsetX
    var lastOffsetY = offsetY
    for component in body {
      component.render(offsetX: lastOffsetX, offsetY: lastOffsetY)
      // World.shared.r!.drawRect( x: Float(component.x + lastOffsetX), y: Float(component.y + lastOffsetY), width: Float(component.width), height: Float(component.height), tint: .random(component))
      lastOffsetX += 0  //component.width  // + vSpacing
      lastOffsetY += component.height + vSpacing
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
  }

  init(spacing: Int = 0, @UIBuilder content: () -> [any UIComponent]) {
    self.body = content()
    self.spacing = spacing
  }

  func render(offsetX: Int, offsetY: Int) {
    var lastOffsetX = offsetX
    var lastOffsetY = offsetY
    for component in body {
      //Center Halignment: TODO: add vAlignment and hAlignment
      lastOffsetY = offsetY + (height - component.height) / 2

      component.render(offsetX: lastOffsetX, offsetY: lastOffsetY)

      lastOffsetX += component.width + spacing
      lastOffsetY += 0
    }
    // World.shared.r!.drawRect( x: Float(x + offsetX - 1), y: Float(y + offsetY - 1), width: Float(width + 1), height: Float(height + 1), tint: .init(r: 255, g: 255, b: 255, a: 10))
  }
}
