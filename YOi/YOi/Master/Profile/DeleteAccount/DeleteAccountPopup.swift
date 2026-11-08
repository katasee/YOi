import SwiftUI

struct DeleteAccountPopup: View {
    @State private var viewModel: DeleteAccountViewModel
    @FocusState private var isPasswordFocused: Bool

    let onDeleted: () -> Void
    let onDismiss: () -> Void

    init(
        viewModel: DeleteAccountViewModel,
        onDeleted: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onDeleted = onDeleted
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(onDismiss: onDismiss) { dismiss in
            Text("account.delete.title")
                .font(.elmsSans(.bold, 18))
                .foregroundStyle(Color.ink)

            Text("account.delete.note")
                .font(.elmsSans(.regular, 14))
                .foregroundStyle(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            passwordField
            failureText

            HStack {
                PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)
                    .disabled(viewModel.isDeleting)

                Spacer()

                CapsuleButton(
                    titleKey: "account.delete.confirm",
                    role: .destructive,
                    isLoading: viewModel.isDeleting,
                    isEnabled: viewModel.canSubmit,
                    action: delete
                )
            }
        }
        .animation(PopupContainerLayout.fade, value: viewModel.failure != nil)
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: ProfileMetrics.Spacing.fieldLabelSpacing) {
            SectionLabel(titleKey: "account.password.current")

            SecureField("account.password.placeholder", text: $viewModel.password)
                .textContentType(.password)
                .focused($isPasswordFocused)
                .submitLabel(.done)
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

    private func delete() {
        isPasswordFocused = false

        Task { @MainActor in
            if await viewModel.delete() {
                onDeleted()
            }
        }
    }
}

#if DEBUG
#Preview("Видалення") {
    Color.background
        .overlay {
            DeleteAccountPopup(
                viewModel: DeleteAccountViewModel(
                    authRepository: FakeAuthRepository(
                        profile: ProfilePreviewData.profile,
                        password: ProfilePreviewData.password
                    ),
                    userDataRepository: FakeUserDataRepository()
                ),
                onDeleted: {},
                onDismiss: {}
            )
        }
}

#Preview("Помилка мережі") {
    Color.background
        .overlay {
            DeleteAccountPopup(
                viewModel: DeleteAccountViewModel(
                    authRepository: FakeAuthRepository(
                        profile: ProfilePreviewData.profile,
                        password: ProfilePreviewData.password
                    ),
                    userDataRepository: FakeUserDataRepository(error: AccountError.network)
                ),
                onDeleted: {},
                onDismiss: {}
            )
        }
}
#endif
