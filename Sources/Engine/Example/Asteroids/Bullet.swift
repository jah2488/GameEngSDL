import CSDL3
import Foundation
import simd

class Bullet: Entity {
  var lifetime: Double = 4.1
  var createdAt: Double = 0

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

  let speed: Double = 800  // Speed of the bullet in units per second
  override func update(delta: Double) {
    let age = Date().timeIntervalSince1970 - self.createdAt
    if age > self.lifetime {
      // TODO: This functionality should be encapsulated in a helper
      // self.parent?.children.removeAll { $0 as? Bullet === self }
      self.alive = false
      return
    }

    let velocityX = cos(self.rotation.value) * speed * -1
    let velocityY = sin(self.rotation.value) * speed * -1

    // Update the bullet's position based on the velocity
    // Delta is the time elapsed since the last frame, so multiplying by delta makes the movement frame-rate independent
    self.position.x += Float(velocityX) * Float(delta)
    self.position.y += Float(velocityY) * Float(delta)
  }
}
