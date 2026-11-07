import Foundation
import Observation

@MainActor
@Observable
final class AddPlanViewModel {
    var days: MonthDaySelection
    var times = PlanTimes()
    private(set) var isSingleDay = false

    private var templateChoice: TemplateChoice

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
        templateChoice = TemplateChoice(templates: templates)
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

    var templateChips: [ChoiceChip] {
        templateChoice.chips
    }

    var hasTemplates: Bool {
        templateChoice.isEmpty == false
    }

    var selectedTemplateId: String? {
        templateChoice.selectedId
    }

    var conflictNotice: ConflictNotice? {
        ConflictNotice(conflicts, subject: .plan)
    }

    var dayConflicts: [String: PlanConflict] {
        WindowConflict.worstLevels(conflicts, by: \.plan.date)
    }

    var canAdd: Bool {
        days.selected.isEmpty == false
            && templateChoice.selectedTemplate != nil
            && times.isValid
            && conflictNotice?.blocksConfirm != true
    }

    func selectTemplate(_ id: String) {
        templateChoice.select(id)
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
        guard
            times.isValid,
            let template = templateChoice.selectedTemplate,
            let templateId = template.id
        else { return [] }

        return days.selected.sorted().map { date in
            PlanEvent(
                date: date,
                startTime: times.startTime,
                endTime: times.endTime,
                templateId: templateId,
                emoji: template.emoji,
                name: template.name
            )
        }
    }
}
