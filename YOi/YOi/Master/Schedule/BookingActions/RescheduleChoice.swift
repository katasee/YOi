import Foundation

struct RescheduleTarget: Equatable {
    let date: String
    let time: String
}

struct RescheduleChoice {
    let days: [Date]
    let markedDays: Set<String>

    var day: Date {
        didSet {
            guard DateFormat.calendar.isDate(day, inSameDayAs: oldValue) == false else { return }

            selected = nil
            custom = nil
        }
    }

    private var selected: String?
    private var custom: String?

    private let freeTimes: [String: [String]]
    private let bookedIds: Set<String>
    private let now: Date

    init(booking: Slot, slots: [Slot], now: Date) {
        let range = RescheduleDays(dateId: booking.date, now: now)
        let freeTimes = Dictionary(grouping: slots.filter { $0.isBookable(now: now) }, by: \.date)
            .mapValues { $0.map(\.time).sorted() }

        days = range.days
        day = range.initialDay
        self.freeTimes = freeTimes
        self.now = now
        markedDays = Set(freeTimes.keys)
        bookedIds = Set(slots.filter(\.isBooked).compactMap(\.id))
    }

    var dayText: String {
        DateFormat.weekdayDayMonth.string(from: day)
    }

    var times: [TimeChipItem] {
        let all = (freeTimes[dayId] ?? []) + [custom].compactMap { $0 }

        return all.sorted().map { time in
            TimeChipItem(
                id: time,
                text: DateFormat.displayTime(time),
                isSelected: time == selected,
                isCustom: time == custom
            )
        }
    }

    var target: RescheduleTarget? {
        guard let selected else { return nil }

        let target = RescheduleTarget(date: dayId, time: selected)

        guard
            bookedIds.contains(Slot.documentId(date: target.date, time: target.time)) == false,
            Slot(date: target.date, time: target.time).isPast(now: now) == false
        else { return nil }

        return target
    }

    mutating func toggle(_ time: String) {
        selected = selected == time ? nil : time
    }

    mutating func setCustom(_ time: ClockTime) {
        let picked = DateFormat.storageTime(minutesOfDay: time.minutesOfDay)

        if freeTimes[dayId]?.contains(picked) != true {
            custom = picked
        }

        selected = picked
    }

    mutating func removeCustom(_ time: String) {
        guard custom == time else { return }

        if selected == time {
            selected = nil
        }

        custom = nil
    }

    private var dayId: String {
        DateFormat.date.string(from: day)
    }
}
