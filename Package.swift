// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Drowzy",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "Drowzy", targets: ["Drowzy"]),
        .library(name: "DrowzyCore", targets: ["DrowzyCore"])
    ],
    targets: [
        .target(
            name: "DrowzyCore",
            linkerSettings: [
                .linkedFramework("IOKit")
            ]
        ),
        .executableTarget(
            name: "Drowzy",
            dependencies: ["DrowzyCore"],
            linkerSettings: [
                .linkedFramework("AppKit")
            ]
        ),
        .testTarget(
            name: "DrowzyCoreTests",
            dependencies: ["DrowzyCore"]
        )
    ]
)
