import CSDL3
import CSDL3_image
import CSDL3_mixer
import CSDL3_ttf
import Foundation

let log = Logger(.error)

class Boot {
  var name: String
  var width: Int32
  var height: Int32

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

    SDL_ShowWindow(window)
    SDL_GetWindowSizeInPixels(window, &width, &height)
    var rect = SDL_Rect(x: 0, y: 0, w: width, h: height)
    SDL_GetRenderViewport(renderer, &rect)

    SDL_SetRenderLogicalPresentation(
      renderer, 800, 600, SDL_LOGICAL_PRESENTATION_INTEGER_SCALE, SDL_SCALEMODE_NEAREST)
    width = Int32(rect.w)
    height = Int32(rect.h)

    let icon = IMG_Load("GameEngSDL_GameEngSDL.bundle/Assets/icon.png")
    SDL_SetWindowIcon(window, icon)
    SDL_DestroySurface(icon)

    SDL_SetRenderScale(renderer, 1, 1)
  }

  deinit {
    Mix_CloseAudio()
    log.log("Deinit Boot")
    Mix_Quit()
    TTF_Quit()
    IMG_Quit()
    SDL_Quit()
  }

  func run(game: Game) {
    var now = SDL_GetPerformanceCounter()
    var delta: Double = 0
    game._start()
    log.start(time: Int(now))
    var keyStates = Keys.State()
    while game.isRunning {
      keyStates.resetReleased()
      let last = now
      now = SDL_GetPerformanceCounter()
      delta = Double((now - last) * 1000 / SDL_GetPerformanceFrequency()) * 0.001
      log.loop(ticks: Int(SDL_GetTicks()), time: Int(now), delta: delta)
      var event = SDL_Event()
      while SDL_PollEvent(&event) != 0 {
        switch event.type {
        case SDL_EVENT_KEY_DOWN.rawValue:
          keyStates.keys[Keys.key(from: event.key.key)] = .down
          break
        case SDL_EVENT_KEY_UP.rawValue:
          keyStates.keys[Keys.key(from: event.key.key)] = .released
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
          var rect = SDL_Rect(x: 0, y: 0, w: self.width, h: self.height)
          SDL_GetRenderViewport(renderer, &rect)
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
    }
  }
}
