import SwiftUI

struct OnboardingProgressDots: View {
    let current: Int
    let count: Int

    var body: some View {
        HStack(spacing: OnboardingMetrics.Dots.spacing) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? Color.ink : Color.hairline)
                    .frame(
                        width: index == current ? OnboardingMetrics.Dots.currentWidth : OnboardingMetrics.Dots.size,
                        height: OnboardingMetrics.Dots.size
                    )
            }
        }
    }
}

#if DEBUG
#Preview {
    OnboardingProgressDots(current: 1, count: 4)
        .padding()
        .background(Color.background)
}
#endif
