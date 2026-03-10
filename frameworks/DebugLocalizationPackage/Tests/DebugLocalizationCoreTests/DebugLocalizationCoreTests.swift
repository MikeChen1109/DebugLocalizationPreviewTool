import Testing
@testable import DebugLocalizationCore

struct DebugLocalizationCoreTests {
    @Test
    func pseudoLocalizationExpandsText() async throws {
        let provider = PseudoLocalizationProvider()

        let localized = try await provider.localize("Remove", into: "fr")

        #expect(localized.contains("[FR"))
        #expect(localized.contains("⟪"))
        #expect(localized.count > "Remove".count)
    }
}
