import SwiftUI

struct PlanRescheduleStep: View {
    @Bindable var viewModel: PlanActionsViewModel
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            RescheduleDayScroller(
                selectedDate: $viewModel.move.day,
                days: viewModel.move.days,
                markedDays: viewModel.move.markedDays
            )
            .padding(.horizontal, -PopupContainerLayout.cardPadding)

            SectionLabel(titleKey: "schedule.plan.time")

            PlanTimeFields(times: $viewModel.move.times)

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
    PlanRescheduleStep(viewModel: SchedulePreviewData.planActions, onConfirm: {})
        .padding()
        .background(Color.card)
}
#endif
