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

  static func run() {
    print("hello!")

    let name = "Asteroids"
    let width: Int32 = 800
    let height: Int32 = 600

    let boot = Boot(_name: name, _width: width, _height: height)

    let game = Asteroids(
      rendererPointer: boot.renderer, name: name, width: Int(boot.width), height: Int(boot.height))

    __GAME_RENDERER = boot.renderer

    boot.run(game: game)

    //print all availabile renderers
    // todo: decide if this is worth saving as a util somewhere.
    // for i in 0..<SDL_GetNumRenderDrivers() {
    // let driver = SDL_GetRenderDriver(i)
    // print("Renderer \(i): \(String(cString: driver!))")
    // }

    print("goodbye!")
  }

}

Main.run()
