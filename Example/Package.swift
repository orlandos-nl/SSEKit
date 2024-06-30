// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Example",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0-beta.8"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Example",
            dependencies: [
                .product(name: "SSEKit", package: "SSEKit"),
                .product(name: "Hummingbird", package: "hummingbird"),
            ]
        ),
    ]
)
