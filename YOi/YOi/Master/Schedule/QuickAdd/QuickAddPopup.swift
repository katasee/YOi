import SwiftUI

struct QuickAddPopup: View {
    let book: QuickBookViewModel
    let addPlan: AddPlanViewModel
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

            actions(dismiss: dismiss)
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
                    action: dismiss
                )
            case .plan:
                CapsuleButton(
                    titleKey: "schedule.plan.add",
                    role: .primary,
                    isEnabled: addPlan.canAdd,
                    action: dismiss
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            QuickAddPopup(
                book: SchedulePreviewData.quickBook,
                addPlan: SchedulePreviewData.quickAddPlan,
                onDismiss: {}
            )
        }
}
#endif
