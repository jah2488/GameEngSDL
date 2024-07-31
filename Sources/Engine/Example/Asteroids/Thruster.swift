import Foundation
import simd

class Thruster: Entity {
  var ship: Player {
    return self.parent as! Player
  }

  required init() {
    super.init()
    self.position.x = 36
    self.position.y = 34
    self.texture = Asset(path: "thrust2.png")
    self.size = simd_float2(100, 100)
    self.blendMode = .mul
  }

  override func input(keys: Keys.State, game: Game) {
    if keys.isReleased(.f) {
      print("Thruster input")
      self.blendMode = .add
    }

    if keys.isPressed(.v) {
      self.blendMode = .mul
    }

    if keys.isPressed(.r) {
      self.blendMode = .mod
    }

    if keys.isPressed(.t) {
      self.blendMode = .none
    }

    if keys.isPressed(.b) {
      self.blendMode = .blend
    }

  }
}
