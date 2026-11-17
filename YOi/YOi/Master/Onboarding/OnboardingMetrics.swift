import CoreGraphics

enum OnboardingMetrics {
    enum TabBar {
        static var horizontalInset: CGFloat {
            if #available(iOS 26, *) {
                20
            } else {
                0
            }
        }

        static let slotInset: CGFloat = 4
    }
}
