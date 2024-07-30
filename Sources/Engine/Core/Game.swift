import simd

struct Weak<T: AnyObject> {
  weak var value: T?
}
struct World {
  static var shared = World()

  let gravity: Double = 9.8
  var width: Int = 800
  var height: Int = 600

  var a: Audio?

  mutating func load(from: Game) {
    self.width = from.width
    self.height = from.height
    self.a = from.a
  }

  var entities: [Weak<Entity>] = []
  mutating func add(_ entity: Entity) {
    // TODO: Prevent adding the same entity multiple times
    entities.append(Weak(value: entity))
  }

  mutating func remove(_ entity: Entity) {
    entities.removeAll { $0.value == nil }
    entities.removeAll { ObjectIdentifier($0.value!) == ObjectIdentifier(entity) }
  }
}

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

  /// Helper property to access the Audio System
  var a: Audio

  /// Private Helper property to access the state of the world
  var w: World

  var e: EventQueue

  var mouse = simd_float2(0, 0)

  /// The color to clear the screen with each frame.
  var clearColor: Color = Color(r: 0, g: 0, b: 0, a: 255)

  init(rendererPointer: OpaquePointer, name: String = "Game", width: Int = 800, height: Int = 600) {
    self.width = width
    self.height = height
    self.name = name
    self.s = SceneManager.empty
    self.r = RendererManager(renderer: rendererPointer)
    self.a = Audio()
    self.w = World()
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

struct Rect<T: Numeric & Comparable & BinaryFloatingPoint> {
  var x: T
  var y: T
  var width: T
  var height: T
  // Convenience properties for readability
  var left: T { return x }
  var right: T { return x + width }
  var top: T { return y }
  var bottom: T { return y + height }

  var minX: T { return x }
  var midX: T { return x + width / 2 }  //(0.5 as! T) }
  var maxX: T { return x + width }

  var center: simd_float2 { return simd_float2(Float(midX), Float(midY)) }

  var minY: T { return y }
  var midY: T { return y + height / 2 }
  var maxY: T { return y + height }

  // Method to check overlap with another rectangle
  @inlinable
  func overlaps(with other: Rect) -> Bool {
    return
      !(left >= other.right || right <= other.left || top >= other.bottom || bottom <= other.top)
  }
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

  static let red = Color(r: 255, g: 0, b: 0, a: 255)
  static let black = Color(r: 0, g: 0, b: 0, a: 255)
  static let white = Color(r: 255, g: 255, b: 255, a: 255)
  static let green = Color(r: 0, g: 255, b: 0, a: 255)
  static let blue = Color(r: 0, g: 0, b: 255, a: 255)
}

enum GameState {
  case running
  case paused
  case stopped
}
