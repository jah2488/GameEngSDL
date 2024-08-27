struct Zipper<T> {
  var left: [T]
  var current: T
  var right: [T]

  func all() -> [T] {
    return left + [current] + right
  }

  mutating func next() {
    if right.isEmpty {
      return
    }
    var newRight = right
    let newCurrent = newRight.removeFirst()
    self.left = left + [current]
    self.current = newCurrent
    self.right = newRight
  }

  mutating func addNext(_ value: T) {
    right.insert(value, at: 0)
  }

  mutating func addPrevious(_ value: T) {
    left.append(value)
  }

  mutating func append(_ value: T) {
    right.append(value)
  }

  mutating func prepend(_ value: T) {
    left.insert(value, at: 0)
  }
}
