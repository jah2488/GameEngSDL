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

let physicalCores = ProcessInfo.processInfo.processorCount
let threadPool = ThreadPool(threadsCount: physicalCores)
class Main {

  static func run() {

    let name = "Sokoban"
    let width: Int32 = 800 / 2
    let height: Int32 = 420 / 2

    let boot = Boot(_name: name, _width: width, _height: height)
    // TODO: This needs to go
    // Assets are currently loaded at initialization and passing the renderer to each asset is bad and a pain
    // This is a temporary solution to get the renderer to the asset by making it globally accessible
    // What is needed here is an AssetManager class that is created in the boot and passed to the game
    // Assets can still be created as data objects, but they need to be loaded by the AssetManager
    __GAME_RENDERER = boot.renderer

    let asteroids_game = Asteroids(
      rendererPointer: boot.renderer, name: name, width: Int(boot.width), height: Int(boot.height))
    boot.run(game: asteroids_game)
    // let fallingsand_game = FallingSand(
    //   rendererPointer: boot.renderer, name: name, width: Int(boot.width), height: Int(boot.height))
    // boot.run(game: fallingsand_game)

    // let sokoban_game = Sokoban(
    //   rendererPointer: boot.renderer, name: name, width: Int(boot.width), height: Int(boot.height))
    // boot.run(game: sokoban_game)

    // let gui = GuiTest(
    // rendererPointer: boot.renderer, name: name, width: Int(boot.width), height: Int(boot.height))
    // boot.run(game: gui)

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
