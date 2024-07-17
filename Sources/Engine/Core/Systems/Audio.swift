import CSDL3
import CSDL3_mixer

class Audio {
  typealias ChunkID = Int
  enum Channel {
    case music
    case soundfx
    case ui
    case voice
    case ambient
    case misc
    case custom(Int)
  }
  var spec = SDL_AudioSpec(
    format: UInt16(SDL_AUDIO_F32),
    channels: 2,  // Stereo
    freq: 44100
  )
  var opened = false

  var chunks: [Int: UnsafeMutablePointer<Mix_Chunk>] = [:]

  init() {
  }

  deinit {
    chunks.forEach { Mix_FreeChunk($1) }
  }

  func load(_ path: String) -> Int {
    guard let chunk = Mix_LoadWAV(path) else {
      fatalError("Failed to load audio: \(String(cString: SDL_GetError()))")
    }
    let hash = path.hash
    chunks[hash] = chunk
    return hash
  }

  func play(
    _ chunkID: ChunkID, _ channel: Channel = .soundfx, _ loops: Int = 0
  ) {
    let chunk = chunks[chunkID]!
    if Mix_PlayChannel(ch2Int(channel), chunk, Int32(loops)) == -1 {
      fatalError("Failed to play audio: \(String(cString: SDL_GetError()))")
    }
  }

  private func ch2Int(_ channel: Channel) -> Int32 {
    switch channel {
    case .music: return 0
    case .soundfx: return 1
    case .ui: return 2
    case .voice: return 3
    case .ambient: return 4
    case .misc: return 5
    case .custom(let ch): return Int32(ch)
    }
  }
}
