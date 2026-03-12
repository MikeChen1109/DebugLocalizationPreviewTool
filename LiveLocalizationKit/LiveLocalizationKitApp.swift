import SwiftUI
import LiveLocalizationCore
import LiveLocalizationTranslationSupport

@main
struct LiveLocalizationKitApp: App {
    private let shouldPresentPreparationGate: Bool

    init() {
        shouldPresentPreparationGate = true
        LiveLocalization.configure(provider: AppleTranslationProvider())
    }

    var body: some Scene {
        WindowGroup {
            RootDemoView(shouldPresentPreparationGate: shouldPresentPreparationGate)
        }
    }
}
