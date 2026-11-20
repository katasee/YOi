import SwiftUI

private extension Currency {
    var titleKey: LocalizedStringKey {
        switch self {
        case .pln: "currency.option.pln"
        case .uah: "currency.option.uah"
        case .usd: "currency.option.usd"
        case .eur: "currency.option.eur"
        }
    }
}

struct MonthStatsCards: View {
    let stats: MonthlyStats
    let onSelectCurrency: (Currency) -> Void

    @Environment(\.currency) private var currency

    var body: some View {
        VStack(spacing: StatsMetrics.Spacing.cardSpacing) {
            Menu {
                ForEach(Currency.allCases) { option in
                    Button {
                        onSelectCurrency(option)
                    } label: {
                        if option == currency {
                            Label(option.titleKey, systemImage: "checkmark")
                        } else {
                            Text(option.titleKey)
                        }
                    }
                }
            } label: {
                RevenueCard(stats: stats)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)

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
