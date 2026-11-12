import CoreGraphics

enum AutoScroll {
    static func step(
        fingerY: CGFloat,
        viewportHeight: CGFloat,
        zone: CGFloat,
        maxStep: CGFloat
    ) -> CGFloat {
        let topDepth = zone - fingerY
        let bottomDepth = fingerY - (viewportHeight - zone)

        if topDepth > 0 {
            return -maxStep * min(topDepth / zone, 1)
        }

        if bottomDepth > 0 {
            return maxStep * min(bottomDepth / zone, 1)
        }

        return 0
    }
}
