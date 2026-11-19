import Foundation

private struct DayLineFormatter {
    let style: MessageDayStyle
    let locale: Locale
    let weekday: DateFormatter
    let weekdayDayMonth: DateFormatter

    init(style: MessageDayStyle, language: MessageLanguage) {
        self.style = style
        locale = language.locale
        weekday = DateFormat.messageWeekday(language.locale)
        weekdayDayMonth = DateFormat.messageWeekdayDayMonth(language.locale)
    }

    func line(day: Date, times: [String]) -> String {
        let dayNumber = DateFormat.messageDay.string(from: day)

        switch style {
        case .compact:
            return dayNumber + "-" + times.joined(separator: "/")
        case .dash:
            return dashLine(dayNumber: dayNumber, times: times)
        case .weekday:
            return capitalized(weekday.string(from: day)) + " " + dashLine(dayNumber: dayNumber, times: times)
        case .list:
            let bullets = times.map { "• " + $0 }
            return ([capitalized(weekdayDayMonth.string(from: day))] + bullets).joined(separator: "\n")
        }
    }

    func separator(from previous: Date, to day: Date) -> String {
        switch style {
        case .compact:
            "\n"
        case .list:
            "\n\n"
        case .dash, .weekday:
            Self.week(of: previous) == Self.week(of: day) ? "\n" : "\n\n"
        }
    }

    private func dashLine(dayNumber: String, times: [String]) -> String {
        dayNumber + " — " + times.joined(separator: ", ")
    }

    private func capitalized(_ text: String) -> String {
        text.prefix(1).uppercased(with: locale) + text.dropFirst()
    }

    private static func week(of day: Date) -> DateComponents {
        DateFormat.salonCalendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: day)
    }
}

enum ScheduleMessage {
    static func text(
        slots: [Slot],
        month: MonthGrid,
        now: Date,
        template: MessageTemplate,
        language: MessageLanguage
    ) -> String? {
        let monthStart = DateFormat.date.string(from: month.start)
        let nextMonthStart = DateFormat.date.string(from: month.shifted(by: 1).start)
        let monthRange = monthStart..<nextMonthStart

        let offeredSlots = slots.filter { slot in
            monthRange.contains(slot.date) && slot.isBookable(now: now)
        }

        let formatter = DayLineFormatter(style: template.dayStyle, language: language)

        guard let body = body(of: offeredSlots, formatter: formatter) else { return nil }

        return [template.header(for: language), body, template.footer(for: language)]
            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
            .joined(separator: "\n\n")
    }

    private static func body(of slots: [Slot], formatter: DayLineFormatter) -> String? {
        let messageTimes = messageTimes(for: Set(slots.map(\.time)))

        let days = Dictionary(grouping: slots, by: \.date)
            .sorted { $0.key < $1.key }
            .compactMap { dayId, daySlots in
                day(dayId: dayId, times: daySlots.map(\.time).sorted().compactMap { messageTimes[$0] })
            }

        var body = ""
        var previous: Date?

        for (day, times) in days {
            if let previous {
                body += formatter.separator(from: previous, to: day)
            }

            body += formatter.line(day: day, times: times)
            previous = day
        }

        return body.isEmpty ? nil : body
    }

    private static func messageTimes(for times: Set<String>) -> [String: String] {
        times.reduce(into: [:]) { messageTimes, time in
            messageTimes[time] = DateFormat.time.date(from: time).map { DateFormat.messageTime.string(from: $0) }
        }
    }

    private static func day(dayId: String, times: [String]) -> (Date, [String])? {
        guard let day = DateFormat.date.date(from: dayId), times.isEmpty == false else { return nil }

        return (day, times)
    }
}
