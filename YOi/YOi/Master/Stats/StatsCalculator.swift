import Foundation

struct MonthlyTotals {
    let revenue: Int
    let previousRevenue: Int?
    let expected: Int
    let visits: Int
    let clients: Int
    let previousClients: Int?
    let freeSlots: Int
    let windows: Int
    let bookedWindows: Int
    let isMonthFinished: Bool
}

enum StatsCalculator {
    static func monthStart(containing date: Date) -> Date {
        let calendar = DateFormat.salonCalendar
        let components = calendar.dateComponents([.year, .month], from: date)

        return calendar.date(from: components) ?? date
    }

    static func monthId(_ monthStart: Date) -> String {
        DateFormat.month.string(from: monthStart)
    }

    static func staleMonthIds(storedIds: Set<String>, now: Date) -> [String] {
        let liveStartId = monthId(Slot.liveMonthsStartDate(now: now))

        return storedIds
            .filter { $0 >= liveStartId }
            .sorted()
    }

    static func missingMonths(storedIds: Set<String>, now: Date) -> [Date] {
        let calendar = DateFormat.salonCalendar
        let liveStart = Slot.liveMonthsStartDate(now: now)
        let liveStartId = monthId(liveStart)
        let newestFinal = storedIds
            .filter { $0 < liveStartId }
            .max()
            .flatMap(DateFormat.month.date(from:))
        let first = newestFinal.flatMap { calendar.date(byAdding: .month, value: 1, to: $0) }
            ?? calendar.date(byAdding: .month, value: -1, to: liveStart)
            ?? liveStart
        let months = sequence(first: first) {
            calendar.date(byAdding: .month, value: 1, to: $0)
        }

        return Array(months.prefix { $0 < liveStart })
    }

    static func summaries(
        months: [Date],
        slots: [Slot],
        now: Date
    ) -> [MonthlySummary] {
        months.map {
            summary(
                slots: slots,
                monthStart: $0,
                now: now
            )
        }
    }

    static func summary(
        slots: [Slot],
        monthStart: Date,
        now: Date
    ) -> MonthlySummary {
        let totals = totals(
            slots: slots,
            monthStart: monthStart,
            previous: nil,
            now: now
        )

        return MonthlySummary(
            id: monthId(monthStart),
            revenue: totals.revenue,
            visits: totals.visits,
            clients: totals.clients,
            windows: totals.windows,
            bookedWindows: totals.bookedWindows
        )
    }

    static func totals(summary: MonthlySummary, previous: MonthlySummary?) -> MonthlyTotals {
        MonthlyTotals(
            revenue: summary.revenue,
            previousRevenue: previous?.revenue,
            expected: summary.revenue,
            visits: summary.visits,
            clients: summary.clients,
            previousClients: previous?.clients,
            freeSlots: summary.windows - summary.bookedWindows,
            windows: summary.windows,
            bookedWindows: summary.bookedWindows,
            isMonthFinished: true
        )
    }

    static func totals(
        slots: [Slot],
        monthStart: Date,
        previous: MonthlySummary?,
        now: Date
    ) -> MonthlyTotals {
        let calendar = DateFormat.salonCalendar
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        let previousStart = calendar.date(byAdding: .month, value: -1, to: monthStart) ?? monthStart
        let isPreviousLive = previousStart >= Slot.liveMonthsStartDate(now: now)

        let monthSlots = slots.filter { isInside($0, start: monthStart, end: monthEnd) }
        let previousSlots = slots.filter { isInside($0, start: previousStart, end: monthStart) }

        let booked = monthSlots.filter(\.isBooked)
        let completed = booked.filter { $0.isPast(now: now) }
        let previousCompleted = previousSlots.filter { $0.isBooked && $0.isPast(now: now) }

        let isMonthFinished = monthEnd <= now

        return MonthlyTotals(
            revenue: total(of: completed),
            previousRevenue: isPreviousLive ? total(of: previousCompleted) : previous?.revenue,
            expected: total(of: booked),
            visits: completed.count,
            clients: clientIds(of: completed).count,
            previousClients: isPreviousLive ? clientIds(of: previousCompleted).count : previous?.clients,
            freeSlots: freeSlots(
                in: monthSlots,
                isMonthFinished: isMonthFinished,
                now: now
            ),
            windows: monthSlots.count,
            bookedWindows: booked.count,
            isMonthFinished: isMonthFinished
        )
    }

    private static func isInside(
        _ slot: Slot,
        start: Date,
        end: Date
    ) -> Bool {
        guard let startsAt = slot.startsAt else { return false }

        return startsAt >= start && startsAt < end
    }

    private static func total(of slots: [Slot]) -> Int {
        slots.reduce(0) { $0 + ($1.servicePrice ?? 0) }
    }

    private static func clientIds(of slots: [Slot]) -> Set<String> {
        Set(slots.compactMap(\.clientId))
    }

    private static func freeSlots(
        in slots: [Slot],
        isMonthFinished: Bool,
        now: Date
    ) -> Int {
        slots.count { slot in
            guard slot.isBooked == false else { return false }

            return isMonthFinished || slot.isPast(now: now) == false
        }
    }
}
