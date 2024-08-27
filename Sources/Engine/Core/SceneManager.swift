class SceneManager {
  var scenes: Zipper<Scene>

  static var empty: SceneManager {
    return SceneManager(scene: Scene(name: "NullScene"))
  }

  init(scene: Scene) {
    self.scenes = Zipper(left: [], current: scene, right: [])
  }

  init(_ scenes: [Scene]) {
    if scenes.isEmpty {
      fatalError("SceneManager must have at least one scene.")
    }
    self.scenes = Zipper(left: [], current: scenes[0], right: Array(scenes.dropFirst()))
  }

  func current() -> Scene {
    return scenes.current
  }

  func changeScene(_ scene: Scene) {
    scenes.addNext(scene)
    scenes.next()
  }
}
