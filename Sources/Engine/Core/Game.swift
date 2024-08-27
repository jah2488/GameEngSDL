import simd

class Game {
  enum GameState {
    case running
    case paused
    case stopped
  }

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

  /// Helper property to access the Audio System
  var a: Audio

  /// Private Helper property to access the state of the world
  var w: World

  var e: EventQueue

  var mouse: Mouse {
    get {
      return World.shared.m
    }
    set {
      World.shared.m = newValue
    }
  }

  /// The color to clear the screen with each frame.
  var clearColor: Color = Color(r: 0, g: 0, b: 0, a: 255)

  init(rendererPointer: OpaquePointer, name: String = "Game", width: Int = 800, height: Int = 600) {
    self.width = width
    self.height = height
    self.name = name
    self.s = SceneManager.empty
    self.r = RendererManager(renderer: rendererPointer)
    self.a = Audio()
    self.w = World.shared
    self.e = EventQueue()
  }

  final func _start() {
    self.state = .running
    self.start()
    World.shared.load(from: self)
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
    //NOTE: Now that all the draw calls have been batched, draw them all in the correct order.
    self.r._draw()
  }

  func draw() {}

  final func _update(delta: Double) {
    self.calculateCollisions()
    self.update(delta: delta)
    self.s.current()._update(delta: delta)
  }

  func update(delta: Double) {}

  func calculateCollisions() {
    let entities = World.shared.entities.compactMap { $0.value }
    for i in 0..<entities.count {
      for j in i + 1..<entities.count {
        let a = entities[i]
        let b = entities[j]
        if a.bounds.overlaps(with: b.bounds) {
          a.onCollisionStart(with: b)
          b.onCollisionStart(with: a)
        } else {
          a.onCollisionEnd(with: b)
          b.onCollisionEnd(with: a)
        }
      }
    }
  }

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

  func _cleanup() {
    self.s.current()._cleanup()
  }

  var changeInProgress: Bool = false
  func changeScene(_ scene: Scene) {
    self.s.current()._unload()
    self.s.changeScene(scene)
    self.s.current()._load()
    self.s.current()._start(game: self)
  }
}
