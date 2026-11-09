import SwiftUI

struct SendSchedulePopup: View {
    @Bindable var viewModel: SendScheduleViewModel
    let onDismiss: () -> Void

    var body: some View {
        PopupContainer(onDismiss: onDismiss) { dismiss in
            switch viewModel.mode {
            case .text:
                textStep

                PopupDismissButton(titleKey: "common.action.close", action: dismiss)
            case .recipient:
                recipientStep
            case .contacts(let recipient):
                contactsStep(recipient)
            }
        }
    }

    private var textStep: some View {
        SendScheduleTextStep(
            monthTitle: viewModel.monthTitle,
            canGoBack: viewModel.canGoBack,
            text: viewModel.text,
            onPrevious: viewModel.showPreviousMonth,
            onNext: viewModel.showNextMonth,
            onCopy: copy,
            onSend: viewModel.startSending
        )
    }

    private var recipientStep: some View {
        SendScheduleRecipientStep(
            searchText: $viewModel.searchText,
            subtitle: viewModel.monthTitle,
            options: viewModel.options,
            onPick: pick,
            onBack: viewModel.back
        )
    }

    private func contactsStep(_ recipient: ClientItem) -> some View {
        SendScheduleContactsStep(
            recipient: recipient,
            message: viewModel.text ?? "",
            onBack: viewModel.back
        )
    }

    private func pick(_ clientId: String) {
        viewModel.pick(clientId)
        copy()
    }

    private func copy() {
        UIPasteboard.general.string = viewModel.text
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            SendSchedulePopup(viewModel: SchedulePreviewData.sendSchedule, onDismiss: {})
        }
}
#endif
