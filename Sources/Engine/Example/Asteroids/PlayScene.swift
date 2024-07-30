import Foundation

class GameUI: Entity {
  required init() {
    super.init()
    self.alwaysOnTop = true
  }
  override func draw(game: Game) {
    if scene is PlayScene {
      let lives = (((scene?.children.first(where: { $0 is Player })) as! Player).lives)
      game.r.drawText(text: "Lives: \(lives)", x: 10, y: 2, width: 100, height: 30)
    }
  }
}

class PlayScene: Scene {
  override func start(game: Game) {
    var player = Player()
    addChild(StarBackground())
    addChild(GameUI())
    addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    // addChild(Asteroid())
    addChild(player)
  }
}
