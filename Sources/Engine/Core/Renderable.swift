protocol Renderable {
  //TODO: This is cool (protocols), but there needs to be a base class that is inerited from for objects this complex.
  var relative: Bool { get }
  func start(game: Game)
  func draw(game: Game)
  func update(delta: Double)
  func input(keys: Keys.State, game: Game)  // TODO: Replace with internal Event
}
