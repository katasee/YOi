import Foundation
import Observation

@MainActor
@Observable
final class AddPlanViewModel {
    var days: MonthDaySelection
    var times = PlanTimes()
    private(set) var isSingleDay = false

    private var planChoice: PlanChoice

    private let slots: [Slot]
    private let now: Date

    init(
        month: Date,
        templates: [EventTemplate],
        plannedDays: Set<String>,
        slots: [Slot],
        now: Date
    ) {
        days = MonthDaySelection(
            month: month,
            now: now,
            markedDays: plannedDays
        )
        planChoice = PlanChoice(templates: templates)
        self.slots = slots
        self.now = now
    }

    convenience init(
        day: Date,
        templates: [EventTemplate],
        plannedDays: Set<String>,
        slots: [Slot],
        now: Date
    ) {
        self.init(
            month: day,
            templates: templates,
            plannedDays: plannedDays,
            slots: slots,
            now: now
        )
        days.toggleDay(DateFormat.date.string(from: day))
        isSingleDay = true
    }

    var ownPlan: OwnPlan {
        get { planChoice.own }
        set { planChoice.own = newValue }
    }

    var templateChips: [ChoiceChip] {
        planChoice.chips
    }

    var hasTemplates: Bool {
        planChoice.isEmpty == false
    }

    var selectedTemplateId: String? {
        planChoice.selectedId
    }

    var conflictNotice: ConflictNotice? {
        ConflictNotice(conflicts, subject: .plan)
    }

    var dayConflicts: [String: PlanConflict] {
        WindowConflict.worstLevels(conflicts, by: \.plan.date)
    }

    var canAdd: Bool {
        days.selected.isEmpty == false
            && planChoice.pick != nil
            && times.isValid
            && conflictNotice?.blocksConfirm != true
    }

    func selectTemplate(_ id: String) {
        planChoice.select(id)
    }

    func makePlans() -> [PlanEvent] {
        canAdd ? candidatePlans : []
    }

    private var conflicts: [WindowConflict] {
        WindowConflict.find(
            windows: slots,
            plans: candidatePlans,
            now: now
        )
    }

    private var candidatePlans: [PlanEvent] {
        guard times.isValid, let pick = planChoice.pick else { return [] }

        return days.selected.sorted().map { date in
            PlanEvent(
                date: date,
                startTime: times.startTime,
                endTime: times.endTime,
                templateId: pick.templateId,
                emoji: pick.emoji,
                name: pick.name
            )
        }
    }
}
