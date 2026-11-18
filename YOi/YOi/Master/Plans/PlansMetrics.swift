import CoreGraphics

enum PlansMetrics {
    enum Size {
        static let rowCornerRadius: CGFloat = 24
        static let emojiTile: CGFloat = 44
        static let emojiTileCornerRadius: CGFloat = 14
        static let emojiGlyph: CGFloat = 22
        static let pickedTile: CGFloat = 56
        static let pickedTileCornerRadius: CGFloat = 18
        static let pickedGlyph: CGFloat = 28
        static let gridCell: CGFloat = 44
        static let gridCellCornerRadius: CGFloat = 14
        static let gridGlyph: CGFloat = 22
        static let gridVisibleHeight: CGFloat = 178
        static let historyName: CGFloat = 22
        static let historyDate: CGFloat = 16
        static let historyTime: CGFloat = 15
        static let historyEmpty: CGFloat = 15
        static let dividerHeight: CGFloat = 1
    }

    enum Spacing {
        static let horizontalPadding: CGFloat = 16
        static let sectionTopPadding: CGFloat = 24
        static let listTopPadding: CGFloat = 12
        static let listBottomPadding: CGFloat = 24
        static let rowSpacing: CGFloat = 12
        static let rowContentSpacing: CGFloat = 14
        static let rowHorizontalPadding: CGFloat = 14
        static let rowVerticalPadding: CGFloat = 12
        static let titleSpacing: CGFloat = 4
        static let nameRowSpacing: CGFloat = 12
        static let nameLabelSpacing: CGFloat = 6
        static let gridSpacing: CGFloat = 8
        static let gridShadowInset: CGFloat = 6
        static let historyTopPadding: CGFloat = 24
        static let historyHeaderSpacing: CGFloat = 10
        static let historySectionsSpacing: CGFloat = 20
        static let historySectionSpacing: CGFloat = 10
        static let historyLabelInset: CGFloat = 4
        static let historyRowHorizontalPadding: CGFloat = 16
        static let historyRowVerticalPadding: CGFloat = 12
        static let historyEmptyPadding: CGFloat = 16
    }

    enum Grid {
        static let columns = 5
    }
}
