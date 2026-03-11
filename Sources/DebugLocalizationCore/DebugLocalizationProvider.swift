import Foundation

/// A pluggable translation backend used by `DebugLocalizer` and `DebugTranslate`.
public protocol LocalizationProvider: Sendable {
    func translate(_ text: String) async -> String
}

/// A translation provider that can return results immediately without async work.
public protocol SyncLocalizationProvider: LocalizationProvider {
    func translateSynchronously(_ text: String) -> String
}

public extension SyncLocalizationProvider {
    func translate(_ text: String) async -> String {
        translateSynchronously(text)
    }
}

public enum DebugLocalizationError: Error {
    case emptyText
    case unsupportedTargetLanguage
    case notSupportedOnPlatform
    case translationFailed(underlying: Error)
}
