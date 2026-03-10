import SwiftUI
import DebugLocalizationCore
import DebugLocalizationTranslationSupport

@main
struct DebugLocalizationDemoApp: App {
    private let configuration: DebugLocalizationConfiguration
    private let localizer: DebugLocalizer

    init() {
        configuration = .debugDefault
        switch configuration.providerMode {
        case .appleTranslation:
            localizer = configuration.makeLocalizer(provider: AppleTranslationProvider())
        default:
            localizer = configuration.makeLocalizer()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootDemoView(localizer: localizer, configuration: configuration)
        }
    }
}
