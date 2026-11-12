import CoreGraphics

struct ChipDrag {
    let id: String
    let size: CGSize
    var origin: CGPoint
    var grab: CGSize?
    var lastTarget: String?
    var isLifted = false
    var isLanding = false
    var didMove = false

    mutating func follow(
        to location: CGPoint,
        frame: CGRect,
        bounds: CGSize
    ) {
        let grab = grab ?? CGSize(
            width: location.x - frame.minX,
            height: location.y - frame.minY
        )

        self.grab = grab
        origin = Self.clampedOrigin(
            CGPoint(x: location.x - grab.width, y: location.y - grab.height),
            size: frame.size,
            in: bounds
        )
    }

    mutating func swapTarget(at location: CGPoint, in frames: [String: CGRect]) -> String? {
        guard let hovered = frames.first(where: { $0.value.contains(location) })?.key else {
            lastTarget = nil
            return nil
        }
        guard hovered != lastTarget else { return nil }

        lastTarget = hovered
        didMove = true
        return hovered
    }

    static func clampedOrigin(
        _ origin: CGPoint,
        size: CGSize,
        in bounds: CGSize
    ) -> CGPoint {
        CGPoint(
            x: min(max(origin.x, 0), max(bounds.width - size.width, 0)),
            y: min(max(origin.y, 0), max(bounds.height - size.height, 0))
        )
    }
}
