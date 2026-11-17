import SwiftUI

struct OnboardingCenteredCard<Actions: View>: View {
    let systemImage: String
    let titleKey: LocalizedStringKey
    let messageKey: LocalizedStringKey
    @ViewBuilder let actions: Actions

    var body: some View {
        VStack(spacing: OnboardingMetrics.Card.centeredSpacing) {
            IconBadge(systemName: systemImage)

            Text(titleKey)
                .font(.elmsSans(.bold, OnboardingMetrics.Card.centeredTitle))
                .foregroundStyle(Color.ink)

            Text(messageKey)
                .font(.elmsSans(.regular, OnboardingMetrics.Card.message))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            actions
        }
        .frame(maxWidth: .infinity)
        .cardSurface(
            padding: OnboardingMetrics.Card.padding,
            cornerRadius: OnboardingMetrics.Card.cornerRadius
        )
    }
}

#if DEBUG
#Preview {
    OnboardingCenteredCard(
        systemImage: "sparkles",
        titleKey: "onboarding.welcome.title",
        messageKey: "onboarding.welcome.message"
    ) {
        CapsuleButton(
            titleKey: "onboarding.action.accept",
            role: .primary,
            fillsWidth: true,
            action: {}
        )
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
#endif
