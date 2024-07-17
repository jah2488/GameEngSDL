import CSDL3
import Foundation

//Todo: Decide what to do with this.
/*
  right now Audio.swift is acting more like a sound manager, as it holds
  the actual chunk information. Then the Sound class here is just a glorified struct
  with some path helpers attached.

  There is no preloading of sounds, right now they load when the class is instantiated,
  but I'm unsure if I want to decouple the sound from the Entity using them.

  Perhaps the entities declare the sounds they want to use, and then fire off events, and
  the entire audio system is async, no passing references to audio information around.

  Just `load("Laser_Shoot.wav", :shoot)` and `play(:shoot)` in the entity and the audio system
  handles the rest when it reads from the queue.

*/

class Sound {
  var id: UUID
  var type: ResourceType
  var path: String
  var sound: OpaquePointer!
  var name: String {
    return String(String(path.split(separator: "/").last!).split(separator: ".").first!)
  }
  var ext: String {
    return String(path.split(separator: ".").last!)
  }

  var url: String = ""

  init(path: String) {
    self.id = UUID()
    self.type = ResourceType.sound
    self.path = path
    let bundlePath = Bundle.module.url(forResource: "Assets/\(self.name)", withExtension: self.ext)
    self.url = asRelativePath(bundlePath!.absoluteString)
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(path)
  }
  func asRelativePath(_ path: String) -> String {
    return
      path
      .replacingOccurrences(of: String(cString: SDL_GetBasePath()!), with: "")
      .replacingOccurrences(of: "file://", with: "")
  }

  deinit {
  }
}
