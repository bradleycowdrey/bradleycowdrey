// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Meridian",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Meridian", path: "Sources/Meridian")
    ]
)
