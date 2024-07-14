import Foundation

protocol Scene {
  var id: UUID { get }
  var name: String { get set }

  var nodes: [Node] { get set }
  func load()
  func unload()
  func start(game: Game)
  func draw(game: Game)
  func update(delta: Double)
  func input(keys: Keys.State, game: Game)
}
