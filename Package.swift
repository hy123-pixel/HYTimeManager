// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ChronoKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "ChronoKit",
            targets: ["ChronoKit"]
        )
    ],
    targets: [
        .target(
            name: "ChronoKit"
        ),
        .testTarget(
            name: "ChronoKitTests",
            dependencies: ["ChronoKit"]
        )
    ]
)
