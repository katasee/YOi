import Foundation

struct PlanHistory {
    let planned: [PlanHistoryItem]
    let history: [PlanHistoryItem]

    init(events: [PlanEvent], now: Date) {
        let sorted = events.sorted { ($0.date, $0.startTime) < ($1.date, $1.startTime) }

        planned = sorted
            .filter { $0.isPast(now: now) == false }
            .map(PlanHistoryItem.init)
        history = sorted
            .filter { $0.isPast(now: now) }
            .reversed()
            .map(PlanHistoryItem.init)
    }
}
