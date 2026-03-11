import Foundation
import Testing
@testable import DebugLocalizationCore

@Suite(.serialized)
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
        defer { DebugTranslate.reset() }

        DebugTranslate.configure(provider: PassthroughLocalizationProvider())
        let passthrough = await "Settings".localize()

        DebugTranslate.configure(provider: PseudoLocalizationProvider())
        let pseudoLocalized = await "Settings".localize()

        #expect(passthrough == "Settings")
        #expect(pseudoLocalized != "Settings")
    }

    @Test
    func syncLocalizationUsesSyncCapableProvider() {
        defer { DebugTranslate.reset() }

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
    func asyncLocalizationUsesAsyncOnlyProvider() async {
        let localizer = DebugLocalizer(provider: AsyncOnlyProvider())

        let localized = await localizer.localize("Settings")

        #expect(localized == "[async] Settings")
    }

    @Test
    func asyncLocalizationCachesAsyncProviderResults() async {
        let counter = LockedCounter()
        let localizer = DebugLocalizer(provider: CountingAsyncProvider(counter: counter))

        let first = await localizer.localize("Settings")
        let second = await localizer.localize("Settings")

        #expect(first == "[async-1] Settings")
        #expect(second == first)
        #expect(counter.value == 1)
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

private final class LockedCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var storage = 0

    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    func increment() -> Int {
        lock.lock()
        defer { lock.unlock() }
        storage += 1
        return storage
    }
}

private struct CountingAsyncProvider: LocalizationProvider {
    let counter: LockedCounter

    func translate(_ text: String) async -> String {
        let callCount = counter.increment()
        return "[async-\(callCount)] \(text)"
    }
}
