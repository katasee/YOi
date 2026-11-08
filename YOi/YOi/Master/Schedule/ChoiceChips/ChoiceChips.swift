import SwiftUI

struct ChoiceChipsAdd {
    let titleKey: LocalizedStringKey
    let action: () -> Void
}

struct ChoiceChips: View {
    let chips: [ChoiceChip]
    let onToggle: (String) -> Void
    var add: ChoiceChipsAdd?

    private let columns = [
        GridItem(
            .adaptive(minimum: ScheduleMetrics.Size.choiceChipMinWidth),
            spacing: ScheduleMetrics.Spacing.chipSpacing
        )
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: ScheduleMetrics.Spacing.chipSpacing) {
            ForEach(chips) { chip in
                Button {
                    onToggle(chip.id)
                } label: {
                    Text(verbatim: chip.title)
                        .font(.elmsSans(.semiBold, ScheduleMetrics.Size.chipTime))
                        .lineLimit(1)
                        .minimumScaleFactor(ScheduleMetrics.Size.chipTextScale)
                        .foregroundStyle(chip.isSelected ? Color.onPrimary : Color.ink)
                        .padding(.horizontal, ScheduleMetrics.Spacing.bookRowPadding)
                        .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.chipHeight)
                        .selectableSurface(isSelected: chip.isSelected, in: .capsule)
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(chip.isSelected ? .isSelected : [])
            }

            if let add {
                Button(action: add.action) {
                    Label(add.titleKey, systemImage: "plus")
                        .font(.elmsSans(.semiBold, ScheduleMetrics.Size.chipTime))
                        .lineLimit(1)
                        .minimumScaleFactor(ScheduleMetrics.Size.chipTextScale)
                        .foregroundStyle(Color.ink)
                        .padding(.horizontal, ScheduleMetrics.Spacing.bookRowPadding)
                        .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.chipHeight)
                        .selectableSurface(isSelected: false, in: .capsule)
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
            }
        }
        .glassEffectGroup()
    }
}

#if DEBUG
#Preview {
    ChoiceChips(
        chips: SchedulePreviewData.serviceChips,
        onToggle: { _ in },
        add: ChoiceChipsAdd(titleKey: "schedule.book.newService", action: {})
    )
        .padding()
        .background(Color.card)
}
#endif
