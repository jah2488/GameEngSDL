final class InputMap {
  static let shared = InputMap()

  var actions: [String: InputAction] = [:]

  func addDefaultBindings() {
    add(action: InputAction(name: "up", keys: [.w, .dpadUpBtn]))
    add(action: InputAction(name: "down", keys: [.s, .dpadDownBtn]))
    add(action: InputAction(name: "left", keys: [.a, .dpadLeftBtn]))
    add(action: InputAction(name: "right", keys: [.d, .dpadRightBtn]))
    add(action: InputAction(name: "fire", keys: [.space, .southBtn]))
    add(action: InputAction(name: "pause", keys: [.escape, .startBtn]))
  }

  func add(action: InputAction) {
    actions[action.name] = action
  }

  func get(name: String) -> InputAction? {
    return actions[name]
  }

  func getActions(for keyToFind: Keys.Key) -> [InputAction] {
    return actions.values.filter { action in
      action.keys.contains(where: { key in
        key == keyToFind
      })
    }
  }

  func remove(name: String) {
    actions.removeValue(forKey: name)
  }
}

struct InputEvent {
  var action: InputAction
  var state: Keys.KeyState

  var name: String {
    return action.name
  }

  func `is`(_ name: String) -> Bool {
    self.name == name
  }

  func `is`(_ name: String, and: Keys.KeyState) -> Bool {
    self.name == name && self.state == state
  }

  var isPressed: Bool {
    return state == .down
  }

  var isReleased: Bool {
    return state == .released
  }

}

struct InputAction {
  var name: String
  var keys: [Keys.Key]

  init(name: String, keys: [Keys.Key]) {
    self.name = name
    self.keys = keys
  }
}

// Name: String, [keys], optional: (pressed, released, held)
