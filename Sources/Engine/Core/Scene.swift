import Foundation

class Scene: Renderable {
  /// The unique internal identifier for this entity.
  let id: UUID = UUID()
  /// Should this entities position be relative to its parent
  /// Default is `true`.
  var relative: Bool = true

  /// The name of the scene.
  let name: String

  /// The parent scene of this scene.
  var parent: (Scene)?

  var children: [Entity] = []

  var isLoaded: Bool = false

  init(name: String, autoLoad: Bool = true) {
    self.name = name
    if !isLoaded && autoLoad {
      _load()
    }
  }

  final func _load() {
    if !isLoaded {
      load()
      isLoaded = true
    }
  }

  func load() {}

  final func _unload() {
    unload()
    isLoaded = false
  }

  func unload() {}

  /// [Internal] Is the method that is called to draw the scene.
  /// Only called one time after ``load``
  final func _start(game: any Game) {
    if isLoaded {
      start(game: game)
    } else {
      print("Scene \(id) _start(:game) was called before loading has completed.")
    }
  }

  func start(game: any Game) {}

  /// [Internal] Is the method that is called to draw the scene.
  final func _draw(game: any Game) {
    draw(game: game)
    self.children.forEach { node in
      node._draw(game: game)
    }
  }
  func draw(game: any Game) {}

  final func _update(delta: Double) {
    update(delta: delta)
    self.children.forEach { node in
      node._update(delta: delta)
    }
  }
  func update(delta: Double) {}

  final func _input(keys: Keys.State, game: any Game) {
    input(keys: keys, game: game)
    self.children.forEach { node in
      node._input(keys: keys, game: game)
    }
  }
  func input(keys: Keys.State, game: any Game) {}

  final func _destroy() {
    self.children.forEach { node in
      node._destroy()
    }
    self.children = []
    self._unload()
  }

  func destroy() {}

  //Adds a child to the scene
  final func addChild(_ child: Entity) {
    self.children.append(child)
    child.scene = self
  }

  //Removes a child from the scene
  final func removeChild(_ child: Entity, destroy: Bool = true) {
    self.children.removeAll { $0.id == child.id }
    child.scene = nil
    child.alive = !destroy
  }

}
