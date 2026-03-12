import Foundation
import Testing
@testable import LiveLocalizationCore

@Suite(.serialized)
struct LiveLocalizationCoreTests {
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
        defer { LiveLocalization.reset() }

        LiveLocalization.configure(provider: PassthroughLocalizationProvider())
        let passthrough = await "Settings".localize()

        LiveLocalization.configure(provider: PseudoLocalizationProvider())
        let pseudoLocalized = await "Settings".localize()

        #expect(passthrough == "Settings")
        #expect(pseudoLocalized != "Settings")
    }

    @Test
    func syncLocalizationUsesSyncCapableProvider() {
        defer { LiveLocalization.reset() }

        LiveLocalization.configure(provider: MockLocalizationProvider())

        let localized = "Settings".localizeSync()

        #expect(localized.contains("Settings"))
    }

    @Test
    func syncLocalizationFallsBackToOriginalTextForAsyncOnlyProvider() {
        let localizer = LiveLocalizer(provider: AsyncOnlyProvider())

        #expect(localizer.localizeSync("Settings") == "Settings")
    }

    @Test
    func asyncLocalizationUsesAsyncOnlyProvider() async {
        let localizer = LiveLocalizer(provider: AsyncOnlyProvider())

        let localized = await localizer.localize("Settings")

        #expect(localized == "[async] Settings")
    }

    @Test
    func asyncLocalizationCachesAsyncProviderResults() async {
        let counter = LockedCounter()
        let localizer = LiveLocalizer(provider: CountingAsyncProvider(counter: counter))

        let first = await localizer.localize("Settings")
        let second = await localizer.localize("Settings")

        #expect(first == "[async-1] Settings")
        #expect(second == first)
        #expect(counter.value == 1)
    }

    @Test
    func localizerReportsSyncCapability() {
        let syncLocalizer = LiveLocalizer(provider: PseudoLocalizationProvider())
        let asyncLocalizer = LiveLocalizer(provider: AsyncOnlyProvider())

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
