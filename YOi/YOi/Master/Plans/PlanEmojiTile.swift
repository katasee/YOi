import SwiftUI

struct PlanEmojiTile: View {
    enum Size {
        case row
        case picked

        var side: CGFloat {
            switch self {
            case .row: PlansMetrics.Size.emojiTile
            case .picked: PlansMetrics.Size.pickedTile
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .row: PlansMetrics.Size.emojiTileCornerRadius
            case .picked: PlansMetrics.Size.pickedTileCornerRadius
            }
        }

        var glyph: CGFloat {
            switch self {
            case .row: PlansMetrics.Size.emojiGlyph
            case .picked: PlansMetrics.Size.pickedGlyph
            }
        }
    }

    let emoji: String
    var size: Size = .row

    var body: some View {
        Text(verbatim: emoji)
            .font(.elmsSans(.regular, size.glyph))
            .frame(width: size.side, height: size.side)
            .background(Color.wineSoft, in: RoundedRectangle(cornerRadius: size.cornerRadius))
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 16) {
        PlanEmojiTile(emoji: "🥊")
        PlanEmojiTile(emoji: "🦷", size: .picked)
    }
    .padding()
    .background(Color.background)
}
#endif
