import SwiftUI

struct RescheduleStep: View {
    @Bindable var viewModel: BookingActionsViewModel
    let onConfirm: () -> Void

    var body: some View {
        let times = viewModel.rescheduleTimes

        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            RescheduleDayScroller(
                selectedDate: $viewModel.rescheduleDay,
                days: viewModel.rescheduleDays,
                markedDays: viewModel.rescheduleMarkedDays
            )
            .padding(.horizontal, -PopupContainerLayout.cardPadding)

            SectionLabel(titleKey: "schedule.reschedule.freeWindows \(viewModel.rescheduleDayText)")

            if times.isEmpty {
                Text("schedule.reschedule.noWindows")
                    .font(.elmsSans(.regular, ScheduleMetrics.Size.rescheduleEmpty))
                    .foregroundStyle(Color.textSecondary)
                    .frame(minHeight: ScheduleMetrics.Size.chipHeight)
            }

            TimeChipPicker(
                times: times,
                spacing: PopupContainerLayout.rowSpacing,
                onToggle: viewModel.toggleRescheduleTime,
                onRemoveCustom: viewModel.removeCustomRescheduleTime,
                onAddCustom: viewModel.addCustomRescheduleTime
            )

            if let notice = viewModel.conflictNotice {
                ConflictNoticeView(notice: notice)
            }

            HStack {
                PopupDismissButton(titleKey: "common.action.back", action: viewModel.stopRescheduling)

                Spacer()

                if viewModel.replacement != nil {
                    ReplaceButton(action: viewModel.startConfirmingReplace)
                } else {
                    CapsuleButton(
                        titleKey: "schedule.reschedule.action",
                        role: .primary,
                        isEnabled: viewModel.canReschedule,
                        action: onConfirm
                    )
                }
            }
        }
        .animation(PopupContainerLayout.fade, value: viewModel.conflictNotice)
    }
}

#if DEBUG
#Preview {
    RescheduleStep(viewModel: SchedulePreviewData.bookingActions, onConfirm: {})
        .padding()
        .background(Color.card)
}
#endif
