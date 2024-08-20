import CSDL3
import CSDL3_image
import CSDL3_ttf
import Foundation
import simd

enum RenderCallType {
  case rect
  case texture
  case tilemap
  case text
}

struct RenderCall {
  let type: RenderCallType
  let resource: (any Resource)?
  let x: Float
  let y: Float
  let width: Float
  let height: Float
  let tile: UInt8
  let tint: Color
  let filled: Bool
  let frame: Int
  let totalFrames: Int
  let blendMode: RendererManager.BlendMode
  let rotation: Double
  let size: RendererManager.FontSize
  let origin: simd_float2?
  let text: String
  let onTop: Bool

  init(
    type: RenderCallType, x: Float, y: Float, width: Float, height: Float, tint: Color,
    tile: UInt8 = 0,
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
    self.tile = tile
    self.totalFrames = 0
    self.blendMode = .blend
    self.rotation = 0
    self.origin = nil
    self.text = ""
    self.size = .Body
    self.onTop = onTop
  }

  init(
    type: RenderCallType, resource: any Resource, x: Float, y: Float, width: Float, height: Float,
    tint: Color, tile: UInt8 = 0, frame: Int,
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
    self.tile = tile
    self.frame = frame
    self.totalFrames = totalFrames
    self.blendMode = blendMode
    self.rotation = rotation
    self.origin = origin
    self.filled = false
    self.text = ""
    self.size = .Body
    self.onTop = onTop
  }

  init(
    type: RenderCallType, x: Float, y: Float, width: Float, tile: UInt8 = 0, height: Float,
    text: String,
    size: RendererManager.FontSize,
    tint: Color = Color(r: 255, g: 255, b: 255, a: 255),
    onTop: Bool = false
  ) {
    self.type = type
    self.resource = nil
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text
    self.size = size
    self.tint = tint
    self.tile = tile
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
class RendererManager {
  enum BlendMode {
    case blend
    case add
    case mod
    case mul
    case none
  }

  /// The font size to use for text rendering.
  enum FontSize {
    /// 48pt font
    case Banner
    /// 36pt font
    case Title
    /// 32pt font
    case Subtitle
    /// 28pt font
    case Header
    /// 24pt font
    case Subheader
    /// 20pt font
    case Body
    /// 36pt font
    case Large
    /// 20pt font
    case Small
  }

  func getFont(at size: FontSize) -> OpaquePointer? {
    switch size {
    case .Banner:
      return font
    case .Title:
      return font_18
    case .Subtitle:
      return font_16
    case .Header:
      return font_14
    case .Subheader:
      return font_12
    case .Body:
      return font_10
    case .Large:
      return font_18
    case .Small:
      return font_10
    }
  }

  let renderer: OpaquePointer!
  let font = TTF_OpenFont("GameEngSDL_GameEngSDL.bundle/Assets/Monogram Extended.ttf", 48)
  let font_18 = TTF_OpenFont("GameEngSDL_GameEngSDL.bundle/Assets/Monogram Extended.ttf", 36)
  let font_16 = TTF_OpenFont("GameEngSDL_GameEngSDL.bundle/Assets/Monogram Extended.ttf", 32)
  let font_14 = TTF_OpenFont("GameEngSDL_GameEngSDL.bundle/Assets/Monogram Extended.ttf", 28)
  let font_12 = TTF_OpenFont("GameEngSDL_GameEngSDL.bundle/Assets/Monogram Extended.ttf", 24)
  let font_10 = TTF_OpenFont("GameEngSDL_GameEngSDL.bundle/Assets/Monogram Extended.ttf", 20)
  var batchedCalls: [RenderCall]

  init(renderer: OpaquePointer) {
    print("RendererManager init")
    self.renderer = renderer
    self.batchedCalls = []
  }

  func drawRect(
    x: Float, y: Float, width: Float, height: Float,
    tint: Color = Color(r: 255, g: 255, b: 255, a: 255),
    filled: Bool = false, onTop: Bool = false
  ) {
    batchedCalls.append(
      RenderCall(
        type: .rect, x: x, y: y, width: width, height: height, tint: tint, filled: filled,
        onTop: onTop))
  }

  func drawTextureAnimated(
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

  func drawTexture(
    resource: any Resource,
    x: Float, y: Float, width: Float, height: Float, tile: UInt8
  ) {
    batchedCalls.append(
      RenderCall(
        type: .tilemap,
        resource: resource, x: x, y: y, width: width, height: height,
        tint: Color(r: 255, g: 255, b: 255, a: 255),
        tile: tile,
        frame: Int(tile), totalFrames: 0, blendMode: .blend, rotation: 0, origin: simd_float2(0, 0),
        onTop: false
      )
    )
  }

  func drawTexture(
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

  func measureText(text: String, fontSize: FontSize) -> (Int32, Int32, Int32) {
    var width: Int32 = 0
    var height: Int32 = 0
    var count: Int32 = 0
    let fontToMeasure = getFont(at: fontSize)

    TTF_SizeUTF8(fontToMeasure, text, &width, &height)
    TTF_MeasureUTF8(fontToMeasure, text, Int32(World.shared.width), &width, &count)
    return (width, height, count)
  }

  func drawText(
    text: String, size: FontSize = .Body, tint: Color = .white, x: Float, y: Float, width: Float,
    height: Float,
    onTop: Bool = false
  ) {
    batchedCalls.append(
      RenderCall(
        type: .text, x: x, y: y, width: width, height: height, text: text, size: size, tint: tint,
        onTop: onTop)
    )
  }

  func _draw() {
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
        break
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
        break
      case .tilemap:
        let text = call.resource?.texture
        switch call.blendMode {
        case .blend:
          SDL_SetTextureBlendMode(text, SDL_BLENDMODE_BLEND)
        case .add:
          SDL_SetTextureBlendMode(text, SDL_BLENDMODE_ADD)
        case .mod:
          SDL_SetTextureBlendMode(text, SDL_BLENDMODE_MOD)
        case .mul:
          SDL_SetTextureBlendMode(text, SDL_BLENDMODE_MUL)
        case .none:
          SDL_SetTextureBlendMode(text, SDL_BLENDMODE_NONE)
        }
        let width = call.width
        let height = call.height
        let tilesPerRow = Int(call.resource!.width) / Int(width)
        let tilex = call.tile % UInt8(tilesPerRow)
        let tiley = call.tile / UInt8(tilesPerRow)
        let x = Float(tilex) * width
        let y = Float(tiley) * height
        SDL_SetTextureScaleMode(call.resource?.texture, SDL_SCALEMODE_NEAREST)
        let _ = withUnsafePointer(
          to: SDL_FRect(x: call.x, y: call.y, w: Float(width), h: Float(height))
        ) {
          rect in
          SDL_SetTextureColorMod(text, call.tint.r, call.tint.g, call.tint.b)

          var frameRect =
            SDL_FRect(x: x, y: y, w: width, h: height)
          let drawOrigin = call.origin ?? simd_float2(width / 2, height / 2)
          var oPoint = SDL_FPoint(x: drawOrigin.x, y: drawOrigin.y)
          SDL_RenderTextureRotated(
            renderer, text, &frameRect, rect, call.rotation, &oPoint, SDL_FLIP_NONE)
        }
      case .text:
        let fontSize = getFont(at: call.size)
        let surface = TTF_RenderUTF8_Solid(
          fontSize,
          call.text,
          SDL_Color(r: call.tint.r, g: call.tint.g, b: call.tint.b, a: call.tint.a)
        )
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
