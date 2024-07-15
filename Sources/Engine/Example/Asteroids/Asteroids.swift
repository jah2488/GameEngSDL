import CSDL3
import CSDL3_image
import CSDL3_ttf
import Foundation

class Asteroids: Game {
  override func start() {
    log.log("Game \(name) starting at \(width)x\(height)")
    self.changeScene(MenuScene(name: "MenuScene"))
  }
}
