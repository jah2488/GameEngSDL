import CSDL3
import Foundation

protocol Resource: Hashable {
  var id: UUID { get }
  var type: ResourceType { get }
  var path: String { get }
  var texture: OpaquePointer! { get }
}

enum ResourceType {
  case texture
  case shader
  case font
  case sound
  case music
}
