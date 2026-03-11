import SwiftUI
import DebugLocalizationTranslationSupport

struct RootDemoView: View {
    let shouldPresentPreparationGate: Bool

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
        }
    }
}
