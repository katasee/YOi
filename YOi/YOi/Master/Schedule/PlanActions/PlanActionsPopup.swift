import SwiftUI

struct PlanActionsPopup: View {
    @Bindable var viewModel: PlanActionsViewModel
    let onUpdate: (PlanEvent) -> Void
    let onDelete: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        PopupContainer(dismissLabel: "common.action.close", onDismiss: onDismiss) { dismiss in
            SchedulePopupHeader(title: viewModel.title, subtitle: viewModel.subtitle)

            switch viewModel.mode {
            case .actions:
                PlanActionsList(
                    onChangePlan: viewModel.startChangingPlan,
                    onReschedule: viewModel.startRescheduling,
                    onDelete: { delete(then: dismiss) }
                )

                PopupDismissButton(titleKey: "common.action.close", action: dismiss)
            case .changePlan:
                ChoiceChipsEditor(
                    titleKey: "schedule.plan.template",
                    chips: viewModel.templateChips,
                    canSave: viewModel.hasPlanChanged,
                    onToggle: viewModel.selectTemplate,
                    onBack: viewModel.stopChangingPlan,
                    onSave: { savePlan(then: dismiss) }
                ) {
                    OwnPlanRow(plan: $viewModel.ownPlan)
                }
            case .reschedule:
                PlanRescheduleStep(viewModel: viewModel, onConfirm: { reschedule(then: dismiss) })
            }
        }
    }

    private func delete(then dismiss: () -> Void) {
        if let planId = viewModel.planId {
            onDelete(planId)
        }

        dismiss()
    }

    private func savePlan(then dismiss: () -> Void) {
        if let plan = viewModel.changedPlan() {
            onUpdate(plan)
        }

        dismiss()
    }

    private func reschedule(then dismiss: () -> Void) {
        if let plan = viewModel.move.movedPlan {
            onUpdate(plan)
        }

        dismiss()
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            PlanActionsPopup(
                viewModel: SchedulePreviewData.planActions,
                onUpdate: { _ in },
                onDelete: { _ in },
                onDismiss: {}
            )
        }
}
#endif
