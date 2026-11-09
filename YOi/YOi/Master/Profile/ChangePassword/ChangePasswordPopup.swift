import SwiftUI

struct ChangePasswordPopup: View {
    private enum Field {
        case current
        case new
        case repeated
    }

    @State private var viewModel: ChangePasswordViewModel
    @FocusState private var focusedField: Field?

    let onDismiss: () -> Void

    init(viewModel: ChangePasswordViewModel, onDismiss: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(onDismiss: onDismiss) { dismiss in
            if viewModel.isChanged {
                successContent(dismiss: dismiss)
            } else {
                formContent(dismiss: dismiss)
            }
        }
        .animation(PopupContainerLayout.fade, value: viewModel.isChanged)
    }

    @ViewBuilder
    private func formContent(dismiss: @escaping () -> Void) -> some View {
        Text("account.password.title")
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)

        secureRow(
            "account.password.current",
            text: $viewModel.currentPassword,
            field: .current,
            next: .new
        )

        secureRow(
            "account.password.new",
            text: $viewModel.newPassword,
            field: .new,
            next: .repeated
        )

        secureRow(
            "account.password.repeat",
            text: $viewModel.repeatedPassword,
            field: .repeated,
            next: nil
        )

        failureText

        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            CapsuleButton(
                titleKey: "account.form.submit",
                role: .primary,
                isLoading: viewModel.isSaving,
                isEnabled: viewModel.canSubmit,
                action: submit
            )
        }
    }

    @ViewBuilder
    private func successContent(dismiss: @escaping () -> Void) -> some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.elmsSans(.bold, ProfileMetrics.Size.successIcon))
            .foregroundStyle(Color.freeSlot)
            .accessibilityHidden(true)

        Text("account.password.successTitle")
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)

        Text("account.password.successMessage")
            .font(.elmsSans(.regular, 14))
            .foregroundStyle(Color.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

        HStack {
            Spacer()

            CapsuleButton(titleKey: "common.action.done", role: .primary, action: dismiss)
        }
    }

    private func secureRow(
        _ labelKey: LocalizedStringKey,
        text: Binding<String>,
        field: Field,
        next: Field?
    ) -> some View {
        VStack(alignment: .leading, spacing: ProfileMetrics.Spacing.fieldLabelSpacing) {
            SectionLabel(titleKey: labelKey)

            SecureField("account.password.placeholder", text: text)
                .textContentType(field == .current ? .password : .newPassword)
                .focused($focusedField, equals: field)
                .submitLabel(next == nil ? .done : .next)
                .onSubmit { focusedField = next }
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

    private func submit() {
        focusedField = nil

        Task {
            await viewModel.submit()
        }
    }
}

#if DEBUG
#Preview("Зміна пароля") {
    Color.background
        .overlay {
            ChangePasswordPopup(
                viewModel: ChangePasswordViewModel(
                    authRepository: FakeAuthRepository(
                        profile: ProfilePreviewData.profile,
                        password: ProfilePreviewData.password
                    )
                ),
                onDismiss: {}
            )
        }
}

#Preview("Неправильний пароль") {
    Color.background
        .overlay {
            ChangePasswordPopup(
                viewModel: ChangePasswordViewModel(
                    authRepository: FailingAuthRepository(error: .wrongPassword)
                ),
                onDismiss: {}
            )
        }
}
#endif
