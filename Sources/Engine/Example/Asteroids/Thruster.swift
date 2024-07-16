import Foundation

class Thruster: Entity {
  var ship: Player {
    return self.parent as! Player
  }

  required init() {
    super.init()
    self.position.x = 36
    self.position.y = 34
    self.texture = Asset(path: "thrust.png")
  }
}
