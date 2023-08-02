// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NPGKit",
    platforms: [
            .macOS(.v11),
            .iOS(.v13)
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
            dependencies: []),
        .testTarget(
            name: "NPGKitTests",
            dependencies: ["NPGKit"]),
    ]
)
