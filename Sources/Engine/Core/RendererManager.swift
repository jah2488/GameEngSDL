import CSDL3
import CSDL3_image
import CSDL3_ttf
import Foundation
import simd

enum RenderCallType {
  case rect
  case texture
  case text
}

struct RenderCall {
  let type: RenderCallType
  let resource: (any Resource)?
  let x: Float
  let y: Float
  let width: Float
  let height: Float
  let tint: Color
  let filled: Bool
  let frame: Int
  let totalFrames: Int
  let blendMode: RendererManager.BlendMode
  let rotation: Double
  let origin: simd_float2?
  let text: String
  let onTop: Bool

  init(
    type: RenderCallType, x: Float, y: Float, width: Float, height: Float, tint: Color,
    filled: Bool, onTop: Bool = false
  ) {
    self.type = type
    self.resource = nil
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.tint = tint
    self.filled = filled
    self.frame = 0
    self.totalFrames = 0
    self.blendMode = .blend
    self.rotation = 0
    self.origin = nil
    self.text = ""
    self.onTop = onTop
  }

  init(
    type: RenderCallType, resource: any Resource, x: Float, y: Float, width: Float, height: Float,
    tint: Color, frame: Int,
    totalFrames: Int, blendMode: RendererManager.BlendMode, rotation: Double, origin: simd_float2,
    onTop: Bool = false
  ) {
    self.type = type
    self.resource = resource
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.tint = tint
    self.frame = frame
    self.totalFrames = totalFrames
    self.blendMode = blendMode
    self.rotation = rotation
    self.origin = origin
    self.filled = false
    self.text = ""
    self.onTop = onTop
  }

  init(
    type: RenderCallType, x: Float, y: Float, width: Float, height: Float, text: String,
    onTop: Bool = false
  ) {
    self.type = type
    self.resource = nil
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text
    self.tint = Color(r: 255, g: 255, b: 255, a: 255)
    self.frame = 0
    self.totalFrames = 0
    self.blendMode = .blend
    self.rotation = 0
    self.origin = nil
    self.filled = false
    self.onTop = onTop
  }
}

//TODO: Rename this class, bad name, not descriptive enough and weird to say.
//All of these draw calls should be batched into a single list so they can be drawn in a single call and in the correct draw order and not dependent on when they're called.
struct RendererManager {
  enum BlendMode {
    case blend
    case add
    case mod
    case mul
    case none
  }
  let renderer: OpaquePointer!
  let font = TTF_OpenFont("GameEngSDL_GameEngSDL.bundle/Assets/Monogram Extended.ttf", 64)
  var batchedCalls: [RenderCall] = []

  mutating func drawRect(
    x: Float, y: Float, width: Float, height: Float,
    tint: Color = Color(r: 255, g: 255, b: 255, a: 255),
    filled: Bool = true, onTop: Bool = false
  ) {
    batchedCalls.append(
      RenderCall(
        type: .rect, x: x, y: y, width: width, height: height, tint: tint, filled: filled,
        onTop: onTop))
  }

  mutating func drawTextureAnimated(
    resource: Asset, x: Float, y: Float, width: Int, height: Int,
    frame: Int, totalFrames: Int, rotation: Double,
    origin: simd_float2? = nil, blendMode: BlendMode = .blend, tint: Color, onTop: Bool = false
  ) {
    let drawOrigin = origin ?? simd_float2(Float(width) / 2, Float(height) / 2)
    batchedCalls.append(
      RenderCall(
        type: .texture, resource: resource, x: x, y: y, width: Float(width), height: Float(height),
        tint: tint,
        frame: frame, totalFrames: totalFrames, blendMode: blendMode, rotation: rotation,
        origin: drawOrigin, onTop: onTop
      ))
  }

  mutating func drawTexture(
    resource: any Resource, x: Float, y: Float, width: Float, height: Float, rotation: Double,
    origin: simd_float2? = nil,
    blendMode: BlendMode = .blend,
    tint: Color,
    onTop: Bool = false
  ) {
    let drawOrigin = origin ?? simd_float2(width / 2, height / 2)
    batchedCalls.append(
      RenderCall(
        type: .texture, resource: resource, x: x, y: y, width: width, height: height,
        tint: tint,
        frame: 0, totalFrames: 0, blendMode: blendMode, rotation: rotation, origin: drawOrigin,
        onTop: onTop))
  }

  mutating func drawText(
    text: String, x: Float, y: Float, width: Float, height: Float, onTop: Bool = false
  ) {
    batchedCalls.append(
      RenderCall(type: .text, x: x, y: y, width: width, height: height, text: text, onTop: onTop))
  }

  mutating func _draw() {
    batchedCalls.sort { $0.onTop && !$1.onTop }
    for call in batchedCalls {
      switch call.type {
      case .rect:
        SDL_SetRenderDrawColor(renderer, call.tint.r, call.tint.g, call.tint.b, call.tint.a)
        var rect = SDL_FRect(x: call.x, y: call.y, w: call.width, h: call.height)
        if call.filled {
          SDL_RenderFillRect(renderer, &rect)
        } else {
          SDL_RenderRect(renderer, &rect)
        }
      case .texture:
        let text = call.resource?.texture
        switch call.blendMode {
        case .blend:
          SDL_SetTextureBlendMode(text, SDL_BLENDMODE_BLEND)
          break
        case .add:
          SDL_SetTextureBlendMode(text, SDL_BLENDMODE_ADD)
          break
        case .mod:
          SDL_SetTextureBlendMode(text, SDL_BLENDMODE_MOD)
          break
        case .mul:
          SDL_SetTextureBlendMode(text, SDL_BLENDMODE_MUL)
          break
        case .none:
          SDL_SetTextureBlendMode(text, SDL_BLENDMODE_NONE)
          break
        }

        let frameWidth = call.resource!.width / Float(call.totalFrames)
        let width = call.width
        let height = call.height
        SDL_SetTextureScaleMode(call.resource?.texture, SDL_SCALEMODE_NEAREST)
        let _ = withUnsafePointer(
          to: SDL_FRect(x: call.x, y: call.y, w: Float(width), h: Float(height))
        ) {
          rect in
          SDL_SetTextureColorMod(text, call.tint.r, call.tint.g, call.tint.b)
          var frameRect =
            if call.totalFrames > 0 {
              SDL_FRect(
                x: Float(call.frame) * frameWidth, y: 0, w: frameWidth > 0 ? frameWidth : width,
                h: call.resource?.height ?? 1)
            } else {
              SDL_FRect(x: 0, y: 0, w: call.resource!.width, h: call.resource!.height)
            }
          let drawOrigin = call.origin ?? simd_float2(width / 2, height / 2)
          var oPoint = SDL_FPoint(x: drawOrigin.x, y: drawOrigin.y)
          SDL_RenderTextureRotated(
            renderer, text, &frameRect, rect, call.rotation, &oPoint, SDL_FLIP_NONE)
        }
      case .text:
        let surface = TTF_RenderUTF8_Blended(
          font, call.text, SDL_Color(r: 255, g: 255, b: 255, a: 255))
        let texture = SDL_CreateTextureFromSurface(renderer, surface)
        var rect = SDL_FRect(x: call.x, y: call.y, w: call.width, h: call.height)

        SDL_RenderTexture(renderer, texture, nil, &rect)
        SDL_DestroyTexture(texture)
        SDL_DestroySurface(surface)
      }
    }
    batchedCalls = []
  }
}
