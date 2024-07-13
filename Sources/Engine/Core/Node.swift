protocol Node {
  var id: UInt64 { get }
  var children: [Node] { get set }
}
