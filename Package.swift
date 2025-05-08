// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NPGKit",
    platforms: [
            .macOS(.v13),
            .iOS(.v16),
            .tvOS(.v16),
            .visionOS(.v2)
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
