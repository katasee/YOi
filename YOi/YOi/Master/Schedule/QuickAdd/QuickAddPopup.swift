import SwiftUI

struct QuickAddPopup: View {
    let book: QuickBookViewModel
    let addPlan: AddPlanViewModel
    let onAddPlans: ([PlanEvent]) -> Void
    let onDismiss: () -> Void

    @State private var tab = QuickAddTab.client
    @State private var contentHeight: CGFloat?

    var body: some View {
        PopupContainer(dismissLabel: "common.action.cancel", onDismiss: onDismiss) { dismiss in
            ScheduleTabs(selection: $tab)

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

            actions(dismiss: dismiss)
        }
        .animation(PopupContainerLayout.fade, value: conflictNotice)
    }

    private var conflictNotice: ConflictNotice? {
        switch tab {
        case .client: book.notice
        case .plan: addPlan.conflictNotice
        }
    }

    @ViewBuilder
    private var sections: some View {
        switch tab {
        case .client:
            QuickBookSection(viewModel: book)
                .transition(.opacity)
        case .plan:
            VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
                SchedulePopupHeader(title: String(localized: "schedule.quickAdd.planTitle"), subtitle: book.subtitle)

                AddPlanSection(viewModel: addPlan)
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
    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            switch tab {
            case .client:
                CapsuleButton(
                    titleKey: "schedule.book.submit",
                    role: .primary,
                    isEnabled: book.canBook,
                    action: { book(then: dismiss) }
                )
            case .plan:
                CapsuleButton(
                    titleKey: "schedule.plan.add",
                    role: .primary,
                    isEnabled: addPlan.canAdd,
                    action: { addPlans(then: dismiss) }
                )
            }
        }
    }

    private func book(then dismiss: () -> Void) {
        book.book()
        dismiss()
    }

    private func addPlans(then dismiss: () -> Void) {
        onAddPlans(addPlan.makePlans())
        dismiss()
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            QuickAddPopup(
                book: SchedulePreviewData.quickBook,
                addPlan: SchedulePreviewData.quickAddPlan,
                onAddPlans: { _ in },
                onDismiss: {}
            )
        }
}
#endif
