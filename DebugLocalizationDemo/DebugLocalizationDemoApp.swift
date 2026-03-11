import SwiftUI
import DebugLocalizationCore
import DebugLocalizationTranslationSupport

@main
struct DebugLocalizationDemoApp: App {
    private let shouldPresentPreparationGate: Bool

    init() {
        shouldPresentPreparationGate = true
        DebugTranslate.configure(provider: AppleTranslationProvider())
    }

    var body: some Scene {
        WindowGroup {
            RootDemoView(shouldPresentPreparationGate: shouldPresentPreparationGate)
        }
    }
}
