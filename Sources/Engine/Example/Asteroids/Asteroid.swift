import Foundation
import simd

struct Sprite {
  var texture: Asset
  var size: simd_float2
  var frame: Int
  var totalFrames: Int
  var frameWidth: Int
  var frameHeight: Int
  var frameRate: Double

  var elapsedTime: Double = 0

  var loop: Bool = true
  var completed: Bool = false

  var animationCompleted: () -> Void = {}

  init(
    path: String, frames: Int, frameRate: Double, loop: Bool = true,
    animationCompleted: @escaping () -> Void = {}
  ) {
    self.texture = Asset(path: path)
    self.size = simd_float2(Float(texture.width), Float(texture.height))
    self.frame = 0
    self.totalFrames = frames
    self.frameWidth = Int(texture.width) / frames
    self.frameHeight = Int(texture.height)
    self.frameRate = frameRate
    self.loop = loop
    self.animationCompleted = animationCompleted
  }

  mutating func update(delta: Double) {
    elapsedTime += delta
    if elapsedTime > Double(frameRate) {

      if loop {
        frame = (frame + 1) % totalFrames
      } else {
        if frame < totalFrames - 1 {
          frame += 1
        } else if !completed {
          completed = true
          animationCompleted()
        }
      }
      elapsedTime = 0
    }
  }
}

class Explosion: Entity {
  var sound = Sound(path: "Asteroid_Explosion.wav")
  required init() {
    super.init()
    let id = World.shared.a?.load(sound.url)
    self.sprite = Sprite(
      path: "explosion.png", frames: 7, frameRate: 1 / 7, loop: false,
      animationCompleted: {
        self.alive = false
      })
    self.relative = true
    World.shared.a?.play(id!, .custom(Int.random(in: 1...16)))
  }
}

class Asteroid: Entity {
  var speed: Double = Double.random(in: 2...10)

  required init() {
    super.init()
    let width: Float = 64 * Float.random(in: (0.5)...(2))
    self.position.x = Float.random(in: 0...(Float(World.shared.width) - 64))
    self.position.y = Float.random(in: 0...(Float(World.shared.height) - 64))

    self.texture = Asset(path: "asteroid.png")
    self.size = simd_float2(width, width)
    self.mass = (width) * 0.001
    self.velocity = simd_float2(Float.random(in: -2...1), Float.random(in: -1...2))
  }

  func explode() {
    let exp = Explosion()
    exp.position = position
    exp.size = size

    if self.size.x < 32 {
      scene?.addChild(exp)
      self.alive = false
      return
    }
    // Create 1-3 smaller asteroids
    let count = Int.random(in: 1...3)
    var velocity = simd_float2(Float.random(in: -1...1), Float.random(in: -1...1))
    for _ in 0..<count {
      let asteroid = Asteroid()
      asteroid.position =
        position + simd_float2(Float.random(in: -16...16), Float.random(in: -16...16))
      asteroid.size = self.size / 2
      asteroid.velocity = velocity * -1 * Float(speed)
      velocity = velocity * Float.random(in: -1.5...1.5)
      scene?.addChild(asteroid)
    }

    scene?.addChild(exp)
  }

  override func update(delta: Double) {
    self.rotation = rotation + Measurement(value: (speed / 10) * delta, unit: UnitAngle.radians)

    let velocityX = Double(velocity.x) * speed * cos(self.rotation.value / 10) * speed
    let velocityY = Double(velocity.y) * speed * sin(self.rotation.value / 10) * speed

    self.position.x += Float(velocityX) * Float(delta)
    self.position.y += Float(velocityY) * Float(delta)

    self.velocity.x *= pow(0.99, Float(delta))
    self.velocity.y *= pow(0.99, Float(delta))

    if abs(velocity.x) < 0.0001 { velocity.x = 0 }
    if abs(velocity.y) < 0.0001 { velocity.y = 0 }

    clamp(&velocity, min: -50, max: 50)

    if (position.x + size.x) < 0 - size.x {
      position.x = Float(World.shared.width)
    }

    if position.x + size.x > Float(World.shared.width) {
      position.x = 0 - size.x
    }

    if position.y + size.y < 0 {
      position.y = Float(World.shared.height)
    }

    if position.y > Float(World.shared.height) {
      position.y = 0
    }
  }

  override func destroy() {

    explode()
  }

  override func onCollisionEnd(with: Entity) {
  }

  override func onCollisionStart(with: Entity) {
    let overlapX = min(self.bounds.right - with.bounds.left, with.bounds.right - self.bounds.left)
    let overlapY = min(self.bounds.bottom - with.bounds.top, with.bounds.bottom - self.bounds.top)

    if with is Bullet {
      self.alive = false
    }

    if with is Player {
      if overlapX < overlapY {
        if self.bounds.center.x < with.bounds.center.x {
          self.position.x -= overlapX / 2
          with.position.x += overlapX / 2
        } else {
          self.position.x += overlapX / 2
          with.position.x -= overlapX / 2
        }
      } else {
        if self.bounds.center.y < with.bounds.center.y {
          self.position.y -= overlapY / 2
          with.position.y += overlapY / 2
        } else {
          self.position.y += overlapY / 2
          with.position.y -= overlapY / 2
        }
      }
    }

    if with is Asteroid {
      // Asteroids should deflect off of each other using linear algebra and the velocity vectors to calculate the normal of the collision and adjust the velocity vectors accordingly.
      // The angle of deflection should be based on the angle of the collision.
      // We should also take into account the mass of the asteroids in the deflection.
      if overlapX < overlapY {
        if self.bounds.center.x < with.bounds.center.x {
          self.position.x -= overlapX / 2
          with.position.x += overlapX / 2
        } else {
          self.position.x += overlapX / 2
          with.position.x -= overlapX / 2
        }
      } else {
        if self.bounds.center.y < with.bounds.center.y {
          self.position.y -= overlapY / 2
          with.position.y += overlapY / 2
        } else {
          self.position.y += overlapY / 2
          with.position.y -= overlapY / 2
        }
      }

      self.velocity *= -1 + with.mass
      with.velocity *= -1 + self.mass
    }

  }

}
