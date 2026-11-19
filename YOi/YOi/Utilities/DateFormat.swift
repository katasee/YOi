import Foundation

enum DateFormat {
    static let date = storageFormatter("yyyy-MM-dd")
    static let time = storageFormatter("HH:mm")
    static let month = storageFormatter("yyyy-MM")
    static let dayNumber = displayFormatter("d")
    static let weekdayLetter = displayFormatter("EEEEE")
    static let weekdayName = displayFormatter("cccc")
    static let monthYear = displayFormatter("LLLL y")
    static let dateTime = storageFormatter("yyyy-MM-dd HH:mm")
    static let dayMonth = templateFormatter("dMMMM")
    static let dayMonthShort = templateFormatter("dMMM")
    static let dayMonthNumeric = templateFormatter("dM")
    static let weekdayDayMonth = templateFormatter("EEEdMMMM")
    static let messageDay = messageFormatter("d.MM")
    static let messageTime = messageFormatter("H:mm")

    static let salonTimeZone = TimeZone(identifier: "Europe/Warsaw") ?? .current

    static let salonCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = salonTimeZone
        calendar.firstWeekday = 2
        return calendar
    }()

    static func storageTime(minutesOfDay: Int) -> String {
        let components = DateComponents(
            year: 2000,
            month: 1,
            day: 1,
            hour: minutesOfDay / 60,
            minute: minutesOfDay % 60
        )

        guard let date = salonCalendar.date(from: components) else { return "" }

        return time.string(from: date)
    }

    static func minutesOfDay(_ storageTime: String) -> Int? {
        guard let date = time.date(from: storageTime) else { return nil }

        let components = salonCalendar.dateComponents([.hour, .minute], from: date)

        guard let hour = components.hour, let minute = components.minute else { return nil }

        return hour * 60 + minute
    }

    static func displayTime(_ storageTime: String) -> String {
        guard let date = time.date(from: storageTime) else { return storageTime }

        return clockTime.string(from: date)
    }

    static func messageWeekday(_ locale: Locale) -> DateFormatter {
        formatter("EEE", locale: locale)
    }

    static func messageWeekdayDayMonth(_ locale: Locale) -> DateFormatter {
        templateFormatter("EEEEdMMMM", locale: locale)
    }

    private static let clockTime = templateFormatter("jmm")

    private static func storageFormatter(_ format: String) -> DateFormatter {
        formatter(format, locale: Locale(identifier: "en_US_POSIX"))
    }

    private static func messageFormatter(_ format: String) -> DateFormatter {
        formatter(format, locale: Locale(identifier: "en_US_POSIX"))
    }

    private static func displayFormatter(_ format: String) -> DateFormatter {
        formatter(format, locale: .current)
    }

    private static func templateFormatter(_ template: String, locale: Locale = .current) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = salonTimeZone
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter
    }

    private static func formatter(_ format: String, locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = salonTimeZone
        return formatter
    }
}
