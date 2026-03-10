import Foundation

public nonisolated func currentAppLanguageIdentifier() -> String {
    if let preferred = Locale.preferredLanguages.first {
        return preferred
    }
    return "en"
}

public nonisolated func isEnglishLanguageIdentifier(_ languageIdentifier: String) -> Bool {
    Locale(identifier: languageIdentifier)
        .language
        .languageCode?
        .identifier == "en"
}
