import SwiftUI

private extension OnboardingHighlight {
    var identity: String {
        switch self {
        case .welcome: "welcome"
        case .tab(let tab): "tab.\(tab)"
        case .target(let target, _): "target.\(target)"
        case .finished: "finished"
        }
    }
}

private struct OnboardingDim: Shape {
    let hole: CGRect
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        path.addRoundedRect(
            in: hole,
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return path
    }
}

struct OnboardingOverlay: View {
    let tour: OnboardingTour
    let selectedTab: MasterTab
    let contentBottomInset: CGFloat
    let homeIndicatorInset: CGFloat

    var body: some View {
        let highlight = tour.highlight(selectedTab: selectedTab)

        GeometryReader { proxy in
            if let highlight {
                content(highlight, in: proxy)
                    .id(highlight.identity)
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .animation(.smooth, value: highlight?.identity)
    }

    @ViewBuilder
    private func content(_ highlight: OnboardingHighlight, in proxy: GeometryProxy) -> some View {
        let hole = OnboardingHole.frame(
            for: highlight,
            origin: proxy.frame(in: .global).origin,
            screen: proxy.size,
            contentBottomInset: contentBottomInset,
            homeIndicatorInset: homeIndicatorInset
        )
        let cornerRadius = OnboardingHole.cornerRadius(for: highlight)
        let dim = OnboardingDim(hole: hole, cornerRadius: cornerRadius)

        ZStack {
            if highlight == .welcome {
                Rectangle()
                    .fill(.ultraThinMaterial)
            }

            dim
                .fill(Color.tourDim, style: FillStyle(eoFill: true))
                .contentShape(dim, eoFill: true)

            if hole != .zero {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.wine, lineWidth: OnboardingMetrics.Hole.outline)
                    .frame(width: hole.width, height: hole.height)
                    .position(x: hole.midX, y: hole.midY)
                    .allowsHitTesting(false)
            }

            card(for: highlight, hole: hole, in: proxy.size)
        }
    }

    @ViewBuilder
    private func card(for highlight: OnboardingHighlight, hole: CGRect, in size: CGSize) -> some View {
        switch highlight {
        case .welcome:
            OnboardingWelcomeCard(onAccept: tour.advance, onDecline: tour.close)
                .padding(.horizontal, OnboardingMetrics.Card.horizontalPadding)
        case .finished:
            OnboardingFinishedCard(onStart: tour.close)
                .padding(.horizontal, OnboardingMetrics.Card.horizontalPadding)
        case .tab(let tab):
            stepCard(tab: tab, hole: hole, in: size)
        case .target:
            stepCard(tab: nil, hole: hole, in: size)
        }
    }

    @ViewBuilder
    private func stepCard(tab: MasterTab?, hole: CGRect, in size: CGSize) -> some View {
        if let step = tour.step {
            let isAbove = hole.midY > size.height / 2

            OnboardingCard(
                step: step,
                tab: tab,
                onSkip: tour.advance,
                onClose: tour.close
            )
            .padding(.horizontal, OnboardingMetrics.Card.horizontalPadding)
            .padding(.top, isAbove ? 0 : hole.maxY + OnboardingMetrics.Card.gap)
            .padding(.bottom, isAbove ? size.height - hole.minY + OnboardingMetrics.Card.gap : 0)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: isAbove ? .bottom : .top
            )
        }
    }
}

#if DEBUG
#Preview {
    let tour = OnboardingTour(step: .services)
    let _ = tour.report(.servicesRow, frame: CGRect(x: 16, y: 320, width: 358, height: 64))

    OnboardingOverlay(
        tour: tour,
        selectedTab: .stats,
        contentBottomInset: 83,
        homeIndicatorInset: 34
    )
    .background(Color.background)
}
#endif
