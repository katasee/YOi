import SwiftUI

struct WeekDayCell: View {
    let day: Date
    let isSelected: Bool
    let isToday: Bool
    var isMarked = false
    var fillsSelection = true
    var namespace: Namespace.ID?
    let action: () -> Void

    private enum Layout {
        static let cellHeight: CGFloat = 58
        static let cellCornerRadius: CGFloat = 18
        static let labelSpacing: CGFloat = 4
        static let dotSize: CGFloat = 4
        static let dotBottomPadding: CGFloat = 6
        static let todayOutline: CGFloat = 1.5
        static let selectedLetterOpacity: Double = 0.7
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: Layout.labelSpacing) {
                Text(DateFormat.weekdayLetter.string(from: day).uppercased())
                    .font(.elmsSans(.medium, 11))
                    .foregroundStyle(
                        isFilled
                            ? Color.onPrimary.opacity(Layout.selectedLetterOpacity)
                            : Color.textSecondary
                    )

                Text(DateFormat.dayNumber.string(from: day))
                    .font(.elmsSans(isToday ? .bold : .semiBold, 16))
                    .foregroundStyle(numberColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Layout.cellHeight)
            .background {
                if isFilled {
                    selectedFill
                } else if isToday {
                    RoundedRectangle(cornerRadius: Layout.cellCornerRadius)
                        .strokeBorder(Color.wine, lineWidth: Layout.todayOutline)
                }
            }
            .overlay(alignment: .bottom) {
                if isMarked {
                    Circle()
                        .fill(isFilled ? Color.onPrimary : Color.wine)
                        .frame(width: Layout.dotSize, height: Layout.dotSize)
                        .padding(.bottom, Layout.dotBottomPadding)
                }
            }
            .contentShape(.rect(cornerRadius: Layout.cellCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var selectedFill: some View {
        if let namespace {
            selectedShape.matchedGeometryEffect(id: "selectedDay", in: namespace)
        } else {
            selectedShape
        }
    }

    @ViewBuilder
    private var selectedShape: some View {
        let shape = RoundedRectangle(cornerRadius: Layout.cellCornerRadius)

        if #available(iOS 26, *) {
            Color.clear
                .glassEffect(.primary, in: shape)
        } else {
            shape
                .fill(Color.primaryFill)
                .brandShadow()
        }
    }

    private var isFilled: Bool {
        isSelected && fillsSelection
    }

    private var numberColor: Color {
        if isFilled {
            Color.onPrimary
        } else if isToday {
            Color.wine
        } else {
            Color.ink
        }
    }
}

#Preview {
    HStack {
        WeekDayCell(day: .now, isSelected: true, isToday: true, isMarked: true, action: {})
        WeekDayCell(day: .now, isSelected: false, isToday: true, isMarked: true, action: {})
        WeekDayCell(day: .now, isSelected: false, isToday: false, action: {})
    }
    .padding()
    .background(Color.background)
}
