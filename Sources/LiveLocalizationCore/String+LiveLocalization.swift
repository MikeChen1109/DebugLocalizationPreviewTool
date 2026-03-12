import Foundation

public extension String {
    func localize() async -> String {
        await LiveLocalizer.shared.localize(self)
    }

    func localizeSync() -> String {
        LiveLocalizer.shared.localizeSync(self)
    }

    func localize(using localizer: LiveLocalizer) async -> String {
        await localizer.localize(self)
    }

    func localizeSync(using localizer: LiveLocalizer) -> String {
        localizer.localizeSync(self)
    }
}
