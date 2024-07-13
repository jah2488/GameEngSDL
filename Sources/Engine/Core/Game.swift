protocol Game {
  var width: Int { get set }
  var height: Int { get set }
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
    resource: any Resource, x: Float, y: Float, width: Float, height: Float, rotation: Double,
    tint: Color)
  func drawText(text: String, x: Float, y: Float, width: Float, height: Float)
  func update(delta: Float)
  func input(keys: Keys.State)
  func changeScene(scene: Scene)
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
