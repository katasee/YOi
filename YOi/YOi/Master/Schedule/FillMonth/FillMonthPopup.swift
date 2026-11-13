import SwiftUI

struct FillMonthPopup: View {
    @Bindable var viewModel: FillMonthViewModel
    let addPlan: AddPlanViewModel
    let onAddPlans: ([PlanEvent]) -> AddedNotice?
    let onReplacePlans: ([String], [PlanEvent]) -> AddedNotice?
    let onCutPlans: (WindowReplacement, AddedNotice?) -> AddedNotice?
    let onAdded: (AddedNotice?) -> Void
    let onDismiss: () -> Void

    @State private var tab = FillMonthTab.slots
    @State private var contentHeight: CGFloat?
    @State private var scrollPosition = ScrollPosition()

    var body: some View {
        PopupContainer(onDismiss: onDismiss) { dismiss in
            let replacement = replacement

            if let replacement, isConfirmingReplace {
                ReplaceConfirmStep(
                    replacement: replacement,
                    onBack: stopConfirmingReplace,
                    onConfirm: { replace(then: dismiss) }
                )
            } else {
                form(offersReplace: replacement != nil, dismiss: dismiss)
            }
        }
        .animation(PopupContainerLayout.fade, value: conflictNotice)
    }

    @ViewBuilder
    private func form(offersReplace: Bool, dismiss: @escaping () -> Void) -> some View {
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

        actions(offersReplace: offersReplace, dismiss: dismiss)
    }

    private var replacement: (any ScheduleReplacement)? {
        switch tab {
        case .slots: viewModel.replacement
        case .plans: addPlan.replacement
        }
    }

    private var isConfirmingReplace: Bool {
        switch tab {
        case .slots: viewModel.isConfirmingReplace
        case .plans: addPlan.isConfirmingReplace
        }
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
    private func actions(offersReplace: Bool, dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            switch tab {
            case .slots:
                if offersReplace {
                    ReplaceButton(action: startConfirmingReplace)
                } else {
                    CapsuleButton(
                        titleKey: "schedule.fill.add \(viewModel.newSlotCount)",
                        role: .primary,
                        isEnabled: viewModel.canAdd,
                        action: { add(then: dismiss) }
                    )
                }
            case .plans:
                if offersReplace {
                    ReplaceButton(action: startConfirmingReplace)
                } else {
                    CapsuleButton(
                        titleKey: "schedule.plan.add",
                        role: .primary,
                        isEnabled: addPlan.canAdd,
                        action: { addPlans(then: dismiss) }
                    )
                }
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

    private func startConfirmingReplace() {
        switch tab {
        case .slots: viewModel.startConfirmingReplace()
        case .plans: addPlan.startConfirmingReplace()
        }
    }

    private func stopConfirmingReplace() {
        switch tab {
        case .slots: viewModel.stopConfirmingReplace()
        case .plans: addPlan.stopConfirmingReplace()
        }
    }

    private func replace(then dismiss: () -> Void) {
        switch tab {
        case .slots:
            guard let replacement = viewModel.replacement else { return }

            onAdded(onCutPlans(replacement, viewModel.addReplacing()))
        case .plans:
            guard let replacement = addPlan.replacement else { return }

            onAdded(onReplacePlans(replacement.windowIds, addPlan.replacingPlans()))
        }

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
                onReplacePlans: { _, _ in nil },
                onCutPlans: { _, notice in notice },
                onAdded: { _ in },
                onDismiss: {}
            )
        }
}
#endif
