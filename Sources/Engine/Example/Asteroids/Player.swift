import CSDL3
import Foundation
import simd

class Player: Entity {
  var thrust: Double = 0
  var rotationSpeed: Double = 0

  required init() {
    super.init()
    let thruster = Thruster()
    self.children = [thruster]
    self.size = simd_float2(64, 64)
    self.texture = Asset(path: "ship.png")
    self.originLocation = .custom(simd_float2(46, 32))
    thruster.parent = self
  }

  override func start(game: Game) {
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
  }

  override func input(keys: Keys.State, game: Game) {
    //todo replace direct key access with keymaps
    if keys.isPressed(.w) {
      thrust -= 50
    }

    if keys.isPressed(.s) {
      thrust += 50
    }

    if keys.isPressed(.a) {
      rotationSpeed -= 1
    }

    if keys.isPressed(.d) {
      rotationSpeed += 1
    }

    if keys.isReleased(.space) {
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

  func fire(game: Game) {
    let bullet = Bullet()
    bullet.position = self.position + self.origin
    bullet.rotation = self.rotation
    bullet.parent = self
    self.children.append(bullet)
    bullet.start(game: game)
  }

}
