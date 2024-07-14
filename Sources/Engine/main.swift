// The Swift Programming Language
// https://docs.swift.org/swift-book

import CSDL3
import CSDL3_image
import CSDL3_ttf
import Foundation

let SDL_WINDOW_FULLSCREEN = Uint64(0x0000_0000_0000_0001)
let SDL_WINDOW_RESIZABLE = Uint64(0x0000_0000_0000_0020)
let SDL_WINDOW_HIGH_PIXEL_DENSITY = Uint64(0x0000_0000_0000_2000)
/**< window uses high pixel density back buffer if possible */

var __GAME_RENDERER: OpaquePointer!
class Main {
  let window: OpaquePointer!
  let renderer: OpaquePointer!
  var width: Int32
  var height: Int32
  var isRunning: Bool = true

  var game: Game

  init(width: Int32 = 800, height: Int32 = 600) {
    SDL_Init(UInt32(SDL_INIT_VIDEO | SDL_INIT_GAMEPAD | SDL_INIT_AUDIO))
    IMG_Init(Int32(IMG_INIT_PNG.rawValue))
    TTF_Init()

    let mode = SDL_GetDesktopDisplayMode(SDL_GetPrimaryDisplay())
    print("Display mode: \(mode!.pointee.w) x \(mode!.pointee.h) @ \(mode!.pointee.refresh_rate)Hz")

    self.width = (mode?.pointee.w ?? width) / 4
    self.height = (mode?.pointee.h ?? height) / 4

    print("Initializing game with \(self.width) x \(self.height)")
    self.game = Asteroids(name: "Asteroids", width: Int(self.width), height: Int(self.height))

    self.window = SDL_CreateWindow(
      game.name, self.width, self.height, SDL_WINDOW_HIGH_PIXEL_DENSITY | SDL_WINDOW_RESIZABLE)
    self.renderer = SDL_CreateRenderer(window, nil)
    __GAME_RENDERER = renderer
    SDL_ShowWindow(window)
    SDL_GetWindowSizeInPixels(window, &self.width, &self.height)
    var rect = SDL_Rect(x: 0, y: 0, w: self.width, h: self.height)
    SDL_GetRenderViewport(renderer, &rect)
    game.width = Int(rect.w)
    game.height = Int(rect.h)

    //print all availabile renderers
    // todo: decide if this is worth saving as a util somewhere.
    for i in 0..<SDL_GetNumRenderDrivers() {
      let driver = SDL_GetRenderDriver(i)
      print("Renderer \(i): \(String(cString: driver!))")
    }

    let icon = IMG_Load("GameEngSDL_GameEngSDL.bundle/Assets/icon.png")
    SDL_SetWindowIcon(self.window, icon)
    SDL_DestroySurface(icon)

    SDL_SetRenderScale(renderer, 2, 2)
    print("Starting game with \(self.width) x \(self.height)")
    print("Viewport: \(rect.w) x \(rect.h)")
    game.start(renderer: renderer)
  }

  deinit {
    print("Exiting...")
    TTF_Quit()
    IMG_Quit()
    SDL_Quit()
  }

  func run() {
    var now = SDL_GetPerformanceCounter()
    var delta: Double = 0
    var keyStates = Keys.State()
    while game.isRunning {
      keyStates.resetReleased()
      let last = now
      now = SDL_GetPerformanceCounter()
      delta = Double((now - last) * 1000 / SDL_GetPerformanceFrequency()) * 0.001
      var event = SDL_Event()
      while SDL_PollEvent(&event) != 0 {
        switch event.type {
        case SDL_EVENT_KEY_DOWN.rawValue:
          keyStates.keys[Keys.key(from: event.key.key)] = .down
          break
        case SDL_EVENT_KEY_UP.rawValue:
          keyStates.keys[Keys.key(from: event.key.key)] = .released
          switch event.key.key {
          case SDLK_ESCAPE:
            SDL_ShowSimpleMessageBox(
              SDL_MESSAGEBOX_INFORMATION, "Exiting!", "you are leaving the game", window)
            isRunning = false
            game.stop()
            break
          default:
            break
          }
          break
        case SDL_EVENT_WINDOW_DESTROYED.rawValue:
          game.stop()
          break
        case SDL_EVENT_QUIT.rawValue:
          game.stop()
          break
        case SDL_EVENT_WINDOW_MOVED.rawValue:
          print("window moved to \(event.window.data1), \(event.window.data2)")
          break
        case SDL_EVENT_WINDOW_RESIZED.rawValue:
          print("window resized to \(event.window.data1), \(event.window.data2)")
          var rect = SDL_Rect(x: 0, y: 0, w: self.width, h: self.height)
          SDL_GetRenderViewport(renderer, &rect)
          SDL_RenderClear(renderer)
          game.width = Int(rect.w)
          game.height = Int(rect.h)
          SDL_RenderClear(renderer)
          break
        default:
          break
        }
      }
      //Send pressed data to game scenes and nodes
      if !keyStates.empty() {
        game.input(keys: keyStates)
      }
      game.update(delta: delta)
      SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)
      SDL_RenderClear(renderer)
      game.draw()
      SDL_RenderPresent(renderer)
    }
  }
}

Main.init().run()
