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
        cache[cacheKey(for: LocalizationRequest(sourceText: text))]
    }

    /// Returns a cached localized value for the given request if one is already available.
    public func cachedLocalization(for request: LocalizationRequest) -> String? {
        cache[cacheKey(for: request)]
    }

    public func localize(_ text: String) async -> String {
        await localize(LocalizationRequest(sourceText: text))
    }

    public func localize(_ request: LocalizationRequest) async -> String {
        let cacheKey = cacheKey(for: request)
        if let cached = cache[cacheKey] {
            return cached
        }

        if let syncProvider = provider as? any SyncLocalizationProvider {
            do {
                let response = try syncProvider.translateSynchronously(request)
                cache[cacheKey] = response.localizedText
                return response.localizedText
            } catch {
                return request.sourceText
            }
        }

        do {
            let response = try await provider.translate(request)
            cache[cacheKey] = response.localizedText
            return response.localizedText
        } catch {
            return request.sourceText
        }
    }

    public func clearCache() {
        cache.removeAll()
    }

    private func cacheKey(for request: LocalizationRequest) -> String {
        let targetLanguageIdentifier = request.targetLanguageIdentifier ?? currentAppLanguageIdentifier()
        let sourceLanguageIdentifier = request.sourceLanguageIdentifier ?? ""
        let context = request.context ?? ""
        return "\(sourceLanguageIdentifier)|\(targetLanguageIdentifier)|\(context)|\(request.sourceText)"
    }
}
