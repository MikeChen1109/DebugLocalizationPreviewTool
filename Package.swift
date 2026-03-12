// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "LiveLocalizationKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "LiveLocalizationCore",
            targets: ["LiveLocalizationCore"]
        ),
        .library(
            name: "LiveLocalizationTranslationSupport",
            targets: ["LiveLocalizationTranslationSupport"]
        )
    ],
    targets: [
        .target(
            name: "LiveLocalizationCore"
        ),
        .target(
            name: "LiveLocalizationTranslationSupport",
            dependencies: ["LiveLocalizationCore"]
        ),
        .testTarget(
            name: "LiveLocalizationCoreTests",
            dependencies: [
                "LiveLocalizationCore",
                "LiveLocalizationTranslationSupport"
            ]
        )
    ]
)
