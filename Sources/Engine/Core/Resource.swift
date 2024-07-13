import CSDL3

protocol Resource: Hashable {
  var id: UInt64 { get }
  var type: ResourceType { get }
  var path: String { get }
  var surface: UnsafeMutablePointer<SDL_Surface> { get }  // Convert this to generic constraint to be renderer agnostic
}

enum ResourceType {
  case texture
  case shader
  case font
  case sound
  case music
}
