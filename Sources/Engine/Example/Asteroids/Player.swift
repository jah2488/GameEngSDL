import CSDL3
import Foundation

class Player: Entity {
  var thrust: Double = 0
  var rotationSpeed: Double = 0
  var ship = Asset(path: "ship.png")

  required init() {
    super.init()
    let thruster = Thruster()
    self.children = [thruster]
    thruster.parent = self
  }

  override func start(game: Game) {
    self.position.x = Float(game.width) / 2
    self.position.y = Float(game.height) / 2
    log.log("Player starting at \(self.position.x), \(self.position.y)")
  }

  override func draw(game: Game) {
    // game.r.drawRect(x: self.position.x, y: self.position.y, width: 10, height: 10)
    game.r.drawTexture(
      resource: self.ship, x: Float(self.position.x), y: Float(self.position.y), width: 64,
      height: 64,
      rotation: rotation.converted(to: .degrees).value - 90,  //(self.angle - Angle(-1.57079, inDegrees: false)).valueInDegrees,
      tint: Color(r: 255, g: 255, b: 255, a: 255))
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
      if thrust < 200 {
        thrust -= 50
      }
    }

    if keys.isPressed(.s) {
      if thrust > -200 {
        thrust += 50
      }
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
      thrust = 0
    }

    if keys.isReleased(.a) || keys.isReleased(.d) {
      rotationSpeed = 0
    }

    clamp(&thrust, min: -200, max: 200)
    clamp(&rotationSpeed, min: -3, max: 3)
  }

  func fire(game: Game) {
    let bullet = Bullet()
    bullet.position = self.position
    bullet.rotation = self.rotation
    bullet.parent = self
    self.children.append(bullet)
    bullet.start(game: game)
  }

}
