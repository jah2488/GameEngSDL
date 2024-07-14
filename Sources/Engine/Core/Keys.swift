import CSDL3

class Keys {
  enum KeyState {
    case down
    case released
    case up  // not pressed or released in the last frame
  }
  struct State {
    var keys: [Key: KeyState] = [:]
    var modifiers: [Key: KeyState] = [:]
    func empty() -> Bool {
      return keys.allSatisfy({ key in
        key.value == .up
      }) && modifiers.isEmpty
    }
    mutating func resetReleased() {
      keys = keys.mapValues { $0 == .released ? .up : $0 }
    }
    func isPressed(_ key: Key) -> Bool {
      (keys[key] == .down)
    }
    func isReleased(_ key: Key) -> Bool {
      (keys[key] == .released)
    }
    func isModifierDown(_ key: Key) -> Bool {
      modifiers[key] == .down
    }
  }
  enum Key {
    case returnKey
    case escape
    case backspace
    case tab
    case space
    case exclaim
    case dblApostrophe
    case hash
    case dollar
    case percent
    case ampersand
    case leftparen
    case rightparen
    case apostrophe
    case asterisk
    case plus
    case minus
    case period
    case slash
    case zero
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case colon
    case semicolon
    case lessthan
    case equal
    case greaterthan
    case question
    case comma
    case at
    case leftbracket
    case backslash
    case rightbracket
    case caret
    case underscore
    case backtick
    case a
    case b
    case c
    case d
    case e
    case f
    case g
    case h
    case i
    case j
    case k
    case l
    case m
    case n
    case o
    case p
    case q
    case r
    case s
    case t
    case u
    case v
    case w
    case x
    case y
    case z
    case leftbrace
    case pipe
    case rightbrace
    case tilde
    case delete
    case capslock
    case none
  }
  static func key(from sdlKey: UInt32) -> Key {
    switch sdlKey {
    case SDLK_RETURN: return Key.returnKey
    case SDLK_ESCAPE: return Key.escape
    case SDLK_BACKSPACE: return Key.backspace
    case SDLK_TAB: return Key.tab
    case SDLK_SPACE: return Key.space
    case SDLK_EXCLAIM: return Key.exclaim
    case SDLK_DBLAPOSTROPHE: return Key.dblApostrophe
    case SDLK_HASH: return Key.hash
    case SDLK_DOLLAR: return Key.dollar
    case SDLK_PERCENT: return Key.percent
    case SDLK_AMPERSAND: return Key.ampersand
    case SDLK_APOSTROPHE: return Key.apostrophe
    case SDLK_LEFTPAREN: return Key.leftparen
    case SDLK_RIGHTPAREN: return Key.rightparen
    case SDLK_ASTERISK: return Key.asterisk
    case SDLK_PLUS: return Key.plus
    case SDLK_COMMA: return Key.comma
    case SDLK_MINUS: return Key.minus
    case SDLK_PERIOD: return Key.period
    case SDLK_SLASH: return Key.slash
    case SDLK_0: return Key.zero
    case SDLK_1: return Key.one
    case SDLK_2: return Key.two
    case SDLK_3: return Key.three
    case SDLK_4: return Key.four
    case SDLK_5: return Key.five
    case SDLK_6: return Key.six
    case SDLK_7: return Key.seven
    case SDLK_8: return Key.eight
    case SDLK_9: return Key.nine
    case SDLK_COLON: return Key.colon
    case SDLK_SEMICOLON: return Key.semicolon
    case SDLK_LESS: return Key.lessthan
    case SDLK_EQUALS: return Key.equal
    case SDLK_GREATER: return Key.greaterthan
    case SDLK_QUESTION: return Key.question
    case SDLK_AT: return Key.at
    case SDLK_LEFTBRACKET: return Key.leftbracket
    case SDLK_BACKSLASH: return Key.backslash
    case SDLK_RIGHTBRACKET: return Key.rightbracket
    case SDLK_CARET: return Key.caret
    case SDLK_UNDERSCORE: return Key.underscore
    case SDLK_GRAVE: return Key.backtick
    case SDLK_A: return Key.a
    case SDLK_B: return Key.b
    case SDLK_C: return Key.c
    case SDLK_D: return Key.d
    case SDLK_E: return Key.e
    case SDLK_F: return Key.f
    case SDLK_G: return Key.g
    case SDLK_H: return Key.h
    case SDLK_I: return Key.i
    case SDLK_J: return Key.j
    case SDLK_K: return Key.k
    case SDLK_L: return Key.l
    case SDLK_M: return Key.m
    case SDLK_N: return Key.n
    case SDLK_O: return Key.o
    case SDLK_P: return Key.p
    case SDLK_Q: return Key.q
    case SDLK_R: return Key.r
    case SDLK_S: return Key.s
    case SDLK_T: return Key.t
    case SDLK_U: return Key.u
    case SDLK_V: return Key.v
    case SDLK_W: return Key.w
    case SDLK_X: return Key.x
    case SDLK_Y: return Key.y
    case SDLK_Z: return Key.z
    case SDLK_LEFTBRACE: return Key.leftbrace
    case SDLK_PIPE: return Key.pipe
    case SDLK_RIGHTBRACE: return Key.rightbrace
    case SDLK_TILDE: return Key.tilde
    default:
      print("Unknown key: \(sdlKey)")
      return Key.none
    }
  }
}
