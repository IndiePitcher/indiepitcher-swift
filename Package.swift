// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IndiePitcherSwift",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "IndiePitcherSwift",
            targets: ["IndiePitcherSwift"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.20.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IndiePitcherSwift",
            dependencies: [.product(name: "AsyncHTTPClient", package: "async-http-client"),]
        ),
        .testTarget(
            name: "IndiePitcherSwiftTests",
            dependencies: ["IndiePitcherSwift", "Nimble"]
        ),
    ]
)
