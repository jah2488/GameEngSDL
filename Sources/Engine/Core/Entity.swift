import Foundation
import simd

enum OriginLocation {
  case topLeft
  case topRight
  case bottomLeft
  case bottomRight
  case center
  case custom(simd_float2)
}

struct Transform2D: Hashable, Equatable {
  var origin: simd_float2
  var x: simd_float2 = simd_float2(1, 0)
  var y: simd_float2 = simd_float2(0, 1)

  init(origin: simd_float2, x: simd_float2, y: simd_float2) {
    self.origin = origin
    self.x = x
    self.y = y
  }

  init(origin: simd_float2) {
    self.origin = origin
  }

  init(from: Transform2D) {
    self.origin = from.origin
    self.x = from.x
    self.y = from.y
  }

  init() {
    self.origin = simd_float2(0, 0)
  }
}

/// A base class for all visible entities in the game.
class Entity: Renderable {
  /// The unique internal identifier for this entity.
  let id: UUID = UUID()
  /// Should this entities position be relative to its parent
  /// Default is `true`.
  var relative: Bool = true

  /// The scene that this entity is a part of.
  var scene: Scene?

  /// The parent of this entity.
  var parent: (Entity)?

  /// The children of this entity.
  var children: [Entity] = []

  /// The transform of the entity.
  var transform: Transform2D = Transform2D()

  /// The position of the entity in 2d space.
  var position: simd_float2 = simd_float2(0, 0)

  /// The velocity of the entity in 2d space.
  var velocity: simd_float2 = simd_float2(0, 0)

  /// The rotation of the entity in radians.
  var rotation: Measurement<UnitAngle> = Measurement(value: 0, unit: .radians)

  /// The scale of the entity.
  var scale: simd_float2 = simd_float2(1, 1)

  /// If the entity should be flipped horizontally.
  var flipX: Bool = false

  /// If the entity should be flipped vertically.
  var flipY: Bool = false

  /// The tint color of the entity.
  var tint: Color = Color(r: 255, g: 255, b: 255, a: 255)

  /// The size of the entity.
  var size: simd_float2 = simd_float2(0, 0)

  /// The visibility of the entity. If false, the entity's ``draw`` method will not be called.
  var visible: Bool = true

  /// The paused state of the entity. If true, the entity's ``update`` method will not be called.
  var paused: Bool = false

  /// The active state of the entity. If false, the ``draw`` and ``update`` methods will not be called.
  var active: Bool = true

  /// The alive state of the entity. If false, the ``destroy`` method will be called and it will be removed from the scene.
  var alive: Bool = true

  /// The origin location of the entity. This defaults to the center of the entity. This determins the point around which the entity is rotated and scaled.
  var originLocation = OriginLocation.center

  /// The origin of the entity. This determins the point around which the entity is rotated and scaled.
  var origin: simd_float2 {
    get {
      switch originLocation {
      case .topLeft:
        return simd_float2(0, 0)
      case .topRight:
        return simd_float2(size.x, 0)
      case .bottomLeft:
        return simd_float2(0, size.y)
      case .bottomRight:
        return size
      case .center:
        return size / 2
      case .custom(let point):
        return point
      }
    }
    set {
      originLocation = .custom(newValue)
    }
  }

  var shouldDraw: Bool {
    return visible && alive && active
  }

  var shouldUpdate: Bool {
    return alive && active && !paused
  }

  var shouldDestroy: Bool {
    return !alive
  }

  required init() {}

  func _start(game: any Game) {
    start(game: game)
    self.children.forEach { child in
      child._start(game: game)
    }
  }

  /// Called when the entity is added to the scene.
  func start(game: any Game) {}

  /// [Internal] Is the method that is called from the main gameloop to draw the entity.
  /// Always calls ``draw`` before drawing children.
  func _draw(game: any Game) {
    draw(game: game)
    self.children.forEach { child in
      if child.shouldDraw {
        child._draw(game: game)
      }
    }
  }

  /// Called when the entity should be drawn (at most once a frame)
  /// Always called after ``update``
  /// - Parameter game: A reference to the main game object
  func draw(game: any Game) {}

  /// [Internal] Is the method that is called from the main gameloop to update the entity.
  /// Always calls ``update`` before updating children.
  func _update(delta: Double) {
    update(delta: delta)
    self.children.forEach { child in
      if child.shouldUpdate {
        child._update(delta: delta)
      }
    }
  }

  /// Called when the entity should be updated (possibly multiple times a frame)
  /// Always called after `input` and before `draw`
  /// - Parameter delta: The time (in milliseconds) since the last update
  func update(delta: Double) {}

  func _input(keys: Keys.State, game: any Game) {
    input(keys: keys, game: game)
    self.children.forEach { child in
      child._input(keys: keys, game: game)
    }
  }

  /// Called when the entity should process input. Always called before `update`
  ///
  /// - Parameters:
  ///   - keys: A struct containing the current state of the keyboard
  ///   - game: A reference to the main game object
  func input(keys: Keys.State, game: any Game) {}

  /// [Internal] Is the method that is called from the main gameloop to destroy the entity.
  /// Always calls ``destroy`` before destroying children.
  func _destroy() {
    destroy()
    self.children.forEach { child in
      if child.shouldDestroy {
        child._destroy()
      }
    }
  }

  /// Called when the entity should be destroyed.
  /// Always called after `draw` and `update` and only on entities where ``alive`` is false.
  func destroy() {}
}