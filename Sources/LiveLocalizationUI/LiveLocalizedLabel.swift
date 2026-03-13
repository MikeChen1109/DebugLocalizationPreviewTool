#if canImport(UIKit)
import UIKit
import LiveLocalizationCore

/// A UIKit label that resolves localized content through ``LiveLocalizer``.
@MainActor
public final class LiveLocalizedLabel: UILabel {
    /// The localizer used by this label. When `nil`, the shared package localizer is used.
    public var localizer: LiveLocalizer?

    /// The current localization phase for this label.
    public private(set) var phase: LiveLocalizationPhase = .idle(source: "")

    /// A callback invoked whenever localization makes progress.
    public var progressHandler: ((LiveLocalizedLabel, LiveLocalizationPhase) -> Void)?

    /// A callback invoked after localized text is committed.
    public var completionHandler: ((LiveLocalizedLabel, LiveLocalizationCompletion) -> Void)?

    private var localizationTask: Task<Void, Never>?

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        localizationTask?.cancel()
    }

    /// Starts localizing the provided source string and updates the label when the result arrives.
    /// - Parameter source: The original source string to localize.
    public func setLocalizedText(_ source: String) {
        setLocalizedText(
            source,
            progressHandler: progressHandler,
            completionHandler: completionHandler
        )
    }

    /// Starts localizing the provided source string and reports progress and completion events.
    /// - Parameters:
    ///   - source: The original source string to localize.
    ///   - progressHandler: A callback that receives phase updates.
    ///   - completionHandler: A callback that runs after the localized text is committed.
    public func setLocalizedText(
        _ source: String,
        progressHandler: ((LiveLocalizedLabel, LiveLocalizationPhase) -> Void)? = nil,
        completionHandler: ((LiveLocalizedLabel, LiveLocalizationCompletion) -> Void)? = nil
    ) {
        localizationTask?.cancel()
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        updatePhase(.loading(source: source))
        text = nil

        localizationTask = Task { [weak self] in
            let resolvedLocalizer = if let localizer = self?.localizer {
                localizer
            } else {
                await LiveLocalization.localizer
            }

            let localizedText = await resolvedLocalizer.localize(source)

            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                self?.commitLocalizedText(localizedText)
            }
        }
    }

    private func commitLocalizedText(_ localizedText: String) {
        let sourceText = phase.displayedText
        text = localizedText
        updatePhase(.loaded(text: localizedText))
        completionHandler?(
            self,
            LiveLocalizationCompletion(
                source: sourceText,
                localizedText: localizedText
            )
        )
    }

    private func updatePhase(_ phase: LiveLocalizationPhase) {
        self.phase = phase
        progressHandler?(self, phase)
    }
}
#endif
