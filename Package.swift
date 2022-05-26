// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScribbleConverter",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ScribbleConverter",
            targets: ["ScribbleConverter"]),
    ],
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.19.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ScribbleConverter",
            dependencies: []),
        .testTarget(
            name: "ScribbleConverterTests",
            dependencies: ["ScribbleConverter"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)