import SwiftUI

struct JumpToDatePopup: View {
    let viewModel: JumpToDateViewModel
    let onPick: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        PopupContainer(blursBackground: true, onDismiss: onDismiss) { dismiss in
            Text("schedule.jump.title")
                .font(.elmsSans(.bold, ScheduleMetrics.Size.fillTitle))
                .foregroundStyle(Color.ink)
                .accessibilityAddTraits(.isHeader)

            MonthHeader(
                title: viewModel.monthTitle,
                canGoBack: viewModel.canGoBack,
                canGoForward: true,
                onPrevious: viewModel.showPreviousMonth,
                onNext: viewModel.showNextMonth
            )

            JumpToDateCalendar(viewModel: viewModel) { dayId in
                pick(dayId, then: dismiss)
            }

            PopupDismissButton(titleKey: "common.action.cancel", action: dismiss)
        }
    }

    private func pick(_ dayId: String, then dismiss: () -> Void) {
        onPick(dayId)
        dismiss()
    }
}

#if DEBUG
#Preview {
    Color.background
        .overlay {
            JumpToDatePopup(
                viewModel: SchedulePreviewData.jumpToDate,
                onPick: { _ in },
                onDismiss: {}
            )
        }
}
#endif
