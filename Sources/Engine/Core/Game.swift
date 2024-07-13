protocol Game {
  var width: Int { get }
  var height: Int { get }
  var name: String { get set }
  var scenes: [Scene] { get set }
  var currentScene: Scene? { get set }
  var state: GameState { get set }
  var isRunning: Bool { get }

  func start(renderer: OpaquePointer)
  func stop()
  func draw()
  func drawRect(x: Float, y: Float, width: Float, height: Float)
  func drawTexture(
    resource: any Resource, x: Float, y: Float, width: Float, height: Float, rotation: Double)
  func update(delta: Float)
  func input(keys: Keys.State)
}

enum GameState {
  case running
  case paused
  case stopped
}
