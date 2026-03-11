import SwiftUI
import DebugLocalizationCore
import DebugLocalizationTranslationSupport

@main
struct DebugLocalizationDemoApp: App {
    private let providerMode: DemoProviderMode
    private let shouldPresentPreparationGate: Bool

    init() {
        providerMode = .appleTranslation
        shouldPresentPreparationGate = true

        switch providerMode {
        case .appleTranslation:
            DebugTranslate.configure(provider: AppleTranslationProvider())
        case .pseudoLocalization:
            DebugTranslate.configure(provider: PseudoLocalizationProvider())
        case .passthrough:
            DebugTranslate.configure(provider: PassthroughLocalizationProvider())
        case .mock:
            DebugTranslate.configure(provider: MockLocalizationProvider())
        }
    }

    var body: some Scene {
        WindowGroup {
            RootDemoView(shouldPresentPreparationGate: shouldPresentPreparationGate)
        }
    }
}
private enum DemoProviderMode {
    case appleTranslation
    case pseudoLocalization
    case passthrough
    case mock
}

