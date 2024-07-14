class StarBackground: Renderable, Node {
  var relative: Bool = false
  var parent: (any Node)?
  let bg = Asset(path: "bg.png")
  let bg2 = Asset(path: "bg-trans.png")
  let bg3 = Asset(path: "bg3.png")

  var x: Float = 0
  var x2: Float = 0
  var x3: Float = 0
  let speed: Float = 30

  var gameTicks: UInt64 = 0

  func start(game: any Game) {
    print("Starting StarBackground")
  }

  func draw(game: any Game) {
    gameTicks += 1
    let h = Float(game.height)
    let w = Float(game.width)

    if x > w {
      x = 0
    }

    if x2 > w {
      x2 = 0
    }

    if x3 > w {
      x3 = 0
    }

    game.drawTexture(
      resource: bg, x: self.x, y: 0, width: w, height: h,
      rotation: 0, tint: Color(r: 255, g: 255, b: 255, a: 255))
    game.drawTexture(
      resource: bg2, x: self.x2, y: 0, width: w, height: h,
      rotation: 0, tint: Color(r: 0, g: 0, b: 255, a: 255))
    game.drawTexture(
      resource: bg3, x: self.x3, y: 0, width: w, height: h,
      rotation: 0, tint: Color(r: 255, g: 200, b: 255, a: 25))

    game.drawTexture(
      resource: bg, x: self.x - w, y: -20, width: w,
      height: h,
      rotation: 0, tint: Color(r: 255, g: 255, b: 255, a: 255))

    game.drawTexture(
      resource: bg2, x: (self.x2 - w), y: 0, width: w,
      height: h,
      rotation: 0, tint: Color(r: 10, g: 10, b: 255, a: 255))
    game.drawTexture(
      resource: bg3, x: (self.x3 - w), y: 0, width: w,
      height: h,
      rotation: 0, tint: Color(r: 255, g: 255, b: 255, a: 25))

  }

  func update(delta: Float) {
    x += speed * delta
    x2 += (speed * 2) * delta
    x3 += (speed * 8) * delta
  }

  func input(keys: Keys.State, game: any Game) {

  }

  var id: UInt64

  var children: [any Node]

  required init() {
    self.id = 0
    self.children = []
  }

}
