import Foundation

class PlayScene: Scene {
  var parent: (any Node)?

  var children: [Entity]

  var id: UUID
  var name: String
  var nodes: [Entity]

  init(id: UUID, name: String, nodes: [Entity]) {
    self.id = id
    self.name = name
    self.children = []
    self.nodes = []
    var childs: [Entity] = [
      StarBackground(), Player(), Asteroid(), Asteroid(), Asteroid(), Asteroid(),
    ]
    for index in childs.indices {
      childs[index].scene = self
    }

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
      if let node = node as? Entity {
        node._draw(game: game)
      }
    }
  }

  func update(delta: Double) {
    children.forEach { node in
      if let node = node as? Entity {
        node._update(delta: delta)
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

class Asteroid: Entity {
  var asteroid = Asset(path: "asteroid.png")
  var speed: Double = Double.random(in: 20...200)
  var width: Float = 64 * Float.random(in: (0.2)...8)

  required init() {
    super.init()
    self.position.x = Float.random(in: 0...800)
    self.position.y = Float.random(in: 0...1300)
  }

  override func draw(game: any Game) {
    game.drawTexture(
      resource: asteroid, x: Float(self.position.x), y: Float(self.position.y),
      width: self.width, height: self.width,
      rotation: self.rotation.converted(to: .degrees).value,
      tint: Color(r: 255, g: 255, b: 255, a: 255))
  }

  override func update(delta: Double) {
    self.rotation = rotation + Measurement(value: speed * delta, unit: UnitAngle.radians)

    let velocityX = cos(self.rotation.value) * speed
    let velocityY = sin(self.rotation.value) * speed

    // Update the bullet's position based on the velocity
    // Delta is the time elapsed since the last frame, so multiplying by delta makes the movement frame-rate independent
    self.position.x += Float(velocityX) * Float(delta)
    self.position.y += Float(velocityY) * Float(delta)

    //TODO: On Destroy, break into two smaller asteroids if size is greater than 16
    //TODO: Model collisionRects separetly from the renderable rect
    //TODO: Should look into polygonal collision shapes.
  }
}
