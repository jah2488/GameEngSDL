import Foundation

class MenuScene: Scene {
  override func load() {
    log.log("Loading scene \(self.name)")
  }

  override func start(game: Game) {
    addChild(MenuUI())
  }

  override func unload() {
    log.log("Unloading scene \(self.name)")
  }
}
