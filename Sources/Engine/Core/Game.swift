class Game {
  /// The width of the viewport of the game in pixels.
  var width: Int
  /// The height of the viewport of the game in pixels.
  var height: Int
  /// The name of the game.
  var name: String = "Game"

  /// The current state of the game.
  var state: GameState = .stopped

  /// Is the game running? When the game is not running, the game loop will not run and the application will exit.
  var isRunning: Bool {
    return self.state == .running || self.state == .paused
  }

  /// Helper property to access the Scene Manager
  var s: SceneManager

  /// Helper property to access the Renderer Manager
  var r: RendererManager

  var clearColor: Color = Color(r: 0, g: 0, b: 0, a: 255)

  init(rendererPointer: OpaquePointer, name: String = "Game", width: Int = 800, height: Int = 600) {
    self.width = width
    self.height = height
    self.name = name
    self.s = SceneManager.empty
    self.r = RendererManager(renderer: rendererPointer)
  }

  final func _start() {
    self.state = .running
    self.start()
    log.log("Game _start()")
    self.s.current()._load()
    self.s.current()._start(game: self)
  }

  func start() {}

  final func _stop() {
    log.log("Game _stop()")
    self.state = .stopped
    self.stop()
  }

  func stop() {}

  final func _draw() {
    self.draw()
    self.s.current()._draw(game: self)
  }

  func draw() {}

  final func _update(delta: Double) {
    self.update(delta: delta)
    self.s.current()._update(delta: delta)
  }

  func update(delta: Double) {}

  final func _input(keys: Keys.State) {
    self.input(keys: keys)
    self.s.current()._input(keys: keys, game: self)
  }

  func input(keys: Keys.State) {}

  final func _destroy() {
    self.destroy()
    self.s.current()._destroy()
  }

  func destroy() {}

  var changeInProgress: Bool = false
  func changeScene(_ scene: Scene) {
    self.s.current()._unload()
    self.s.changeScene(scene)
    self.s.current()._load()
    self.s.current()._start(game: self)
  }
}

struct Rect<T> {
  var x: T
  var y: T
  var width: T
  var height: T
}

class SceneManager {
  var scenes: Zipper<Scene>

  static var empty: SceneManager {
    return SceneManager(scene: Scene(name: "NullScene"))
  }

  init(scene: Scene) {
    self.scenes = Zipper(left: [], current: scene, right: [])
  }

  init(_ scenes: [Scene]) {
    if scenes.isEmpty {
      fatalError("SceneManager must have at least one scene.")
    }
    self.scenes = Zipper(left: [], current: scenes[0], right: Array(scenes.dropFirst()))
  }

  func current() -> Scene {
    return scenes.current
  }

  func changeScene(_ scene: Scene) {
    scenes.addNext(scene)
    scenes.next()
  }
}

struct Zipper<T> {
  var left: [T]
  var current: T
  var right: [T]

  func all() -> [T] {
    return left + [current] + right
  }

  mutating func next() {
    if right.isEmpty {
      return
    }
    var newRight = right
    let newCurrent = newRight.removeFirst()
    self.left = left + [current]
    self.current = newCurrent
    self.right = newRight
  }

  mutating func addNext(_ value: T) {
    right.insert(value, at: 0)
  }

  mutating func addPrevious(_ value: T) {
    left.append(value)
  }

  mutating func append(_ value: T) {
    right.append(value)
  }

  mutating func prepend(_ value: T) {
    left.insert(value, at: 0)
  }
}

struct Color {
  var r: UInt8
  var g: UInt8
  var b: UInt8
  var a: UInt8
}

enum GameState {
  case running
  case paused
  case stopped
}
