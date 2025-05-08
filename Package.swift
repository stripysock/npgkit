// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NPGKit",
    platforms: [
            .macOS(.v13),
            .iOS(.v15),
            .tvOS(.v15),
            .visionOS(.v1)
        ],
    products: [
        .library(
            name: "NPGKit",
            targets: ["NPGKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "NPGKit",
            dependencies: [],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "NPGKitTests",
            dependencies: ["NPGKit"]),
    ]
)
