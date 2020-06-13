// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Slang",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Slang", targets: ["Slang"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.29.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        .package(url: "https://github.com/sharplet/Regex.git", from: "2.1.0"),
    ],
    targets: [
        .target(name: "Slang", dependencies: ["Regex", "SourceKittenFramework"], path: "source/Slang", exclude: ["Test"]),
        .testTarget(name: "Slang-Test", dependencies: ["Slang", "Quick", "Nimble"], path: "source/Slang/Test"),
    ],
    swiftLanguageVersions: [.v5]
)
