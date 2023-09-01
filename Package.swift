// swift-tools-version:5.5

import PackageDescription

var linkerSettings: [LinkerSetting] = [.linkedLibrary("z"), .linkedLibrary("c++")]

var targets: [Target] = [
  .executableTarget(
    name: "chfn",
    dependencies: [
      .product(name: "NorthLib", package: "NorthLib"),
      .product(name: "ArgumentParser", package: "swift-argument-parser"),
    ],
    path: "src/chfn",
    linkerSettings: linkerSettings
  ),
  .executableTarget(
    name: "unzip",
    dependencies: [
      .product(name: "NorthLib", package: "NorthLib"),
      .product(name: "ArgumentParser", package: "swift-argument-parser"),
    ],
    path: "src/unzip",
    linkerSettings: linkerSettings
  ),
  .executableTarget(
    name: "nltest",
    dependencies: [
      .product(name: "NorthLib", package: "NorthLib"),
      .product(name: "ArgumentParser", package: "swift-argument-parser"),
    ],
    path: "src/nltest",
    linkerSettings: linkerSettings
  ),
]

var products: [Product] = [
  .executable(
    name: "chfn", 
    targets: ["chfn"]
  ),
  .executable(
    name: "unzip",
    targets: ["unzip"]
  ),
  .executable(
    name: "nltest",
    targets: ["nltest"]
  ),
]

var dependencies: [Package.Dependency] = [
  .package(url: "https://github.com/apple/swift-argument-parser", 
    from: "1.0.0"),
  .package(url: "https://github.com/nthies/NorthLib",
    .branch("release")),
]


let package = Package(
  name: "NorthUtils",
  defaultLocalization: "en",
  platforms: [.macOS(.v11)],
  products: products,
  dependencies: dependencies,
  targets: targets,
  cxxLanguageStandard: .cxx20
)
