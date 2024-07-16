import CSDL3
import CSDL3_image
import CSDL3_ttf
import Foundation

class Asset: Resource {
  var id: UUID
  var type: ResourceType
  var path: String
  var texture: OpaquePointer!
  var width: Float
  var height: Float
  var name: String {
    return String(String(path.split(separator: "/").last!).split(separator: ".").first!)
  }
  var ext: String {
    return String(path.split(separator: ".").last!)
  }

  init(path: String) {
    self.id = UUID()
    self.type = ResourceType.texture
    self.path = path
    self.width = 0
    self.height = 0

    let url = Bundle.module.url(forResource: "Assets/\(self.name)", withExtension: self.ext)
    var out: OpaquePointer!
    switch self.type {
    case .texture:
      guard let path = url?.absoluteString else {
        log.log("Error loading asset: '\(self.path)' was not found.")
        // Should this just crash?
        return
      }
      if __GAME_RENDERER == nil {
        log.log("Renderer not initialized, how did you get here?")
        return
      }
      out = IMG_LoadTexture(__GAME_RENDERER, asRelativePath(path))
      SDL_GetTextureSize(out, &self.width, &self.height)
      break
    case .font:
      break
    case .shader:
      break
    case .sound:
      break
    case .music:
      break
    }
    self.texture = out!
  }

  deinit {
    if self.texture != nil {
      SDL_DestroyTexture(self.texture)
    }
  }

  func asRelativePath(_ path: String) -> String {
    return
      path
      .replacingOccurrences(of: String(cString: SDL_GetBasePath()!), with: "")
      .replacingOccurrences(of: "file://", with: "")
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
    hasher.combine(self.type)
    hasher.combine(self.path)
  }

  static func == (lhs: Asset, rhs: Asset) -> Bool {
    lhs.id == rhs.id || (lhs.type == rhs.type && lhs.hashValue == rhs.hashValue)
  }
}
