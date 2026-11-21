import Foundation

struct MonthlyStats {
    let revenueLabel: String
    let expectedLabel: String?
    let revenueTrend: StatsTrend?
    let visitsLabel: String
    let clientsLabel: String
    let clientsTrend: StatsTrend?
    let occupancyLabel: String
    let freeSlotsLabel: String
    let isMonthFinished: Bool

    init(totals: MonthlyTotals, currency: Currency) {
        revenueLabel = ServiceFormat.price(totals.revenue, currency: currency)
        expectedLabel = totals.isMonthFinished
            ? nil
            : ServiceFormat.price(totals.expected, currency: currency)
        revenueTrend = totals.previousRevenue.flatMap {
            StatsTrend.percent(current: totals.revenue, previous: $0)
        }
        visitsLabel = totals.visits.formatted()
        clientsLabel = totals.clients.formatted()
        clientsTrend = totals.previousClients.flatMap {
            StatsTrend.count(current: totals.clients, previous: $0)
        }
        occupancyLabel = totals.windows == 0
            ? "—"
            : (Double(totals.bookedWindows) / Double(totals.windows))
                .formatted(.percent.precision(.fractionLength(0)))
        freeSlotsLabel = totals.freeSlots.formatted()
        isMonthFinished = totals.isMonthFinished
    }
}
