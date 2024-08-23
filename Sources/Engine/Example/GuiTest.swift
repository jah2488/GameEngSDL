class GuiTest: Game {
  var clicks: Int = 0
  var buttonLabel: String = "Click me!"
  // var gui: some UIComponent {
  //   return VStack(height: .fixed(World.shared.height)) {
  //     Text("hello", fontSize: .Header)
  //     Text("world", fontSize: .Small)
  //     Spacer(size: 10)
  //     Text("abcdefghijklmnopqrstuvwxyz", fontSize: .Body)
  //     Text("0123456789", fontSize: .Body)
  //     Text("[I am before VStack]")
  //     HStack {
  //       Text("goodnight").color(.blue)
  //       Text("moon", fontSize: .Banner)
  //       Spacer(size: 30)
  //       VStack {
  //         Text("!")
  //         Text("?")
  //         Text(".")
  //       }
  //     }
  //     Text("[I am after VStack]")
  //     Button(buttonLabel) {
  //       self.clicks += 1
  //       self.buttonLabel = "You clicked me \(self.clicks) times!"
  //     }
  //   }
  // }
  var gui: some UIComponent {
    return VStack(spacing: 0) {
      row(.top, "top")
      row(.center, "center")
      row(.bottom, "bottom")
    }
  }

  var space: Double = 300

  var gui2: some UIComponent {
    var roundedSpace = space
    roundedSpace.round(.up)
    return HStack(spacing: Int(roundedSpace)) {
      column(alignment: .leading, text: "leading")
      column(alignment: .center, text: "center")
      column(alignment: .trailing, text: "trailing")
    }
  }

  func row(_ alignment: HStack.VerticalAlignment, _ label: String) -> some UIComponent {
    return HStack(alignment: alignment, spacing: 30) {
      Spacer(width: 50, height: 1)
      Text(label)
      Spacer(width: 50, height: 1)
    }
  }
  private func column(alignment: VStack.HorizontalAlignment, text: String) -> some UIComponent {
    VStack(alignment: alignment, spacing: 10) {
      Spacer(width: 1, height: 20)
      Text(text)
      Spacer(width: 1, height: 20)
    }
  }
  // sudo cmake -S . -B build && sudo cmake --build build && sudo cmake --install build

  override func start() {
    log.log("Game start()")
  }

  override func draw() {
    gui.render(offsetX: 10, offsetY: 10)
    gui2.render(offsetX: 10, offsetY: 70)
  }

  override func update(delta: Double) {
    if space > 0 {
      space -= 1 * delta
    }
  }
}
