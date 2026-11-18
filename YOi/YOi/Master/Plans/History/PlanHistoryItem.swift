import Foundation

struct PlanHistoryItem: Identifiable {
    let id: String
    let dateText: String
    let timeText: String

    init(event: PlanEvent) {
        id = event.id ?? "\(event.date) \(event.startTime)"
        dateText = DateFormat.date.date(from: event.date).map(DateFormat.weekdayDayMonth.string(from:)) ?? event.date
        timeText = "\(DateFormat.displayTime(event.startTime))–\(DateFormat.displayTime(event.endTime))"
    }
}
