import CSDL3
import Foundation
import simd

class Shield: Entity {
  required init() {
    super.init()
    self.sprite = Sprite(
      path: "shield.png", frames: 6, frameRate: 1 / 120, loop: true, animationCompleted: {})
    self.size = simd_float2(64, 64)
    self.blendMode = .blend
    self.relative = true
    self.originLocation = .center
    self.position = simd_float2(-10, -16)
  }

  override func update(delta: Double) {
    self.rotation = self.rotation + Measurement(value: 20 * delta, unit: UnitAngle.radians)
  }
}

class Player: Entity {
  var thrust: Double = 0
  var rotationSpeed: Double = 0
  var lives: Int = 0
  var shield: Bool = false
  var invulnerable: Bool = false

  var damagedSound = Sound(path: "Explosion.wav")
  var chunkID: Int?
  var shieldSprite = Shield()

  required init() {
    super.init()
    let thruster = Thruster()
    self.children = [thruster, shieldSprite]
    self.size = simd_float2(32, 32)
    self.texture = Asset(path: "ship.png")
    self.originLocation = .custom(simd_float2(23, 16))
    thruster.parent = self
    shieldSprite.parent = self
    self.lives = 3
    self.shield = false
  }

  override func start(game: Game) {
    self.chunkID = game.a.load(damagedSound.url)
    self.position.x = Float(game.width) / 2
    self.position.y = Float(game.height) / 2
    log.log("Player starting at \(self.position.x), \(self.position.y)")
  }

  override func update(delta: Double) {
    rotation = rotation + Measurement(value: rotationSpeed * delta, unit: UnitAngle.radians)

    let ax = thrust * cos(rotation.value)
    let ay = thrust * sin(rotation.value)

    velocity.x += Float(ax * delta)
    velocity.y += Float(ay * delta)

    position.x += velocity.x * Float(delta)
    position.y += velocity.y * Float(delta)

    velocity.x *= 0.99
    velocity.y *= 0.99

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

    if shield {
      shieldSprite.visible = true
    } else {
      shieldSprite.visible = false
    }

  }

  override func input(keys: Keys.State, game: Game) {
    //todo replace direct key access with keymaps
    if keys.isPressed(.w) || keys.isPressed(.dpadUpBtn) {
      thrust -= 50
    }

    if keys.isPressed(.s) || keys.isPressed(.dpadDownBtn) {
      thrust += 50
    }

    if keys.isPressed(.a) || keys.isPressed(.dpadLeftBtn) || keys.isPressed(.leftShoulderBtn) {
      rotationSpeed -= 1
    }

    if keys.isPressed(.d) || keys.isPressed(.dpadRightBtn) || keys.isPressed(.rightShoulderBtn) {
      rotationSpeed += 1
    }

    if keys.isPressed(.q) || keys.isPressed(.eastBtn) {
      thrust *= 0.01
      velocity *= 0.5
      shield = true
    }

    if keys.isReleased(.q) || keys.isReleased(.eastBtn) {
      shield = false
    }

    if keys.isReleased(.space) || keys.isReleased(.southBtn) {
      fire(game: game)
    }

    if keys.isReleased(.w) || keys.isReleased(.s) {
      thrust *= 0.5
    }

    if keys.isReleased(.a) || keys.isReleased(.d) {
      rotationSpeed = 0
    }

    clamp(&thrust, min: -800, max: 800)
    clamp(&rotationSpeed, min: -4, max: 4)
  }

  override func onCollisionStart(with: Entity) {
    if with is Asteroid {
      if shield {
        shield = false
        with.destroy()
        return
      }
      self.damage()
    }
  }

  func damage() {
    if self.invulnerable { return }

    World.shared.a?.play(self.chunkID!, .soundfx)

    self.lives -= 1
    self.invulnerable = true

    self.tint = .red
    DispatchQueue.main.async {
      self.tint = .white
      self.flash()
      self.flash()
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.invulnerable = false
      }
    }

    if self.lives <= 0 {
      self.alive = false
    }
  }

  func flash() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.tint = .red
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      self.tint = .white
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.tint = .red
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
      self.tint = .white
    }
  }

  func fire(game: Game) {
    let bullet = Bullet()
    bullet.position = self.position + (self.origin / 2)
    bullet.rotation =
      self.rotation
      + Measurement(value: 1 * Double.random(in: -(0.1)...(0.1)), unit: UnitAngle.radians)
    bullet.parent = self
    self.children.append(bullet)
    bullet.start(game: game)
    self.velocity.x += cos(Float(self.rotation.value)) * 50
  }

}
