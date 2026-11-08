import SwiftUI

struct ServiceFormPopup: View {
    private enum Field {
        case name
        case price
    }

    @State private var viewModel: ServiceFormViewModel
    @FocusState private var focusedField: Field?

    let blursBackground: Bool
    let onDismiss: () -> Void

    init(
        viewModel: ServiceFormViewModel,
        blursBackground: Bool = false,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.blursBackground = blursBackground
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(blursBackground: blursBackground, onDismiss: onDismiss) { dismiss in
            title
            nameField
            priceField
            errorText
            actions(dismiss: dismiss)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("common.action.done", action: dismissKeyboard)
            }
        }
    }

    private var title: some View {
        Text(viewModel.mode.titleKey)
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)
    }

    private var nameField: some View {
        fieldRow("services.form.nameLabel") {
            TextField("services.form.namePlaceholder", text: $viewModel.name)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit { focusedField = .price }
        }
    }

    private var priceField: some View {
        fieldRow("services.form.priceLabel") {
            TextField("services.form.pricePlaceholder", text: $viewModel.priceText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .price)
        }
    }

    @ViewBuilder
    private var errorText: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.elmsSans(.regular, 13))
                .foregroundStyle(Color.destructive)
        }
    }

    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            CapsuleButton(
                titleKey: viewModel.mode.submitKey,
                role: .primary,
                isLoading: viewModel.isSaving,
                isEnabled: viewModel.canSubmit,
                action: { save(then: dismiss) }
            )
        }
    }

    private func save(then dismiss: @escaping () -> Void) {
        focusedField = nil

        Task { @MainActor in
            if await viewModel.submit() {
                dismiss()
            }
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }

    private func fieldRow(
        _ labelKey: LocalizedStringKey,
        @ViewBuilder control: () -> some View
    ) -> some View {
        HStack {
            Text(labelKey)
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.ink)

            Spacer()

            control()
        }
        .font(.elmsSans(.regular, 15))
    }
}

#if DEBUG
#Preview("Додавання") {
    Color.background
        .overlay {
            ServiceFormPopup(
                viewModel: ServiceFormViewModel(
                    mode: .add,
                    serviceRepository: FakeServiceRepository()
                ),
                onDismiss: {}
            )
        }
}

#Preview("Редагування") {
    Color.background
        .overlay {
            ServiceFormPopup(
                viewModel: ServiceFormViewModel(
                    mode: .edit(ServicesPreviewData.services[0]),
                    serviceRepository: FakeServiceRepository(
                        services: ServicesPreviewData.services
                    )
                ),
                onDismiss: {}
            )
        }
}
#endif
