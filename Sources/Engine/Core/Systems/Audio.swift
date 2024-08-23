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
  enum SDLAudioFormat: UInt16 {
    case u8 = 0x0008  // Unsigned 8-bit samples
    case s8 = 0x8008  // Signed 8-bit samples
    case s16LE = 0x8010  // Signed 16-bit samples (Little-endian)
    case s16BE = 0x9010  // Signed 16-bit samples (Big-endian)
    case s32LE = 0x8020  // 32-bit integer samples (Little-endian)
    case s32BE = 0x9020  // 32-bit integer samples (Big-endian)
    case f32LE = 0x8120  // 32-bit floating point samples (Little-endian)
    case f32BE = 0x9120  // 32-bit floating point samples (Big-endian)
  }

  var spec = SDL_AudioSpec(
    format: SDL_AudioFormat(0x8020),  // SDL_audio.h:142  SDL_AUDIO_F32LE     = 0x8120u,  /**< 32-bit floating point samples */
    channels: 2,  // Stereo
    freq: 44100
  )
  var opened = false

  var chunks: [Int: UnsafeMutablePointer<Mix_Chunk>] = [:]

  init() {
    for channel: Int32 in 0..<6 {
      Mix_Volume(channel, 20)
    }
  }

  deinit {
    chunks.forEach { Mix_FreeChunk($1) }
  }

  func load(_ path: String) -> Int {
    let hash = path.hash
    if chunks[hash] != nil {
      return hash
    }
    guard let chunk = Mix_LoadWAV(path) else {
      fatalError("Failed to load audio: \(String(cString: SDL_GetError()))")
    }
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
