import Foundation

class MenuScene: Scene {
  override func load() {
    print("Loading scene \(self.name)")
  }

  override func start(game: Game) {
    addChild(MenuUI())
  }

  override func draw(game: Game) {
    print("Children: \(children.map { type(of: $0) })")
  }

  override func unload() {
    print("Unloading scene \(self.name)")
  }
}
