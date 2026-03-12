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
        defer {
            Task {
                await LiveLocalization.reset()
            }
        }

        await LiveLocalization.configure(provider: PassthroughLocalizationProvider())
        let passthrough = await "Settings".localize()

        await LiveLocalization.configure(provider: PseudoLocalizationProvider())
        let pseudoLocalized = await "Settings".localize()

        #expect(passthrough == "Settings")
        #expect(pseudoLocalized != "Settings")
    }

    @Test
    func asyncLocalizationUsesSyncCapableProvider() async {
        defer {
            Task {
                await LiveLocalization.reset()
            }
        }

        await LiveLocalization.configure(provider: MockLocalizationProvider())

        let localized = await "Settings".localize()

        #expect(localized.contains("Settings"))
    }

    @Test
    func cachedLocalizationReturnsNilForUnknownValue() async {
        let localizer = LiveLocalizer(provider: AsyncOnlyProvider())

        #expect(await localizer.cachedLocalization(for: "Settings") == nil)
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
        #expect(await counter.value == 1)
    }

    @Test
    func localizerReportsSyncCapability() async {
        let syncLocalizer = LiveLocalizer(provider: PseudoLocalizationProvider())
        let asyncLocalizer = LiveLocalizer(provider: AsyncOnlyProvider())

        #expect(await syncLocalizer.canLocalizeSynchronously)
        #expect(await !asyncLocalizer.canLocalizeSynchronously)
    }
}

private struct AsyncOnlyProvider: LocalizationProvider {
    func translate(_ text: String) async -> String {
        "[async] \(text)"
    }
}

private actor LockedCounter {
    private var storage = 0

    var value: Int {
        return storage
    }

    func increment() -> Int {
        storage += 1
        return storage
    }
}

private struct CountingAsyncProvider: LocalizationProvider {
    let counter: LockedCounter

    func translate(_ text: String) async -> String {
        let callCount = await counter.increment()
        return "[async-\(callCount)] \(text)"
    }
}
