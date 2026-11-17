import SwiftUI

struct ClientsView: View {
    @State private var viewModel: ClientListViewModel
    @State private var addForm: ClientFormViewModel?
    @Environment(OnboardingTour.self) private var tour: OnboardingTour?

    init(viewModel: ClientListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let items = viewModel.items

        NavigationStack {
            VStack(spacing: 0) {
                LargeTitleHeader(titleKey: "clients.title", subtitle: subtitle) {
                    RoundIconButton(
                        systemImage: "plus",
                        accessibilityLabel: "clients.action.add",
                        action: addClient
                    )
                    .onboardingTarget(.addClient)
                }

                SearchField(text: $viewModel.searchText, placeholderKey: "clients.search.placeholder")
                    .padding(.horizontal, ClientsMetrics.Spacing.horizontalPadding)
                    .padding(.top, ClientsMetrics.Spacing.searchTopPadding)

                content(items)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ClientRoute.self) { route in
                ClientCardView(viewModel: viewModel.makeCardViewModel(id: route.id))
            }
            .task {
                await viewModel.observeClients()
            }
            .onChange(of: viewModel.totalCount > 0, initial: true) { _, hasClients in
                guard hasClients else { return }

                tour?.record([.client])
            }
            .fullScreenCover(item: $addForm) { form in
                @Bindable var form = form

                ClientFormPopup(
                    fields: $form.fields,
                    errors: form.errors,
                    isSaving: form.isSaving,
                    onSubmit: form.submit,
                    onDismiss: dismissForm
                )
                .onChange(of: form.fields) {
                    form.applyMasks()
                }
                .presentationBackground(.clear)
            }
        }
    }

    private var subtitle: String? {
        guard viewModel.hasLoaded, viewModel.hasFailed == false else { return nil }

        return String(localized: "clients.count \(viewModel.totalCount)")
    }

    private var isBaseEmpty: Bool {
        viewModel.totalCount == 0
    }

    private func content(_ items: [ClientItem]) -> some View {
        ZStack {
            if items.isEmpty == false {
                list(items)
            }

            ListStatusOverlay(
                hasLoaded: viewModel.hasLoaded,
                isEmpty: items.isEmpty,
                titleKey: emptyTitleKey,
                messageKey: emptyMessageKey
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyTitleKey: LocalizedStringKey {
        if viewModel.hasFailed {
            "clients.loadFailed.title"
        } else if isBaseEmpty {
            "clients.empty.title"
        } else {
            "clients.search.empty.title"
        }
    }

    private var emptyMessageKey: LocalizedStringKey {
        if viewModel.hasFailed {
            "clients.loadFailed.message"
        } else if isBaseEmpty {
            "clients.empty.message"
        } else {
            "clients.search.empty.message"
        }
    }

    private func list(_ items: [ClientItem]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: ClientsMetrics.Spacing.rowSpacing) {
                if viewModel.searchText.isEmpty {
                    SectionLabel(titleKey: "clients.section.recent")
                        .padding(.horizontal, ClientsMetrics.Spacing.sectionLabelInset)
                }

                ForEach(items) { item in
                    ClientRow(item: item)
                }
            }
            .padding(.horizontal, ClientsMetrics.Spacing.horizontalPadding)
            .padding(.top, ClientsMetrics.Spacing.listTopPadding)
            .padding(.bottom, ClientsMetrics.Spacing.listBottomPadding)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    private func addClient() {
        withoutPresentationAnimation {
            addForm = viewModel.makeAddFormViewModel()
        }
    }

    private func dismissForm() {
        withoutPresentationAnimation {
            addForm = nil
        }
    }
}

#if DEBUG
#Preview {
    ClientsView(
        viewModel: ClientListViewModel(
            clientRepository: FakeClientRepository(clients: ClientsPreviewData.clients),
            slotRepository: FakeSlotRepository(slots: ClientsPreviewData.visits)
        )
    )
}
#endif
