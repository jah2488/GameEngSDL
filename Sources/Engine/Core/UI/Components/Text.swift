struct Text: UIComponent {
  @UIBuilder var body: [any UIComponent]
  var x: Int = 0
  var y: Int = 0
  let text: String
  var fontSize: RendererManager.FontSize
  var width: Int
  var height: Int

  var _color = UIAttr<Color>.unset
  // @discardableResult
  func color(_ color: Color) -> Text {
    var copy = self
    copy._color = .set(color)
    return copy
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
    World.shared.r!.drawText(
      text: text,
      size: fontSize,
      tint: World.shared.mouseOverRect(rect)
        ? World.shared.m.left == .down ? .green : .red : _color.value ?? .white,
      x: Float(x + offsetX),
      y: Float(y + offsetY),
      width: Float(width),
      height: Float(height)
    )
  }
}
