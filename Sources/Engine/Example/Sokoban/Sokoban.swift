class Sokoban: Game {
  override func start() {
    log.log("Game \(name) starting at \(width)x\(height)")
    self.changeScene(
      MenuScene(
        ui: MenuUI(destinationScene: PuzzleScene(name: "Play"), gameTitle: "Sokoban"),
        name: "MenuScene"))
  }
}
