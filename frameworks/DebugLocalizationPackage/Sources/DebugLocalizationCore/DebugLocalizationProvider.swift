import Foundation

public protocol DebugLocalizationProvider: Sendable {
    func localize(_ text: String, into languageIdentifier: String) async throws -> String
}

public enum DebugLocalizationError: Error {
    case emptyText
    case unsupportedTargetLanguage
    case notSupportedOnPlatform
    case translationFailed(underlying: Error)
}
