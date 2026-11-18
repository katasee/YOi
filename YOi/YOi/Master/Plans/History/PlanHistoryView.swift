import SwiftUI

struct PlanHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PlanHistoryViewModel
    @State private var formMode: PlanFormMode?

    init(viewModel: PlanHistoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            if let template = viewModel.template {
                VStack(spacing: PlansMetrics.Spacing.historySectionsSpacing) {
                    header(template)

                    TimelineView(.everyMinute) { context in
                        if let history = viewModel.history(now: context.date) {
                            sections(history)
                        }
                    }
                }
                .padding(.horizontal, PlansMetrics.Spacing.horizontalPadding)
                .padding(.top, PlansMetrics.Spacing.historyTopPadding)
                .padding(.bottom, PlansMetrics.Spacing.listBottomPadding)
            }
        }
        .scrollIndicators(.hidden)
        .overlay {
            ListStatusOverlay(
                hasLoaded: viewModel.template != nil || viewModel.hasFailed,
                isEmpty: viewModel.template == nil,
                titleKey: "plans.loadFailed.title",
                messageKey: "plans.loadFailed.message"
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("plans.action.edit", systemImage: "pencil", action: edit)
            }
        }
        .task {
            await viewModel.observeTemplate()
        }
        .task {
            await viewModel.observeEvents()
        }
        .onChange(of: viewModel.isDeleted) {
            closeIfDeleted()
        }
        .alert(
            viewModel.failure?.titleKey ?? "",
            isPresented: $viewModel.hasFailure
        ) {
            Button("common.action.ok", role: .cancel) {}
        }
        .fullScreenCover(item: $formMode, onDismiss: closeIfDeleted) { mode in
            PlanFormPopup(
                viewModel: PlanFormViewModel(mode: mode),
                onSave: viewModel.save,
                onDismiss: dismissForm
            )
            .presentationBackground(.clear)
        }
    }

    private func header(_ template: EventTemplate) -> some View {
        VStack(spacing: PlansMetrics.Spacing.historyHeaderSpacing) {
            PlanEmojiTile(emoji: template.emoji, size: .picked)

            Text(verbatim: template.name)
                .font(.elmsSans(.semiBold, PlansMetrics.Size.historyName))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func sections(_ history: PlanHistory) -> some View {
        VStack(spacing: PlansMetrics.Spacing.historySectionsSpacing) {
            if history.planned.isEmpty == false {
                PlanHistorySection(
                    titleKey: "plans.section.planned",
                    emptyKey: "plans.history.empty",
                    items: history.planned
                )
            }

            if history.showsHistory {
                PlanHistorySection(
                    titleKey: "plans.section.history",
                    emptyKey: "plans.history.empty",
                    items: history.history
                )
            }
        }
    }

    private func edit() {
        guard let template = viewModel.template else { return }

        withoutPresentationAnimation {
            formMode = .edit(template)
        }
    }

    private func dismissForm() {
        withoutPresentationAnimation {
            formMode = nil
        }
    }

    private func closeIfDeleted() {
        guard viewModel.isDeleted else { return }

        if formMode != nil {
            dismissForm()
        } else {
            dismiss()
        }
    }
}

#if DEBUG
private struct PreviewPlanRepository: EventTemplateRepository, EventRepository {
    func observeTemplates() -> AsyncThrowingStream<[EventTemplate], Error> {
        AsyncThrowingStream { $0.yield(PlansPreviewData.templates) }
    }

    func observeTemplate(id: String) -> AsyncThrowingStream<EventTemplate?, Error> {
        AsyncThrowingStream { $0.yield(PlansPreviewData.templates.first { $0.id == id }) }
    }

    func observeEvents() -> AsyncThrowingStream<[PlanEvent], Error> {
        AsyncThrowingStream { $0.yield(PlansPreviewData.events) }
    }

    func add(_ template: EventTemplate) throws {}
    func update(_ template: EventTemplate) throws {}
    func add(_ events: [PlanEvent]) throws {}
    func update(_ event: PlanEvent) throws {}
    func delete(id: String) throws {}
}

#Preview {
    NavigationStack {
        PlanHistoryView(
            viewModel: PlanHistoryViewModel(
                templateId: PlansPreviewData.templates[0].id ?? "",
                templateRepository: PreviewPlanRepository(),
                eventRepository: PreviewPlanRepository()
            )
        )
    }
}
#endif
