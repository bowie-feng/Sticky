// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Sticky",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Sticky", targets: ["Sticky"])
    ],
    targets: [
        .executableTarget(
            name: "Sticky",
            path: "Sources"
        )
    ]
)
