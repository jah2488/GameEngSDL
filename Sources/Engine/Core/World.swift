struct Weak<T: AnyObject> {
  weak var value: T?
}
struct World {
  static var shared = World()

  let gravity: Double = 9.8
  var width: Int = 800
  var height: Int = 600

  var a: Audio?
  var r: RendererManager?
  var m: Mouse = Mouse(0, 0)

  mutating func load(from: Game) {
    self.width = from.width
    self.height = from.height
    self.a = from.a
    self.r = from.r
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

  func mouseOverRect(_ rect: Rect<Float>) -> Bool {
    return rect.left < self.m.x && rect.right > self.m.x && rect.top < self.m.y
      && rect.bottom > self.m.y
  }

}
