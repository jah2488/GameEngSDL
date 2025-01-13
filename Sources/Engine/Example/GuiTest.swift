class GuiTest: Game {
  var active = 0
  var clicks: Int = 0
  var buttonLabel: String = "Click me!"
  var gui0: some UIComponent {
    return VStack(height: .fixed(World.shared.height)) {
      Text("hello", fontSize: .Header)
      Text("world", fontSize: .Small)
      Spacer(size: 10)
      Text("abcdefghijklmnopqrstuvwxyz", fontSize: .Body)
      Text("0123456789", fontSize: .Body)
      Text("[I am before VStack]")
      HStack {
        Text("goodnight").color(.blue)
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
  var gui1: some UIComponent {
    return VStack(spacing: 0) {
      row(.top, "top")
      row(.center, "center")
      row(.bottom, "bottom")
    }
  }

  var space: Double = 100

  var gui2: some UIComponent {
    var roundedSpace = space
    roundedSpace.round(.toNearestOrAwayFromZero)
    return HStack(spacing: Int(roundedSpace)) {
      column(alignment: .leading, text: "leading")
      column(alignment: .center, text: "center")
      column(alignment: .trailing, text: "trailing")
    }
  }

  var gui3: some UIComponent {
    return Grid(vSpacing: 10, hSpacing: 2) {
      GridRow {
        Text("Row 1")
        Box.from(.red)
        Box.from(.red)
      }
      GridRow {
        Text("Row 2")
        Box.from(.green)
        Box.from(.green)
        Box.from(.green)
        Box.from(.green)
        Box.from(.green)
      }
      GridRow {
        Text("Row 3")
        Box.from(.blue)
        Box.from(.blue)
        Box.from(.blue)
        Box.from(.blue)
      }
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
    switch active {
    case 0:
      gui0.render(offsetX: 10, offsetY: 10)
    case 1:
      gui1.render(offsetX: 10, offsetY: 10)
    case 2:
      gui2.render(offsetX: 10, offsetY: 10)
    case 3:
      gui3.render(offsetX: 10, offsetY: 10)
    default:
      break
    }
  }

  override func input(keys: Keys.State) {
    if keys.isReleased(.space) {
      active += 1
      if active > 3 {
        active = 0
      }
      if active == 2 {
        space = 150
      }
    }
  }

  override func update(delta: Double) {
    if space > 0 && active == 2 {
      space -= 20 * delta
    }
  }
}
