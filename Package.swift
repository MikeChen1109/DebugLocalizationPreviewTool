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
            name: "DebugLocalizationCore",
            path: "frameworks/DebugLocalizationPackage/Sources/DebugLocalizationCore"
        ),
        .target(
            name: "DebugLocalizationTranslationSupport",
            dependencies: ["DebugLocalizationCore"],
            path: "frameworks/DebugLocalizationPackage/Sources/DebugLocalizationTranslationSupport"
        ),
        .testTarget(
            name: "DebugLocalizationCoreTests",
            dependencies: ["DebugLocalizationCore"],
            path: "frameworks/DebugLocalizationPackage/Tests/DebugLocalizationCoreTests"
        )
    ]
)
