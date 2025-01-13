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

  init(width: Int, height: Int) {
    self.body = []
    self.size = 0
    self.width = width
    self.height = height
  }

  func render(offsetX: Int = 0, offsetY: Int = 0) {
    World.shared.r!.drawRect(
      x: Float(x + offsetX),
      y: Float(y + offsetY),
      width: Float(width),
      height: Float(height),
      tint: .random(self)
    )
  }
}
