import SwiftUI

struct PlanHistoryView: View {
    @State private var viewModel: PlanHistoryViewModel
    @State private var formMode: PlanFormMode?

    private let onSave: (EventTemplate) -> Void

    init(viewModel: PlanHistoryViewModel, onSave: @escaping (EventTemplate) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSave = onSave
    }

    var body: some View {
        ScrollView {
            VStack(spacing: PlansMetrics.Spacing.historySectionsSpacing) {
                header

                TimelineView(.everyMinute) { context in
                    sections(viewModel.history(now: context.date))
                }
            }
            .padding(.horizontal, PlansMetrics.Spacing.horizontalPadding)
            .padding(.top, PlansMetrics.Spacing.historyTopPadding)
            .padding(.bottom, PlansMetrics.Spacing.listBottomPadding)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("plans.action.edit", systemImage: "pencil", action: edit)
            }
        }
        .fullScreenCover(item: $formMode) { mode in
            PlanFormPopup(
                viewModel: PlanFormViewModel(mode: mode),
                onSave: save,
                onDismiss: dismissForm
            )
            .presentationBackground(.clear)
        }
    }

    private var header: some View {
        VStack(spacing: PlansMetrics.Spacing.historyHeaderSpacing) {
            PlanEmojiTile(emoji: viewModel.template.emoji, size: .picked)

            Text(verbatim: viewModel.template.name)
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
        withoutPresentationAnimation {
            formMode = .edit(viewModel.template)
        }
    }

    private func save(_ template: EventTemplate) {
        viewModel.apply(template)
        onSave(template)
    }

    private func dismissForm() {
        withoutPresentationAnimation {
            formMode = nil
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PlanHistoryView(
            viewModel: PlanHistoryViewModel(template: PlansPreviewData.templates[0]),
            onSave: { _ in }
        )
    }
}
#endif
