protocol Renderable {
  init()
  func start(game: Game)
  func draw(game: Game)
  func update(delta: Float)
  func input(keys: Keys.State)  // TODO: Replace with internal Event
}
