import CSDL3_ttf

class MenuUI: Renderable, Node {
  var id: UInt64
  var children: [any Node]
  var parent: (any Node)?

  var font: OpaquePointer!

  required init() {
    self.id = 1
    self.children = []

    self.font = TTF_OpenFont("GameEngSDL_GameEngSDL.bundle/Assets/Monogram Extended.ttf", 28)
  }

  func start(game: any Game) {

  }

  func draw(game: any Game) {
    let center = game.width / 2
    game.drawText(text: "ASTEROIDS-LIKE", x: Float(center) - 200, y: 20, width: 400, height: 70)
    game.drawText(
      text: "press any key to start", x: Float(center) - 200, y: 100, width: 400, height: 70)
  }

  func update(delta: Float) {

  }

  func input(keys: Keys.State, game: any Game) {
    if !keys.empty() {
      game.changeScene(scene: PlayScene(id: 2, name: "PlayScene"))
    }
  }
}
