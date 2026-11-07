import SwiftUI

struct BookClientPopup: View {
    @Bindable var viewModel: BookClientViewModel
    let onDismiss: () -> Void

    @State private var contentHeight: CGFloat?

    var body: some View {
        PopupContainer(dismissLabel: "common.action.cancel", onDismiss: onDismiss) { dismiss in
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
            .opacity(contentHeight == nil ? 0 : 1)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .padding(-ScheduleMetrics.Spacing.scrollShadowInset)

            actions(dismiss: dismiss)
        }
    }

    private var sections: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            SchedulePopupHeader(title: String(localized: "schedule.book.title"), subtitle: viewModel.subtitle)

            ClientBookingSection(choice: viewModel.choice, focusesSearchOnAppear: true)
        }
    }

    private func actions(dismiss: @escaping () -> Void) -> some View {
        HStack {
            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)

            Spacer()

            CapsuleButton(
                titleKey: "schedule.book.submit",
                role: .primary,
                isEnabled: viewModel.canBook,
                action: { book(then: dismiss) }
            )
        }
    }

    private func book(then dismiss: () -> Void) {
        viewModel.book()
        dismiss()
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            BookClientPopup(viewModel: SchedulePreviewData.bookClient, onDismiss: {})
        }
}
#endif
