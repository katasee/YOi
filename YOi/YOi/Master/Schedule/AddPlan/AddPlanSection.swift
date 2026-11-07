import SwiftUI

struct AddPlanSection: View {
    @Bindable var viewModel: AddPlanViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            if viewModel.isSingleDay == false {
                MonthDayPicker(selection: $viewModel.days, conflicts: viewModel.dayConflicts)
            }

            SectionLabel(titleKey: "schedule.plan.template")

            if viewModel.hasTemplates {
                ChoiceChips(chips: viewModel.templateChips, onToggle: viewModel.selectTemplate)
            } else {
                Text("schedule.plan.noTemplates")
                    .font(.elmsSans(.regular, ScheduleMetrics.Size.planHint))
                    .foregroundStyle(Color.textSecondary)
            }

            SectionLabel(titleKey: "schedule.plan.time")

            PlanTimeFields(times: $viewModel.times)
        }
    }
}

#if DEBUG
#Preview {
    AddPlanSection(viewModel: SchedulePreviewData.addPlan)
        .padding()
        .background(Color.card)
}
#endif
