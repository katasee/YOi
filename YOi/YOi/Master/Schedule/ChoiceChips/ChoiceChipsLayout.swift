import SwiftUI

struct ChoiceChipsLayout: Layout {
    private struct Row {
        var indices: [Int]
        let isWide: Bool
    }

    var spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let height = frames(for: subviews, width: width).map(\.maxY).max() ?? 0

        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let frames = frames(for: subviews, width: bounds.width)

        for (subview, frame) in zip(subviews, frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func frames(for subviews: Subviews, width: CGFloat) -> [CGRect] {
        let columnWidth = (width - spacing) / 2
        var frames = Array(repeating: CGRect.zero, count: subviews.count)
        var y: CGFloat = 0

        for row in rows(for: subviews, columnWidth: columnWidth) {
            let itemWidth = row.isWide ? width : columnWidth
            let itemProposal = ProposedViewSize(width: itemWidth, height: nil)
            let rowHeight = row.indices.map { subviews[$0].sizeThatFits(itemProposal).height }.max() ?? 0

            for (column, index) in row.indices.enumerated() {
                frames[index] = CGRect(
                    x: CGFloat(column) * (columnWidth + spacing),
                    y: y,
                    width: itemWidth,
                    height: rowHeight
                )
            }

            y += rowHeight + spacing
        }

        return frames
    }

    private func rows(for subviews: Subviews, columnWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var openRow: Int?

        for index in subviews.indices {
            if subviews[index].sizeThatFits(.unspecified).width > columnWidth {
                rows.append(Row(indices: [index], isWide: true))
            } else if let row = openRow {
                rows[row].indices.append(index)
                openRow = nil
            } else {
                rows.append(Row(indices: [index], isWide: false))
                openRow = rows.count - 1
            }
        }

        return rows
    }
}
