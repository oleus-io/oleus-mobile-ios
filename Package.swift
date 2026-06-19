// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OleusRUM",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [.library(name: "OleusRUM", targets: ["OleusRUM"])],
    targets: [
        .target(
            name: "OleusRUM",
            path: "Sources/OleusRUM",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
    ]
)
