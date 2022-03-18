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
]

var dependencies: [Package.Dependency] = [
  .package(url: "https://github.com/apple/swift-argument-parser", 
    from: "1.0.0"),
  .package(url: "https://github.com/die-tageszeitung/NorthLib",
    .branch("spm")),
]


let package = Package(
  name: "NorthUtils",
  defaultLocalization: "en",
  platforms: [.macOS(.v10_15)],
  products: products,
  dependencies: dependencies,
  targets: targets,
  cxxLanguageStandard: .cxx20
)
