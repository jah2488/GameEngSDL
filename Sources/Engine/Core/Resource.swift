import Foundation

protocol Resource: Hashable {
  var id: UUID { get }
  var type: ResourceType { get }
  var path: String { get }
  var texture: OpaquePointer! { get }
  var width: Float { get set }
  var height: Float { get set }
}

enum ResourceType {
  case texture
  case shader
  case font
  case sound
  case music
}
