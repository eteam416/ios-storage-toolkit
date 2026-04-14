// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StorageToolkit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "StorageToolkit",
            targets: ["StorageToolkit"]
        )
    ],
    targets: [
        .target(
            name: "StorageToolkit"
        ),
        .testTarget(
            name: "StorageToolkitTests",
            dependencies: ["StorageToolkit"]
        )
    ]
)
