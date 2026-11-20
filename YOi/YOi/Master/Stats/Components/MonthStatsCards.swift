import SwiftUI

struct MonthStatsCards: View {
    let stats: MonthlyStats

    var body: some View {
        VStack(spacing: StatsMetrics.Spacing.cardSpacing) {
            RevenueCard(stats: stats)

            Grid(
                horizontalSpacing: StatsMetrics.Spacing.cardSpacing,
                verticalSpacing: StatsMetrics.Spacing.cardSpacing
            ) {
                GridRow {
                    StatCard(
                        iconName: "checkmark.circle",
                        value: stats.visitsLabel,
                        titleKey: "stats.card.visits"
                    )

                    StatCard(
                        iconName: "person.2",
                        value: stats.clientsLabel,
                        titleKey: "stats.card.clients",
                        trend: stats.clientsTrend
                    )
                }

                GridRow {
                    StatCard(
                        iconName: "chart.pie",
                        value: stats.occupancyLabel,
                        titleKey: "stats.card.occupancy"
                    )

                    StatCard(
                        iconName: "square.dashed",
                        value: stats.freeSlotsLabel,
                        titleKey: stats.isMonthFinished
                            ? "stats.card.unbookedSlots"
                            : "stats.card.freeSlots"
                    )
                }
            }
        }
    }
}
