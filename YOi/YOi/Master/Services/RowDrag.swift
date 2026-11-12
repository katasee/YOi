import CoreGraphics

struct RowDrag {
    let id: String
    let source: Int
    private(set) var target: Int
    var translation: CGFloat = 0
    var isLifted = false
    var isLanding = false

    private let frames: [CGRect]
    private let shift: CGFloat

    init(
        id: String,
        source: Int,
        frames: [CGRect],
        spacing: CGFloat
    ) {
        self.id = id
        self.source = source
        self.frames = frames
        target = source
        shift = frames[source].height + spacing
    }

    var landingTranslation: CGFloat {
        target > source
            ? frames[target].maxY - frames[source].maxY
            : frames[target].minY - frames[source].minY
    }

    mutating func updateTarget() -> Bool {
        let center = frames[source].midY + translation
        let above = frames.indices.first { $0 < source && center < frames[$0].midY }
        let below = frames.indices.last { $0 > source && center > frames[$0].midY }
        let newTarget = above ?? below ?? source

        guard newTarget != target else { return false }

        target = newTarget
        return true
    }

    func offset(at index: Int) -> CGFloat {
        if index == source {
            translation
        } else if index >= target, index < source {
            shift
        } else if index > source, index <= target {
            -shift
        } else {
            0
        }
    }
}
