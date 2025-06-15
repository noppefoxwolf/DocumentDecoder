// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DocumentDecoder",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DocumentDecoder",
            targets: ["DocumentDecoder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kitura/swift-html-entities", from: "4.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DocumentDecoder",
            dependencies: [
                .product(name: "HTMLEntities", package: "swift-html-entities")
            ]
        ),
        .testTarget(
            name: "DocumentDecoderTests",
            dependencies: ["DocumentDecoder"]
        ),
    ]
)
