import Foundation

public final class LiveLocalizer: @unchecked Sendable {
    public static var shared: LiveLocalizer {
        LiveLocalization.localizer
    }

    private let provider: any LocalizationProvider
    private let lock = NSLock()
    private var cache: [String: String] = [:]

    public init(provider: any LocalizationProvider) {
        self.provider = provider
    }

    public var canLocalizeSynchronously: Bool {
        provider is any SyncLocalizationProvider
    }

    public func localize(_ text: String) async -> String {
        let cacheKey = cacheKey(for: text)
        if let cached = cachedValue(for: cacheKey) {
            return cached
        }

        if let syncProvider = provider as? any SyncLocalizationProvider {
            let localized = syncProvider.translateSynchronously(text)
            store(localized, for: cacheKey)
            return localized
        }

        let localized = await provider.translate(text)
        store(localized, for: cacheKey)
        return localized
    }

    public func localizeSync(_ text: String) -> String {
        guard let syncProvider = provider as? any SyncLocalizationProvider else {
            return text
        }

        let cacheKey = cacheKey(for: text)
        if let cached = cachedValue(for: cacheKey) {
            return cached
        }

        let localized = syncProvider.translateSynchronously(text)
        store(localized, for: cacheKey)
        return localized
    }

    public func clearCache() {
        lock.lock()
        cache.removeAll()
        lock.unlock()
    }

    private func cachedValue(for key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return cache[key]
    }

    private func cacheKey(for text: String) -> String {
        "\(currentAppLanguageIdentifier())|\(text)"
    }

    private func store(_ value: String, for key: String) {
        lock.lock()
        cache[key] = value
        lock.unlock()
    }
}
