import SwiftUI

struct ClientBookingSection: View {
    @Bindable var choice: ClientBookingChoice
    var focusesSearchOnAppear = false

    @State private var newClientForm: ClientFormViewModel?

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            SearchField(
                text: $choice.searchText,
                placeholderKey: "schedule.book.search.placeholder",
                focusesOnAppear: focusesSearchOnAppear
            )

            if choice.options.isEmpty == false {
                VStack(spacing: ScheduleMetrics.Spacing.bookOptionSpacing) {
                    ForEach(choice.options) { option in
                        BookClientRow(option: option) {
                            choice.toggleClient(option.id)
                        }
                    }
                }
            }

            CapsuleButton(
                titleKey: "schedule.book.newClient",
                role: .secondary,
                systemImage: "plus",
                fillsWidth: true,
                action: openNewClientForm
            )

            SectionLabel(titleKey: "schedule.book.service")

            ChoiceChips(
                chips: choice.services,
                onToggle: choice.toggleService,
                add: ChoiceChipsAdd(titleKey: "schedule.book.newService", action: openNewServiceForm)
            )
        }
        .fullScreenCover(item: $newClientForm) { form in
            @Bindable var form = form

            ClientFormPopup(
                fields: $form.fields,
                errors: form.errors,
                isSaving: form.isSaving,
                onSubmit: form.submit,
                onDismiss: closeNewClientForm
            )
            .onChange(of: form.fields) {
                form.applyMasks()
            }
            .presentationBackground(.clear)
        }
    }

    private func openNewClientForm() {
        withoutPresentationAnimation {
            newClientForm = choice.makeNewClientForm()
        }
    }

    private func openNewServiceForm() {}

    private func closeNewClientForm() {
        if let client = newClientForm?.savedClient {
            choice.select(newClient: client)
        }

        withoutPresentationAnimation {
            newClientForm = nil
        }
    }
}

#if DEBUG
#Preview {
    ClientBookingSection(choice: SchedulePreviewData.bookClient.choice)
        .padding()
        .background(Color.card)
}
#endif
