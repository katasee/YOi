import SwiftUI

struct RevenueCard: View {
    let stats: MonthlyStats

    var body: some View {
        VStack(spacing: StatsMetrics.Spacing.revenueContentSpacing) {
            Text("stats.revenue.title")
                .font(.elmsSans(.medium, 15))
                .foregroundStyle(Color.textSecondary)

            Text(verbatim: stats.revenueLabel)
                .font(.elmsSans(.bold, StatsMetrics.Size.revenueValue))
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            trendRow

            expectedRow
        }
        .frame(maxWidth: .infinity)
        .cardSurface(
            padding: StatsMetrics.Spacing.revenuePadding,
            cornerRadius: StatsMetrics.Size.cardCornerRadius
        )
    }

    @ViewBuilder
    private var trendRow: some View {
        if let trend = stats.revenueTrend {
            StatsTrendLabel(trend: trend)
        }
    }

    @ViewBuilder
    private var expectedRow: some View {
        if let expectedLabel = stats.expectedLabel {
            VStack(spacing: StatsMetrics.Spacing.expectedSpacing) {
                Rectangle()
                    .fill(Color.ink.opacity(StatsMetrics.Opacity.divider))
                    .frame(height: StatsMetrics.Size.dividerHeight)

                HStack(spacing: StatsMetrics.Spacing.expectedSpacing) {
                    Text("stats.revenue.expected")
                        .font(.elmsSans(.regular, 14))
                        .foregroundStyle(Color.textSecondary)

                    Text(verbatim: expectedLabel)
                        .font(.elmsSans(.bold, 14))
                        .foregroundStyle(Color.wine)
                }
            }
            .padding(.top, StatsMetrics.Spacing.expectedTopPadding)
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 14) {
        RevenueCard(
            stats: MonthlyStats(
                totals: StatsCalculator.totals(
                    slots: StatsPreviewData.slots,
                    monthStart: StatsCalculator.monthStart(containing: .now),
                    previous: nil,
                    now: .now
                ),
                currency: .pln
            )
        )

        RevenueCard(
            stats: MonthlyStats(
                totals: StatsCalculator.totals(
                    slots: [],
                    monthStart: StatsCalculator.monthStart(containing: .now),
                    previous: nil,
                    now: .now
                ),
                currency: .pln
            )
        )
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
#endif
