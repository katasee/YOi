import SwiftUI

struct MonthDayCell: View {
    let day: MonthDay
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: ScheduleMetrics.Spacing.dayDotSpacing) {
                Text(verbatim: day.numberText)
                    .font(.elmsSans(day.isToday ? .semiBold : .medium, ScheduleMetrics.Size.dayNumber))
                    .foregroundStyle(numberColor)
                    .frame(width: ScheduleMetrics.Size.daySelection, height: ScheduleMetrics.Size.daySelection)
                    .background {
                        if day.isSelected {
                            selectionCircle
                        } else if day.isToday {
                            Circle()
                                .strokeBorder(Color.wine, lineWidth: ScheduleMetrics.Size.todayRing)
                        }
                    }

                Circle()
                    .fill(dotColor)
                    .frame(width: ScheduleMetrics.Size.dayDot, height: ScheduleMetrics.Size.dayDot)
            }
            .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.dayCellHeight)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(day.isEnabled == false)
        .accessibilityAddTraits(day.isSelected ? .isSelected : [])
        .accessibilityValue(day.hasSlots ? Text("schedule.day.hasSlots") : Text(verbatim: ""))
    }

    @ViewBuilder
    private var selectionCircle: some View {
        if #available(iOS 26, *) {
            Color.clear
                .glassEffect(.primary, in: .circle)
        } else {
            Circle()
                .fill(Color.primaryFill)
                .brandShadow()
        }
    }

    private var dotColor: Color {
        if let conflict = day.conflict {
            ConflictMark(conflict).color
        } else if day.hasSlots {
            Color.wine
        } else {
            Color.clear
        }
    }

    private var numberColor: Color {
        if day.isSelected {
            Color.onPrimary
        } else if day.isEnabled == false {
            Color.textTertiary
        } else if day.isToday {
            Color.wine
        } else {
            Color.ink
        }
    }
}

#if DEBUG
#Preview {
    HStack {
        ForEach(SchedulePreviewData.dayStates) { day in
            MonthDayCell(day: day, action: {})
        }
    }
    .padding()
    .background(Color.background)
}
#endif
