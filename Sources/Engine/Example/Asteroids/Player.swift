import CSDL3
import Foundation

class Player: Renderable, Node {
  var id: UInt64
  var children: [any Node]
  var parent: (any Node)?

  var position = Vector2(x: 0, y: 0)
  var velocity = Vector2(x: 0, y: 0)
  var angle: Angle = Angle(0, inDegrees: false)
  var thrust: Double = 0
  var rotationSpeed: Double = 0
  var ship = Asset(path: "ship.png")

  required init() {
    self.id = 1
    self.children = []
  }

  func start(game: Game) {
    self.position.x = Double(game.width) / 2
    self.position.y = Double(game.height) / 2
  }

  func draw(game: Game) {
    // game.drawRect(x: self.position.x, y: self.position.y, width: 10, height: 10)
    game.drawTexture(
      resource: self.ship, x: Float(self.position.x), y: Float(self.position.y), width: 64,
      height: 64,
      rotation: (self.angle - Angle(-1.57079, inDegrees: false)).valueInDegrees,
      tint: Color(r: 255, g: 255, b: 255, a: 255))

    for child in self.children {
      if let child = child as? Renderable {
        child.draw(game: game)
      }
    }
  }

  func update(delta: Float) {
    angle = angle + rotationSpeed * Double(delta)

    let ax = thrust * cos(angle.value)
    let ay = thrust * sin(angle.value)

    velocity.x += ax * Double(delta)
    velocity.y += ay * Double(delta)

    position.x += velocity.x * Double(delta)
    position.y += velocity.y * Double(delta)

    velocity.x *= 0.99
    velocity.y *= 0.99

    for child in self.children {
      if let child = child as? Renderable {
        child.update(delta: delta)
      }
    }
  }

  func input(keys: Keys.State, game: Game) {
    //todo replace direct key access with keymaps
    if keys.isPressed(.w) {
      if thrust < 200 {
        thrust += 50
      }
    }

    if keys.isPressed(.s) {
      if thrust > -200 {
        thrust -= 50
      }
    }

    if keys.isPressed(.a) {
      rotationSpeed -= 1
    }

    if keys.isPressed(.d) {
      rotationSpeed += 1
    }

    if keys.isReleased(.space) {
      fire(game: game)
    }

    if keys.isReleased(.w) || keys.isReleased(.s) {
      thrust = 0
    }

    if keys.isReleased(.a) || keys.isReleased(.d) {
      rotationSpeed = 0
    }

    clamp(&thrust, min: -200, max: 200)
    clamp(&rotationSpeed, min: -3, max: 3)
  }

  func fire(game: Game) {
    let bullet = Bullet()
    bullet.position = self.position
    bullet.rotation = self.angle
    bullet.parent = self
    self.children.append(bullet)
    bullet.start(game: game)
  }

}

class Bullet: Renderable, Node {
  var id: UInt64
  var children: [any Node]
  var parent: (any Node)?
  var bullet = Asset(path: "bullet.png")
  var lifetime: Double = 4.1
  var createdAt: Double = 0

  var position = Vector2(x: 0, y: 0)
  var rotation: Angle = Angle(0, inDegrees: false)

  required init() {
    self.id = 0
    self.children = []
    self.createdAt = Date().timeIntervalSince1970
  }

  func start(game: any Game) {
    // TODO: None of this resource loading should be happening here in object creation. Only the playing of the audio.
    var audioSpec = SDL_AudioSpec()
    audioSpec.format = UInt16(SDL_AUDIO_F32)
    audioSpec.channels = 2
    audioSpec.freq = 44100
    var audio_buf: UnsafeMutablePointer<Uint8>?
    var audio_len: Int32 = 0
    print(String(cString: SDL_GetError()))
    withUnsafeMutablePointer(to: &audio_len) { len in
      SDL_LoadWAV(
        "GameEngSDL_GameEngSDL.bundle/Assets/Laser_Shoot.wav", &audioSpec, &audio_buf, len)
    }
    var audio = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, &audioSpec, nil, nil)
    var devid = SDL_GetCurrentAudioDriver()
    var audioDevice = SDL_OpenAudioDevice(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, &audioSpec)
    SDL_ResumeAudioDevice(SDL_GetAudioStreamDevice(audio))

    /* ...in your main loop... */
    /* calculate a little more audio into `buf`, add it to `stream` */
    SDL_PutAudioStreamData(audio, audio_buf, audio_len)

  }

  func draw(game: any Game) {
    game.drawTexture(
      resource: bullet,
      x: Float(self.position.x), y: Float(self.position.y), width: 32, height: 32,
      rotation: (self.rotation - Angle(-1.57079, inDegrees: false)).valueInDegrees,
      tint: Color.init(r: 255, g: 255, b: 255, a: 255))
  }

  let speed: Double = 800  // Speed of the bullet in units per second
  func update(delta: Float) {
    let age = Date().timeIntervalSince1970 - self.createdAt
    if age > self.lifetime {
      // TODO: This functionality should be encapsulated in a helper
      self.parent?.children.removeAll { $0 as? Bullet === self }
      return
    }

    let velocityX = cos(self.rotation.value) * speed
    let velocityY = sin(self.rotation.value) * speed

    // Update the bullet's position based on the velocity
    // Delta is the time elapsed since the last frame, so multiplying by delta makes the movement frame-rate independent
    self.position.x += Double(velocityX) * Double(delta)
    self.position.y += Double(velocityY) * Double(delta)
  }

  func input(keys: Keys.State, game: any Game) {

  }

}
