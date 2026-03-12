import Foundation
import LiveLocalizationCore

actor DemoLocalizationEventStore {
    private let entryLimit = 50
    private var entries: [String] = []
    private var continuations: [UUID: AsyncStream<[String]>.Continuation] = [:]

    func record(_ event: LocalizationEvent) {
        entries.insert(Self.description(for: event), at: 0)
        if entries.count > entryLimit {
            entries.removeLast(entries.count - entryLimit)
        }

        let snapshot = entries
        for continuation in continuations.values {
            continuation.yield(snapshot)
        }
    }

    func snapshots() -> AsyncStream<[String]> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation
            continuation.yield(entries)

            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.removeContinuation(withID: id)
                }
            }
        }
    }

    private func removeContinuation(withID id: UUID) {
        continuations[id] = nil
    }

    private static func description(for event: LocalizationEvent) -> String {
        switch event {
        case .sharedConfigurationStarted:
            return "Shared configuration started"
        case .sharedConfigurationFinished:
            return "Shared configuration finished"
        case .cacheWarmupStarted:
            return "Cache warmup started"
        case .cacheWarmupFinished:
            return "Cache warmup finished"
        case .cacheHit(let key):
            return "Cache hit: \(key)"
        case .cacheMiss(let key):
            return "Cache miss: \(key)"
        case .cacheStoreWrite(let key):
            return "Cache write: \(key)"
        case .cacheInvalidated(let key):
            return "Cache invalidated: \(key)"
        case .cacheCleared:
            return "Cache cleared"
        case .providerTranslationStarted(let request):
            return "Provider started: \(request.sourceText)"
        case .providerTranslationSucceeded(let request, let localizedText):
            return "Provider succeeded: \(request.sourceText) -> \(localizedText)"
        case .providerTranslationFailed(let request, let fallbackText):
            return "Provider fallback: \(request.sourceText) -> \(fallbackText)"
        }
    }
}
