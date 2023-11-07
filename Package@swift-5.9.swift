// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NPGKit",
    platforms: [
            .macOS(.v11),
            .iOS(.v13),
            .visionOS("1.0.0")
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
