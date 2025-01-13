import CSDL3
import CSDL3_image
import CSDL3_mixer
import CSDL3_ttf
import Foundation

//TODO: Move this to a more appropriate location, and let log levels be set when the game is about to be run
let log = Logger(.warning)

enum SDLEventType: UInt32 {
  case SDL_EVENT_FIRST = 0  // Unused (do not remove)

  // Application events
  case SDL_EVENT_QUIT = 0x100  // User-requested quit

  // These application events have special meaning on iOS and Android, see README-ios.md and README-android.md for details
  case SDL_EVENT_TERMINATING  // The application is being terminated by the OS. This event must be handled in a callback set with SDL_AddEventWatch().
  // Called on iOS in applicationWillTerminate()
  // Called on Android in onDestroy()
  case SDL_EVENT_LOW_MEMORY  // The application is low on memory, free memory if possible. This event must be handled in a callback set with SDL_AddEventWatch().
  // Called on iOS in applicationDidReceiveMemoryWarning()
  // Called on Android in onTrimMemory()
  case SDL_EVENT_WILL_ENTER_BACKGROUND  // The application is about to enter the background. This event must be handled in a callback set with SDL_AddEventWatch().
  // Called on iOS in applicationWillResignActive()
  // Called on Android in onPause()
  case SDL_EVENT_DID_ENTER_BACKGROUND  // The application did enter the background and may not get CPU for some time. This event must be handled in a callback set with SDL_AddEventWatch().
  // Called on iOS in applicationDidEnterBackground()
  // Called on Android in onPause()
  case SDL_EVENT_WILL_ENTER_FOREGROUND  // The application is about to enter the foreground. This event must be handled in a callback set with SDL_AddEventWatch().
  // Called on iOS in applicationWillEnterForeground()
  // Called on Android in onResume()
  case SDL_EVENT_DID_ENTER_FOREGROUND  // The application is now interactive. This event must be handled in a callback set with SDL_AddEventWatch().
  // Called on iOS in applicationDidBecomeActive()
  // Called on Android in onResume()

  case SDL_EVENT_LOCALE_CHANGED  // The user's locale preferences have changed.

  case SDL_EVENT_SYSTEM_THEME_CHANGED  // The system theme changed

  // Display events
  // 0x150 was SDL_DISPLAYEVENT, reserve the number for sdl2-compat
  case SDL_EVENT_DISPLAY_ORIENTATION = 0x151  // Display orientation has changed to data1
  case SDL_EVENT_DISPLAY_ADDED  // Display has been added to the system
  case SDL_EVENT_DISPLAY_REMOVED  // Display has been removed from the system
  case SDL_EVENT_DISPLAY_MOVED  // Display has changed position
  case SDL_EVENT_DISPLAY_DESKTOP_MODE_CHANGED  // Display has changed desktop mode
  case SDL_EVENT_DISPLAY_CURRENT_MODE_CHANGED  // Display has changed current mode
  case SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED  // Display has changed content scale

  // Window events
  // 0x200 was SDL_WINDOWEVENT, reserve the number for sdl2-compat
  // 0x201 was SDL_EVENT_SYSWM, reserve the number for sdl2-compat
  case SDL_EVENT_WINDOW_SHOWN = 0x202  // Window has been shown
  case SDL_EVENT_WINDOW_HIDDEN  // Window has been hidden
  case SDL_EVENT_WINDOW_EXPOSED  // Window has been exposed and should be redrawn, and can be redrawn directly from event watchers for this event
  case SDL_EVENT_WINDOW_MOVED  // Window has been moved to data1, data2
  case SDL_EVENT_WINDOW_RESIZED  // Window has been resized to data1xdata2
  case SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED  // The pixel size of the window has changed to data1xdata2
  case SDL_EVENT_WINDOW_METAL_VIEW_RESIZED  // The pixel size of a Metal view associated with the window has changed
  case SDL_EVENT_WINDOW_MINIMIZED  // Window has been minimized
  case SDL_EVENT_WINDOW_MAXIMIZED  // Window has been maximized
  case SDL_EVENT_WINDOW_RESTORED  // Window has been restored to normal size and position
  case SDL_EVENT_WINDOW_MOUSE_ENTER  // Window has gained mouse focus
  case SDL_EVENT_WINDOW_MOUSE_LEAVE  // Window has lost mouse focus
  case SDL_EVENT_WINDOW_FOCUS_GAINED  // Window has gained keyboard focus
  case SDL_EVENT_WINDOW_FOCUS_LOST  // Window has lost keyboard focus
  case SDL_EVENT_WINDOW_CLOSE_REQUESTED  // The window manager requests that the window be closed
  case SDL_EVENT_WINDOW_HIT_TEST  // Window had a hit test that wasn't SDL_HITTEST_NORMAL
  case SDL_EVENT_WINDOW_ICCPROF_CHANGED  // The ICC profile of the window's display has changed
  case SDL_EVENT_WINDOW_DISPLAY_CHANGED  // Window has been moved to display data1
  case SDL_EVENT_WINDOW_DISPLAY_SCALE_CHANGED  // Window display scale has been changed
  case SDL_EVENT_WINDOW_SAFE_AREA_CHANGED  // The window safe area has been changed
  case SDL_EVENT_WINDOW_OCCLUDED  // The window has been occluded
  case SDL_EVENT_WINDOW_ENTER_FULLSCREEN  // The window has entered fullscreen mode
  case SDL_EVENT_WINDOW_LEAVE_FULLSCREEN  // The window has left fullscreen mode
  case SDL_EVENT_WINDOW_DESTROYED  // The window with the associated ID is being or has been destroyed. If this message is being handled
  // in an event watcher, the window handle is still valid and can still be used to retrieve any userdata
  // associated with the window. Otherwise, the handle has already been destroyed and all resources
  // associated with it are invalid
  case SDL_EVENT_WINDOW_HDR_STATE_CHANGED  // Window HDR properties have changed

  // Keyboard events
  case SDL_EVENT_KEY_DOWN = 0x300  // Key pressed
  case SDL_EVENT_KEY_UP  // Key released
  case SDL_EVENT_TEXT_EDITING  // Keyboard text editing (composition)
  case SDL_EVENT_TEXT_INPUT  // Keyboard text input
  case SDL_EVENT_KEYMAP_CHANGED  // Keymap changed due to a system event such as an
  // input language or keyboard layout change.
  case SDL_EVENT_KEYBOARD_ADDED  // A new keyboard has been inserted into the system
  case SDL_EVENT_KEYBOARD_REMOVED  // A keyboard has been removed
  case SDL_EVENT_TEXT_EDITING_CANDIDATES  // Keyboard text editing candidates

  // Mouse events
  case SDL_EVENT_MOUSE_MOTION = 0x400  // Mouse moved
  case SDL_EVENT_MOUSE_BUTTON_DOWN  // Mouse button pressed
  case SDL_EVENT_MOUSE_BUTTON_UP  // Mouse button released
  case SDL_EVENT_MOUSE_WHEEL  // Mouse wheel motion
  case SDL_EVENT_MOUSE_ADDED  // A new mouse has been inserted into the system
  case SDL_EVENT_MOUSE_REMOVED  // A mouse has been removed

  // Joystick events
  case SDL_EVENT_JOYSTICK_AXIS_MOTION = 0x600  // Joystick axis motion
  case SDL_EVENT_JOYSTICK_BALL_MOTION  // Joystick trackball motion
  case SDL_EVENT_JOYSTICK_HAT_MOTION  // Joystick hat position change
  case SDL_EVENT_JOYSTICK_BUTTON_DOWN  // Joystick button pressed
  case SDL_EVENT_JOYSTICK_BUTTON_UP  // Joystick button released
  case SDL_EVENT_JOYSTICK_ADDED  // A new joystick has been inserted into the system
  case SDL_EVENT_JOYSTICK_REMOVED  // An opened joystick has been removed
  case SDL_EVENT_JOYSTICK_BATTERY_UPDATED  // Joystick battery level change
  case SDL_EVENT_JOYSTICK_UPDATE_COMPLETE  // Joystick update is complete

  // Gamepad events
  case SDL_EVENT_GAMEPAD_AXIS_MOTION = 0x650  // Gamepad axis motion
  case SDL_EVENT_GAMEPAD_BUTTON_DOWN  // Gamepad button pressed
  case SDL_EVENT_GAMEPAD_BUTTON_UP  // Gamepad button released
  case SDL_EVENT_GAMEPAD_ADDED  // A new gamepad has been inserted into the system
  case SDL_EVENT_GAMEPAD_REMOVED  // A gamepad has been removed
  case SDL_EVENT_GAMEPAD_REMAPPED  // The gamepad mapping was updated
  case SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN  // Gamepad touchpad was touched
  case SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION  // Gamepad touchpad finger was moved
  case SDL_EVENT_GAMEPAD_TOUCHPAD_UP  // Gamepad touchpad finger was lifted
  case SDL_EVENT_GAMEPAD_SENSOR_UPDATE  // Gamepad sensor was updated
  case SDL_EVENT_GAMEPAD_UPDATE_COMPLETE  // Gamepad update is complete
  case SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED  // Gamepad Steam handle has changed

  // Touch events
  case SDL_EVENT_FINGER_DOWN = 0x700
  case SDL_EVENT_FINGER_UP
  case SDL_EVENT_FINGER_MOTION

  // 0x800, 0x801, and 0x802 were the Gesture events from SDL2. Do not reuse these values! sdl2-compat needs them!

  // Clipboard events
  case SDL_EVENT_CLIPBOARD_UPDATE = 0x900  // The clipboard or primary selection changed

  // Drag and drop events
  case SDL_EVENT_DROP_FILE = 0x1000  // The system requests a file open
  case SDL_EVENT_DROP_TEXT  // text/plain drag-and-drop event
  case SDL_EVENT_DROP_BEGIN  // A new set of drops is beginning (NULL filename)
  case SDL_EVENT_DROP_COMPLETE  // Current set of drops is now complete (NULL filename)
  case SDL_EVENT_DROP_POSITION  // Position while moving over the window

  // Audio hotplug events
  case SDL_EVENT_AUDIO_DEVICE_ADDED = 0x1100  // A new audio device is available
  case SDL_EVENT_AUDIO_DEVICE_REMOVED  // An audio device has been removed.
  case SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED  // An audio device's format has been changed by the system.

  // Sensor events
  case SDL_EVENT_SENSOR_UPDATE = 0x1200  // A sensor was updated

  // Pressure-sensitive pen events
  case SDL_EVENT_PEN_PROXIMITY_IN = 0x1300  // Pressure-sensitive pen has become available
  case SDL_EVENT_PEN_PROXIMITY_OUT  // Pressure-sensitive pen has become unavailable
  case SDL_EVENT_PEN_DOWN  // Pressure-sensitive pen touched drawing surface
  case SDL_EVENT_PEN_UP  // Pressure-sensitive pen stopped touching drawing surface
  case SDL_EVENT_PEN_BUTTON_DOWN  // Pressure-sensitive pen button pressed
  case SDL_EVENT_PEN_BUTTON_UP  // Pressure-sensitive pen button released
  case SDL_EVENT_PEN_MOTION  // Pressure-sensitive pen is moving on the tablet
  case SDL_EVENT_PEN_AXIS  // Pressure-sensitive pen angle/pressure/etc changed

  // Camera hotplug events
  case SDL_EVENT_CAMERA_DEVICE_ADDED = 0x1400  // A new camera device is available
  case SDL_EVENT_CAMERA_DEVICE_REMOVED  // A camera device has been removed.
  case SDL_EVENT_CAMERA_DEVICE_APPROVED  // A camera device has been approved for use by the user.
  case SDL_EVENT_CAMERA_DEVICE_DENIED  // A camera device has been denied for use by the user.

  // Render events
  case SDL_EVENT_RENDER_TARGETS_RESET = 0x2000  // The render targets have been reset and their contents need to be updated
  case SDL_EVENT_RENDER_DEVICE_RESET  // The device has been reset and all textures need to be recreated

  // Internal events
  case SDL_EVENT_POLL_SENTINEL = 0x7F00  // Signals the end of an event poll cycle

  // Events SDL_EVENT_USER through SDL_EVENT_LAST are for your use,
  // and should be allocated with SDL_RegisterEvents()
  case SDL_EVENT_USER = 0x8000

  // This last event is only for bounding internal arrays
  case SDL_EVENT_LAST = 0xFFFF

  // This just makes sure the enum is the size of UInt32
  case SDL_EVENT_ENUM_PADDING = 0x7FFF_FFFF

}

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

    let sdl_init_video = UInt32(0x0000_0020)
    let sdl_init_gamepad = UInt32(0x0000_2000)
    SDL_Init(sdl_init_gamepad)
    SDL_InitSubSystem(sdl_init_video)
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
    spec.format = SDL_AudioFormat(0x8010)  //UInt16(MIX_DEFAULT_FORMAT)
    Mix_OpenAudio(1, &spec)
    if Mix_OpenAudio(0, &spec) < 0 {
      fatalError("Failed to open audio: \(String(cString: SDL_GetError()))")
    } else {
      Mix_QuerySpec(&spec.freq, &spec.format, &spec.channels)
      log.log(
        "Opened audio at \(spec.freq) Hz \(spec.format) bit \((spec.channels > 2) ? "surround" : (spec.channels > 1) ? "stereo" : "mono"))"
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
    var lastDelta: Double = 0
    var tick: UInt64 = 0
    game._start()
    log.start(time: Int(now))
    var keyStates = Keys.State()
    let last_ticks = SDL_GetTicks()
    while game.isRunning {
      keyStates.resetReleased()
      game.mouse.left == .released ? game.mouse.left = .up : ()
      game.mouse.right == .released ? game.mouse.right = .up : ()
      let last = now
      tick = SDL_GetTicks()
      now = SDL_GetPerformanceCounter()
      lastDelta = delta
      let newDelta = Double((now - last) * 1000 / SDL_GetPerformanceFrequency()) * 0.001
      delta = (lastDelta + newDelta) / 2
      log.loop(ticks: Int(tick), time: Int(now), delta: delta)
      if tick % 10 == 0 {
        SDL_SetWindowTitle(window, "tick: \(tick) - \((1 / delta).rounded()) fps")
      }
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
        case SDL_EVENT_GAMEPAD_BUTTON_DOWN.rawValue:
          keyStates.keys[Keys.button(from: SDL_GamepadButton.init(Int32(event.gbutton.button)))] =
            .down
        case SDL_EVENT_GAMEPAD_BUTTON_UP.rawValue:
          keyStates.keys[Keys.button(from: SDL_GamepadButton.init(Int32(event.gbutton.button)))] =
            .released
        case SDL_EVENT_GAMEPAD_AXIS_MOTION.rawValue:
          keyStates.keys[Keys.axis(from: SDL_GamepadAxis.init(Int32(event.gaxis.axis)))] = .at(
            event.gaxis.value)
        case SDL_EVENT_KEY_DOWN.rawValue:
          keyStates.keys[Keys.key(from: event.key.key)] = .down
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
        case SDL_EVENT_WINDOW_DESTROYED.rawValue:
          game._stop()
        case SDL_EVENT_QUIT.rawValue:
          game._stop()
        case SDL_EVENT_WINDOW_MOVED.rawValue, SDL_EVENT_WINDOW_RESIZED.rawValue:
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
        default:
          print(
            "unhandled event: \(SDLEventType(rawValue: event.type).debugDescription)")
          break
        }
      }

      //Send pressed data to game scenes and nodes
      if !keyStates.empty() {
        // Loop over all keyStates and check if they have a corresponding action in the InputMap
        // If they do, create an InputEvent and send it to the current scene
        log.indent("_input")
        for (key, state) in keyStates.keys {
          // TODO: This only sends the first action for a key, but there could be multiple actions
          if let action = game.i.getActions(for: key).first {
            let event = InputEvent(action: action, state: state)
            game._input(event: event, keys: keyStates)
          }
        }
        log.dedent()
      }

      if tick - last_ticks < 1000 / 10 {
        print("too fast, skipping")
        continue
      }

      // log.log("\(SDL_GetTicks() - last_ticks)ms")
      // if SDL_GetTicks() - last_ticks < 1000 / 120 {
      log.indent("_update")
      game._update(delta: delta)
      log.dedent()
      // }

      let c = game.clearColor
      SDL_SetRenderDrawColor(renderer, c.r, c.g, c.b, c.a)
      SDL_RenderClear(renderer)

      log.indent("_draw")
      game._draw()
      log.dedent()

      SDL_RenderPresent(renderer)
      game._cleanup()
      last_ticks = SDL_GetTicks()
    }
  }
}
