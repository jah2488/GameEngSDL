import CSDL3

struct Mouse {
  var x: Float = 0
  var y: Float = 0
  var dx: Float = 0
  var dy: Float = 0
  var scrollX: Float = 0
  var scrollY: Float = 0
  var left: Keys.KeyState = .up
  var right: Keys.KeyState = .up
  init(_ x: Float = 0, _ y: Float = 0) {
    self.x = x
    self.y = y
  }
}
class Keys {
  public enum KeyState: Equatable {
    case down
    case released
    case up  // not pressed or released in the last frame
    case at(_ val: Int16)
  }

  struct State {
    var mouse: Mouse = Mouse()
    var keys: [Key: KeyState] = [:]
    var modifiers: [Key: KeyState] = [:]
    func empty() -> Bool {
      return keys.allSatisfy({ key in
        key.value == .up
      }) && modifiers.isEmpty && mouse.left == .up && mouse.right == .up
    }
    mutating func resetReleased() {
      keys = keys.mapValues { $0 == .released ? .up : $0 }
      mouse.left = mouse.left == .released ? .up : mouse.left
      mouse.right = mouse.right == .released ? .up : mouse.right
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
    case leftshift
    case rightshift
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
    // controller buttons
    case southBtn
    case eastBtn
    case westBtn
    case northBtn
    case backBtn
    case guideBtn
    case startBtn
    case leftStickBtn
    case rightStickBtn
    case leftShoulderBtn
    case rightShoulderBtn
    case dpadUpBtn
    case dpadDownBtn
    case dpadLeftBtn
    case dpadRightBtn
    case misc1Btn
    case rightPaddle1Btn
    case leftPaddle1Btn
    case rightPaddle2Btn
    case leftPaddle2Btn
    case touchpadBtn
    case misc2Btn
    case misc3Btn
    case misc4Btn
    case misc5Btn
    case misc6Btn
    case maxBtn
    case leftStickXAxis
    case leftStickYAxis
    case rightStickXAxis
    case rightStickYAxis
    case leftTriggerAxis
    case rightTriggerAxis
    case maxAxis
  }

  static func button(from sdlButton: SDL_GamepadButton) -> Key {
    switch sdlButton.rawValue {
    case -1: return Key.none  // SDL_CONTROLLER_BUTTON_INVALID
    case 0: return Key.southBtn  // SDL_GAMEPAD_BUTTON_SOUTH,           /* Bottom face button (e.g. Xbox A button) */
    case 1: return Key.eastBtn  // SDL_GAMEPAD_BUTTON_EAST,            /* Right face button (e.g. Xbox B button) */
    case 2: return Key.westBtn  // SDL_GAMEPAD_BUTTON_WEST,            /* Left face button (e.g. Xbox X button) */
    case 3: return Key.northBtn  // SDL_GAMEPAD_BUTTON_NORTH,           /* Top face button (e.g. Xbox Y button) */
    case 4: return Key.backBtn  // SDL_GAMEPAD_BUTTON_BACK,
    case 5: return Key.guideBtn  // SDL_GAMEPAD_BUTTON_GUIDE,
    case 6: return Key.startBtn  // SDL_GAMEPAD_BUTTON_START,
    case 7: return Key.leftStickBtn  // SDL_GAMEPAD_BUTTON_LEFT_STICK,
    case 8: return Key.rightStickBtn  // SDL_GAMEPAD_BUTTON_RIGHT_STICK,
    case 9: return Key.leftShoulderBtn  // SDL_GAMEPAD_BUTTON_LEFT_SHOULDER,
    case 10: return Key.rightShoulderBtn  // SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER,
    case 11: return Key.dpadUpBtn  // SDL_GAMEPAD_BUTTON_DPAD_UP,
    case 12: return Key.dpadDownBtn  // SDL_GAMEPAD_BUTTON_DPAD_DOWN,
    case 13: return Key.dpadLeftBtn  // SDL_GAMEPAD_BUTTON_DPAD_LEFT,
    case 14: return Key.dpadRightBtn  // SDL_GAMEPAD_BUTTON_DPAD_RIGHT,
    case 15: return Key.misc1Btn  // SDL_GAMEPAD_BUTTON_MISC1,           /* Additional button (e.g. Xbox Series X share button, PS5 microphone button, Nintendo Switch Pro capture button, Amazon Luna microphone button, Google Stadia capture button) */
    case 16: return Key.rightPaddle1Btn  // SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1,   /* Upper or primary paddle, under your right hand (e.g. Xbox Elite paddle P1) */
    case 17: return Key.leftPaddle1Btn  // SDL_GAMEPAD_BUTTON_LEFT_PADDLE1,    /* Upper or primary paddle, under your left hand (e.g. Xbox Elite paddle P3) */
    case 18: return Key.rightPaddle2Btn  // SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2,   /* Lower or secondary paddle, under your right hand (e.g. Xbox Elite paddle P2) */
    case 19: return Key.leftPaddle2Btn  // SDL_GAMEPAD_BUTTON_LEFT_PADDLE2,    /* Lower or secondary paddle, under your left hand (e.g. Xbox Elite paddle P4) */
    case 20: return Key.touchpadBtn  // SDL_GAMEPAD_BUTTON_TOUCHPAD,        /* PS4/PS5 touchpad button */
    case 21: return Key.misc2Btn  // SDL_GAMEPAD_BUTTON_MISC2,           /* Additional button */
    case 22: return Key.misc3Btn  // SDL_GAMEPAD_BUTTON_MISC3,           /* Additional button */
    case 23: return Key.misc4Btn  // SDL_GAMEPAD_BUTTON_MISC4,           /* Additional button */
    case 24: return Key.misc5Btn  // SDL_GAMEPAD_BUTTON_MISC5,           /* Additional button */
    case 25: return Key.misc6Btn  // SDL_GAMEPAD_BUTTON_MISC6,           /* Additional button */
    case 26: return Key.maxBtn  // SDL_GAMEPAD_BUTTON_MAX
    default:
      log.log("Unknown button: \(sdlButton)")
      return Key.none
    }
  }

  static func axis(from sdlAxis: SDL_GamepadAxis) -> Key {
    switch sdlAxis.rawValue {
    case -1: return Key.none  // SDL_CONTROLLER_AXIS_INVALID
    case 0: return Key.leftStickXAxis  // SDL_GAMEPAD_AXIS_LEFTX,            /* Left stick X axis */
    case 1: return Key.leftStickYAxis  // SDL_GAMEPAD_AXIS_LEFTY,            /* Left stick Y axis */
    case 2: return Key.rightStickXAxis  // SDL_GAMEPAD_AXIS_RIGHTX,           /* Right stick X axis */
    case 3: return Key.rightStickYAxis  // SDL_GAMEPAD_AXIS_RIGHTY,           /* Right stick Y axis */
    case 4: return Key.leftTriggerAxis  // SDL_GAMEPAD_AXIS_TRIGGERLEFT,      /* Left trigger */
    case 5: return Key.rightTriggerAxis  // SDL_GAMEPAD_AXIS_TRIGGERRIGHT,     /* Right trigger */
    case 6: return Key.maxAxis  // SDL_GAMEPAD_AXIS_MAX
    default:
      log.log("Unknown axis: \(sdlAxis)")
      return Key.none
    }
  }

  static func key(from sdlKey: UInt32) -> Key {
    switch sdlKey {
    case SDLK_LSHIFT: return Key.leftshift
    case SDLK_RSHIFT: return Key.rightshift
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
      log.log("Unknown key: \(sdlKey)")
      return Key.none
    }
  }
}
