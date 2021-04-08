// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ComposableAppleMusic",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "ComposableAppleMusic",
            targets: ["ComposableAppleMusic"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.16.0")
    ],
    targets: [
        .target(
            name: "ComposableAppleMusic",
            dependencies: [
                        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
                    ]),
        .testTarget(
            name: "ComposableAppleMusicTests",
            dependencies: ["ComposableAppleMusic"]),
    ]
)
