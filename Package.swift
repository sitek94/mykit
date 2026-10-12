// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MyKit",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "MyKit", targets: ["MyKit"])
    ],
    dependencies: [
        // Pins the SwiftLint binary that scripts/check.sh runs; no target uses it. Apps pin the same version themselves.
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.1")
    ],
    targets: [
        .target(name: "MyKit", swiftSettings: [.defaultIsolation(MainActor.self)]),
        .testTarget(name: "MyKitTests", dependencies: ["MyKit"], swiftSettings: [.defaultIsolation(MainActor.self)]),
    ]
)
