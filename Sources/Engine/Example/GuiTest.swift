class GuiTest: Game {
  override func draw() {
    r.drawText(text: "hello world", x: 10, y: 10, width: 80, height: 14)
    var ui = ui {
      Button(label: "click me")
      Button(label: "click me too")
    }
    print(ui.render())
  }
}
