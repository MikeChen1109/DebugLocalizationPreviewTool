// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DebugLocalization",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "DebugLocalizationCore",
            targets: ["DebugLocalizationCore"]
        ),
        .library(
            name: "DebugLocalizationTranslationSupport",
            targets: ["DebugLocalizationTranslationSupport"]
        )
    ],
    targets: [
        .target(
            name: "DebugLocalizationCore"
        ),
        .target(
            name: "DebugLocalizationTranslationSupport",
            dependencies: ["DebugLocalizationCore"]
        ),
        .testTarget(
            name: "DebugLocalizationCoreTests",
            dependencies: ["DebugLocalizationCore"]
        )
    ]
)
