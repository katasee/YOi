import SwiftUI

struct QuickAddPopup: View {
    let quickBook: QuickBookViewModel
    let addPlan: AddPlanViewModel?
    let onAddPlans: ([PlanEvent]) -> AddedNotice?
    let onReplacePlans: ([String], [PlanEvent]) -> AddedNotice?
    let onCutPlans: (WindowReplacement, AddedNotice?) -> AddedNotice?
    let onAdded: (AddedNotice?) -> Void
    let onDismiss: () -> Void

    @State private var tab = QuickAddTab.client
    @State private var contentHeight: CGFloat?

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
        if addPlan != nil {
            ScheduleTabs(selection: $tab)
        }

        ScrollView {
            sections
                .padding(ScheduleMetrics.Spacing.scrollShadowInset)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    resize(to: height)
                }
        }
        .frame(maxHeight: contentHeight)
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
        case .client: quickBook.replacement
        case .plan: addPlan?.replacement
        }
    }

    private var isConfirmingReplace: Bool {
        switch tab {
        case .client: quickBook.isConfirmingReplace
        case .plan: addPlan?.isConfirmingReplace == true
        }
    }

    private var conflictNotice: ConflictNotice? {
        switch tab {
        case .client: quickBook.notice
        case .plan: addPlan?.conflictNotice
        }
    }

    @ViewBuilder
    private var sections: some View {
        switch tab {
        case .client:
            QuickBookSection(viewModel: quickBook)
                .transition(.opacity)
        case .plan:
            VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
                SchedulePopupHeader(title: String(localized: "schedule.quickAdd.planTitle"), subtitle: quickBook.subtitle)

                if let addPlan {
                    AddPlanSection(viewModel: addPlan)
                }
            }
            .transition(.opacity)
        }
    }

    private func resize(to height: CGFloat) {
        guard contentHeight != nil else {
            contentHeight = height
            return
        }

        withAnimation(.snappy) {
            contentHeight = height
        }
    }

    @ViewBuilder
    private func actions(offersReplace: Bool, dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            switch tab {
            case .client:
                if offersReplace {
                    ReplaceButton(isEnabled: quickBook.canReplace, action: startConfirmingReplace)
                } else {
                    CapsuleButton(
                        titleKey: "schedule.book.submit",
                        role: .primary,
                        isEnabled: quickBook.canBook,
                        action: { book(then: dismiss) }
                    )
                }
            case .plan:
                if offersReplace {
                    ReplaceButton(action: startConfirmingReplace)
                } else {
                    CapsuleButton(
                        titleKey: "schedule.plan.add",
                        role: .primary,
                        isEnabled: addPlan?.canAdd == true,
                        action: { addPlans(then: dismiss) }
                    )
                }
            }
        }
    }

    private func book(then dismiss: () -> Void) {
        onAdded(quickBook.book())
        dismiss()
    }

    private func addPlans(then dismiss: () -> Void) {
        guard let addPlan else { return }

        onAdded(onAddPlans(addPlan.makePlans()))
        dismiss()
    }

    private func startConfirmingReplace() {
        switch tab {
        case .client: quickBook.startConfirmingReplace()
        case .plan: addPlan?.startConfirmingReplace()
        }
    }

    private func stopConfirmingReplace() {
        switch tab {
        case .client: quickBook.stopConfirmingReplace()
        case .plan: addPlan?.stopConfirmingReplace()
        }
    }

    private func replace(then dismiss: () -> Void) {
        switch tab {
        case .client:
            guard let replacement = quickBook.replacement else { return }

            onAdded(onCutPlans(replacement, quickBook.bookReplacing()))
        case .plan:
            guard let addPlan, let replacement = addPlan.replacement else { return }

            onAdded(onReplacePlans(replacement.windowIds, addPlan.replacingPlans()))
        }

        dismiss()
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            QuickAddPopup(
                quickBook: SchedulePreviewData.quickBook,
                addPlan: SchedulePreviewData.quickAddPlan,
                onAddPlans: { _ in nil },
                onReplacePlans: { _, _ in nil },
                onCutPlans: { _, notice in notice },
                onAdded: { _ in },
                onDismiss: {}
            )
        }
}
#endif
