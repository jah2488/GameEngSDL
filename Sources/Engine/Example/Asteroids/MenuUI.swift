import CSDL3_ttf
import Foundation

class MenuUI: Entity {
  var font: OpaquePointer!

  required init() {
    print("MenuUI init")
    super.init()
    self.font = TTF_OpenFont("GameEngSDL_GameEngSDL.bundle/Assets/Monogram Extended.ttf", 28)
  }

  override func draw(game: Game) {
    let center = game.width / 2
    game.r.drawText(text: "ASTEROIDS-LIKE", x: Float(center) - 200, y: 20, width: 400, height: 70)
    game.r.drawText(
      text: "press spacebar to start", x: Float(center) - 200, y: 100, width: 400, height: 70)
  }

  override func input(keys: Keys.State, game: Game) {
    print("\(keys.empty()):\(keys.keys.map({ "\($0.key):\($0.value)" }))")
    if keys.isReleased(.space) {
      print("MenuUI input detected, swapping to PlayScene")
      game.changeScene(PlayScene(name: "PlayScene"))
    }
  }
}
