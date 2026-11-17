import SwiftUI

struct OnboardingWelcomeCard: View {
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        OnboardingCenteredCard(
            systemImage: "sparkles",
            titleKey: "onboarding.welcome.title",
            messageKey: "onboarding.welcome.message"
        ) {
            CapsuleButton(
                titleKey: "onboarding.action.accept",
                role: .primary,
                fillsWidth: true,
                action: onAccept
            )

            CapsuleButton(
                titleKey: "onboarding.action.decline",
                role: .secondary,
                fillsWidth: true,
                action: onDecline
            )
        }
    }
}

#if DEBUG
#Preview {
    OnboardingWelcomeCard(onAccept: {}, onDecline: {})
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color.background)
}
#endif
