import Foundation

public enum LiveLocalization {
    private static let sharedStore = SharedLocalizerStore()

    public static func configure(provider: any LocalizationProvider) {
        sharedStore.setLocalizer(LiveLocalizer(provider: provider))
    }

    public static func configure(localizer: LiveLocalizer) {
        sharedStore.setLocalizer(localizer)
    }

    public static var localizer: LiveLocalizer {
        sharedStore.localizer
    }

    public static var canLocalizeSynchronously: Bool {
        localizer.canLocalizeSynchronously
    }

    public static func clearCache() {
        localizer.clearCache()
    }

    public static func reset() {
        configure(provider: PseudoLocalizationProvider())
    }
}

private final class SharedLocalizerStore: @unchecked Sendable {
    private let lock = NSLock()
    private var currentLocalizer = LiveLocalizer(provider: PseudoLocalizationProvider())

    var localizer: LiveLocalizer {
        lock.lock()
        defer { lock.unlock() }
        return currentLocalizer
    }

    func setLocalizer(_ localizer: LiveLocalizer) {
        lock.lock()
        currentLocalizer = localizer
        lock.unlock()
    }
}
