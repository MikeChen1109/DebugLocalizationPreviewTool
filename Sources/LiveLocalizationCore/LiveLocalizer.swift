import Foundation

public actor LiveLocalizer {
    private let provider: any LocalizationProvider
    private var cache: [String: String] = [:]

    public init(provider: any LocalizationProvider) {
        self.provider = provider
    }

    public var canLocalizeSynchronously: Bool {
        provider is any SyncLocalizationProvider
    }

    /// Returns a cached localized value for the given text if one is already available.
    public func cachedLocalization(for text: String) -> String? {
        cache[cacheKey(for: text)]
    }

    public func localize(_ text: String) async -> String {
        let cacheKey = cacheKey(for: text)
        if let cached = cache[cacheKey] {
            return cached
        }

        if let syncProvider = provider as? any SyncLocalizationProvider {
            let localized = syncProvider.translateSynchronously(text)
            cache[cacheKey] = localized
            return localized
        }

        let localized = await provider.translate(text)
        cache[cacheKey] = localized
        return localized
    }

    public func clearCache() {
        cache.removeAll()
    }

    private func cacheKey(for text: String) -> String {
        "\(currentAppLanguageIdentifier())|\(text)"
    }
}
