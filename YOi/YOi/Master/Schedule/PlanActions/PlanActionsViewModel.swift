import Foundation
import Observation

enum PlanActionsMode {
    case actions
    case changeTemplate
    case reschedule
}

@MainActor
@Observable
final class PlanActionsViewModel: Identifiable {
    private(set) var mode = PlanActionsMode.actions
    var move: PlanMove

    private var templateChoice: TemplateChoice

    private let plan: PlanEvent
    private let initialChoice: TemplateChoice
    private let initialMove: PlanMove
    private let slots: [Slot]
    private let now: Date

    init(
        plan: PlanEvent,
        templates: [EventTemplate],
        plannedDays: Set<String>,
        slots: [Slot],
        now: Date
    ) {
        self.plan = plan
        self.slots = slots
        self.now = now
        initialChoice = TemplateChoice(templates: templates, pinning: plan)
        templateChoice = initialChoice
        initialMove = PlanMove(
            plan: plan,
            plannedDays: plannedDays,
            now: now
        )
        move = initialMove
    }

    var planId: String? {
        plan.id
    }

    var title: String {
        switch mode {
        case .reschedule: String(localized: "schedule.plan.reschedule.title")
        case .actions, .changeTemplate: planTitle
        }
    }

    var subtitle: String {
        switch mode {
        case .reschedule: "\(planTitle) · \(dayAndTime)"
        case .actions, .changeTemplate: dayAndTime
        }
    }

    var ownPlan: OwnPlan {
        get { templateChoice.own }
        set { templateChoice.own = newValue }
    }

    var templateChips: [ChoiceChip] {
        templateChoice.chips
    }

    var hasTemplateChanged: Bool {
        guard let id = templateChoice.selectedTemplate?.id else { return false }

        return id != plan.templateId
    }

    var conflictNotice: ConflictNotice? {
        ConflictNotice(
            WindowConflict.find(
                windows: slots,
                plans: [move.movedPlan].compactMap { $0 },
                now: now
            ),
            subject: .plan
        )
    }

    var canReschedule: Bool {
        move.movedPlan != nil && conflictNotice?.blocksConfirm != true
    }

    func startChangingTemplate() {
        templateChoice = initialChoice
        mode = .changeTemplate
    }

    func stopChangingTemplate() {
        mode = .actions
    }

    func selectTemplate(_ id: String) {
        templateChoice.select(id)
    }

    func changedPlan() -> PlanEvent? {
        guard
            hasTemplateChanged,
            let template = templateChoice.selectedTemplate,
            let templateId = template.id
        else { return nil }

        var changed = plan
        changed.templateId = templateId
        changed.emoji = template.emoji
        changed.name = template.name

        return changed
    }

    func startRescheduling() {
        move = initialMove
        mode = .reschedule
    }

    func stopRescheduling() {
        mode = .actions
    }

    private var planTitle: String {
        "\(plan.emoji) \(plan.name)"
    }

    private var dayAndTime: String {
        let day = DateFormat.date
            .date(from: plan.date)
            .map(DateFormat.weekdayDayMonth.string(from:)) ?? plan.date
        let start = DateFormat.displayTime(plan.startTime)
        let end = DateFormat.displayTime(plan.endTime)

        return "\(day) · \(start)–\(end)"
    }
}
