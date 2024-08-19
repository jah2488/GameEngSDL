class GuiTest: Game {
  var clicks: Int = 0
  var buttonLabel: String = "Click me!"
  var gui: some UIComponent {
    return VStack(height: .fixed(World.shared.height)) {
      Text("hello", fontSize: .Header)
      Text("world", fontSize: .Small)
      Spacer(size: 10)
      Text("!")
      Text("[I am before VStack]")
      HStack {
        Text("goodnight").with({ $0.color(.green) })
        Text("moon", fontSize: .Banner)
        Spacer(size: 30)
        VStack {
          Text("!")
          Text("?")
          Text(".")
        }
      }
      Text("[I am after VStack]")
      Button(buttonLabel) {
        self.clicks += 1
        self.buttonLabel = "You clicked me \(self.clicks) times!"
      }
    }
  }

  override func start() {
    log.log("Game start()")
  }

  override func draw() {
    gui.render(offsetX: 0, offsetY: 0)
  }
}
