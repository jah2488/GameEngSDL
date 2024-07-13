// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "GameEngSDL",
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .systemLibrary(name: "CSDL3", pkgConfig: "sdl3"),
    .systemLibrary(name: "CSDL3_image", pkgConfig: "sdl3-image"),
    .executableTarget(
      name: "GameEngSDL",
      dependencies: ["CSDL3", "CSDL3_image"],
      path: "./Sources/Engine",
      resources: [
        .copy("Assets/")
      ],
      linkerSettings: [
        .linkedLibrary("sdl3"),
        .linkedLibrary("SDL3_image"),
        .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "/usr/local/lib"]),
      ]),
  ]
)
