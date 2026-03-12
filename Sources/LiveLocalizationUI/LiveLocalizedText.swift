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
    private let animationStyle: LiveLocalizationTextAnimation

    @State private var displayedText: String
    @State private var requestCoordinator = LiveLocalizationTextRequestCoordinator()

    /// Creates a text view that localizes the provided source string.
    /// - Parameters:
    ///   - source: The original source string to localize.
    ///   - localizer: An optional localizer. When omitted, the shared package localizer is used.
    ///   - animationStyle: The animation used when committing the localized text.
    public init(
        _ source: String,
        localizer: LiveLocalizer? = nil,
        animationStyle: LiveLocalizationTextAnimation = .fade
    ) {
        self.source = source
        self.localizer = localizer
        self.animationStyle = animationStyle
        _displayedText = State(initialValue: source)
    }

    public var body: some View {
        Group {
            localizedTextView
        }
            .task(id: taskKey) {
                let resolvedLocalizer = if let localizer {
                    localizer
                } else {
                    await LiveLocalization.localizer
                }

                if let cachedText = await resolvedLocalizer.cachedLocalization(for: source) {
                    await MainActor.run {
                        displayedText = cachedText
                    }
                    return
                }

                let currentRequestVersion = await requestCoordinator.beginRequest()

                await MainActor.run {
                    displayedText = source
                }

                let localizedText = await resolvedLocalizer.localize(source)

                guard await requestCoordinator.isCurrent(currentRequestVersion) else {
                    return
                }

                await MainActor.run {
                    switch animationStyle {
                    case .none:
                        displayedText = localizedText
                    case .fade:
                        withAnimation(.easeInOut(duration: 0.2)) {
                            displayedText = localizedText
                        }
                    }
                }
            }
    }

    @ViewBuilder
    private var localizedTextView: some View {
        switch animationStyle {
        case .none:
            Text(displayedText)
        case .fade:
            Text(displayedText)
                .contentTransition(.opacity)
        }
    }

    private var taskKey: TaskKey {
        TaskKey(
            source: source,
            localizerIdentifier: localizer.map(ObjectIdentifier.init)
        )
    }
}
#endif
