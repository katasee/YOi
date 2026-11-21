import SwiftUI

private struct RescheduleLens: View {
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: ScheduleMetrics.Size.dayLensCornerRadius)
    }

    var body: some View {
        Group {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(.regular, in: shape)
            } else {
                shape
                    .fill(Color.raised)
                    .strokeBorder(Color.hairline)
            }
        }
        .frame(
            width: ScheduleMetrics.Size.dayScrollerCell * ScheduleMetrics.Size.dayScrollerSelectedScale,
            height: ScheduleMetrics.Size.dayLensHeight
        )
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct RescheduleDayScroller: View {
    @Binding var selectedDate: Date
    let days: [Date]
    let markedDays: Set<String>

    @State private var position = ScrollPosition(idType: Date.self)
    @State private var width: CGFloat = 0

    private var sideMargin: CGFloat {
        max(0, (width - ScheduleMetrics.Size.dayScrollerCell) / 2)
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: ScheduleMetrics.Spacing.dayScrollerSpacing) {
                ForEach(days, id: \.self) { day in
                    WeekDayCell(
                        day: day,
                        isSelected: DateFormat.calendar.isDate(day, inSameDayAs: selectedDate),
                        isToday: DateFormat.calendar.isDateInToday(day),
                        isMarked: markedDays.contains(DateFormat.date.string(from: day)),
                        fillsSelection: false,
                        action: { scroll(to: day) }
                    )
                    .frame(width: ScheduleMetrics.Size.dayScrollerCell)
                    .visualEffect { content, proxy in
                        content.scaleEffect(Self.magnification(of: proxy))
                    }
                }
            }
            .padding(.vertical, ScheduleMetrics.Spacing.dayScrollerVerticalInset)
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, sideMargin, for: .scrollContent)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition($position, anchor: .center)
        .fixedSize(horizontal: false, vertical: true)
        .background {
            RescheduleLens()
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newWidth in
            resize(to: newWidth)
        }
        .onChange(of: position, selectCentered)
    }

    private nonisolated static func magnification(of proxy: GeometryProxy) -> CGFloat {
        let frame = proxy.frame(in: .scrollView(axis: .horizontal))
        let visibleWidth = proxy.bounds(of: .scrollView(axis: .horizontal))?.width ?? 0
        let distance = abs(frame.midX - visibleWidth / 2)
        let reach = ScheduleMetrics.Size.dayScrollerCell + ScheduleMetrics.Spacing.dayScrollerSpacing
        let closeness = max(0, 1 - distance / reach)

        return 1 + (ScheduleMetrics.Size.dayScrollerSelectedScale - 1) * closeness
    }

    private func resize(to newWidth: CGFloat) {
        let isFirstLayout = width == 0

        width = newWidth

        if isFirstLayout {
            position.scrollTo(id: selectedDate, anchor: .center)
        }
    }

    private func selectCentered() {
        guard let day = position.viewID(type: Date.self) else { return }

        selectedDate = day
    }

    private func scroll(to day: Date) {
        withAnimation {
            position.scrollTo(id: day, anchor: .center)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selectedDate = DateFormat.calendar.startOfDay(for: .now)

    let today = DateFormat.calendar.startOfDay(for: .now)
    let days = (0..<21).compactMap {
        DateFormat.calendar.date(byAdding: .day, value: $0, to: today)
    }

    RescheduleDayScroller(
        selectedDate: $selectedDate,
        days: days,
        markedDays: [DateFormat.date.string(from: .now)]
    )
    .padding(.vertical, 24)
    .background(Color.background)
}
#endif
