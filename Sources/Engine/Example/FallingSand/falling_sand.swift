import CSDL3
import Foundation
import simd

class Cursor: Entity {
  required init() {
    super.init()
    super.size = simd_float2(4, 4)
    super.tint = .red
    super.originLocation = .center
  }
}

enum Material: Int32 {
  case sand = 0xFFFFFF
  case water = 0x0000FF
  case fire = 0xFF0000
  case wood = 0x8B4513
  case smoke = 0x808080
  case steam = 0x00FF00
}

struct Rule {
  enum Neighbor {
    case above
    case below
    case left
    case right
    case aboveLeft
    case aboveRight
    case belowLeft
    case belowRight
  }
  var base: Material
  var neighbors: [Neighbor: Material]
  var result: Material
}

class FallingSand: Game {
  var pixels: [Int32]
  var backPixels: [Int32]
  var backPixelDirty: [Bool] = []
  var texture: OpaquePointer? = nil

  var cursor = Cursor()
  var density: Float = 1
  var material: Material = .sand

  required override init(
    rendererPointer: OpaquePointer, name: String = "Game", width: Int = 800, height: Int = 600
  ) {
    self.pixels = Array(repeating: 0, count: width * height)
    self.backPixels = Array(repeating: 0, count: width * height)
    self.backPixelDirty = Array(repeating: false, count: width * height)
    super.init(rendererPointer: rendererPointer, name: name, width: width, height: height)

    texture = SDL_CreateTexture(
      rendererPointer, SDL_PIXELFORMAT_ARGB8888, Int32(SDL_TEXTUREACCESS_STREAMING.rawValue),
      Int32(width), Int32(height)
    )
    // SDL_HideCursor()
  }

  override func start() {
    log.log("Game '\(name)' starting at \(width)x\(height)")
    for i in 0..<width {
      for j in 0..<height {
        pixels[i + j * width] = 0x000000
        backPixels[i + j * width] = 0x000000
      }
    }
    cursor.start(game: self)
    clearColor = .init(r: 50, g: 50, b: 50, a: 50)
  }

  override func draw() {
    var pitch = Int32(0)
    var lockedPixels: UnsafeMutableRawPointer? = nil
    if SDL_LockTexture(texture, nil, &lockedPixels, &pitch) == 0 {
      lockedPixels?.copyMemory(from: pixels, byteCount: width * height * MemoryLayout<UInt32>.size)
      SDL_UnlockTexture(texture)
    }
    SDL_RenderTexture(r.renderer, texture, nil, nil)
    cursor.draw(game: self)
  }

  let cursorSize = 2
  override func input(keys: Keys.State) {
    if keys.isReleased(.one) {
      material = .sand
      cursor.tint = .init(r: 100, g: 100, b: 10, a: 100)
      density = 0.4
    }
    if keys.isReleased(.two) {
      material = .water
      cursor.tint = .init(r: 0, g: 0, b: 255, a: 100)
      density = 0.2
    }
    if keys.isReleased(.three) {
      material = .fire
      cursor.tint = .init(r: 255, g: 0, b: 0, a: 100)
      density = 0.5
    }
    if keys.isReleased(.four) {
      material = .smoke
      cursor.tint = .init(r: 128, g: 128, b: 128, a: 100)
      density = 0.01
    }
    if keys.isReleased(.five) {
      material = .steam
      cursor.tint = .init(r: 0, g: 255, b: 0, a: 100)
      density = 0.01
    }
    if keys.isReleased(.w) {
      material = .wood
      cursor.tint = .init(r: 139, g: 69, b: 19, a: 100)
      density = 1
    }

    if keys.mouse.left == .down {
      let cursorX = Int(keys.mouse.x / 4)
      let cursorY = Int(keys.mouse.y / 4)
      let halfCursor = cursorSize * 2

      for i in -halfCursor...halfCursor {
        for j in -halfCursor...halfCursor {
          let pixelX = cursorX + i
          let pixelY = cursorY + j

          if pixelX >= 0 && pixelX < width && pixelY >= 0 && pixelY < height {
            if Float.random(in: 0...1) < density {
              backPixels[pixelX + pixelY * width] = material.rawValue
            }
          }
        }
      }
    }
  }

  @inlinable
  func updateMaterial(
    m: Material, i: Int, j: Int, below: Int32, belowLeft: Int32, belowRight: Int32, right: Int32,
    left: Int32, above: Int32, aboveRight: Int32, aboveLeft: Int32
  ) {

    if m == .steam {  // Steam
      self.safeSetBackPixel(i + j * width, 0)
      if i > 0 && (j - 1 > 0) && self.pixels[i - 1 + (j - 1) * width] == 0 {
        self.safeSetBackPixel(i + (j - 1) * width, Material.steam.rawValue)
      }
      if i < width - 1 && (j - 1 > 0) && self.pixels[i + 1 + (j - 1) * width] == 0 {
        self.safeSetBackPixel(i + (j - 1) * width, Material.steam.rawValue)
      }
    }

    if m == .water {
      if below == 0 {
        self.safeSetBackPixel(i + j * width, 0)
        self.safeSetBackPixel(i + (j + 1) * width, 0x0000FF)
      } else if belowLeft == 0 {
        self.safeSetBackPixel(i + j * width, 0)
        self.safeSetBackPixel(i - 1 + (j + 1) * width, 0x0000FF)
      } else if belowRight == 0 {
        self.safeSetBackPixel(i + j * width, 0)
        self.safeSetBackPixel(i + 1 + (j + 1) * width, 0x0000FF)
      } else if right == 0 && self.safeGetBackPixel(i + 1 + j * width) != Material.water.rawValue {
        if self.safeSetBackPixel(i + 1 + j * width, 0x0000FF) == Material.water.rawValue {
          self.safeSetBackPixel(i + j * width, 0)
        } else {
          self.safeSetBackPixel(i + j * width, 0x0000FF)
        }
      } else if left == 0 && self.safeGetBackPixel(i - 1 + j * width) != Material.water.rawValue {
        if self.safeSetBackPixel(i - 1 + j * width, 0x0000FF) == Material.water.rawValue {
          self.safeSetBackPixel(i + j * width, 0)
        } else {
          self.safeSetBackPixel(i + j * width, 0x0000FF)
        }
      } else {
        self.safeSetBackPixel(i + j * width, 0x0000FF)
      }
    }

    if m == .sand {  // Sand
      if below == 0 || below == Material.water.rawValue {
        self.safeSetBackPixel(i + j * width, below)
        let pixel = self.safeSetBackPixel(i + (j + 1) * width, Material.sand.rawValue)
        if pixel == Material.sand.rawValue {
          self.safeSetBackPixel(i + j * width, Material.sand.rawValue)
        } else {
          self.safeSetBackPixel(i + j * width, Material.fire.rawValue)
        }
      } else if belowLeft == 0 || belowLeft == Material.water.rawValue {
        self.safeSetBackPixel(i + j * width, 0)
        self.safeSetBackPixel(i - 1 + (j + 1) * width, 0xFFFFFF)
      } else if belowRight == 0 || belowRight == Material.water.rawValue {
        self.safeSetBackPixel(i + j * width, 0)
        self.safeSetBackPixel(i + 1 + (j + 1) * width, 0xFFFFFF)
      } else {
        self.safeSetBackPixel(i + j * width, 0xFFFFFF)
      }
    }

    if m == .smoke {
      if Float.random(in: 0...1) < 0.3 {
        self.safeSetBackPixel(i + j * width, 0)
      } else if above == 0 {
        self.safeSetBackPixel(i + j * width, 0)
        self.safeSetBackPixel(i + (j - 1) * width, Material.smoke.rawValue)
      } else if aboveRight == 0 {
        self.safeSetBackPixel(i + j * width, 0)
        self.safeSetBackPixel(i + 1 + (j - 1) * width, Material.smoke.rawValue)
      } else if aboveLeft == 0 {
        self.safeSetBackPixel(i + j * width, 0)
        self.safeSetBackPixel(i + 1 + (j - 1) * width, Material.smoke.rawValue)
      } else if left == 0 {
        self.safeSetBackPixel(i + j * width, 0)
        self.safeSetBackPixel(i - 1 + j * width, Material.smoke.rawValue)
      } else if right == 0 {
        self.safeSetBackPixel(i + j * width, 0)
        self.safeSetBackPixel(i + 1 + j * width, Material.smoke.rawValue)
      } else {
        self.safeSetBackPixel(i + j * width, Material.smoke.rawValue)
      }
    }

    if m == .fire {
      if above == Material.water.rawValue {
        self.safeSetBackPixel(i + j * width, Material.steam.rawValue)
      } else if below == 0 {
        self.safeSetBackPixel(i + j * width, Material.smoke.rawValue)
        if Float.random(in: 0...1) < 0.05 {
          self.safeSetBackPixel(i + (j + 1) * width, Material.smoke.rawValue)
        } else {
          self.safeSetBackPixel(i + (j + 1) * width, 0xFF0000)
        }
      } else if below == Material.water.rawValue {
        self.safeSetBackPixel(i + j * width, Material.steam.rawValue)
        self.safeSetBackPixel(i + (j + 1) * width, Material.steam.rawValue)
      } else if below == Material.wood.rawValue {
        if above == 0 {
          self.safeSetBackPixel(i + (j - 1) * width, Material.smoke.rawValue)
        } else if above == Material.smoke.rawValue {
          if Float.random(in: 0...1) < 0.1 {
            self.safeSetBackPixel(i + (j + 1) * width, Material.fire.rawValue)
          }
        }
        self.safeSetBackPixel(i + j * width, Material.fire.rawValue)
        if right == 0 {
          self.safeSetBackPixel(i + 1 + j * width, Material.smoke.rawValue)
        }
      } else if right == Material.wood.rawValue {
        self.safeSetBackPixel(i + j * width, Material.smoke.rawValue)
        self.safeSetBackPixel(i + 1 + j * width, 0xFF0000)
        if aboveRight == 0 {
          self.safeSetBackPixel(i + 1 + (j - 1) * width, Material.smoke.rawValue)
        }
      } else if left == Material.wood.rawValue {
        self.safeSetBackPixel(i + j * width, Material.smoke.rawValue)
        self.safeSetBackPixel(i - 1 + j * width, 0xFF0000)
        if aboveLeft == 0 {
          self.safeSetBackPixel(i - 1 + (j - 1) * width, Material.smoke.rawValue)
        }
      } else if left == 0 {
        self.safeSetBackPixel(i + j * width, Material.smoke.rawValue)
        if Float.random(in: 0...1) < 0.2 {
          self.safeSetBackPixel(i - 1 + j * width, 0xFF0000)
        }
      } else if right == 0 {
        self.safeSetBackPixel(i + j * width, Material.smoke.rawValue)
        if Float.random(in: 0...1) < 0.2 {
          self.safeSetBackPixel(i - 1 + j * width, 0xFF0000)
        }
      } else {
        if Float.random(in: 0...1) < 0.5 {
          self.safeSetBackPixel(i + j * width, Material.smoke.rawValue)
        }
      }
    }
  }

  @inlinable
  @inline(__always)
  func safeGetPixel(_ n: Int) -> Int32 {
    if n < 0 || n >= pixels.count {
      return Int32.max
    }
    return self.pixels[n]
  }

  @inlinable
  @inline(__always)
  func safeGetBackPixel(_ n: Int) -> Int32 {
    if n < 0 || n >= backPixels.count {
      return Int32.max
    }
    return self.backPixels[n]
  }

  @inlinable
  @inline(__always)
  @discardableResult
  func safeSetBackPixel(_ n: Int, _ val: Int32) -> Int32 {
    if n < 0 || n >= pixels.count {
      return Int32.max
    } else if self.backPixelDirty[n] {
      return self.backPixels[n]
    } else {
      self.backPixelDirty[n] = val == 0 ? true : false
      self.backPixels[n] = val
      return self.backPixels[n]
    }
  }

  @inlinable
  @inline(__always)
  func updatePixels() {
    for i in 0..<self.pixels.count - 1 {
      for j in 0..<self.width - 1 {
        let pixel = self.safeGetPixel(i + j * self.width)
        let below = self.safeGetPixel(i + (j + 1) * self.width)
        let belowLeft = self.safeGetPixel(i - 1 + (j + 1) * self.width)
        let belowRight = self.safeGetPixel(i + 1 + (j + 1) * self.width)
        let right = self.safeGetPixel((i + 1 + j * self.width) % self.pixels.count)
        let left = self.safeGetPixel(i - 1 + j * self.width)
        let above = self.safeGetPixel(i + (j - 1) * self.width)
        let aboveRight = self.safeGetPixel(i + 1 + (j - 1) * self.width)
        let aboveLeft = self.safeGetPixel(i - 1 + (j - 1) * self.width)

        let m = Material(rawValue: pixel)
        if m != nil {
          self.updateMaterial(
            m: m!, i: i, j: j, below: below, belowLeft: belowLeft, belowRight: belowRight,
            right: right, left: left, above: above, aboveRight: aboveRight, aboveLeft: aboveLeft
          )
        }
      }
    }
  }

  var elapsed: Double = 0
  let fps: Double = (1000 / 120) / 1000
  override func update(delta: Double) {
    elapsed += delta
    cursor.position = simd_float2(Float(self.mouse.x), Float(self.mouse.y))
    cursor.update(delta: delta)
    //Update each pixel based on its neighbors and its type
    self.updatePixels()
    if elapsed > fps {
      elapsed = 0
      withUnsafeMutablePointer(to: &backPixels) {
        pixels = $0.pointee
      }
      backPixelDirty = Array(repeating: false, count: width * height)
    }
  }
}
