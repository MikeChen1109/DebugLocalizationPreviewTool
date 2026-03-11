import Foundation
import Observation
import DebugLocalizationCore
#if canImport(Translation)
import Translation
#endif

@MainActor
@Observable
public final class TranslationPreparationCoordinator {
    enum PreparationAvailability: Sendable {
        case installed
        case supported
        case unsupported
    }

    public enum State {
        case checking
        case ready
#if canImport(Translation)
        case needsDownload(AppleTranslationProvider.Preparation)
#endif
    }

    public private(set) var state: State = .checking
    public private(set) var downloadStatusMessage: String?

    private var currentLanguageIdentifier = ""
    private let appLanguageIdentifier: () -> String
    private let preparationResolver: (String) async -> AppleTranslationProvider.Preparation?
    private let availabilityStatusProvider: (AppleTranslationProvider.Preparation) async -> PreparationAvailability
    private let installationWaiter: (AppleTranslationProvider.Preparation?) async -> Bool

#if canImport(Translation)
    public private(set) var translationConfiguration: TranslationSession.Configuration?
    private var activePreparationRequest: AppleTranslationProvider.Preparation?
    public private(set) var isPreparingTranslation = false
#endif

    public init() {
        self.appLanguageIdentifier = currentAppLanguageIdentifier
        self.preparationResolver = AppleTranslationProvider.preparation
        self.availabilityStatusProvider = Self.systemAvailabilityStatus
        self.installationWaiter = Self.waitForInstallationStatus
    }

    init(
        appLanguageIdentifier: @escaping () -> String,
        preparationResolver: @escaping (String) async -> AppleTranslationProvider.Preparation?,
        availabilityStatusProvider: @escaping (AppleTranslationProvider.Preparation) async -> PreparationAvailability,
        installationWaiter: @escaping (AppleTranslationProvider.Preparation?) async -> Bool
    ) {
        self.appLanguageIdentifier = appLanguageIdentifier
        self.preparationResolver = preparationResolver
        self.availabilityStatusProvider = availabilityStatusProvider
        self.installationWaiter = installationWaiter
    }

    public func refresh(force: Bool = false) async {
        let latestLanguageIdentifier = appLanguageIdentifier()
        guard force || latestLanguageIdentifier != currentLanguageIdentifier else { return }

        currentLanguageIdentifier = latestLanguageIdentifier
        state = .checking
        downloadStatusMessage = nil

#if canImport(Translation)
        if #available(iOS 18.0, *) {
            guard let request = await preparationResolver(latestLanguageIdentifier) else {
                state = .ready
                return
            }

            let status = await availabilityStatusProvider(request)

            switch status {
            case .installed:
                state = .ready
            case .supported:
                state = .needsDownload(request)
                if !isPreparingTranslation {
                    downloadStatusMessage = "The language pack is not ready yet. Tap to start or resume the download."
                }
            case .unsupported:
                print("Translation preparation unsupported for language: \(latestLanguageIdentifier)")
                state = .ready
            }
        } else {
            state = .ready
        }
#else
        state = .ready
#endif
    }

#if canImport(Translation)
    @available(iOS 18.0, *)
    public func startPreparation(for request: AppleTranslationProvider.Preparation) {
        downloadStatusMessage = "Waiting for the system translation download to finish."
        activePreparationRequest = request
        isPreparingTranslation = true
        translationConfiguration = TranslationSession.Configuration(
            source: request.sourceLanguage,
            target: request.targetLanguage
        )
    }

    @available(iOS 18.0, *)
    public func prepareTranslation(using session: sending TranslationSession) async {
        do {
            try await session.prepareTranslation()
            await completePreparation(with: .success(()))
        } catch {
            await completePreparation(with: .failure(error))
        }
    }

    @available(iOS 18.0, *)
    func completePreparation(with result: Result<Void, any Error>) async {
        let request = activePreparationRequest
        var statusMessage: String?

        switch result {
        case .success:
            break
        case .failure(let error):
            switch error {
            case CocoaError.userCancelled:
                print("Translation preparation cancelled by user.")
                statusMessage = "The sheet was dismissed. If the download already started, iOS may keep downloading in the background."
            case TranslationError.unsupportedTargetLanguage:
                print("Translation preparation failed: unsupported target language.")
                statusMessage = "This target language isn't supported by Translation."
            case TranslationError.unsupportedSourceLanguage:
                print("Translation preparation failed: unsupported source language.")
                statusMessage = "This source language isn't supported by Translation."
            case TranslationError.unsupportedLanguagePairing:
                print("Translation preparation failed: unsupported language pairing.")
                statusMessage = "This language pair isn't supported."
            default:
                print("Translation preparation failed. Error: \(error)")
                statusMessage = "The download didn't complete. Tap again to retry."
            }
        }

        let isInstalled = await installationWaiter(request)

        translationConfiguration = nil
        activePreparationRequest = nil
        isPreparingTranslation = false

        if isInstalled {
            downloadStatusMessage = nil
            state = .ready
            return
        }

        await refresh(force: true)

        if let statusMessage {
            downloadStatusMessage = statusMessage
        } else if case .needsDownload = state {
            downloadStatusMessage = "The language pack is still downloading or waiting to start. You can tap again to check its status."
        }
    }

    @available(iOS 18.0, *)
    public func displayName(for language: Locale.Language) -> String {
        let identifier = language.languageCode?.identifier ?? "unknown"
        return Locale.current.localizedString(forLanguageCode: identifier) ?? identifier
    }

    @available(iOS 18.0, *)
    private func waitForInstallationIfNeeded(_ request: AppleTranslationProvider.Preparation?) async -> Bool {
        await Self.waitForInstallationStatus(request)
    }

    @available(iOS 18.0, *)
    private static func systemAvailabilityStatus(_ request: AppleTranslationProvider.Preparation) async -> PreparationAvailability {
        let availability = LanguageAvailability()
        let status = await availability.status(from: request.sourceLanguage, to: request.targetLanguage)
        switch status {
        case .installed:
            return .installed
        case .supported:
            return .supported
        case .unsupported:
            return .unsupported
        @unknown default:
            return .unsupported
        }
    }

    @available(iOS 18.0, *)
    private static func waitForInstallationStatus(_ request: AppleTranslationProvider.Preparation?) async -> Bool {
        guard let request else { return false }

        for _ in 0..<15 {
            let status = await systemAvailabilityStatus(request)
            switch status {
            case .installed:
                return true
            case .supported:
                try? await Task.sleep(for: .seconds(1))
            case .unsupported:
                return false
            }
        }

        return false
    }
#endif

    public var downloadButtonTitle: String {
        if downloadStatusMessage == nil {
            return "Download Translation"
        }
        return "Retry / Check Again"
    }
}
