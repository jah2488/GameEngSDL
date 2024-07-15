class Thruster: Entity {
  var thrust = Asset(path: "thrust.png")

  var ship: Player {
    return self.parent as! Player
  }

  required init() {
    super.init()
    self.position.x = 36
    self.position.y = 34
  }

  override func draw(game: Game) {
    game.r.drawTexture(
      resource: thrust, x: Float(self.position.x + ship.position.x),
      y: Float(self.position.y + ship.position.y),
      width: 16, height: 16,
      rotation: rotation.converted(to: UnitAngle.degrees).value,  //(self.rotation - Angle(-1.57079, inDegrees: false)).valueInDegrees,
      tint: Color(r: 255, g: 255, b: 255, a: 255))
  }
}