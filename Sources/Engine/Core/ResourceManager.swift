protocol ResourceManager {
  associatedtype Resource: Hashable
  func load(resource: Resource)
  func unload(resource: Resource)
  func get(resource: Resource) -> Resource?
  func get(id: UInt64) -> Resource?
  func clear()
}
