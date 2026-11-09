import SwiftUI

struct ClientFormPopup: View {
    private enum Field {
        case instagram
        case name
        case phone
    }

    @Binding var fields: ClientFormFields
    @FocusState private var focusedField: Field?

    let mode: ClientFormMode
    let errors: ClientFormErrors
    let isSaving: Bool
    let onSubmit: () async -> Bool
    let onDelete: (() async -> Bool)?
    let blursBackground: Bool
    let onDismiss: () -> Void

    init(
        fields: Binding<ClientFormFields>,
        mode: ClientFormMode = .add,
        errors: ClientFormErrors,
        isSaving: Bool,
        onSubmit: @escaping () async -> Bool,
        onDelete: (() async -> Bool)? = nil,
        blursBackground: Bool = false,
        onDismiss: @escaping () -> Void
    ) {
        _fields = fields
        self.mode = mode
        self.errors = errors
        self.isSaving = isSaving
        self.onSubmit = onSubmit
        self.onDelete = onDelete
        self.blursBackground = blursBackground
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(blursBackground: blursBackground, onDismiss: onDismiss) { dismiss in
            title
            instagramInput
            nameInput
            phoneInput
            saveError
            actions(dismiss: dismiss)

            if onDelete != nil {
                Color.hairline
                    .frame(height: ClientsMetrics.Size.dividerHeight)

                ClientDeleteButton(isDisabled: isSaving) {
                    delete(then: dismiss)
                }
            }
        }
        .onAppear(perform: focusFirstFieldIfAdding)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("common.action.done", action: dismissKeyboard)
            }
        }
    }

    private var title: some View {
        Text(mode.titleKey)
            .font(.elmsSans(.bold, 18))
            .foregroundStyle(Color.ink)
            .accessibilityAddTraits(.isHeader)
    }

    private var instagramInput: some View {
        inputRow(
            "clients.form.instagram.label",
            prefix: "@",
            error: errors.instagram
        ) {
            TextField("clients.form.instagram.placeholder", text: $fields.instagram)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .instagram)
                .submitLabel(.next)
                .onSubmit { focusedField = .name }
        }
    }

    private var nameInput: some View {
        inputRow("clients.form.name.label") {
            TextField("clients.form.name.placeholder", text: $fields.name)
                .textInputAutocapitalization(.words)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit { focusedField = .phone }
        }
    }

    private var phoneInput: some View {
        inputRow(
            "clients.form.phone.label",
            prefix: "+48",
            error: errors.phone
        ) {
            TextField("clients.form.phone.placeholder", text: $fields.phone)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .phone)
        }
    }

    @ViewBuilder
    private var saveError: some View {
        if let error = errors.save {
            errorLine(error)
        }
    }

    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)
                .disabled(isSaving)

            Spacer()

            CapsuleButton(
                titleKey: mode.submitKey,
                role: .primary,
                isLoading: isSaving,
                action: { save(then: dismiss) }
            )
        }
    }

    private func save(then dismiss: @escaping () -> Void) {
        focusedField = nil

        Task { @MainActor in
            if await onSubmit() {
                dismiss()
            }
        }
    }

    private func delete(then dismiss: @escaping () -> Void) {
        guard let onDelete else { return }

        Task { @MainActor in
            if await onDelete() {
                dismiss()
            }
        }
    }

    private func focusFirstFieldIfAdding() {
        guard mode == .add else { return }

        focusedField = .instagram
    }

    private func dismissKeyboard() {
        focusedField = nil
    }

    private func inputRow(
        _ labelKey: LocalizedStringKey,
        prefix: String? = nil,
        error: ClientFormError? = nil,
        @ViewBuilder field: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: ClientsMetrics.Spacing.fieldLabelSpacing) {
            SectionLabel(titleKey: labelKey)
                .accessibilityHidden(true)

            HStack(spacing: ClientsMetrics.Spacing.fieldPrefixSpacing) {
                if let prefix {
                    Text(verbatim: prefix)
                        .foregroundStyle(Color.textSecondary)
                        .accessibilityHidden(true)
                }

                field()
                    .accessibilityLabel(Text(labelKey))
            }
            .inputFieldStyle()

            if let error {
                errorLine(error)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func errorLine(_ error: ClientFormError) -> some View {
        Text(error.messageKey)
            .font(.elmsSans(.regular, 13))
            .foregroundStyle(Color.destructive)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var fields = ClientFormFields(
        instagram: "olya.nails",
        name: "Оля",
        phone: "600 12"
    )

    Color.background
        .overlay {
            ClientFormPopup(
                fields: $fields,
                mode: .edit,
                errors: ClientFormErrors(
                    instagram: .duplicateHandle,
                    phone: .incompletePhone
                ),
                isSaving: false,
                onSubmit: { false },
                onDelete: { true },
                onDismiss: {}
            )
        }
}
#endif
