import Foundation

class MenuScene: Scene {
  internal init(id: UUID, name: String, nodes: [Entity]) {
    self.id = id
    self.name = name
    self.nodes = nodes
  }

  var id: UUID
  var name: String
  var nodes: [Entity]

  init(id: UUID, name: String) {
    self.id = id
    self.name = name
    self.nodes = [StarBackground(), MenuUI()]
  }

  func load() {
    print("Loading scene \(self.name)")
  }

  func unload() {
    print("Unloading scene \(self.name)")
  }

  func start(game: Game) {
    nodes.forEach { node in
      if let node = node as? Renderable {
        node.start(game: game)
      }
    }
  }

  func draw(game: Game) {
    nodes.forEach { node in
      if let node = node as? Renderable {
        node.draw(game: game)
      }
    }
  }

  func update(delta: Double) {
    nodes.forEach { node in
      if let node = node as? Renderable {
        node.update(delta: delta)
      }
    }
  }

  func input(keys: Keys.State, game: Game) {
    nodes.forEach { node in
      if let node = node as? Renderable {
        node.input(keys: keys, game: game)
      }
    }
  }
}
