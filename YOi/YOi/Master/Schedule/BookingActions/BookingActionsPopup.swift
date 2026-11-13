import SwiftUI

struct BookingActionsPopup: View {
    let viewModel: BookingActionsViewModel
    let onOpenCard: (String) -> Void
    let onRescheduled: (String) -> Void
    let onCutPlans: (WindowReplacement) -> Void
    let onDismiss: () -> Void

    @State private var isConfirmingCancel = false
    @State private var newServiceForm: ServiceFormViewModel?

    var body: some View {
        PopupContainer(onDismiss: onDismiss) { dismiss in
            if viewModel.isConfirmingReplace == false {
                SchedulePopupHeader(title: viewModel.title, subtitle: viewModel.subtitle)
            }

            switch viewModel.mode {
            case .actions:
                BookingActionsList(
                    contacts: viewModel.contacts,
                    canOpenCard: viewModel.cardClientId != nil,
                    onChangeService: viewModel.startChangingService,
                    onReschedule: viewModel.startRescheduling,
                    onOpenCard: { openCard(then: dismiss) },
                    onCancelBooking: confirmCancel
                )
                .alert("schedule.actions.cancel.title", isPresented: $isConfirmingCancel) {
                    Button("schedule.actions.cancelBooking", role: .destructive) {
                        cancelBooking(then: dismiss)
                    }

                    Button("common.action.back", role: .cancel) {}
                } message: {
                    Text("schedule.actions.cancel.message")
                }

                PopupDismissButton(titleKey: "common.action.close", action: dismiss)
            case .changeService:
                ChoiceChipsEditor(
                    titleKey: "schedule.book.service",
                    chips: viewModel.services,
                    add: ChoiceChipsAdd(titleKey: "schedule.book.newService", action: addService),
                    reorder: ChoiceChipsReorder(move: viewModel.moveService, commit: viewModel.commitServiceOrder),
                    canSave: viewModel.hasServiceChanged,
                    onToggle: viewModel.toggleService,
                    onBack: viewModel.stopChangingService,
                    onSave: { saveService(then: dismiss) }
                )
            case .reschedule:
                RescheduleStep(viewModel: viewModel, onConfirm: { reschedule(then: dismiss) })
            case .confirmReplace:
                if let replacement = viewModel.replacement {
                    ReplaceConfirmStep(
                        replacement: replacement,
                        onBack: viewModel.stopConfirmingReplace,
                        onConfirm: { replace(replacement, then: dismiss) }
                    )
                } else {
                    RescheduleStep(viewModel: viewModel, onConfirm: { reschedule(then: dismiss) })
                }
            case .rescheduled(let message):
                RescheduleNotifyStep(
                    message: message,
                    contacts: viewModel.contacts,
                    onDone: dismiss
                )
            }
        }
        .newServiceForm($newServiceForm, onSaved: viewModel.select(newService:))
    }

    private func openCard(then dismiss: () -> Void) {
        guard let clientId = viewModel.cardClientId else { return }

        onOpenCard(clientId)
        dismiss()
    }

    private func confirmCancel() {
        isConfirmingCancel = true
    }

    private func cancelBooking(then dismiss: () -> Void) {
        viewModel.cancelBooking()
        dismiss()
    }

    private func reschedule(then dismiss: () -> Void) {
        guard let dayId = viewModel.reschedule() else {
            dismiss()
            return
        }

        onRescheduled(dayId)
    }

    private func replace(_ replacement: WindowReplacement, then dismiss: () -> Void) {
        guard let dayId = viewModel.rescheduleReplacing() else {
            dismiss()
            return
        }

        onCutPlans(replacement)
        onRescheduled(dayId)
    }

    private func addService() {
        withoutPresentationAnimation {
            newServiceForm = viewModel.makeNewServiceForm()
        }
    }

    private func saveService(then dismiss: () -> Void) {
        viewModel.saveService()
        dismiss()
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            BookingActionsPopup(
                viewModel: SchedulePreviewData.bookingActions,
                onOpenCard: { _ in },
                onRescheduled: { _ in },
                onCutPlans: { _ in },
                onDismiss: {}
            )
        }
}
#endif
