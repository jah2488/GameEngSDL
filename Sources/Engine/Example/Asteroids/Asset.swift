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

    let url = Bundle.module.path(forResource: "Assets/\(self.name)", ofType: self.ext)
    var out: OpaquePointer!
    switch self.type {
    case .texture:
      // TODO: Related to the todo in main.swift, this is a temporary solution to get the renderer to the asset
      // the asset should not need to know about the renderer and should just be a data object
      out = IMG_LoadTexture(__GAME_RENDERER, url)
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

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
    hasher.combine(self.type)
    hasher.combine(self.path)
  }

  static func == (lhs: Asset, rhs: Asset) -> Bool {
    lhs.id == rhs.id || (lhs.type == rhs.type && lhs.hashValue == rhs.hashValue)
  }
}
