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
