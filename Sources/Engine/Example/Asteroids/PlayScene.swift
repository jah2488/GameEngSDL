import Foundation

class PlayScene: Scene {
  override func start(game: Game) {
    addChild(StarBackground())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Player())
  }
}
