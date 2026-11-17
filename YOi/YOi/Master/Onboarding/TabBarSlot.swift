import CoreGraphics

enum TabBarSlot {
    static func bar(
        screen: CGSize,
        contentBottomInset: CGFloat,
        homeIndicatorInset: CGFloat,
        horizontalInset: CGFloat
    ) -> CGRect {
        CGRect(
            x: horizontalInset,
            y: screen.height - contentBottomInset,
            width: screen.width - horizontalInset * 2,
            height: contentBottomInset - homeIndicatorInset
        )
    }

    static func frame(index: Int, count: Int, bar: CGRect) -> CGRect {
        let width = bar.width / CGFloat(max(count, 1))

        return CGRect(
            x: bar.minX + width * CGFloat(index),
            y: bar.minY,
            width: width,
            height: bar.height
        )
    }
}
