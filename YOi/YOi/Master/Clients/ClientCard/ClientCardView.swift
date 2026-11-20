import SwiftUI

struct ClientCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.currency) private var currency

    @State private var viewModel: ClientCardViewModel
    @State private var editForm: ClientFormViewModel?

    init(viewModel: ClientCardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let card = viewModel.card {
                content(card)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("clients.action.edit", systemImage: "pencil", action: edit)
            }
        }
        .task {
            await viewModel.observeClient()
        }
        .task {
            await viewModel.observeVisits()
        }
        .onChange(of: viewModel.isDeleted) {
            closeIfDeleted()
        }
        .fullScreenCover(item: $editForm, onDismiss: closeIfDeleted) { form in
            @Bindable var form = form

            ClientFormPopup(
                fields: $form.fields,
                mode: form.mode,
                errors: form.errors,
                isSaving: form.isSaving,
                onSubmit: form.submit,
                onDelete: form.delete,
                onDismiss: dismissForm
            )
            .onChange(of: form.fields) {
                form.applyMasks()
            }
            .presentationBackground(.clear)
        }
    }

    private func content(_ card: ClientCard) -> some View {
        ScrollView {
            VStack(spacing: ClientsMetrics.Spacing.cardSectionSpacing) {
                profile(card)
                contact(card)

                TimelineView(.everyMinute) { context in
                    if let visits = viewModel.visits(now: context.date, currency: currency) {
                        visitSections(visits)
                    }
                }
            }
            .padding(.horizontal, ClientsMetrics.Spacing.horizontalPadding)
            .padding(.top, ClientsMetrics.Spacing.cardTopPadding)
            .padding(.bottom, ClientsMetrics.Spacing.listBottomPadding)
        }
        .scrollIndicators(.hidden)
    }

    private func profile(_ card: ClientCard) -> some View {
        VStack(spacing: ClientsMetrics.Spacing.cardProfileSpacing) {
            ClientAvatar(initial: card.initial, size: ClientsMetrics.Size.cardAvatar)

            Text(verbatim: card.title)
                .font(.elmsSans(.semiBold, ClientsMetrics.Size.cardName))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            if let details = card.details {
                Text(verbatim: details)
                    .font(.elmsSans(.regular, ClientsMetrics.Size.cardDetails))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func contact(_ card: ClientCard) -> some View {
        if card.contacts.isEmpty {
            ClientNoContactsPlate()
        } else {
            ClientContactMenu(contacts: card.contacts) {
                contactLabel
            }
        }
    }

    @ViewBuilder
    private func visitSections(_ visits: ClientVisits) -> some View {
        if visits.planned.isEmpty == false {
            ClientVisitsSection(
                titleKey: "clients.section.planned",
                emptyKey: "clients.visits.empty",
                visits: visits.planned
            )
        }

        if visits.showsHistory {
            ClientVisitsSection(
                titleKey: "clients.section.history",
                emptyKey: "clients.visits.empty",
                visits: visits.history
            )
        }
    }

    private var contactLabel: some View {
        let shape = RoundedRectangle(cornerRadius: ClientsMetrics.Size.rowCornerRadius)

        return Group {
            if #available(iOS 26, *) {
                contactContent
                    .glassEffect(.regular.interactive(), in: shape)
            } else {
                contactContent
                    .cardSurface(padding: 0, cornerRadius: ClientsMetrics.Size.rowCornerRadius)
            }
        }
        .contentShape(shape)
    }

    private var contactContent: some View {
        HStack(spacing: ClientsMetrics.Spacing.contactIconSpacing) {
            Image(systemName: "bubble.left")
                .font(.elmsSans(.bold, ClientsMetrics.Size.contactIcon))
                .accessibilityHidden(true)

            Text("clients.contact.action")
                .font(.elmsSans(.semiBold, ClientsMetrics.Size.contactTitle))
                .lineLimit(1)
        }
        .foregroundStyle(Color.ink)
        .frame(maxWidth: .infinity, minHeight: ClientsMetrics.Size.contactMinHeight)
    }

    private func edit() {
        withoutPresentationAnimation {
            editForm = viewModel.makeEditFormViewModel()
        }
    }

    private func dismissForm() {
        withoutPresentationAnimation {
            editForm = nil
        }
    }

    private func closeIfDeleted() {
        guard viewModel.isDeleted else { return }

        if editForm != nil {
            dismissForm()
        } else {
            dismiss()
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ClientCardView(
            viewModel: ClientCardViewModel(
                clientId: ClientsPreviewData.clients[0].id ?? "",
                takenHandles: [],
                clientRepository: FakeClientRepository(clients: ClientsPreviewData.clients),
                slotRepository: FakeSlotRepository(slots: ClientsPreviewData.visits)
            )
        )
    }
}
#endif
