// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScribbleConverter",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ScribbleConverter",
            targets: ["ScribbleConverter"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.19.0"),
    ],
    targets: [
            .target(
                name: "ScribbleConverter",
                dependencies: [.product(name: "SwiftProtobuf", package: "swift-protobuf")],
                path: "Sources"
            ),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
