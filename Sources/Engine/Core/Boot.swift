import CSDL3
import CSDL3_image
import CSDL3_mixer
import CSDL3_ttf
import Foundation

//TODO: Move this to a more appropriate location, and let log levels be set when the game is about to be run
let log = Logger(.warning)

class Boot {
  var name: String
  var width: Int32
  var height: Int32
  var scale: (x: Double, y: Double) = (1, 1)

  var window: OpaquePointer!
  var renderer: OpaquePointer!

  var windowFlags: UInt64 = SDL_WINDOW_HIGH_PIXEL_DENSITY | SDL_WINDOW_RESIZABLE

  init(_name: String = "Game", _width: Int32 = 800, _height: Int32 = 600) {
    self.name = _name
    self.width = _width
    self.height = _height

    SDL_Init(UInt32(SDL_INIT_VIDEO | SDL_INIT_GAMEPAD))
    IMG_Init(Int32(IMG_INIT_PNG.rawValue))
    TTF_Init()
    Mix_Init(Int32(MIX_INIT_MP3.rawValue))

    var count: Int32 = 0
    SDL_GetGamepads(&count)
    var gamepad: OpaquePointer!
    for i: UInt32 in UInt32(0)..<(UInt32(10)) {  // Seems reasonable to only look for 10 gamepads
      gamepad = SDL_OpenGamepad(UInt32(i))
      if gamepad != nil {
        break
      }
    }
    if SDL_GamepadConnected(gamepad) == SDL_TRUE {
      log.log("Gamepad connected")
    } else {
      log.log("No Gamepad connected")
    }

    var spec = SDL_AudioSpec()
    spec.freq = 44100
    spec.channels = 2
    spec.format = UInt16(MIX_DEFAULT_FORMAT)
    Mix_OpenAudio(1, &spec)
    if Mix_OpenAudio(0, &spec) < 0 {
      fatalError("Failed to open audio: \(String(cString: SDL_GetError()))")
    } else {
      Mix_QuerySpec(&spec.freq, &spec.format, &spec.channels)
      log.log(
        "Opened audio at \(spec.freq) Hz \(spec.format&0xFF) bit \((spec.channels > 2) ? "surround" : (spec.channels > 1) ? "stereo" : "mono"))"
      )
    }

    let _ = SDL_GetDesktopDisplayMode(SDL_GetPrimaryDisplay())

    self.window = SDL_CreateWindow(name, width, height, windowFlags)
    self.renderer = SDL_CreateRenderer(window, nil)
    // SDL_SetRenderDawBlendMode(renderer, SDL_BLENDMODE_BLEND)

    SDL_ShowWindow(window)
    SDL_GetWindowSizeInPixels(window, &width, &height)
    var rect = SDL_Rect(x: 0, y: 0, w: width, h: height)
    SDL_GetRenderViewport(renderer, &rect)

    SDL_SetRenderLogicalPresentation(
      renderer, _width, _height, SDL_LOGICAL_PRESENTATION_STRETCH, SDL_SCALEMODE_NEAREST)

    var displayRect = SDL_Rect(x: 0, y: 0, w: 0, h: 0)
    SDL_GetDisplayBounds(SDL_GetPrimaryDisplay(), &displayRect)

    print("Display size: \(displayRect.w)x\(displayRect.h)")
    print("Window size: \(width)x\(height)")
    print("Logical size: \(_width)x\(_height)")
    print("Renderer size: \(rect.w)x\(rect.h)")

    // TODO: Move this to use standard resource loading, and it should be defined as part of game setup
    let icon = IMG_Load("GameEngSDL_GameEngSDL.bundle/Assets/icon.png")
    SDL_SetWindowIcon(window, icon)
    SDL_DestroySurface(icon)

    SDL_SetRenderScale(renderer, 1, 1)
    SDL_SetWindowSize(window, _width * 4, _height * 4)
    SDL_SetWindowPosition(window, 0, 0)

    self.width = _width
    self.height = _height
  }

  func withSDLRect(_ body: (inout SDL_Rect) -> Void) -> SDL_Rect {
    // let testRect = withSDLRect { rect in
    //   SDL_GetRenderViewport(renderer, &rect)
    // }

    // print("Rect: \(rect.w)x\(rect.h)")
    // print("testRect: \(testRect.w)x\(testRect.h)")
    var rect = SDL_Rect(x: 0, y: 0, w: 0, h: 0)
    var _ = body(&rect)
    return rect
  }

  deinit {
    Mix_CloseAudio()
    log.log("Deinit Boot")
    Mix_Quit()
    TTF_Quit()
    IMG_Quit()
    SDL_Quit()
  }

  @inlinable
  func mouseMask(_ button: Int32) -> UInt32 {
    return ((1 << ((button) - 1)))
  }

  func run(game: Game) {
    var logical_presentation_index = 0
    let presentations = [
      SDL_LOGICAL_PRESENTATION_DISABLED,
      SDL_LOGICAL_PRESENTATION_STRETCH,
      SDL_LOGICAL_PRESENTATION_LETTERBOX,
      SDL_LOGICAL_PRESENTATION_OVERSCAN,
      SDL_LOGICAL_PRESENTATION_INTEGER_SCALE,
    ]
    var now = SDL_GetPerformanceCounter()
    var delta: Double = 0
    game._start()
    log.start(time: Int(now))
    var keyStates = Keys.State()
    let last_ticks = SDL_GetTicks()
    while game.isRunning {
      keyStates.resetReleased()
      game.mouse.left == .released ? game.mouse.left = .up : ()
      game.mouse.right == .released ? game.mouse.right = .up : ()
      let last = now
      now = SDL_GetPerformanceCounter()
      delta = Double((now - last) * 1000 / SDL_GetPerformanceFrequency()) * 0.001
      log.loop(ticks: Int(SDL_GetTicks()), time: Int(now), delta: delta)
      var event = SDL_Event()
      while SDL_PollEvent(&event) != 0 {
        switch event.type {
        case SDL_EVENT_MOUSE_WHEEL.rawValue:
          game.mouse.scrollX = event.wheel.x
          game.mouse.scrollY = event.wheel.y
          break
        case SDL_EVENT_MOUSE_MOTION.rawValue:
          game.mouse.x = (event.motion.x) / Float(scale.x)
          game.mouse.y = (event.motion.y) / Float(scale.y)
          keyStates.mouse.x = event.motion.x
          keyStates.mouse.y = event.motion.y
          keyStates.mouse.dx = event.motion.xrel
          keyStates.mouse.dy = event.motion.yrel
        case SDL_EVENT_MOUSE_BUTTON_DOWN.rawValue:
          if event.motion.state & mouseMask(1) == 1 {
            if event.motion.state & mouseMask(2) != 0 {
              keyStates.mouse.right = .down
              game.mouse.right = .down
            } else {
              keyStates.mouse.left = .down
              game.mouse.left = .down
            }
          }
          break
        case SDL_EVENT_MOUSE_BUTTON_UP.rawValue:
          if event.motion.state & mouseMask(1) == 1 {
            if event.motion.state & mouseMask(2) != 0 {
              keyStates.mouse.right = .released
              game.mouse.right = .released
            } else {
              keyStates.mouse.left = .released
              game.mouse.left = .released
            }
          }
          break
        case SDL_EVENT_GAMEPAD_BUTTON_DOWN.rawValue:
          keyStates.keys[Keys.button(from: SDL_GamepadButton.init(Int32(event.gbutton.button)))] =
            .down
          break
        case SDL_EVENT_GAMEPAD_BUTTON_UP.rawValue:
          keyStates.keys[Keys.button(from: SDL_GamepadButton.init(Int32(event.gbutton.button)))] =
            .released
          break
        case SDL_EVENT_GAMEPAD_AXIS_MOTION.rawValue:
          keyStates.keys[Keys.axis(from: SDL_GamepadAxis.init(Int32(event.gaxis.axis)))] = .at(
            event.gaxis.value)
          break
        case SDL_EVENT_KEY_DOWN.rawValue:
          keyStates.keys[Keys.key(from: event.key.key)] = .down
          break
        case SDL_EVENT_KEY_UP.rawValue:
          keyStates.keys[Keys.key(from: event.key.key)] = .released

          if event.key.key == SDLK_ESCAPE {
            SDL_SetRenderLogicalPresentation(
              renderer, self.width, self.height, presentations[logical_presentation_index],
              SDL_SCALEMODE_NEAREST)
            print("Logical Presentation: \(logical_presentation_index)")
            if logical_presentation_index == presentations.count - 1 {
              logical_presentation_index = 0
            } else {
              logical_presentation_index += 1
            }
          }
          break
        case SDL_EVENT_WINDOW_DESTROYED.rawValue:
          game._stop()
          break
        case SDL_EVENT_QUIT.rawValue:
          game._stop()
          break
        case SDL_EVENT_WINDOW_MOVED.rawValue:
          break
        case SDL_EVENT_WINDOW_RESIZED.rawValue:
          log.log("window resized to \(event.window.data1), \(event.window.data2)")
          let oldWidth = self.width
          let oldHeight = self.height
          var rect = SDL_Rect(x: 0, y: 0, w: self.width, h: self.height)
          SDL_GetRenderViewport(renderer, &rect)
          SDL_GetWindowSize(window, &self.width, &self.height)
          scale = (
            x: Double(self.width) / Double(oldWidth), y: Double(self.height) / Double(oldHeight)
          )
          game.width = Int(rect.w)
          game.height = Int(rect.h)
          break
        default:
          break
        }
      }

      //Send pressed data to game scenes and nodes
      if !keyStates.empty() {
        log.indent("_input")
        game._input(keys: keyStates)
        log.dedent()
      }
      if SDL_GetTicks() - last_ticks < 1000 / 10 {
        continue
      }

      log.indent("_update")
      game._update(delta: delta)
      log.dedent()

      let c = game.clearColor
      SDL_SetRenderDrawColor(renderer, c.r, c.g, c.b, c.a)
      SDL_RenderClear(renderer)

      log.indent("_draw")
      game._draw()
      log.dedent()

      SDL_RenderPresent(renderer)
      game._cleanup()
    }
  }
}
