import SwiftUI

private struct OnboardingDim: Shape {
    var hole: CGRect
    let cornerRadius: CGFloat

    var animatableData: CGRect.AnimatableData {
        get { hole.animatableData }
        set { hole.animatableData = newValue }
    }

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
            }
        }
        .ignoresSafeArea()
        .animation(.smooth, value: highlight)
    }

    @ViewBuilder
    private func content(_ highlight: OnboardingHighlight, in proxy: GeometryProxy) -> some View {
        let hole = hole(for: highlight, in: proxy)
        let cornerRadius = cornerRadius(for: highlight)
        let dim = OnboardingDim(hole: hole, cornerRadius: cornerRadius)

        ZStack {
            dim
                .fill(Color.backdrop, style: FillStyle(eoFill: true))
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
        if highlight == .finished {
            OnboardingFinishedCard(onStart: tour.close)
                .padding(.horizontal, OnboardingMetrics.Card.horizontalPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let step = tour.step {
            let isAbove = hole.midY > size.height / 2

            OnboardingCard(
                step: step,
                onSkip: tour.skip,
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

    private func hole(for highlight: OnboardingHighlight, in proxy: GeometryProxy) -> CGRect {
        switch highlight {
        case .finished:
            return .zero
        case .target(_, let frame):
            let origin = proxy.frame(in: .global).origin
            let padding = -OnboardingMetrics.Hole.padding

            return frame
                .offsetBy(dx: -origin.x, dy: -origin.y)
                .insetBy(dx: padding, dy: padding)
        case .tab(let tab):
            let bar = TabBarSlot.bar(
                screen: proxy.size,
                contentBottomInset: contentBottomInset,
                homeIndicatorInset: homeIndicatorInset - OnboardingMetrics.TabBar.bottomOverlap,
                horizontalInset: OnboardingMetrics.TabBar.horizontalInset
            )
            let index = MasterTab.allCases.firstIndex(of: tab) ?? 0
            let inset = OnboardingMetrics.TabBar.slotInset

            return TabBarSlot.frame(
                index: index,
                count: MasterTab.allCases.count,
                bar: bar
            )
            .insetBy(dx: inset, dy: inset)
        }
    }

    private func cornerRadius(for highlight: OnboardingHighlight) -> CGFloat {
        switch highlight {
        case .tab: OnboardingMetrics.TabBar.cornerRadius
        case .target, .finished: OnboardingMetrics.Hole.cornerRadius
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
