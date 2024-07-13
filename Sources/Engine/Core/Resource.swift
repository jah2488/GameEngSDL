import CSDL3

protocol Resource: Hashable {
  var id: UInt64 { get }
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
