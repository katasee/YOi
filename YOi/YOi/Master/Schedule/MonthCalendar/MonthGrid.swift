import Foundation

struct MonthGrid: Equatable {
    let start: Date

    init(containing date: Date) {
        start = DateFormat.calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    var days: [Date] {
        let calendar = DateFormat.calendar
        let count = calendar.range(
            of: .day,
            in: .month,
            for: start
        )?.count ?? 0

        return (0..<count).compactMap { calendar.date(
            byAdding: .day,
            value: $0,
            to: start
        )}
    }

    var firstWeek: [Date] {
        days
            .prefix(7)
            .sorted { Self.column(of: $0) < Self.column(of: $1) }
    }

    var leadingBlanks: Int {
        Self.column(of: start)
    }

    func shifted(by months: Int) -> MonthGrid {
        let date = DateFormat.calendar.date(
            byAdding: .month,
            value: months,
            to: start
        ) ?? start

        return MonthGrid(containing: date)
    }

    static func column(of day: Date) -> Int {
        let calendar = DateFormat.calendar
        let weekday = calendar.component(.weekday, from: day)

        return (weekday - calendar.firstWeekday + 7) % 7
    }
}
