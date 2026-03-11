import Foundation
import Testing
@testable import DebugLocalizationTranslationSupport

struct DebugLocalizationTranslationSupportTests {
    @Test
    func appleTranslationProviderFallsBackToOriginalTextWhenTranslationFails() async {
        let provider = AppleTranslationProvider(
            appLanguageIdentifier: { "zh-Hant" },
            englishLanguageIdentifierChecker: { _ in false },
            preparationResolver: { _ in testPreparation },
            translationExecutor: { _, _ in throw DebugLocalizationTestError.expectedFailure }
        )

        let localized = await provider.translate("Settings")

        #expect(localized == "Settings")
    }

    @Test
    func appleTranslationProviderReturnsOriginalTextForEnglish() async {
        let provider = AppleTranslationProvider(
            appLanguageIdentifier: { "en" },
            englishLanguageIdentifierChecker: { _ in true },
            preparationResolver: { _ in
                Issue.record("Preparation should not be requested for English.")
                return nil
            },
            translationExecutor: { _, _ in
                Issue.record("Translation should not run for English.")
                return ""
            }
        )

        let localized = await provider.translate("Settings")

        #expect(localized == "Settings")
    }

    @Test
    @MainActor
    func refreshTransitionsToNeedsDownloadWhenLanguagePackIsSupportedButMissing() async {
        let coordinator = TranslationPreparationCoordinator(
            appLanguageIdentifier: { "zh-Hant" },
            preparationResolver: { _ in testPreparation },
            availabilityStatusProvider: { _ in .supported },
            installationWaiter: { _ in false }
        )

        await coordinator.refresh()

        switch coordinator.state {
        case .needsDownload(let request):
            #expect(request.sourceLanguage == testPreparation.sourceLanguage)
            #expect(request.targetLanguage == testPreparation.targetLanguage)
        case .checking, .ready:
            Issue.record("Expected coordinator to require download.")
        }

        #expect(coordinator.downloadStatusMessage == "The language pack is not ready yet. Tap to start or resume the download.")
    }

    @Test
    @MainActor
    func prepareTranslationRetriesAndRestoresNeedsDownloadStateWhenInstallDoesNotComplete() async {
        let coordinator = TranslationPreparationCoordinator(
            appLanguageIdentifier: { "zh-Hant" },
            preparationResolver: { _ in testPreparation },
            availabilityStatusProvider: { _ in .supported },
            installationWaiter: { _ in false }
        )
        coordinator.startPreparation(for: testPreparation)

        await coordinator.completePreparation(with: .success(()))

        switch coordinator.state {
        case .needsDownload:
            break
        case .checking, .ready:
            Issue.record("Expected coordinator to remain in needsDownload state.")
        }

        #expect(coordinator.translationConfiguration == nil)
        #expect(!coordinator.isPreparingTranslation)
        #expect(coordinator.downloadStatusMessage == "The language pack is still downloading or waiting to start. You can tap again to check its status.")
    }
}

private enum DebugLocalizationTestError: Error {
    case expectedFailure
}

@available(iOS 18.0, *)
private let testPreparation = AppleTranslationProvider.Preparation(
    sourceLanguage: Locale.Language(identifier: "en"),
    targetLanguage: Locale.Language(identifier: "zh-Hant")
)
