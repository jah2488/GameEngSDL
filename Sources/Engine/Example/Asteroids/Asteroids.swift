import CSDL3
import CSDL3_image
import CSDL3_ttf
import Foundation

class Asteroids: Game {
  var name: String
  var scenes: [Scene]
  var currentScene: Scene?
  var state: GameState
  var renderer: OpaquePointer!
  var width: Int
  var height: Int

  init(name: String, width: Int, height: Int) {
    self.name = name
    self.scenes = []
    self.state = .stopped
    self.currentScene = MenuScene(id: 1, name: "Menu")
    // self.currentScene = PlayScene(id: 1, name: "Play")
    self.width = width
    self.height = height
    print("Game \(name) initialized at \(width)x\(height)")
  }

  var isRunning: Bool {
    return self.state == .running || self.state == .paused
  }

  func start(renderer: OpaquePointer) {
    self.state = .running
    self.renderer = renderer
    self.currentScene!.start(game: self)
  }

  func stop() {
    self.state = .stopped
  }

  func drawRect(x: Float, y: Float, width: Float, height: Float) {
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
    var rect = SDL_FRect(x: x, y: y, w: width, h: height)
    SDL_RenderFillRect(renderer, &rect)
    // SDL_RenderRect(renderer, &rect)
  }

  func drawBackground(resource: any Resource, offsetX: Float, offsetY: Float) {
    let text = resource.texture
    SDL_SetTextureScaleMode(text, SDL_SCALEMODE_NEAREST)
    SDL_RenderTexture(renderer, text, nil, nil)
  }

  func drawTexture(
    resource: any Resource, x: Float, y: Float, width: Float, height: Float, rotation: Double,
    tint: Color
  ) {
    //TODO: Clean up this API, as I can already see this getting horribly overloaded with options.
    // need to add ability to tint opacity using SDL_SetTextureAlphaMod
    let text = resource.texture
    SDL_SetTextureScaleMode(text, SDL_SCALEMODE_NEAREST)
    let _ = withUnsafePointer(to: SDL_FRect(x: x, y: y, w: width, h: height)) { rect in
      SDL_SetTextureColorMod(text, tint.r, tint.g, tint.b)
      SDL_RenderTextureRotated(renderer, text, nil, rect, rotation, nil, SDL_FLIP_NONE)
    }
  }

  func drawText(text: String, x: Float, y: Float, width: Float, height: Float) {
    let font = TTF_OpenFont("GameEngSDL_GameEngSDL.bundle/Assets/Monogram Extended.ttf", 64)
    let surface = TTF_RenderUTF8_Blended(font, text, SDL_Color(r: 255, g: 255, b: 255, a: 255))
    let texture = SDL_CreateTextureFromSurface(renderer, surface)
    var rect = SDL_FRect(x: x, y: y, w: width, h: height)

    SDL_RenderTexture(renderer, texture, nil, &rect)

    SDL_DestroyTexture(texture)
    SDL_DestroySurface(surface)
    TTF_CloseFont(font)
  }

  func draw() {
    self.currentScene!.draw(game: self)
  }

  func update(delta: Float) {
    self.currentScene!.update(delta: delta)
  }

  func input(keys: Keys.State) {
    self.currentScene!.input(keys: keys, game: self)
  }

  func changeScene(scene: Scene) {
    self.currentScene!.unload()
    self.currentScene = scene
    self.currentScene!.load()
    self.currentScene!.start(game: self)
  }
}
