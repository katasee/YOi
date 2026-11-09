import SwiftUI

struct PlanFormPopup: View {
    @State private var viewModel: PlanFormViewModel
    @FocusState private var isNameFocused: Bool

    let onSave: (EventTemplate) -> Void
    let onDismiss: () -> Void

    init(
        viewModel: PlanFormViewModel,
        onSave: @escaping (EventTemplate) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSave = onSave
        self.onDismiss = onDismiss
    }

    var body: some View {
        PopupContainer(onDismiss: onDismiss) { dismiss in
            header
            nameRow
            PlanEmojiGrid(selection: $viewModel.emoji)
            actions(dismiss: dismiss)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("common.action.done", action: dismissKeyboard)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PlansMetrics.Spacing.titleSpacing) {
            Text(viewModel.mode.titleKey)
                .font(.elmsSans(.bold, 18))
                .foregroundStyle(Color.ink)

            Text("plans.form.subtitle")
                .font(.elmsSans(.regular, 14))
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var nameRow: some View {
        HStack(spacing: PlansMetrics.Spacing.nameRowSpacing) {
            PlanEmojiTile(emoji: viewModel.emoji, size: .picked)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: PlansMetrics.Spacing.nameLabelSpacing) {
                SectionLabel(titleKey: "plans.form.nameLabel")

                TextField("plans.form.namePlaceholder", text: $viewModel.name)
                    .inputFieldStyle()
                    .focused($isNameFocused)
                    .submitLabel(.done)
            }
        }
    }

    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            CapsuleButton(
                titleKey: "plans.form.save",
                role: .primary,
                isEnabled: viewModel.canSubmit,
                action: { save(then: dismiss) }
            )
        }
    }

    private func save(then dismiss: () -> Void) {
        isNameFocused = false

        guard let template = viewModel.makeTemplate() else { return }

        onSave(template)
        dismiss()
    }

    private func dismissKeyboard() {
        isNameFocused = false
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            PlanFormPopup(
                viewModel: PlanFormViewModel(
                    mode: .edit(
                        EventTemplate(
                            id: "plan-guitar",
                            emoji: "🎸",
                            name: "Гітара",
                            isActive: true
                        )
                    )
                ),
                onSave: { _ in },
                onDismiss: {}
            )
        }
}
#endif
