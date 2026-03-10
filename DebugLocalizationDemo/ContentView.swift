import SwiftUI
import DebugLocalizationCore
import DebugLocalizationTranslationSupport

struct ContentView: View {
    private let englishSourceText = "Payment successful"
    private let localizer: DebugLocalizer

    @State private var displayedText: String

    init(localizer: DebugLocalizer) {
        self.localizer = localizer
        _displayedText = State(initialValue: englishSourceText)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("SwiftUI Demo")
                .font(.headline)
            Text(displayedText)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .task {
            displayedText = await localizer.localize(englishSourceText)
        }
    }
}

#Preview {
    ContentView(localizer: DebugLocalizer(provider: MockTranslationProvider()))
}
