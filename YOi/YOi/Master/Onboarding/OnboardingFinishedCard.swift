import SwiftUI

struct OnboardingFinishedCard: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: OnboardingMetrics.Card.finishedSpacing) {
            IconBadge(systemName: "checkmark")

            Text("onboarding.finished.title")
                .font(.elmsSans(.bold, OnboardingMetrics.Card.finishedTitle))
                .foregroundStyle(Color.ink)

            Text("onboarding.finished.message")
                .font(.elmsSans(.regular, OnboardingMetrics.Card.message))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)

            CapsuleButton(
                titleKey: "onboarding.action.start",
                role: .primary,
                fillsWidth: true,
                action: onStart
            )
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
    OnboardingFinishedCard(onStart: {})
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color.background)
}
#endif
