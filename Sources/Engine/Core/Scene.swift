protocol Scene {
  var id: UInt64 { get }
  var name: String { get set }

  var nodes: [Node] { get set }
  func load()
  func unload()
  func start(game: Game)
  func draw(game: Game)
  func update(delta: Float)
  func input(keys: Keys.State, game: Game)
}
