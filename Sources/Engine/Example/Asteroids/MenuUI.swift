import Foundation

class MenuUI: Entity {

  var gameTitle: String = "ASTEROIDS-LIKE"
  var destinationScene: Scene
  init(destinationScene: Scene, gameTitle: String) {
    self.destinationScene = destinationScene
    self.gameTitle = gameTitle
    super.init()
  }

  required init() {
    self.destinationScene = PlayScene(name: "PlayScene")
    super.init()
  }

  override func draw(game: Game) {
    let center = game.width / 2
    game.r.drawText(text: gameTitle, x: Float(center) - 200, y: 20, width: 400, height: 70)
    game.r.drawText(
      text: "press spacebar to start", x: Float(center) - 200, y: 100, width: 400, height: 70)
  }

  override func input(keys: Keys.State, game: Game) {
    if keys.isReleased(.space) || keys.isReleased(.startBtn) {
      game.changeScene(self.destinationScene)
    }
  }
}
