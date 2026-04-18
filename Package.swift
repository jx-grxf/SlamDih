// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SlamX",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SlamX", targets: ["SlamX"]),
        .library(name: "SlamXCore", targets: ["SlamXCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.7.3")
    ],
    targets: [
        .target(name: "SlamXCore"),
        .executableTarget(
            name: "SlamX",
            dependencies: [
                "SlamXCore",
                .product(name: "Sparkle", package: "Sparkle")
            ],
            resources: [
                .copy("Resources/ImpactSoundEffect.mp3"),
                .copy("Resources/AirPopSoundEffect.mp3"),
                .copy("Resources/SpotlightSoundEffect.mp3"),
                .copy("Resources/AlertSoundEffect.mp3"),
                .copy("Resources/SnapSoundEffect.mp3")
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("Carbon"),
                .linkedFramework("IOKit"),
                .linkedFramework("ServiceManagement")
            ]
        ),
        .testTarget(
            name: "SlamXCoreTests",
            dependencies: ["SlamXCore"]
        )
    ]
)
