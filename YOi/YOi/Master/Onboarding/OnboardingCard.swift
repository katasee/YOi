import SwiftUI

private extension OnboardingStep {
    var titleKey: LocalizedStringKey {
        switch self {
        case .welcome: "onboarding.welcome.title"
        case .services: "onboarding.services.title"
        case .client: "onboarding.client.title"
        case .windows: "onboarding.windows.title"
        case .sendSchedule: "onboarding.sendSchedule.title"
        case .booking: "onboarding.booking.title"
        case .finished: "onboarding.finished.title"
        }
    }

    var messageKey: LocalizedStringKey {
        switch self {
        case .welcome: "onboarding.welcome.message"
        case .services: "onboarding.services.message"
        case .client: "onboarding.client.message"
        case .windows: "onboarding.windows.message"
        case .sendSchedule: "onboarding.sendSchedule.message"
        case .booking: "onboarding.booking.message"
        case .finished: "onboarding.finished.message"
        }
    }
}

struct OnboardingCard: View {
    let step: OnboardingStep
    let tab: MasterTab?
    let onSkip: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: OnboardingMetrics.Card.spacing) {
            Text(step.titleKey)
                .font(.elmsSans(.bold, OnboardingMetrics.Card.title))
                .foregroundStyle(Color.ink)
                .padding(.trailing, OnboardingMetrics.Card.minTapSize - OnboardingMetrics.Card.closeOffset)

            Text(step.messageKey)
                .font(.elmsSans(.regular, OnboardingMetrics.Card.message))
                .foregroundStyle(Color.textSecondary)

            if let tab {
                Label {
                    Text("onboarding.hint.tab \(Text(tab.titleKey))")
                } icon: {
                    Image(systemName: "hand.tap")
                }
                .font(.elmsSans(.semiBold, OnboardingMetrics.Card.message))
                .foregroundStyle(Color.wine)
                .padding(.top, OnboardingMetrics.Card.spacing)
            }

            HStack {
                OnboardingProgressDots(current: step.progressIndex ?? 0, count: OnboardingStep.guided.count)

                Spacer(minLength: 0)

                Button("onboarding.action.skip", action: onSkip)
                    .font(.elmsSans(.semiBold, OnboardingMetrics.Card.action))
                    .foregroundStyle(Color.wine)
                    .frame(minHeight: OnboardingMetrics.Card.minTapSize)
                    .contentShape(.rect)
                    .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            Button("onboarding.action.close", systemImage: "xmark", action: onClose)
                .labelStyle(.iconOnly)
                .font(.elmsSans(.semiBold, OnboardingMetrics.Card.closeIcon))
                .foregroundStyle(Color.textSecondary)
                .frame(width: OnboardingMetrics.Card.minTapSize, height: OnboardingMetrics.Card.minTapSize)
                .contentShape(.rect)
                .buttonStyle(.plain)
                .offset(x: OnboardingMetrics.Card.closeOffset, y: -OnboardingMetrics.Card.closeOffset)
        }
        .cardSurface(
            padding: OnboardingMetrics.Card.padding,
            cornerRadius: OnboardingMetrics.Card.cornerRadius
        )
    }
}

#if DEBUG
#Preview {
    OnboardingCard(
        step: .services,
        tab: .stats,
        onSkip: {},
        onClose: {}
    )
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
#endif
