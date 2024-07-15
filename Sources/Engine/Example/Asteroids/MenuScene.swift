import Foundation

class MenuScene: Scene {
  override func start(game: Game) {
    addChild(MenuUI())
  }
}
