import Foundation

class MenuScene: Scene {
  override func load() {
    print("Loading scene \(self.name)")
  }

  override func start(game: any Game) {
    addChild(MenuUI())
  }

  override func unload() {
    print("Unloading scene \(self.name)")
  }
}
