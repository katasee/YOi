import SwiftUI

struct ResetPasswordPopup: View {
    @State private var viewModel: ResetPasswordViewModel
    @FocusState private var isEmailFocused: Bool

    let onDismiss: () -> Void

    init(viewModel: ResetPasswordViewModel, onDismiss: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(onDismiss: onDismiss) { dismiss in
            if viewModel.isSent {
                sentContent(dismiss: dismiss)
            } else {
                formContent(dismiss: dismiss)
            }
        }
        .animation(PopupContainerLayout.fade, value: viewModel.isSent)
        .animation(PopupContainerLayout.fade, value: viewModel.failure)
    }

    @ViewBuilder
    private func formContent(dismiss: @escaping () -> Void) -> some View {
        Text("auth.reset.title")
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)

        Text("auth.reset.note")
            .font(.elmsSans(.regular, 14))
            .foregroundStyle(Color.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

        emailField

        failureText

        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            CapsuleButton(
                titleKey: "auth.reset.submit",
                role: .primary,
                isLoading: viewModel.isSending,
                isEnabled: viewModel.canSubmit,
                action: send
            )
        }
    }

    @ViewBuilder
    private func sentContent(dismiss: @escaping () -> Void) -> some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.elmsSans(.bold, AuthMetrics.successIcon))
            .foregroundStyle(Color.freeSlot)
            .accessibilityHidden(true)

        Text("auth.reset.sentTitle")
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)

        Text("auth.reset.sentMessage")
            .font(.elmsSans(.regular, 14))
            .foregroundStyle(Color.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

        HStack {
            Spacer()

            CapsuleButton(titleKey: "common.action.done", role: .primary, action: dismiss)
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: AuthMetrics.Spacing.fieldLabelToBox) {
            Text("auth.field.email")
                .font(.elmsSans(.semiBold, AuthMetrics.FontSize.fieldLabel))
                .foregroundStyle(Color.textSecondary)

            TextField("", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isEmailFocused)
                .submitLabel(.send)
                .onSubmit(send)
                .inputFieldStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var failureText: some View {
        if let failure = viewModel.failure {
            Text(failure.messageKey)
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.destructive)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func send() {
        isEmailFocused = false

        Task {
            await viewModel.send()
        }
    }
}

#if DEBUG
#Preview("Скидання") {
    Color.background
        .overlay {
            ResetPasswordPopup(
                viewModel: ResetPasswordViewModel(
                    email: "maria@example.com",
                    authRepository: FakeAuthRepository(
                        profile: UserProfile(
                            uid: "preview-master",
                            name: "Марія",
                            email: "maria@example.com"
                        ),
                        password: "secret1"
                    )
                ),
                onDismiss: {}
            )
        }
}

#Preview("Неправильний email") {
    Color.background
        .overlay {
            ResetPasswordPopup(
                viewModel: ResetPasswordViewModel(
                    email: "maria@",
                    authRepository: FailingAuthRepository(error: .invalidEmail)
                ),
                onDismiss: {}
            )
        }
}
#endif
