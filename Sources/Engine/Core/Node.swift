protocol Node {
  var id: UInt64 { get }
  var parent: Node? { get set }
  var children: [Node] { get set }
}
