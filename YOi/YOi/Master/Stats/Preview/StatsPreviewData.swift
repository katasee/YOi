import Foundation

#if DEBUG
enum StatsPreviewData {
    static let reference = Date.now

    static let slots: [Slot] = [
        slot(id: "done-1", day: 2, time: "10:00", price: 450, client: "client-olena"),
        slot(id: "done-2", day: 4, time: "12:00", price: 750, client: "client-maria"),
        slot(id: "done-3", day: 6, time: "14:00", price: 600, client: "client-olena"),
        slot(id: "done-legacy", day: 7, time: "16:00", price: nil, client: "client-sofia"),
        slot(id: "upcoming-1", day: 27, time: "10:00", price: 750, client: "client-maria"),
        slot(id: "upcoming-2", day: 26, time: "12:00", price: 450, client: "client-sofia"),
        slot(id: "free-1", day: 26, time: "14:00", price: nil, client: nil),
        slot(id: "free-2", day: 28, time: "09:00", price: nil, client: nil),
        slot(id: "prev-1", monthOffset: -1, day: 5, time: "10:00", price: 450, client: "client-olena"),
        slot(id: "prev-2", monthOffset: -1, day: 9, time: "10:00", price: 600, client: "client-maria")
    ]

    static let summaries: [MonthlySummary] = [
        summary(monthOffset: -4, revenue: 2400, visits: 5, clients: 4, windows: 9, bookedWindows: 5),
        summary(monthOffset: -6, revenue: 1800, visits: 4, clients: 3, windows: 8, bookedWindows: 4)
    ]

    private static func summary(
        monthOffset: Int,
        revenue: Int,
        visits: Int,
        clients: Int,
        windows: Int,
        bookedWindows: Int
    ) -> MonthlySummary {
        let calendar = DateFormat.calendar
        let start = StatsCalculator.monthStart(containing: reference)
        let month = calendar.date(byAdding: .month, value: monthOffset, to: start) ?? start

        return MonthlySummary(
            id: StatsCalculator.monthId(month),
            revenue: revenue,
            visits: visits,
            clients: clients,
            windows: windows,
            bookedWindows: bookedWindows
        )
    }

    private static func slot(
        id: String,
        monthOffset: Int = 0,
        day: Int,
        time: String,
        price: Int?,
        client: String?
    ) -> Slot {
        Slot(
            id: id,
            date: date(monthOffset: monthOffset, day: day),
            time: time,
            clientId: client,
            serviceId: client == nil ? nil : "svc-classic",
            serviceName: client == nil ? nil : "Класичний манікюр",
            servicePrice: price
        )
    }

    private static func date(monthOffset: Int, day: Int) -> String {
        let calendar = DateFormat.calendar
        let start = StatsCalculator.monthStart(containing: reference)
        let month = calendar.date(byAdding: .month, value: monthOffset, to: start) ?? start
        let target = calendar.date(byAdding: .day, value: day - 1, to: month) ?? month

        return DateFormat.date.string(from: target)
    }
}
#endif
