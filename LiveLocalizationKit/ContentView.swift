import SwiftUI
import LiveLocalizationCore
import LiveLocalizationUI

struct ContentView: View {
    private let englishSourceText = "Payment successful"
    private let wrapperSourceText = """
    Continue on the next line
    and review the updated settings
    """
    
    @State private var coreLocalizedText = "Payment successful"
    
    var body: some View {
        VStack(spacing: 24) {
            Text("SwiftUI Demo")
                .font(.headline)
            
            VStack(spacing: 8) {
                Text("Core API")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(coreLocalizedText)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 8) {
                Text("UI Wrapper")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                LiveLocalizedText(wrapperSourceText)
                    .placeholder { phase in
                        ZStack(alignment: .topTrailing) {
                            Text(phase.displayedText)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .redacted(reason: .placeholder)
                        }
                    }
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .task {
            coreLocalizedText = await englishSourceText.localize()
        }
    }
}

#Preview {
    ContentView()
}
