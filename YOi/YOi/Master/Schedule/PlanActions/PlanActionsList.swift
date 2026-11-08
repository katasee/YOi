import SwiftUI

struct PlanActionsList: View {
    let onChangePlan: () -> Void
    let onReschedule: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: ScheduleMetrics.Spacing.actionSpacing) {
            ActionRowButton(
                titleKey: "schedule.plan.actions.change",
                systemImage: "arrow.triangle.2.circlepath",
                action: onChangePlan
            )

            ActionRowButton(
                titleKey: "schedule.actions.reschedule",
                systemImage: "arrow.left.arrow.right",
                action: onReschedule
            )

            ActionRowButton(
                titleKey: "schedule.plan.actions.delete",
                systemImage: "trash",
                role: .destructive,
                action: onDelete
            )
        }
    }
}

#if DEBUG
#Preview {
    PlanActionsList(
        onChangePlan: {},
        onReschedule: {},
        onDelete: {}
    )
    .padding()
    .background(Color.card)
}
#endif
