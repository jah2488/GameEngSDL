import Foundation

protocol Node {
  var id: UUID { get }
  var parent: Node? { get set }
  var children: [Node] { get set }
}
