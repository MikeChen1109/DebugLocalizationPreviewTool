import Foundation

public extension String {
    func localize() async -> String {
        let localizer = await LiveLocalization.localizer
        return await localizer.localize(self)
    }

    func localize(
        sourceLanguageIdentifier: String? = nil,
        targetLanguageIdentifier: String? = nil,
        context: String? = nil
    ) async -> String {
        let localizer = await LiveLocalization.localizer
        let request = LocalizationRequest(
            sourceText: self,
            sourceLanguageIdentifier: sourceLanguageIdentifier,
            targetLanguageIdentifier: targetLanguageIdentifier,
            context: context
        )
        return await localizer.localize(request)
    }

    func localize(using localizer: LiveLocalizer) async -> String {
        await localizer.localize(self)
    }

    func localize(
        using localizer: LiveLocalizer,
        sourceLanguageIdentifier: String? = nil,
        targetLanguageIdentifier: String? = nil,
        context: String? = nil
    ) async -> String {
        let request = LocalizationRequest(
            sourceText: self,
            sourceLanguageIdentifier: sourceLanguageIdentifier,
            targetLanguageIdentifier: targetLanguageIdentifier,
            context: context
        )
        return await localizer.localize(request)
    }
}
