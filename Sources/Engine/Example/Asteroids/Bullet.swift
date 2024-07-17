import CSDL3
import Foundation

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
      self.parent?.children.removeAll { $0 as? Bullet === self }
      return
    }

    let velocityX = cos(self.rotation.value) * speed * -1
    let velocityY = sin(self.rotation.value) * speed * -1

    // Update the bullet's position based on the velocity
    // Delta is the time elapsed since the last frame, so multiplying by delta makes the movement frame-rate independent
    self.position.x += Float(velocityX) * Float(delta)
    self.position.y += Float(velocityY) * Float(delta)

    var rect = SDL_Rect(x: Int32(self.position.x), y: Int32(self.position.y), w: 32, h: 32)
    var _ = self.parent?.parent?.children.forEach { child in
      if let child = child as? Asteroid {
        let pos = child.position
        let size = child.size.x
        var rect2 = SDL_Rect(x: Int32(pos.x), y: Int32(pos.y), w: Int32(size), h: Int32(size))
        if SDL_HasRectIntersection(&rect, &rect2) == SDL_TRUE {
          self.parent?.children.removeAll { $0 as? Bullet === self }
          child.parent?.children.removeAll { $0 as? Asteroid === child }
        }
      }
    }
  }
}
