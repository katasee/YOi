import SwiftUI

struct QuickBookSection: View {
    @Bindable var viewModel: QuickBookViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            SchedulePopupHeader(title: String(localized: "schedule.book.title"), subtitle: viewModel.subtitle)

            ClientBookingSection(choice: viewModel.choice)

            SectionLabel(titleKey: "schedule.plan.time")

            TimeWheel(
                time: $viewModel.time,
                hours: WorkHours.customHours,
                minuteStep: WorkHours.minuteStep
            )
        }
    }
}

#if DEBUG
#Preview {
    QuickBookSection(viewModel: SchedulePreviewData.quickBook)
        .padding()
        .background(Color.card)
}
#endif
