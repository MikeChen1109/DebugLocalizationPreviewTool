import SwiftUI

struct LocalizationEventLogView: View {
    let eventStore: DemoLocalizationEventStore

    @State private var entries: [DemoLocalizationEventEntry] = []

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Events Yet",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Run the SwiftUI or UIKit demos to generate localization events.")
                    )
                } else {
                    List(entries) { entry in
                        Text(entry.message)
                            .font(.footnote.monospaced())
                            .textSelection(.enabled)
                    }
                }
            }
            .navigationTitle("Events")
        }
        .task {
            for await snapshot in await eventStore.snapshots() {
                entries = snapshot
            }
        }
    }
}

#Preview {
    LocalizationEventLogView(eventStore: DemoLocalizationEventStore())
}
