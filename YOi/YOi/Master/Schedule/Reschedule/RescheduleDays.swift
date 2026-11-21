import Foundation

struct RescheduleDays {
    private static let weeksAhead = 8

    let days: [Date]
    let initialDay: Date

    init(dateId: String, now: Date) {
        let calendar = DateFormat.calendar
        let firstDay = calendar.startOfDay(for: now)
        let day = max(DateFormat.date.date(from: dateId) ?? firstDay, firstDay)
        let lastDay = max(
            calendar.date(byAdding: .weekOfYear, value: Self.weeksAhead, to: firstDay) ?? firstDay,
            calendar.date(byAdding: .weekOfYear, value: 1, to: day) ?? day
        )
        let dayCount = calendar.dateComponents([.day], from: firstDay, to: lastDay).day ?? 0

        days = (0...dayCount).compactMap { calendar.date(byAdding: .day, value: $0, to: firstDay) }
        initialDay = day
    }
}
