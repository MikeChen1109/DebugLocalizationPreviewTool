import Foundation

public actor DebugLocalizer {
    private let provider: any DebugLocalizationProvider
    private var cache: [String: String] = [:]

    public init(provider: any DebugLocalizationProvider) {
        self.provider = provider
    }

    public func localize(_ text: String) async -> String {
        let targetLanguage = currentAppLanguageIdentifier()

        guard !isEnglishLanguageIdentifier(targetLanguage) else {
            return text
        }

        let cacheKey = "\(text)|\(targetLanguage)"
        if let cached = cache[cacheKey] {
            return cached
        }

        do {
            let localized = try await provider.localize(text, into: targetLanguage)
            cache[cacheKey] = localized
            return localized
        } catch {
            print("Debug localization fallback. Error: \(error)")
            cache[cacheKey] = text
            return text
        }
    }
}
