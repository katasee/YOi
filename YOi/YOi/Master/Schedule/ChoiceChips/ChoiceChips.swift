import SwiftUI

struct ChoiceChipsAdd {
    let titleKey: LocalizedStringKey
    let action: () -> Void
}

struct ChoiceChips: View {
    let chips: [ChoiceChip]
    let onToggle: (String) -> Void
    var add: ChoiceChipsAdd?

    var body: some View {
        ChoiceChipsLayout(spacing: ScheduleMetrics.Spacing.chipSpacing) {
            ForEach(chips) { chip in
                Button {
                    onToggle(chip.id)
                } label: {
                    Text(verbatim: chip.title)
                        .choiceChipLabel()
                        .foregroundStyle(chip.isSelected ? Color.onPrimary : Color.ink)
                        .selectableSurface(isSelected: chip.isSelected, in: .capsule)
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(chip.isSelected ? .isSelected : [])
            }

            if let add {
                Button(action: add.action) {
                    Label(add.titleKey, systemImage: "plus")
                        .choiceChipLabel()
                        .foregroundStyle(Color.textSecondary)
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    Color.stroke,
                                    style: StrokeStyle(
                                        lineWidth: ScheduleMetrics.Size.rowBorderWidth,
                                        dash: ScheduleMetrics.Size.rowDash
                                    )
                                )
                        }
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
