import CSDL3
import CSDL3_image
import Foundation

class Asteroids: Game {
  var name: String
  var scenes: [Scene]
  var currentScene: Scene?
  var state: GameState
  var renderer: OpaquePointer!
  var width: Int
  var height: Int

  init(name: String, width: Int, height: Int) {
    self.name = name
    self.scenes = []
    self.state = .stopped
    self.currentScene = Play(id: 1, name: "Play")
    self.width = width
    self.height = height
  }

  var isRunning: Bool {
    return self.state == .running || self.state == .paused
  }

  func start(renderer: OpaquePointer) {
    self.state = .running
    self.renderer = renderer
    self.currentScene!.start(game: self)
  }

  func stop() {
    self.state = .stopped
  }

  func drawRect(x: Float, y: Float, width: Float, height: Float) {
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
    var rect = SDL_FRect(x: x, y: y, w: width, h: height)
    SDL_RenderFillRect(renderer, &rect)
    // SDL_RenderRect(renderer, &rect)
  }

  func drawTexture(
    resource: any Resource, x: Float, y: Float, width: Float, height: Float, rotation: Double
  ) {
    let text = SDL_CreateTextureFromSurface(renderer, resource.surface)
    SDL_SetTextureScaleMode(text, SDL_SCALEMODE_NEAREST)
    let _ = withUnsafePointer(to: SDL_FRect(x: x, y: y, w: width, h: height)) { rect in
      SDL_RenderTextureRotated(renderer, text, nil, rect, rotation, nil, SDL_FLIP_NONE)
    }
  }

  func draw() {
    self.currentScene!.draw(game: self)
  }

  func update(delta: Float) {
    self.currentScene!.update(delta: delta)
  }

  func input(keys: Keys.State) {
    self.currentScene!.input(keys: keys)
  }
}

class Asset: Resource {
  var id: UInt64
  var type: ResourceType
  var path: String
  var surface: UnsafeMutablePointer<SDL_Surface>

  init(path: String) {
    self.id = 1
    self.type = ResourceType.texture
    self.path = path
    let out = IMG_Load(path)
    if out == nil {
      print("Error loading asset \(self.path)")
      print("SDL Error: \(String(cString: SDL_GetError()))")
      self.surface = SDL_CreateSurface(0, 0, SDL_PIXELFORMAT_ABGR8888)
    } else {
      self.surface = out!
    }
  }

  deinit {
    SDL_DestroySurface(self.surface)
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
    hasher.combine(self.type)
    hasher.combine(self.path)
  }

  static func == (lhs: Asset, rhs: Asset) -> Bool {
    lhs.id == rhs.id || (lhs.type == rhs.type && lhs.hashValue == rhs.hashValue)
  }
}

class Play: Scene {

  var id: UInt64
  var name: String
  var nodes: [Node]

  init(id: UInt64, name: String) {
    self.id = id
    self.name = name
    self.nodes = [Player()]
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

  func update(delta: Float) {
    nodes.forEach { node in
      if let node = node as? Renderable {
        node.update(delta: delta)
      }
    }
  }

  func input(keys: Keys.State) {
    nodes.forEach { node in
      if let node = node as? Renderable {
        node.input(keys: keys)
      }
    }
  }

}

class Player: Renderable, Node {
  var id: UInt64
  var children: [any Node]

  var position = Vector2(x: 0, y: 0)
  var velocity = Vector2(x: 0, y: 0)
  var angle: Angle = Angle(0, inDegrees: false)
  var thrust: Double = 0
  var rotationSpeed: Double = 0
  var ship = Asset(path: "GameEngSDL_GameEngSDL.bundle/Assets/ship.png")

  required init() {
    self.id = 1
    self.children = []
  }

  func start(game: Game) {
    self.position.x = Double(game.width) / 2
    self.position.y = Double(game.height) / 2
  }

  func draw(game: Game) {
    // game.drawRect(x: self.position.x, y: self.position.y, width: 10, height: 10)
    game.drawTexture(
      resource: self.ship, x: Float(self.position.x), y: Float(self.position.y), width: 64,
      height: 64,
      rotation: (self.angle - Angle(-1.57079, inDegrees: false)).valueInDegrees)
  }

  func update(delta: Float) {
    angle = angle + rotationSpeed * Double(delta)

    let ax = thrust * cos(angle.value)
    let ay = thrust * sin(angle.value)

    velocity.x += ax * Double(delta)
    velocity.y += ay * Double(delta)

    position.x += velocity.x * Double(delta)
    position.y += velocity.y * Double(delta)

    velocity.x *= 0.99
    velocity.y *= 0.99
  }

  func input(keys: Keys.State) {
    //todo replace direct key access with keymaps
    if keys.isPressed(.w) {
      if thrust < 200 {
        thrust += 50
      }
    }

    if keys.isPressed(.s) {
      if thrust > -200 {
        thrust -= 50
      }
    }

    if keys.isPressed(.a) {
      rotationSpeed -= 1
    }

    if keys.isPressed(.d) {
      rotationSpeed += 1
    }

    if keys.isReleased(.space) {
      print("pew pew")
    }

    if keys.isReleased(.w) || keys.isReleased(.s) {
      thrust = 0
    }

    if keys.isReleased(.a) || keys.isReleased(.d) {
      rotationSpeed = 0
    }

    clamp(&thrust, min: -200, max: 200)
    clamp(&rotationSpeed, min: -3, max: 3)
  }

}

struct Angle {
  let value: Double
  var valueInDegrees: Double {
    return value * 180 / Double.pi
  }
  private static let twoPi = Double.pi * 2

  init(_ value: Double, inDegrees: Bool = false) {
    if inDegrees {
      let normalized = value.truncatingRemainder(dividingBy: 360)
      if normalized < 0 {
        self.value = 360 + normalized
      } else {
        self.value = normalized
      }
    } else {
      let normalized = value.truncatingRemainder(dividingBy: Angle.twoPi)
      if normalized < 0 {
        self.value = Angle.twoPi + normalized
      } else {
        self.value = normalized
      }
    }
  }

  static func += (lhs: inout Angle, rhs: Double) {
    _ = Angle(lhs.value + rhs)
  }

  static func + (lhs: Angle, rhs: Double) -> Angle {
    Angle(lhs.value + rhs)
  }

  static func + (lhs: Angle, rhs: Angle) -> Angle {
    Angle(lhs.value + rhs.value)
  }

  static func - (lhs: Angle, rhs: Double) -> Angle {
    Angle(lhs.value - rhs)
  }

  static func - (lhs: Angle, rhs: Angle) -> Angle {
    Angle(lhs.value - rhs.value)
  }

  static func * (lhs: Angle, rhs: Angle) -> Angle {
    Angle(lhs.value * rhs.value)
  }

  static func / (lhs: Angle, rhs: Angle) -> Angle {
    Angle(lhs.value / rhs.value)
  }

}

func clamp(_ value: inout Double, min: Double, max: Double) {
  if value < min {
    value = min
  }

  if value > max {
    value = max
  }
}

struct Vector2 {
  var x: Double
  var y: Double
}
