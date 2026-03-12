import Foundation

public extension String {
    func localize() async -> String {
        let localizer = await LiveLocalization.localizer
        return await localizer.localize(self)
    }

    func localize(using localizer: LiveLocalizer) async -> String {
        await localizer.localize(self)
    }
}
