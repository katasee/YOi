import CoreGraphics

enum OnboardingHole {
    static func frame(
        for highlight: OnboardingHighlight,
        origin: CGPoint,
        screen: CGSize,
        contentBottomInset: CGFloat,
        homeIndicatorInset: CGFloat
    ) -> CGRect {
        switch highlight {
        case .welcome, .finished:
            return .zero
        case .target(_, let frame):
            let padding = -OnboardingMetrics.Hole.padding

            return frame
                .offsetBy(dx: -origin.x, dy: -origin.y)
                .insetBy(dx: padding, dy: padding)
        case .tab(let tab):
            let bar = TabBarSlot.bar(
                screen: screen,
                contentBottomInset: contentBottomInset,
                homeIndicatorInset: homeIndicatorInset - OnboardingMetrics.TabBar.bottomOverlap,
                horizontalInset: OnboardingMetrics.TabBar.horizontalInset
            )
            let inset = OnboardingMetrics.TabBar.slotInset

            return TabBarSlot.frame(
                index: MasterTab.allCases.firstIndex(of: tab) ?? 0,
                count: MasterTab.allCases.count,
                bar: bar
            )
            .insetBy(dx: inset, dy: inset)
        }
    }

    static func cornerRadius(for highlight: OnboardingHighlight) -> CGFloat {
        switch highlight {
        case .tab: OnboardingMetrics.TabBar.cornerRadius
        case .welcome, .target, .finished: OnboardingMetrics.Hole.cornerRadius
        }
    }
}
