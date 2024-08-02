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

    let name = "Sokoban"
    let width: Int32 = 800 / 4
    let height: Int32 = 420 / 4

    let boot = Boot(_name: name, _width: width, _height: height)

    let asteroids_game = Asteroids(
      rendererPointer: boot.renderer, name: name, width: Int(boot.width), height: Int(boot.height))
    let fallingsand_game = FallingSand(
      rendererPointer: boot.renderer, name: name, width: Int(boot.width), height: Int(boot.height))
    let sokoban_game = Sokoban(
      rendererPointer: boot.renderer, name: name, width: Int(boot.width), height: Int(boot.height))

    __GAME_RENDERER = boot.renderer

    boot.run(game: sokoban_game)

    //log.log all availabile renderers
    // todo: decide if this is worth saving as a util somewhere.
    // for i in 0..<SDL_GetNumRenderDrivers() {
    // let driver = SDL_GetRenderDriver(i)
    // log.log("Renderer \(i): \(String(cString: driver!))")
    // }

    log.log("goodbye!")
  }

}

Main.run()
