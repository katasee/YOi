import SwiftUI

private struct PlanHistoryRow: View {
    let item: PlanHistoryItem

    var body: some View {
        HStack(spacing: PlansMetrics.Spacing.rowContentSpacing) {
            Text(verbatim: item.dateText)
                .font(.elmsSans(.semiBold, PlansMetrics.Size.historyDate))
                .foregroundStyle(Color.ink)

            Spacer(minLength: 0)

            Text(verbatim: item.timeText)
                .font(.elmsSans(.medium, PlansMetrics.Size.historyTime))
                .foregroundStyle(Color.ink)
        }
        .padding(.horizontal, PlansMetrics.Spacing.historyRowHorizontalPadding)
        .padding(.vertical, PlansMetrics.Spacing.historyRowVerticalPadding)
    }
}

struct PlanHistorySection: View {
    let titleKey: LocalizedStringKey
    let emptyKey: LocalizedStringKey
    let items: [PlanHistoryItem]

    var body: some View {
        VStack(alignment: .leading, spacing: PlansMetrics.Spacing.historySectionSpacing) {
            SectionLabel(titleKey: titleKey)
                .padding(.horizontal, PlansMetrics.Spacing.historyLabelInset)

            if items.isEmpty {
                Text(emptyKey)
                    .font(.elmsSans(.regular, PlansMetrics.Size.historyEmpty))
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PlansMetrics.Spacing.historyEmptyPadding)
            } else {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        if item.id != items.first?.id {
                            Color.hairline
                                .frame(height: PlansMetrics.Size.dividerHeight)
                        }

                        PlanHistoryRow(item: item)
                    }
                }
                .cardSurface(padding: 0, cornerRadius: PlansMetrics.Size.rowCornerRadius)
            }
        }
    }
}

#if DEBUG
#Preview {
    PlanHistorySection(
        titleKey: "plans.section.planned",
        emptyKey: "plans.history.empty",
        items: PlansPreviewData.events.map(PlanHistoryItem.init)
    )
    .padding()
    .background(Color.background)
}
#endif
