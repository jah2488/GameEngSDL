import Foundation

class MenuScene: Scene {
  var ui: Entity = MenuUI()

  init(ui: Entity, name: String) {
    self.ui = ui
    super.init(name: name)
  }

  init(name: String) {
    super.init(name: name)
  }

  override func start(game: Game) {
    addChild(ui)
  }
}
