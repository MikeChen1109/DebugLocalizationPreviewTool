import Testing
@testable import DebugLocalizationCore

struct DebugLocalizationCoreTests {
    @Test
    func pseudoLocalizationExpandsText() async throws {
        let provider = PseudoLocalizationProvider()

        let localized = await provider.translate("Remove")

        #expect(localized.contains("["))
        #expect(localized.contains("⟪"))
        #expect(localized.count > "Remove".count)
    }

    @Test
    func stringExtensionUsesConfiguredSharedLocalizer() async {
        DebugTranslate.configure(provider: PassthroughLocalizationProvider())
        let passthrough = await "Settings".localize()

        DebugTranslate.configure(provider: PseudoLocalizationProvider())
        let pseudoLocalized = await "Settings".localize()

        #expect(passthrough == "Settings")
        #expect(pseudoLocalized != "Settings")
    }

    @Test
    func syncLocalizationUsesSyncCapableProvider() {
        DebugTranslate.configure(provider: MockLocalizationProvider())

        let localized = "Settings".localizeSync()

        #expect(localized.contains("Settings"))
    }

    @Test
    func syncLocalizationFallsBackToOriginalTextForAsyncOnlyProvider() {
        let localizer = DebugLocalizer(provider: AsyncOnlyProvider())

        #expect(localizer.localizeSync("Settings") == "Settings")
    }

    @Test
    func localizerReportsSyncCapability() {
        let syncLocalizer = DebugLocalizer(provider: PseudoLocalizationProvider())
        let asyncLocalizer = DebugLocalizer(provider: AsyncOnlyProvider())

        #expect(syncLocalizer.canLocalizeSynchronously)
        #expect(!asyncLocalizer.canLocalizeSynchronously)
    }
}

private struct AsyncOnlyProvider: LocalizationProvider {
    func translate(_ text: String) async -> String {
        "[async] \(text)"
    }
}
