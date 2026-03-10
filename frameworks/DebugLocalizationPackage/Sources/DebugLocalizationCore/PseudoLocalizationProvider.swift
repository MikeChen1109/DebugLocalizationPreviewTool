import Foundation

public struct PseudoLocalizationProvider: DebugLocalizationProvider {
    public init() {}

    public func localize(_ text: String, into languageIdentifier: String) async throws -> String {
        let locale = Locale(identifier: languageIdentifier)
        let languageCode = locale.language.languageCode?.identifier ?? languageIdentifier
        let accented = accent(text)
        let padded = pad(accented)
        return "[\(languageCode.uppercased()) ⟪\(padded)⟫]"
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

public struct PassthroughLocalizationProvider: DebugLocalizationProvider {
    public init() {}

    public func localize(_ text: String, into languageIdentifier: String) async throws -> String {
        text
    }
}

public struct MockTranslationProvider: DebugLocalizationProvider {
    public init() {}

    public func localize(_ text: String, into languageIdentifier: String) async throws -> String {
        let locale = Locale(identifier: languageIdentifier)
        let languageCode = locale.language.languageCode?.identifier ?? languageIdentifier
        try await Task.sleep(nanoseconds: 250_000_000)
        return "[\(languageCode.uppercased())] \(text)"
    }
}
