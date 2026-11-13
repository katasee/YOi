import Foundation
import Observation

@MainActor
@Observable
final class FillMonthViewModel: Identifiable {
    let id = UUID()

    var days: MonthDaySelection
    private(set) var isConfirmingReplace = false

    private var fillTimes = FillTimes()

    private let existingIds: Set<String>
    private let plans: [PlanEvent]
    private let now: Date
    private let slotRepository: SlotRepository

    init(
        month: Date,
        existing: [Slot],
        plans: [PlanEvent],
        now: Date,
        slotRepository: SlotRepository
    ) {
        days = MonthDaySelection(
            month: month,
            now: now,
            markedDays: Set(existing.map(\.date))
        )
        existingIds = Set(existing.map { Slot.documentId(date: $0.date, time: $0.time) })
        self.plans = plans
        self.now = now
        self.slotRepository = slotRepository
    }

    var times: [TimeChipItem] {
        fillTimes.all.map { time in
            TimeChipItem(
                id: time,
                text: DateFormat.displayTime(time),
                isSelected: fillTimes.selected.contains(time),
                isCustom: fillTimes.isCustom(time)
            )
        }
    }

    var newSlotCount: Int {
        missingSlots(now: now).count
    }

    var conflictNotice: ConflictNotice? {
        ConflictNotice(conflicts, subject: .window)
    }

    var dayConflicts: [String: PlanConflict] {
        WindowConflict.worstLevels(conflicts, by: \.window.date)
    }

    var canAdd: Bool {
        newSlotCount > 0 && conflictNotice?.blocksConfirm != true
    }

    var replacement: WindowReplacement? {
        guard days.selected.count == 1 else { return nil }

        return WindowReplacement(conflicts)
    }

    func startConfirmingReplace() {
        isConfirmingReplace = true
    }

    func stopConfirmingReplace() {
        isConfirmingReplace = false
    }

    func toggleTime(_ id: String) {
        fillTimes.toggle(id)
    }

    func addCustomTime(_ time: ClockTime) {
        fillTimes.addCustom(DateFormat.storageTime(minutesOfDay: time.minutesOfDay))
    }

    func removeCustomTime(_ id: String) {
        fillTimes.removeCustom(id)
    }

    func add(now: Date = .now) -> AddedNotice? {
        save(missingSlots(now: now))
    }

    func addReplacing(now: Date = .now) -> AddedNotice? {
        guard replacement != nil else { return nil }

        return save(missingSlots(now: now))
    }

    private func save(_ slots: [Slot]) -> AddedNotice? {
        guard slots.isEmpty == false else { return nil }

        do {
            try slotRepository.add(slots)
            return AddedNotice(kind: .windows, outcome: .saved(dates: slots.map(\.date)))
        } catch {
            return AddedNotice(kind: .windows, outcome: .failed)
        }
    }

    private var conflicts: [WindowConflict] {
        WindowConflict.find(
            windows: missingSlots(now: now),
            plans: plans,
            now: now
        )
    }

    private func missingSlots(now: Date) -> [Slot] {
        Slot.missing(
            days: days.selected,
            times: fillTimes.selected,
            existingIds: existingIds,
            now: now
        )
    }
}
