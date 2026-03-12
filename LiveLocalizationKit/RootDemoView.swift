import SwiftUI
import LiveLocalizationTranslationSupport

struct RootDemoView: View {
    let shouldPresentPreparationGate: Bool
    let eventStore: DemoLocalizationEventStore

    var body: some View {
        TranslationPreparationGate(isEnabled: shouldPresentPreparationGate) {
            tabContent
        }
    }

    private var tabContent: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("SwiftUI", systemImage: "swift")
                }

            UIKitDemoView()
                .tabItem {
                    Label("UIKit", systemImage: "square.stack.3d.up")
                }

            LocalizationEventLogView(eventStore: eventStore)
                .tabItem {
                    Label("Events", systemImage: "list.bullet.rectangle")
                }
        }
    }
}
