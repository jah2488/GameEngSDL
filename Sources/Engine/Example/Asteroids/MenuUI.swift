import CSDL3_ttf
import Foundation

class MenuUI: Entity {

  override func draw(game: Game) {
    let center = game.width / 2
    game.r.drawText(text: "ASTEROIDS-LIKE", x: Float(center) - 200, y: 20, width: 400, height: 70)
    game.r.drawText(
      text: "press spacebar to start", x: Float(center) - 200, y: 100, width: 400, height: 70)
  }

  override func input(keys: Keys.State, game: Game) {
    if keys.isReleased(.space) || keys.isReleased(.startBtn) {
      game.changeScene(PlayScene(name: "PlayScene"))
    }
  }
}
