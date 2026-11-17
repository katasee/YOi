import SwiftUI

struct OnboardingFinishedCard: View {
    let onStart: () -> Void

    var body: some View {
        OnboardingCenteredCard(
            systemImage: "checkmark",
            titleKey: "onboarding.finished.title",
            messageKey: "onboarding.finished.message"
        ) {
            CapsuleButton(
                titleKey: "onboarding.action.start",
                role: .primary,
                fillsWidth: true,
                action: onStart
            )
        }
    }
}

#if DEBUG
#Preview {
    OnboardingFinishedCard(onStart: {})
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color.background)
}
#endif
