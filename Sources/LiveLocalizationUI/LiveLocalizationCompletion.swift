import Foundation

/// The completed output of a localization request.
public struct LiveLocalizationCompletion: Sendable, Equatable {
    /// The original source string provided to the wrapper.
    public let source: String

    /// The final localized text displayed by the wrapper.
    public let localizedText: String

    public init(source: String, localizedText: String) {
        self.source = source
        self.localizedText = localizedText
    }
}
