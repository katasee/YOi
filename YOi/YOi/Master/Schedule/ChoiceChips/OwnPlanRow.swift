import SwiftUI

struct OwnPlanRow: View {
    @Binding var plan: OwnPlan

    @State private var isPickingEmoji = false

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            HStack(spacing: ScheduleMetrics.Spacing.ownPlanRowSpacing) {
                Button(action: toggleEmojiGrid) {
                    PlanEmojiTile(emoji: plan.emoji)
                }
                .buttonStyle(.plain)

                TextField("schedule.plan.own.placeholder", text: $plan.name)
                    .inputFieldStyle()
                    .submitLabel(.done)
            }

            if isPickingEmoji {
                PlanEmojiGrid(selection: $plan.emoji)
                    .transition(.opacity)
            }
        }
        .onChange(of: plan.emoji, collapseEmojiGrid)
    }

    private func toggleEmojiGrid() {
        withAnimation(.snappy) {
            isPickingEmoji.toggle()
        }
    }

    private func collapseEmojiGrid() {
        withAnimation(.snappy) {
            isPickingEmoji = false
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var plan = OwnPlan(emoji: "🦷", name: "Стоматолог")

    OwnPlanRow(plan: $plan)
        .padding()
        .background(Color.card)
}
#endif
