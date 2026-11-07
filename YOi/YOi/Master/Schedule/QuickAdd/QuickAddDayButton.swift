import SwiftUI

struct QuickAddDayButton: View {
    let action: () -> Void

    var body: some View {
        CapsuleButton(
            titleKey: "schedule.quickAdd.action",
            role: .secondary,
            systemImage: "plus",
            fillsWidth: true,
            action: action
        )
    }
}

#Preview {
    QuickAddDayButton(action: {})
        .padding()
        .background(Color.background)
}
