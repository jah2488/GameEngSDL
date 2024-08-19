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
