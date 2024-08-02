import simd

class PuzzleScene: Scene {
  override func start(game: Game) {
    let level = Level()
    addChild(level)
  }
}

class PuzzleSolver: Entity {
  var tiles: [UInt8] = []
  init(x: Float, y: Float, tiles: [UInt8], width: Float = 16) {
    super.init()
    self.position = simd_float2(x, y)
    self.size = simd_float2(16, 16)
    self.tiles = tiles
  }

  required init() {
    super.init()
  }
  enum Dir {
    case north
    case east
    case south
    case west
  }

  override func input(keys: Keys.State, game: Game) {
    if keys.isReleased(.w) { move(.north) }
    if keys.isReleased(.a) { move(.west) }
    if keys.isReleased(.s) { move(.south) }
    if keys.isReleased(.d) { move(.east) }
  }

  func move(_ dir: Dir) {
    var newPos = self.position
    switch dir {
    case .north:
      newPos = self.position - simd_float2(0, 16)
    case .east:
      newPos = self.position + simd_float2(16, 0)
    case .south:
      newPos = self.position + simd_float2(0, 16)
    case .west:
      newPos = self.position - simd_float2(16, 0)
    }
    print(newPos)
    if available(newPos) {
      self.position = newPos
    }
  }

  func available(_ pos: simd_float2) -> Bool {
    let t = posToTile(x: pos.x, y: pos.y)
    return t == 5 || t == 1 || t == 4
  }

  //TODO: This should be a helper on the tilemap class
  func posToTile(x: Float, y: Float) -> UInt8 {
    let _x: Float = ((x / 16) * 7).rounded()
    let _y: Float = ((y / 16) * 7).rounded()
    let n: Float = _x + _y
    if Int(n) < tiles.count {
      print("n: \(Int(n)) of _x: \(x) _y: \(y) equals \(tiles[Int(n)])")
      return tiles[Int(n)]
    } else {
      return UInt8.max
    }
  }
}

class Level: Entity {
  var tiles: [UInt8] = [
    2, 0, 0, 0, 0, 1, 2,
    2, 5, 5, 5, 5, 6, 2,
    2, 5, 12, 12, 12, 6, 7,
    7, 5, 12, 8, 12, 5, 5,
    4, 5, 5, 5, 5, 6, 2,
    1, 0, 0, 0, 0, 0, 2,
  ]

  var TILE_WIDTH = 16
  var MAP_WIDTH = 7

  required init() {
    super.init()
    self.texture = Asset(path: "tileset.png")
  }

  override func start(game: Game) {
    // place player
    for n in 0..<tiles.count {
      if tiles[n] == 4 {
        let x = Float((n % MAP_WIDTH) * TILE_WIDTH)
        let y = Float((n / MAP_WIDTH) * TILE_WIDTH)
        self.children.append(
          PuzzleSolver(x: x, y: y, tiles: tiles)
        )
      }
    }
  }

  override func draw(game: Game) {
    for n in 0..<tiles.count {
      let x = n % MAP_WIDTH
      let y = n / MAP_WIDTH
      let tile = tiles[n]
      game.r.drawTexture(
        resource: self.texture!,
        x: Float(x * TILE_WIDTH),
        y: Float(y * TILE_WIDTH),
        width: Float(TILE_WIDTH),
        height: Float(TILE_WIDTH),
        tile: tile
      )
    }
  }
}
