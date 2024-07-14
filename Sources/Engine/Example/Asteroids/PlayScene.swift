import Foundation

class PlayScene: Scene, Node {
  var parent: (any Node)?

  var children: [any Node]

  var id: UInt64
  var name: String
  var nodes: [Node]

  init(id: UInt64, name: String) {
    self.id = id
    self.name = name
    self.children = []
    self.nodes = []
    var childs: [any Node] = [
      StarBackground(), Player(), Asteroid(), Asteroid(), Asteroid(), Asteroid(),
    ]
    for index in childs.indices {
      childs[index].parent = self
    }

    self.nodes = childs
    self.children = childs
  }

  func load() {
    print("Loading scene \(self.name)")
  }

  func unload() {
    print("Unloading scene \(self.name)")
  }

  func start(game: Game) {
    children.forEach { node in
      if let node = node as? Renderable {
        node.start(game: game)
      }
    }
  }

  func draw(game: Game) {
    children.forEach { node in
      if let node = node as? Renderable {
        node.draw(game: game)
      }
    }
  }

  func update(delta: Float) {
    children.forEach { node in
      if let node = node as? Renderable {
        node.update(delta: delta)
      }
    }
  }

  func input(keys: Keys.State, game: Game) {
    children.forEach { node in
      if let node = node as? Renderable {
        node.input(keys: keys, game: game)
      }
    }
  }

}

class Asteroid: Renderable, Node {
  var relative: Bool = true
  var position = Vector2(x: 0, y: 0)
  var rotation: Angle = Angle(0, inDegrees: false)
  var parent: (any Node)?
  var id: UInt64
  var children: [any Node]
  var asteroid = Asset(path: "asteroid.png")
  var speed: Double = Double.random(in: 20...200)
  var width: Float = 64 * Float.random(in: (0.2)...8)

  required init() {
    self.id = 0
    self.children = []
    self.position.x = Double.random(in: 0...800)
    self.position.y = Double.random(in: 0...1300)
  }

  func start(game: any Game) {

  }

  func draw(game: any Game) {
    game.drawTexture(
      resource: asteroid, x: Float(self.position.x), y: Float(self.position.y),
      width: self.width, height: self.width,
      rotation: self.rotation.valueInDegrees,
      tint: Color(r: 255, g: 255, b: 255, a: 255))
  }

  func update(delta: Float) {
    self.rotation += Angle(speed, inDegrees: false).value

    let velocityX = cos(self.rotation.value) * speed
    let velocityY = sin(self.rotation.value) * speed

    // Update the bullet's position based on the velocity
    // Delta is the time elapsed since the last frame, so multiplying by delta makes the movement frame-rate independent
    self.position.x += Double(velocityX) * Double(delta)
    self.position.y += Double(velocityY) * Double(delta)

    //TODO: On Destroy, break into two smaller asteroids if size is greater than 16
    //TODO: Model collisionRects separetly from the renderable rect
    //TODO: Should look into polygonal collision shapes.
  }

  func input(keys: Keys.State, game: any Game) {

  }
}
