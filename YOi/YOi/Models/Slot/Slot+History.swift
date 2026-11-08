import Foundation

extension Slot {
    static let historyMonths = 3

    static func historyStartDate(now: Date) -> Date {
        DateFormat.salonCalendar.date(byAdding: .month, value: -historyMonths, to: now) ?? now
    }

    static func historyStart(now: Date) -> String {
        DateFormat.date.string(from: historyStartDate(now: now))
    }

    static func liveMonthsStartDate(now: Date) -> Date {
        let calendar = DateFormat.salonCalendar
        let historyStart = historyStartDate(now: now)
        let components = calendar.dateComponents([.year, .month], from: historyStart)
        let start = calendar.date(from: components) ?? historyStart

        guard start < historyStart else { return start }

        return calendar.date(byAdding: .month, value: 1, to: start) ?? start
    }
}
