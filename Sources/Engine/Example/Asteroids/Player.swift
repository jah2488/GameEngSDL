import Foundation

class Player: Renderable, Node {
  var id: UInt64
  var children: [any Node]

  var position = Vector2(x: 0, y: 0)
  var velocity = Vector2(x: 0, y: 0)
  var angle: Angle = Angle(0, inDegrees: false)
  var thrust: Double = 0
  var rotationSpeed: Double = 0
  var ship = Asset(path: "ship.png")

  required init() {
    self.id = 1
    self.children = []
  }

  func start(game: Game) {
    self.position.x = Double(game.width) / 2
    self.position.y = Double(game.height) / 2
  }

  func draw(game: Game) {
    // game.drawRect(x: self.position.x, y: self.position.y, width: 10, height: 10)
    game.drawTexture(
      resource: self.ship, x: Float(self.position.x), y: Float(self.position.y), width: 64,
      height: 64,
      rotation: (self.angle - Angle(-1.57079, inDegrees: false)).valueInDegrees,
      tint: Color(r: 255, g: 255, b: 255, a: 255))
  }

  func update(delta: Float) {
    angle = angle + rotationSpeed * Double(delta)

    let ax = thrust * cos(angle.value)
    let ay = thrust * sin(angle.value)

    velocity.x += ax * Double(delta)
    velocity.y += ay * Double(delta)

    position.x += velocity.x * Double(delta)
    position.y += velocity.y * Double(delta)

    velocity.x *= 0.99
    velocity.y *= 0.99
  }

  func input(keys: Keys.State, game: Game) {
    //todo replace direct key access with keymaps
    if keys.isPressed(.w) {
      if thrust < 200 {
        thrust += 50
      }
    }

    if keys.isPressed(.s) {
      if thrust > -200 {
        thrust -= 50
      }
    }

    if keys.isPressed(.a) {
      rotationSpeed -= 1
    }

    if keys.isPressed(.d) {
      rotationSpeed += 1
    }

    if keys.isReleased(.space) {
      print("pew pew")
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

}
