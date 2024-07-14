import CSDL3
import Foundation

class Player: Entity {
  var thrust: Double = 0
  var rotationSpeed: Double = 0
  var ship = Asset(path: "ship.png")

  required init() {
    super.init()
    let thruster = Thruster()
    self.children = [thruster]
    thruster.parent = self
  }

  override func start(game: Game) {
    self.position.x = Float(game.width) / 2
    self.position.y = Float(game.height) / 2
  }

  override func draw(game: Game) {
    // game.drawRect(x: self.position.x, y: self.position.y, width: 10, height: 10)
    game.drawTexture(
      resource: self.ship, x: Float(self.position.x), y: Float(self.position.y), width: 64,
      height: 64,
      rotation: rotation.converted(to: .degrees).value - 90,  //(self.angle - Angle(-1.57079, inDegrees: false)).valueInDegrees,
      tint: Color(r: 255, g: 255, b: 255, a: 255))
  }

  override func update(delta: Double) {
    rotation = rotation + Measurement(value: rotationSpeed * delta, unit: UnitAngle.radians)

    let ax = thrust * cos(rotation.value)
    let ay = thrust * sin(rotation.value)

    velocity.x += Float(ax * delta)
    velocity.y += Float(ay * delta)

    position.x += velocity.x * Float(delta)
    position.y += velocity.y * Float(delta)

    velocity.x *= 0.99
    velocity.y *= 0.99
  }

  override func input(keys: Keys.State, game: Game) {
    //todo replace direct key access with keymaps
    if keys.isPressed(.w) {
      if thrust < 200 {
        thrust -= 50
      }
    }

    if keys.isPressed(.s) {
      if thrust > -200 {
        thrust += 50
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
    bullet.rotation = self.rotation
    bullet.parent = self
    self.children.append(bullet)
    bullet.start(game: game)
  }

}

class Thruster: Entity {
  var thrust = Asset(path: "thrust.png")

  var ship: Player {
    return self.parent as! Player
  }

  required init() {
    super.init()
    self.position.x = 36
    self.position.y = 34
  }

  override func draw(game: any Game) {
    game.drawTexture(
      resource: thrust, x: Float(self.position.x + ship.position.x),
      y: Float(self.position.y + ship.position.y),
      width: 16, height: 16,
      rotation: rotation.converted(to: UnitAngle.degrees).value,  //(self.rotation - Angle(-1.57079, inDegrees: false)).valueInDegrees,
      tint: Color(r: 255, g: 255, b: 255, a: 255))
  }
}

class Bullet: Entity {
  var bullet = Asset(path: "bullet.png")
  var lifetime: Double = 4.1
  var createdAt: Double = 0

  required init() {
    super.init()
    self.relative = false
    self.createdAt = Date().timeIntervalSince1970
  }

  override func start(game: any Game) {
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

  override func draw(game: any Game) {
    game.drawTexture(
      resource: bullet,
      x: Float(self.position.x), y: Float(self.position.y), width: 32, height: 32,
      rotation: (rotation.converted(to: .degrees).value - 90),  //(self.rotation - Angle(-1.57079, inDegrees: false)).valueInDegrees,
      tint: Color.init(r: 255, g: 255, b: 255, a: 255))
  }

  let speed: Double = 800  // Speed of the bullet in units per second
  override func update(delta: Double) {
    let age = Date().timeIntervalSince1970 - self.createdAt
    if age > self.lifetime {
      // TODO: This functionality should be encapsulated in a helper
      self.parent?.children.removeAll { $0 as? Bullet === self }
      return
    }

    let velocityX = cos(self.rotation.value) * speed * -1
    let velocityY = sin(self.rotation.value) * speed * -1

    // Update the bullet's position based on the velocity
    // Delta is the time elapsed since the last frame, so multiplying by delta makes the movement frame-rate independent
    self.position.x += Float(velocityX) * Float(delta)
    self.position.y += Float(velocityY) * Float(delta)

    var rect = SDL_Rect(x: Int32(self.position.x), y: Int32(self.position.y), w: 32, h: 32)
    var _ = self.parent?.parent?.children.forEach { child in
      if let child = child as? Asteroid {
        let pos = child.position
        let size = child.width
        var rect2 = SDL_Rect(x: Int32(pos.x), y: Int32(pos.y), w: Int32(size), h: Int32(size))
        if SDL_HasRectIntersection(&rect, &rect2) == SDL_TRUE {
          self.parent?.children.removeAll { $0 as? Bullet === self }
          child.parent?.children.removeAll { $0 as? Asteroid === child }
        }
      }
    }
  }
}
