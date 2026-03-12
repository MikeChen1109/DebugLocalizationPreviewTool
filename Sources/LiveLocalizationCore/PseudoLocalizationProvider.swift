import Foundation

/// A sync provider that expands and accents text to stress test localized UI layout.
public struct PseudoLocalizationProvider: SyncLocalizationProvider {
    public init() {}

    public func translateSynchronously(_ request: LocalizationRequest) throws -> LocalizationResponse {
        let languageIdentifier = request.targetLanguageIdentifier ?? currentAppLanguageIdentifier()
        let locale = Locale(identifier: languageIdentifier)
        let languageCode = locale.language.languageCode?.identifier ?? languageIdentifier
        let accented = accent(request.sourceText)
        let padded = pad(accented)
        return LocalizationResponse(localizedText: "[\(languageCode.uppercased()) ⟪\(padded)⟫]")
    }

    private func accent(_ text: String) -> String {
        let replacements: [Character: Character] = [
            "a": "á", "A": "Á",
            "e": "ë", "E": "Ë",
            "i": "ï", "I": "Ï",
            "o": "õ", "O": "Õ",
            "u": "ü", "U": "Ü",
            "c": "ç", "C": "Ç",
            "n": "ñ", "N": "Ñ"
        ]

        return String(text.map { replacements[$0] ?? $0 })
    }

    private func pad(_ text: String) -> String {
        guard !text.isEmpty else { return text }

        let targetLength = Int(ceil(Double(text.count) * 1.35))
        guard targetLength > text.count else { return text }

        let paddingCount = targetLength - text.count
        return text + String(repeating: "~", count: paddingCount)
    }
}

/// A sync provider that returns the original text unchanged.
public struct PassthroughLocalizationProvider: SyncLocalizationProvider {
    public init() {}

    public func translateSynchronously(_ request: LocalizationRequest) throws -> LocalizationResponse {
        LocalizationResponse(localizedText: request.sourceText)
    }
}

/// A sync provider that adds the current language code to the original text for deterministic previews.
public struct MockLocalizationProvider: SyncLocalizationProvider {
    public init() {}

    public func translateSynchronously(_ request: LocalizationRequest) throws -> LocalizationResponse {
        let languageIdentifier = request.targetLanguageIdentifier ?? currentAppLanguageIdentifier()
        let locale = Locale(identifier: languageIdentifier)
        let languageCode = locale.language.languageCode?.identifier ?? languageIdentifier
        return LocalizationResponse(localizedText: "[\(languageCode.uppercased())] \(request.sourceText)")
    }
}

@available(*, deprecated, renamed: "MockLocalizationProvider")
public typealias MockTranslationProvider = MockLocalizationProvider
