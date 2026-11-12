import SwiftUI

struct MyServicesView: View {
    @State private var viewModel: MyServicesViewModel
    @State private var formMode: ServiceFormMode?
    @State private var openRowId: String?

    init(viewModel: MyServicesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            intro
            sectionHeader
            list
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("services.title")
                    .font(.elmsSans(.semiBold, 17))
                    .foregroundStyle(Color.ink)
            }
        }
        .task {
            await viewModel.observeServices()
        }
        .alert(
            viewModel.failure?.titleKey ?? "",
            isPresented: $viewModel.hasFailure
        ) {
            Button("common.action.ok", role: .cancel) {}
        }
        .fullScreenCover(item: $formMode) { mode in
            ServiceFormPopup(
                viewModel: viewModel.makeFormViewModel(for: mode),
                onDismiss: dismissForm
            )
            .presentationBackground(.clear)
        }
    }

    private var intro: some View {
        HStack(spacing: ServicesMetrics.Spacing.rowContentSpacing) {
            subtitle

            Spacer(minLength: 0)

            addButton
        }
        .padding(.horizontal, ServicesMetrics.Spacing.horizontalPadding)
        .padding(.top, ServicesMetrics.Spacing.introTopPadding)
    }

    private var subtitle: some View {
        Text("services.subtitle")
            .font(.elmsSans(.regular, 15))
            .foregroundStyle(Color.textSecondary)
    }

    @ViewBuilder
    private var addButton: some View {
        if #available(iOS 26, *) {
            addButtonContent
                .glassEffect(.primary.interactive(), in: .circle)
        } else {
            addButtonContent
                .background(Color.primaryFill, in: .circle)
        }
    }

    private var addButtonContent: some View {
        Button("services.action.add", systemImage: "plus", action: addService)
            .labelStyle(.iconOnly)
            .font(.elmsSans(.bold, ServicesMetrics.Size.addIcon))
            .foregroundStyle(Color.onPrimary)
            .frame(
                width: ServicesMetrics.Size.addButton,
                height: ServicesMetrics.Size.addButton
            )
            .contentShape(.circle)
    }

    @ViewBuilder
    private var sectionHeader: some View {
        if viewModel.services.isEmpty == false {
            SectionLabel(titleKey: "services.section.all", count: viewModel.services.count)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ServicesMetrics.Spacing.horizontalPadding)
            .padding(.top, ServicesMetrics.Spacing.sectionTopPadding)
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: ServicesMetrics.Spacing.rowSpacing) {
                ForEach(viewModel.services) { service in
                    SwipeToDelete(
                        id: service.id ?? "",
                        openId: $openRowId,
                        cornerRadius: ServicesMetrics.Size.rowCornerRadius,
                        onDelete: { delete(service) }
                    ) {
                        ServiceRow(
                            service: service,
                            onToggleActive: { toggleActive(service) }
                        )
                        .onTapGesture { editService(service) }
                    }
                }
            }
            .padding(.horizontal, ServicesMetrics.Spacing.horizontalPadding)
            .padding(.top, ServicesMetrics.Spacing.listTopPadding)
            .padding(.bottom, ServicesMetrics.Spacing.listBottomPadding)
        }
        .overlay {
            ListStatusOverlay(
                hasLoaded: viewModel.hasLoaded,
                isEmpty: viewModel.services.isEmpty,
                titleKey: "services.empty.title",
                messageKey: "services.empty.message"
            )
        }
    }

    private func delete(_ service: Service) {
        Task {
            await viewModel.delete(service)
        }
    }

    private func toggleActive(_ service: Service) {
        Task {
            await viewModel.toggleActive(service)
        }
    }

    private func addService() {
        withoutPresentationAnimation {
            formMode = .add(position: viewModel.nextPosition)
        }
    }

    private func editService(_ service: Service) {
        guard openRowId == nil else {
            openRowId = nil
            return
        }

        withoutPresentationAnimation {
            formMode = .edit(service)
        }
    }

    private func dismissForm() {
        withoutPresentationAnimation {
            formMode = nil
        }
    }
}

#if DEBUG
#Preview("З послугами") {
    NavigationStack {
        MyServicesView(
            viewModel: MyServicesViewModel(
                serviceRepository: FakeServiceRepository(services: ServicesPreviewData.services)
            )
        )
    }
}

#Preview("Порожній список") {
    NavigationStack {
        MyServicesView(
            viewModel: MyServicesViewModel(serviceRepository: FakeServiceRepository(services: []))
        )
    }
}
#endif
