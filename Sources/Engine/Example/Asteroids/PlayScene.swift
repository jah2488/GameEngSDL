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

  override func load() {
    log.log("Loading scene \(self.name)")
  }

  override func unload() {
    log.log("Unloading scene \(self.name)")
  }

}

class Asteroid: Entity {
  var asteroid = Asset(path: "asteroid.png")
  var speed: Double = Double.random(in: 20...200)
  var width: Float = 64 * Float.random(in: (0.2)...8)

  required init() {
    super.init()
    self.position.x = Float.random(in: 0...800)
    self.position.y = Float.random(in: 0...1300)
  }

  override func draw(game: Game) {
    game.r.drawTexture(
      resource: asteroid, x: Float(self.position.x), y: Float(self.position.y),
      width: self.width, height: self.width,
      rotation: self.rotation.converted(to: .degrees).value,
      tint: Color(r: 255, g: 255, b: 255, a: 255))
  }

  override func update(delta: Double) {
    self.rotation = rotation + Measurement(value: (speed / 10) * delta, unit: UnitAngle.radians)

    let velocityX = cos(self.rotation.value) * speed
    let velocityY = sin(self.rotation.value) * speed

    // Update the bullet's position based on the velocity
    // Delta is the time elapsed since the last frame, so multiplying by delta makes the movement frame-rate independent
    self.position.x += Float(velocityX) * Float(delta)
    self.position.y += Float(velocityY) * Float(delta)

    //TODO: On Destroy, break into two smaller asteroids if size is greater than 16
    //TODO: Model collisionRects separetly from the renderable rect
    //TODO: Should look into polygonal collision shapes.
  }
}
