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

  func rotated(by: Measurement<UnitAngle>) -> Transform2D {
    var new = Transform2D(from: self)
    let angle = by.converted(to: .radians).value
    let c = Float(cos(angle))
    let s = Float(sin(angle))
    new.x = simd_float2(x.x * c - x.y * s, x.x * s + x.y * c)
    new.y = simd_float2(y.x * c - y.y * s, y.x * s + y.y * c)
    return new
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

  var mass: Float = 1

  /// The rotation of the entity in radians.
  var rotation: Measurement<UnitAngle> = Measurement(value: 0, unit: .radians)

  /// The scale of the entity.
  var scale: simd_float2 = simd_float2(1, 1)

  /// The texture of the entity.
  var texture: Asset?

  /// The blendmode of the entity.
  var blendMode: RendererManager.BlendMode = .blend

  /// The animated sprite of the entity.
  var sprite: Sprite?

  var debugTexture = Asset(path: "bounds-debug.png")
  var debugTint = Color(r: 0, g: 255, b: 0, a: 100)
  var debugTintCollision = Color(r: 255, g: 0, b: 0, a: 100)

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

  var alwaysOnTop: Bool = false

  var debugRender: Bool = true

  /// Bounds of the entity.
  var bounds: Rect<Float> {
    return Rect(
      x: Float(position.x), y: Float(position.y), width: Float(size.x), height: Float(size.y))
  }

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

  required init() {
    World.shared.add(self)
  }

  deinit {
    World.shared.remove(self)
  }

  func _start(game: Game) {
    start(game: game)
    self.children.forEach { child in
      child._start(game: game)
    }
  }

  /// Called when the entity is added to the scene.
  func start(game: Game) {}

  /// [Internal] Is the method that is called from the main gameloop to draw the entity.
  /// Always calls ``draw`` before drawing children.
  func _draw(game: Game) {
    draw(game: game)
    self.children.forEach { child in
      if child.shouldDraw {
        child._draw(game: game)
      }
    }
    // Draw velocity vector
    let magnitude = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
    let norm = normalize(velocity)
    game.r.drawRect(
      x: worldPosition.x, y: worldPosition.y, width: 3.0, height: magnitude,
      tint: .red)

    game.r.drawRect(
      x: worldPosition.x - 6, y: worldPosition.y, width: 3, height: abs(norm.x) * 10, tint: .white)
    game.r.drawRect(
      x: worldPosition.x - 9, y: worldPosition.y, width: 3, height: abs(norm.y) * 10, tint: .green)

    if debugRender {
      var color = debugTint
      if isOverlapping {
        color = debugTintCollision
      }
      game.r.drawTexture(
        resource: debugTexture,
        x: worldPosition.x - 1,
        y: worldPosition.y - 1,
        width: Float(self.size.x) + 1,
        height: Float(self.size.y) + 1,
        rotation: worldRotation.converted(to: .degrees).value,
        origin: self.origin,
        tint: color
      )
    }
  }

  var worldPosition: simd_float2 {
    if relative && parent != nil {
      return self.position + parent!.worldPosition
    } else {
      return self.position
    }
  }

  var worldRotation: Measurement<UnitAngle> {
    if relative && parent != nil {
      return self.rotation + parent!.worldRotation
    } else {
      return self.rotation
    }
  }

  /// Called when the entity should be drawn (at most once a frame)
  /// Always called after ``update``
  /// - Parameter game: A reference to the main game object
  func draw(game: Game) {
    if self.sprite != nil {
      game.r.drawTextureAnimated(
        resource: self.sprite!.texture, x: worldPosition.x, y: worldPosition.y,
        width: Int(self.size.x), height: Int(self.size.y),
        frame: self.sprite!.frame, totalFrames: self.sprite!.totalFrames,
        rotation: worldRotation.converted(to: .degrees).value,
        origin: self.origin,
        tint: self.tint
      )
    } else if self.texture != nil {
      let width = self.size.x == 0 ? texture!.width : self.size.x
      let height = self.size.y == 0 ? texture!.height : self.size.y
      game.r.drawTexture(
        resource: self.texture!, x: worldPosition.x, y: worldPosition.y,
        width: width, height: height,
        rotation: worldRotation.converted(to: .degrees).value,
        origin: self.origin,
        blendMode: self.blendMode,
        tint: self.tint)
    } else {
      if self.size.x == 0 || self.size.y == 0 {
        return
      }
      //TODO: This should always draw a texture, so scale/rotation/skew can still be applied
      game.r.drawRect(
        x: worldPosition.x, y: worldPosition.y, width: Float(self.size.x),
        height: Float(self.size.y), tint: self.tint)
    }
  }

  /// [Internal] Is the method that is called from the main gameloop to update the entity.
  /// Always calls ``update`` before updating children.
  func _update(delta: Double) {
    update(delta: delta)
    self.sprite?.update(delta: delta)
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

  func _input(keys: Keys.State, game: Game) {
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
  func input(keys: Keys.State, game: Game) {}

  /// [Internal] Is the method that is called when its time to destroy the entity.
  /// Always calls ``destroy`` before destroying children.
  func _destroy() {
    World.shared.remove(self)
    destroy()
    self.children.forEach { child in
      child._destroy()
    }

    //TODO: This feels hacky
    self.parent?.children.removeAll { $0.id == self.id }
    self.scene?.children.removeAll { $0.id == self.id }
  }

  /// Called when the entity should be destroyed.
  /// Always called after `draw` and `update` and only on entities where ``alive`` is false.
  func destroy() {}

  /// [Internal] Is the method that is called from the main gameloop to clean up the entity.
  func _cleanup() {
    self.children.removeAll { $0.shouldDestroy }
    self.children.forEach { child in
      child._cleanup()
    }
    if shouldDestroy {
      _destroy()
    }
  }

  var isOverlapping: Bool = false
  func _onCollisionStart(with: Entity) {
    isOverlapping = true
    onCollisionStart(with: with)
  }
  func onCollisionStart(with: Entity) {}

  func _onCollisionEnd(with: Entity) {
    isOverlapping = false
    onCollisionEnd(with: with)
  }
  func onCollisionEnd(with: Entity) {}

  func allocationSize() -> Int {
    // return malloc_size(Unmanaged.passUnretained(self).toOpaque())
    return class_getInstanceSize(type(of: self)) + children.reduce(0, { $0 + $1.allocationSize() })
  }
}
