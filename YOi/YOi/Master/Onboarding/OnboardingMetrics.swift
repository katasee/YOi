import CoreGraphics

enum OnboardingMetrics {
    enum TabBar {
        static var horizontalInset: CGFloat {
            if #available(iOS 26, *) {
                58
            } else {
                4
            }
        }

        static var bottomOverlap: CGFloat {
            if #available(iOS 26, *) {
                12
            } else {
                10
            }
        }

        static let slotInset: CGFloat = 4
        static let cornerRadius: CGFloat = 18
    }

    enum Hole {
        static let padding: CGFloat = 6
        static let cornerRadius: CGFloat = 16
        static let outline: CGFloat = 2
    }

    enum Card {
        static let padding: CGFloat = 16
        static let cornerRadius: CGFloat = 20
        static let spacing: CGFloat = 6
        static let gap: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let minTapSize: CGFloat = 44
        static let closeOffset: CGFloat = 12
        static let closeIcon: CGFloat = 13
        static let title: CGFloat = 15
        static let message: CGFloat = 13
        static let action: CGFloat = 13
        static let centeredTitle: CGFloat = 18
        static let centeredSpacing: CGFloat = 10
    }

    enum Dots {
        static let size: CGFloat = 6
        static let currentWidth: CGFloat = 14
        static let spacing: CGFloat = 4
    }
}
