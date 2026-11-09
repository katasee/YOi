import Foundation
import Synchronization

#if DEBUG
final class FakeMonthlySummaryRepository: MonthlySummaryRepository {
    private struct State {
        var summaries: [MonthlySummary]
        var observers: [UUID: ([MonthlySummary]) -> Void] = [:]
    }

    private let state: Mutex<State>

    init(summaries: [MonthlySummary] = []) {
        state = Mutex(State(summaries: summaries))
    }

    func observeSummaries() -> AsyncThrowingStream<[MonthlySummary], Error> {
        let key = UUID()
        let (stream, continuation) = AsyncThrowingStream.makeStream(
            of: [MonthlySummary].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        continuation.onTermination = { [weak self] _ in
            self?.state.withLock { $0.observers[key] = nil }
        }

        state.withLock { state in
            state.observers[key] = { continuation.yield($0) }
            continuation.yield(state.summaries)
        }

        return stream
    }

    func fetchSummaryIds() async throws -> Set<String> {
        state.withLock { Set($0.summaries.compactMap(\.id)) }
    }

    func add(_ summaries: [MonthlySummary]) throws {
        state.withLock { state in
            for summary in summaries {
                guard let id = summary.id else { continue }
                guard state.summaries.contains(where: { $0.id == id }) == false else { continue }

                state.summaries.append(summary)
            }

            for observer in state.observers.values {
                observer(state.summaries)
            }
        }
    }

    func delete(ids: [String]) throws {
        state.withLock { state in
            state.summaries.removeAll { $0.id.map(ids.contains) ?? false }

            for observer in state.observers.values {
                observer(state.summaries)
            }
        }
    }
}
#endif
