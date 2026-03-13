import Foundation
import Testing
@testable import LiveLocalizationCore
@testable import LiveLocalizationUI

struct LiveLocalizationUITests {
    @Test
    func liveLocalizationPhaseExposesDisplayTextAndLoadingState() {
        #expect(LiveLocalizationPhase.idle(source: "Profile").displayedText == "Profile")
        #expect(LiveLocalizationPhase.loading(source: "Profile").isLoading)
        #expect(LiveLocalizationPhase.loaded(text: "Profil").displayedText == "Profil")
        #expect(!LiveLocalizationPhase.loaded(text: "Profil").isLoading)
    }

    @Test
    func sharedLocalizerIsUsedWhenNoLocalizerIsInjected() async {
        defer {
            Task {
                await LiveLocalization.reset()
            }
        }

        await LiveLocalization.configure(
            provider: MockLocalizationProvider(),
            cacheStore: MemoryLocalizationCacheStore(),
            cachePolicy: LocalizationCachePolicy(providerIdentifier: "mock")
        )

        let localizer = await LiveLocalization.localizer
        let localized = await localizer.localize("Settings")

        #expect(localized.contains("Settings"))
    }
}

#if canImport(UIKit)
import UIKit

@Suite(.serialized)
struct LiveLocalizedLabelTests {
    @Test
    @MainActor
    func labelStaysBlankWhileLoadingAndCommitsLatestLocalizedText() async throws {
        let localizer = LiveLocalizer(provider: DelayedProvider(delayNanoseconds: 50_000_000))
        let label = LiveLocalizedLabel()
        label.localizer = localizer

        label.setLocalizedText("Profile")

        #expect(label.text == nil)
        #expect(label.phase == .loading(source: "Profile"))

        try await Task.sleep(nanoseconds: 1_200_000_000)

        #expect(label.text == "[localized] Profile")
        #expect(label.phase == .loaded(text: "[localized] Profile"))
    }

    @Test
    @MainActor
    func labelUsesCachedLocalizedValueWhenAvailable() async throws {
        let localizer = LiveLocalizer(provider: MockLocalizationProvider())
        _ = await localizer.localize("Profile")

        let label = LiveLocalizedLabel()
        label.localizer = localizer

        label.setLocalizedText("Profile")

        #expect(label.text == nil)

        try await Task.sleep(nanoseconds: 1_200_000_000)

        #expect(label.text?.contains("Profile") == true)
        #expect(label.text != "Profile")
        #expect(label.phase == .loaded(text: label.text ?? ""))
    }

    @Test
    @MainActor
    func labelIgnoresStaleAsyncResults() async throws {
        let localizer = LiveLocalizer(provider: SequenceDelayedProvider())
        let label = LiveLocalizedLabel()
        label.localizer = localizer

        label.setLocalizedText("First")
        label.setLocalizedText("Second")

        #expect(label.text == nil)

        try await Task.sleep(nanoseconds: 1_300_000_000)

        #expect(label.text == "[localized] Second")
    }

    @Test
    @MainActor
    func labelProgressHandlerReceivesPhaseChanges() async throws {
        let localizer = LiveLocalizer(provider: DelayedProvider(delayNanoseconds: 50_000_000))
        let label = LiveLocalizedLabel()
        label.localizer = localizer

        var phases: [LiveLocalizationPhase] = []
        label.progressHandler = { reportedLabel, phase in
            #expect(reportedLabel === label)
            phases.append(phase)
        }

        label.setLocalizedText("Profile")

        try await Task.sleep(nanoseconds: 1_200_000_000)

        #expect(phases == [
            .loading(source: "Profile"),
            .loaded(text: "[localized] Profile")
        ])
    }

    @Test
    @MainActor
    func labelCompletionHandlerReceivesLocalizedText() async throws {
        let localizer = LiveLocalizer(provider: DelayedProvider(delayNanoseconds: 50_000_000))
        let label = LiveLocalizedLabel()
        label.localizer = localizer

        var completion: LiveLocalizationCompletion?

        label.setLocalizedText(
            "Profile",
            progressHandler: { _, _ in },
            completionHandler: { reportedLabel, result in
                #expect(reportedLabel === label)
                completion = result
            }
        )

        try await Task.sleep(nanoseconds: 1_200_000_000)

        #expect(completion == LiveLocalizationCompletion(
            source: "Profile",
            localizedText: "[localized] Profile"
        ))
    }
}

private struct DelayedProvider: LocalizationProvider {
    let delayNanoseconds: UInt64

    func translate(_ request: LocalizationRequest) async throws -> LocalizationResponse {
        try? await Task.sleep(nanoseconds: delayNanoseconds)
        return LocalizationResponse(localizedText: "[localized] \(request.sourceText)")
    }
}

private actor LockedDelayCounter {
    private var storage = 0

    func increment() -> Int {
        storage += 1
        return storage
    }
}

private struct SequenceDelayedProvider: LocalizationProvider {
    private let counter = LockedDelayCounter()

    func translate(_ request: LocalizationRequest) async throws -> LocalizationResponse {
        let callIndex = await counter.increment()
        let delayNanoseconds: UInt64 = callIndex == 1 ? 150_000_000 : 30_000_000
        try? await Task.sleep(nanoseconds: delayNanoseconds)
        return LocalizationResponse(localizedText: "[localized] \(request.sourceText)")
    }
}
#endif
