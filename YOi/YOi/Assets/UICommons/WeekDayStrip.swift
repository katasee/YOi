import SwiftUI

struct WeekDayStrip: View {
    @Binding var selectedDate: Date

    @Namespace private var namespace

    private enum Layout {
        static let daySpacing: CGFloat = 4
        static let horizontalPadding: CGFloat = 6
        static let chevronWidth: CGFloat = 32
        static let chevronHeight: CGFloat = 44
    }

    fileprivate static let selectionAnimation = Animation.spring(response: 0.35, dampingFraction: 0.75)

    private var weekDates: [Date] {
        Self.weekDates(containing: selectedDate)
    }

    var body: some View {
        HStack(spacing: Layout.daySpacing) {
            weekNavButton(forward: false)

            ForEach(weekDates, id: \.self) { day in
                WeekDayCell(
                    day: day,
                    isSelected: DateFormat.calendar.isDate(day, inSameDayAs: selectedDate),
                    isToday: DateFormat.calendar.isDateInToday(day),
                    namespace: namespace,
                    action: { select(day) }
                )
            }

            weekNavButton(forward: true)
        }
        .padding(.horizontal, Layout.horizontalPadding)
    }

    private func select(_ day: Date) {
        withAnimation(Self.selectionAnimation) {
            selectedDate = day
        }
    }

    fileprivate static func landingDay(
        shiftingWeekOf date: Date,
        forward: Bool,
        now: Date
    ) -> Date? {
        let calendar = DateFormat.calendar

        guard
            let shifted = calendar.date(
                byAdding: .weekOfYear,
                value: forward ? 1 : -1,
                to: date
            ),
            let week = calendar.dateInterval(of: .weekOfYear, for: shifted)
        else {
            return nil
        }

        let isCurrentWeek = calendar.isDate(
            now,
            equalTo: shifted,
            toGranularity: .weekOfYear
        )

        return isCurrentWeek ? now : week.start
    }

    private func shiftWeek(forward: Bool) {
        if let day = Self.landingDay(shiftingWeekOf: selectedDate, forward: forward, now: .now) {
            select(day)
        }
    }

    private func weekNavButton(forward: Bool) -> some View {
        Button {
            shiftWeek(forward: forward)
        } label: {
            Image(systemName: forward ? "chevron.right" : "chevron.left")
                .font(.elmsSans(.semiBold, 13))
                .foregroundStyle(Color.textSecondary)
                .frame(width: Layout.chevronWidth, height: Layout.chevronHeight)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private static func weekDates(containing date: Date) -> [Date] {
        let startOfWeek = DateFormat.calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { DateFormat.calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

private enum WeekSwipeLayout {
    static let minimumDistance: CGFloat = 20
}

extension View {
    func weekSwipe(selectedDate: Binding<Date>) -> some View {
        gesture(
            DragGesture(minimumDistance: WeekSwipeLayout.minimumDistance)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }

                    guard
                        let day = WeekDayStrip.landingDay(
                            shiftingWeekOf: selectedDate.wrappedValue,
                            forward: value.translation.width < 0,
                            now: .now
                        )
                    else {
                        return
                    }

                    withAnimation(WeekDayStrip.selectionAnimation) {
                        selectedDate.wrappedValue = day
                    }
                }
        )
    }
}

#Preview {
    @Previewable @State var selectedDate = Date.now

    WeekDayStrip(selectedDate: $selectedDate)
        .padding(.vertical, 24)
        .background(Color.background)
}
