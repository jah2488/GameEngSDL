import CSDL3
import Foundation
import simd

class Bullet: Entity {
  var lifetime: Double = 1.1
  var createdAt: Double = 0
  let speed: Double = 1500  // Speed of the bullet in units per second

  let fireSound = Sound(path: "Laser_Shoot.wav")
  var chunkID: Int?

  required init() {
    super.init()
    self.relative = false
    self.createdAt = Date().timeIntervalSince1970
    self.texture = Asset(path: "bullet.png")

    self.size = simd_float2(16, 16)
  }

  override func start(game: Game) {
    self.chunkID = game.a.load(fireSound.url)
    game.a.play(chunkID!, .soundfx)
  }

  override func update(delta: Double) {
    let age = Date().timeIntervalSince1970 - self.createdAt
    if age > self.lifetime {
      self.alive = false
      return
    }

    let velocityX = cos(self.rotation.value) * speed * -1
    let velocityY = sin(self.rotation.value) * speed * -1

    self.position.x += Float(velocityX) * Float(delta)
    self.position.y += Float(velocityY) * Float(delta)

    if position.x + size.x < 0 {
      position.x = Float(World.shared.width)
    }

    if position.x > Float(World.shared.width) {
      position.x = 0
    }

    if position.y + size.y < 0 {
      position.y = Float(World.shared.height)
    }

    if position.y > Float(World.shared.height) {
      position.y = 0 - size.y
    }

  }

  override func onCollisionStart(with other: Entity) {
    if other is Asteroid {
      self.alive = false
    }
  }
}
