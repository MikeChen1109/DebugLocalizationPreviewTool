import Foundation

actor LiveLocalizationTextRequestCoordinator {
    private var currentRequestVersion = 0

    func beginRequest() -> Int {
        currentRequestVersion += 1
        return currentRequestVersion
    }

    func invalidateCurrentRequest() {
        currentRequestVersion += 1
    }

    func isCurrent(_ requestVersion: Int) -> Bool {
        return requestVersion == currentRequestVersion
    }
}
