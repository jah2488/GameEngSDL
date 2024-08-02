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
  var player: Player = Player()
  override func start(game: Game) {
    addChild(StarBackground())
    addChild(GameUI())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(Asteroid())
    addChild(player)
  }

  override func draw(game: Game) {
    if player.lives < 1 {
      self.children.removeAll()
      game.r.drawText(
        text: "Game Over", x: Float(World.shared.width / 2) - 100,
        y: Float(World.shared.height / 2) - 30,
        width: 100, height: 30)
    }
  }

  override func update(delta: Double) {
    if children.count < 1 {
      addChild(Asteroid())
    }
  }
}
