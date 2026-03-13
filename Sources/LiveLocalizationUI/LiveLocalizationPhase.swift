import Foundation

/// The UI state produced while resolving localized text.
public enum LiveLocalizationPhase: Sendable, Equatable {
    /// The wrapper has been created but has not started localizing yet.
    case idle(source: String)

    /// The source text is currently being localized.
    case loading(source: String)

    /// A localized value is ready to display.
    case loaded(text: String)

    /// The text that should be displayed for the current phase.
    public var displayedText: String {
        switch self {
        case .idle(let source), .loading(let source):
            source
        case .loaded(let text):
            text
        }
    }

    /// Indicates whether localization work is in progress.
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }
}
