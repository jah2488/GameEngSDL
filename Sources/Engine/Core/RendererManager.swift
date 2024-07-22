import CSDL3
import CSDL3_image
import CSDL3_ttf
import Foundation
import simd

//TODO: Rename this class, bad name, not descriptive enough and weird to say.
struct RendererManager {
  let renderer: OpaquePointer!
  func drawRect(
    x: Float, y: Float, width: Float, height: Float,
    tint: Color = Color(r: 255, g: 255, b: 255, a: 255),
    filled: Bool = true
  ) {
    SDL_SetRenderDrawColor(renderer, tint.r, tint.g, tint.b, tint.a)
    var rect = SDL_FRect(x: x, y: y, w: width, h: height)
    if filled {
      SDL_RenderFillRect(renderer, &rect)
    } else {
      SDL_RenderRect(renderer, &rect)
    }
  }

  func drawBackground(resource: any Resource, offsetX: Float, offsetY: Float) {
    let text = resource.texture
    SDL_SetTextureScaleMode(text, SDL_SCALEMODE_NEAREST)
    SDL_RenderTexture(renderer, text, nil, nil)
  }

  func drawTextureAnimated(
    resource: Asset, x: Float, y: Float, width: Int, height: Int,
    frame: Int, totalFrames: Int, rotation: Double,
    origin: simd_float2? = nil, tint: Color
  ) {
    let frameWidth = resource.width / Float(totalFrames)
    let text = resource.texture
    SDL_SetTextureScaleMode(text, SDL_SCALEMODE_NEAREST)
    let _ = withUnsafePointer(to: SDL_FRect(x: x, y: y, w: Float(width), h: Float(height))) {
      rect in
      SDL_SetTextureColorMod(text, tint.r, tint.g, tint.b)
      var frameRect = SDL_FRect(
        x: Float(frame) * frameWidth, y: 0, w: frameWidth, h: resource.height)
      var oPoint = SDL_FPoint(x: origin?.x ?? Float(width) / 2, y: origin?.y ?? Float(height) / 2)
      SDL_RenderTextureRotated(
        renderer, text, &frameRect, rect, rotation, &oPoint, SDL_FLIP_NONE)
    }
  }

  func drawTexture(
    resource: any Resource, x: Float, y: Float, width: Float, height: Float, rotation: Double,
    origin: simd_float2? = nil,
    tint: Color
  ) {
    //TODO: Clean up this API, as I can already see this getting horribly overloaded with options.
    // need to add ability to tint opacity using SDL_SetTextureAlphaMod
    let text = resource.texture
    SDL_SetTextureScaleMode(text, SDL_SCALEMODE_NEAREST)
    let _ = withUnsafePointer(to: SDL_FRect(x: x, y: y, w: width, h: height)) { rect in
      SDL_SetTextureColorMod(text, tint.r, tint.g, tint.b)
      //TODO: If I want to be able to rotate children that are relatively positioned, I need to be able to get their parent's rect from here. I need a better abstraction layer.
      var oPoint = SDL_FPoint(x: origin?.x ?? width / 2, y: origin?.y ?? height / 2)

      SDL_RenderTextureRotated(
        renderer, text, nil, rect, rotation, &oPoint, SDL_FLIP_NONE)
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
}
