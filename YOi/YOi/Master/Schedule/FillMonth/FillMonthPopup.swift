import SwiftUI

struct FillMonthPopup: View {
    @Bindable var viewModel: FillMonthViewModel
    let addPlan: AddPlanViewModel
    let onAddPlans: ([PlanEvent]) -> AddedNotice?
    let onAdded: (AddedNotice?) -> Void
    let onDismiss: () -> Void

    @State private var tab = FillMonthTab.slots
    @State private var contentHeight: CGFloat?
    @State private var scrollPosition = ScrollPosition()

    var body: some View {
        PopupContainer(dismissLabel: "common.action.cancel", onDismiss: onDismiss) { dismiss in
            ScheduleTabs(selection: $tab)

            ScrollView {
                sections
                    .padding(ScheduleMetrics.Spacing.scrollShadowInset)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        contentHeight = height
                    }
            }
            .frame(maxHeight: contentHeight)
            .scrollPosition($scrollPosition)
            .onChange(of: addPlan.selectedTemplateId, scrollToTime)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .padding(-ScheduleMetrics.Spacing.scrollShadowInset)

            if let conflictNotice {
                ConflictNoticeView(notice: conflictNotice)
                    .id(tab)
            }

            actions(dismiss: dismiss)
        }
        .animation(PopupContainerLayout.fade, value: conflictNotice)
    }

    private var conflictNotice: ConflictNotice? {
        switch tab {
        case .slots: viewModel.conflictNotice
        case .plans: addPlan.conflictNotice
        }
    }

    @ViewBuilder
    private var sections: some View {
        switch tab {
        case .slots:
            VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
                MonthDayPicker(selection: $viewModel.days, conflicts: viewModel.dayConflicts)

                FillMonthHours(viewModel: viewModel)
            }
        case .plans:
            AddPlanSection(viewModel: addPlan)
        }
    }

    @ViewBuilder
    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            switch tab {
            case .slots:
                CapsuleButton(
                    titleKey: "schedule.fill.add \(viewModel.newSlotCount)",
                    role: .primary,
                    isEnabled: viewModel.canAdd,
                    action: { add(then: dismiss) }
                )
            case .plans:
                CapsuleButton(
                    titleKey: "schedule.plan.add",
                    role: .primary,
                    isEnabled: addPlan.canAdd,
                    action: { addPlans(then: dismiss) }
                )
            }
        }
    }

    private func add(then dismiss: () -> Void) {
        onAdded(viewModel.add())
        dismiss()
    }

    private func scrollToTime() {
        withAnimation {
            scrollPosition.scrollTo(edge: .bottom)
        }
    }

    private func addPlans(then dismiss: () -> Void) {
        onAdded(onAddPlans(addPlan.makePlans()))
        dismiss()
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            FillMonthPopup(
                viewModel: SchedulePreviewData.fillMonth,
                addPlan: SchedulePreviewData.addPlan,
                onAddPlans: { _ in nil },
                onAdded: { _ in },
                onDismiss: {}
            )
        }
}
#endif
