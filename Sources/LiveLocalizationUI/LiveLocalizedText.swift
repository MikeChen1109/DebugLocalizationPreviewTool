#if canImport(SwiftUI)
import SwiftUI
import LiveLocalizationCore

/// A SwiftUI text view that resolves localized content through ``LiveLocalizer``.
public struct LiveLocalizedText: View {
    private struct TaskKey: Equatable {
        let source: String
        let localizerIdentifier: ObjectIdentifier?
    }

    private let source: String
    private let localizer: LiveLocalizer?
    private let placeholder: ((LiveLocalizationPhase) -> AnyView)?
    private let progressHandler: ((LiveLocalizationPhase) -> Void)?
    private let completionHandler: ((LiveLocalizationCompletion) -> Void)?

    @State private var phase: LiveLocalizationPhase

    /// Creates a text view that localizes the provided source string.
    /// - Parameters:
    ///   - source: The original source string to localize.
    ///   - localizer: An optional localizer. When omitted, the shared package localizer is used.
    ///   - content: A view builder that renders the current localization phase.
    public init(
        _ source: String,
        localizer: LiveLocalizer? = nil
    ) {
        self.init(
            source,
            localizer: localizer,
            placeholder: nil,
            progressHandler: nil,
            completionHandler: nil
        )
    }

    private init(
        _ source: String,
        localizer: LiveLocalizer?,
        placeholder: ((LiveLocalizationPhase) -> AnyView)?,
        progressHandler: ((LiveLocalizationPhase) -> Void)?,
        completionHandler: ((LiveLocalizationCompletion) -> Void)?
    ) {
        self.source = source
        self.localizer = localizer
        self.placeholder = placeholder
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        _phase = State(initialValue: .idle(source: source))
    }

    public var body: some View {
        Group {
            if phase.isLoading, let placeholder {
                placeholder(phase)
            } else {
                Text(phase.displayedText)
            }
        }
            .task(id: taskKey) {
                let resolvedLocalizer = if let localizer {
                    localizer
                } else {
                    await LiveLocalization.localizer
                }

                await MainActor.run {
                    updatePhase(.loading(source: source))
                }

                let localizedText = await resolvedLocalizer.localize(source)

                guard !Task.isCancelled else {
                    return
                }

                await MainActor.run {
                    commitLocalizedText(localizedText)
                }
            }
    }

    private func commitLocalizedText(_ localizedText: String) {
        updatePhase(.loaded(text: localizedText))
        completionHandler?(
            LiveLocalizationCompletion(
                source: source,
                localizedText: localizedText
            )
        )
    }

    private func updatePhase(_ phase: LiveLocalizationPhase) {
        self.phase = phase
        progressHandler?(phase)
    }

    private var taskKey: TaskKey {
        TaskKey(
            source: source,
            localizerIdentifier: localizer.map(ObjectIdentifier.init)
        )
    }
}

extension LiveLocalizedText {
    /// Replaces the default text view while localization is loading.
    public func placeholder<Placeholder: View>(
        @ViewBuilder _ builder: @escaping (LiveLocalizationPhase) -> Placeholder
    ) -> Self {
        Self(
            source,
            localizer: localizer,
            placeholder: { phase in AnyView(builder(phase)) },
            progressHandler: progressHandler,
            completionHandler: completionHandler
        )
    }

    /// Registers a callback that receives phase updates while localizing text.
    public func onProgress(_ handler: @escaping (LiveLocalizationPhase) -> Void) -> Self {
        Self(
            source,
            localizer: localizer,
            placeholder: placeholder,
            progressHandler: handler,
            completionHandler: completionHandler
        )
    }

    /// Registers a callback that runs after the localized text is committed.
    public func onCompletion(_ handler: @escaping (LiveLocalizationCompletion) -> Void) -> Self {
        Self(
            source,
            localizer: localizer,
            placeholder: placeholder,
            progressHandler: progressHandler,
            completionHandler: handler
        )
    }
}
#endif
