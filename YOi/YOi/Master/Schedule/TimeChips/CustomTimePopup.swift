import SwiftUI

struct CustomTimePopup: View {
    @Binding var time: ClockTime
    let onAdd: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        PopupContainer(blursBackground: true, onDismiss: onDismiss) { dismiss in
            Text("schedule.fill.customTime")
                .font(.elmsSans(.bold, ScheduleMetrics.Size.fillTitle))
                .foregroundStyle(Color.ink)
                .accessibilityAddTraits(.isHeader)

            TimeWheel(
                time: $time,
                hours: WorkHours.customHours,
                minuteStep: WorkHours.minuteStep
            )

            HStack {
                PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

                Spacer()

                CapsuleButton(
                    titleKey: "schedule.fill.action.addTime",
                    role: .primary,
                    action: { add(then: dismiss) }
                )
            }
        }
    }

    private func add(then dismiss: () -> Void) {
        onAdd()
        dismiss()
    }
}

#if DEBUG
#Preview {
    @Previewable @State var time = WorkHours.defaultCustomTime

    Color.background
        .overlay {
            CustomTimePopup(
                time: $time,
                onAdd: {},
                onDismiss: {}
            )
        }
}
#endif
