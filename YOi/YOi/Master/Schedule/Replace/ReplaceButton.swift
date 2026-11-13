import SwiftUI

struct ReplaceButton: View {
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        CapsuleButton(
            titleKey: "schedule.replace.action",
            role: .warning,
            isEnabled: isEnabled,
            action: action
        )
    }
}

#if DEBUG
#Preview {
    ReplaceButton(action: {})
        .padding()
        .background(Color.card)
}
#endif
