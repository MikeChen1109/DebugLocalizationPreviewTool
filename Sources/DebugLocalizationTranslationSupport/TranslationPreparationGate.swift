import SwiftUI
#if canImport(Translation)
import Translation
#endif

public struct TranslationPreparationGate<Content: View>: View {
    private let isEnabled: Bool
    private let content: Content

    @Environment(\.scenePhase) private var scenePhase
    @State private var coordinator = TranslationPreparationCoordinator()

    public init(
        isEnabled: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.isEnabled = isEnabled
        self.content = content()
    }

    public var body: some View {
        rootContent
            .task {
                await coordinator.refresh()
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                Task {
                    await coordinator.refresh(force: true)
                }
            }
    }

    @ViewBuilder
    private var rootContent: some View {
#if canImport(Translation)
        if isEnabled, #available(iOS 18.0, *) {
            switch coordinator.state {
            case .ready:
                content
                    .translationTask(coordinator.translationConfiguration) { session in
                        guard coordinator.isPreparingTranslation else { return }
                        await coordinator.prepareTranslation(using: session)
                    }
            case .checking:
                ProgressView("Checking translation availability…")
            case .needsDownload(let request):
                preparationPrompt(for: request)
                    .translationTask(coordinator.translationConfiguration) { session in
                        guard coordinator.isPreparingTranslation else { return }
                        await coordinator.prepareTranslation(using: session)
                    }
            }
        } else {
            content
        }
#else
        content
#endif
    }

#if canImport(Translation)
    @available(iOS 18.0, *)
    @ViewBuilder
    private func preparationPrompt(for request: AppleTranslationProvider.Preparation) -> some View {
        VStack(spacing: 16) {
            Text("Translation Download Required")
                .font(.title3.weight(.semibold))

            Text("Download the translation model for \(coordinator.displayName(for: request.targetLanguage)) before showing localized text.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if let downloadStatusMessage = coordinator.downloadStatusMessage {
                Text(downloadStatusMessage)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            Button {
                coordinator.startPreparation(for: request)
            } label: {
                if coordinator.isPreparingTranslation {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Checking Download Status")
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Text(coordinator.downloadButtonTitle)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(coordinator.isPreparingTranslation)
        }
        .padding(24)
    }
#endif
}
