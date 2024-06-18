// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSEKit",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
    products: [
        .library(
            name: "SSEKit",
            targets: ["SSEKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.67.0"),
    ],
    targets: [
        .target(
            name: "SSEKit",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
            ]
        ),
        .testTarget(
            name: "SSEKitTests",
            dependencies: ["SSEKit"]
        ),
    ]
)
