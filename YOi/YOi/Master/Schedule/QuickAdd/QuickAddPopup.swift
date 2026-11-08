import SwiftUI

struct QuickAddPopup: View {
    let quickBook: QuickBookViewModel
    let addPlan: AddPlanViewModel?
    let onAddPlans: ([PlanEvent]) -> AddedNotice?
    let onAdded: (AddedNotice?) -> Void
    let onDismiss: () -> Void

    @State private var tab = QuickAddTab.client
    @State private var contentHeight: CGFloat?

    var body: some View {
        PopupContainer(onDismiss: onDismiss) { dismiss in
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

            actions(dismiss: dismiss)
        }
        .animation(PopupContainerLayout.fade, value: conflictNotice)
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
    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            switch tab {
            case .client:
                CapsuleButton(
                    titleKey: "schedule.book.submit",
                    role: .primary,
                    isEnabled: quickBook.canBook,
                    action: { book(then: dismiss) }
                )
            case .plan:
                CapsuleButton(
                    titleKey: "schedule.plan.add",
                    role: .primary,
                    isEnabled: addPlan?.canAdd == true,
                    action: { addPlans(then: dismiss) }
                )
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
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            QuickAddPopup(
                quickBook: SchedulePreviewData.quickBook,
                addPlan: SchedulePreviewData.quickAddPlan,
                onAddPlans: { _ in nil },
                onAdded: { _ in },
                onDismiss: {}
            )
        }
}
#endif
