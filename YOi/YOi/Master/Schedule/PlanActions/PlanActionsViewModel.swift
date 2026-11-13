import Foundation
import Observation

enum PlanActionsMode {
    case actions
    case changePlan
    case reschedule
    case confirmReplace
}

@MainActor
@Observable
final class PlanActionsViewModel: Identifiable {
    private(set) var mode = PlanActionsMode.actions
    var move: PlanMove

    private var planChoice: PlanChoice

    private let plan: PlanEvent
    private let initialChoice: PlanChoice
    private let initialMove: PlanMove
    private let slots: [Slot]
    private let now: Date
    private let directory: ClientDirectory

    init(
        plan: PlanEvent,
        templates: [EventTemplate],
        plannedDays: Set<String>,
        slots: [Slot],
        now: Date,
        directory: ClientDirectory
    ) {
        self.plan = plan
        self.slots = slots
        self.now = now
        self.directory = directory
        initialChoice = PlanChoice(templates: templates, pinning: plan)
        planChoice = initialChoice
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
        case .reschedule, .confirmReplace: String(localized: "schedule.plan.reschedule.title")
        case .actions, .changePlan: planTitle
        }
    }

    var subtitle: String {
        switch mode {
        case .reschedule, .confirmReplace: "\(planTitle) · \(dayAndTime)"
        case .actions, .changePlan: dayAndTime
        }
    }

    var ownPlan: OwnPlan {
        get { planChoice.own }
        set { planChoice.own = newValue }
    }

    var templateChips: [ChoiceChip] {
        planChoice.chips
    }

    var hasPlanChanged: Bool {
        planChoice.pick?.changes(plan) == true
    }

    var conflictNotice: ConflictNotice? {
        ConflictNotice(conflicts, subject: .plan)
    }

    var replacement: PlanReplacement? {
        PlanReplacement(conflicts, directory: directory)
    }

    var canReschedule: Bool {
        move.movedPlan != nil && conflictNotice?.blocksConfirm != true
    }

    func startChangingPlan() {
        planChoice = initialChoice
        mode = .changePlan
    }

    func stopChangingPlan() {
        mode = .actions
    }

    func selectTemplate(_ id: String) {
        planChoice.select(id)
    }

    func changedPlan() -> PlanEvent? {
        guard let pick = planChoice.pick, pick.changes(plan) else { return nil }

        var changed = plan
        changed.templateId = pick.templateId
        changed.emoji = pick.emoji
        changed.name = pick.name

        return changed
    }

    func startRescheduling() {
        move = initialMove
        mode = .reschedule
    }

    func stopRescheduling() {
        mode = .actions
    }

    func startConfirmingReplace() {
        mode = .confirmReplace
    }

    func stopConfirmingReplace() {
        mode = .reschedule
    }

    private var conflicts: [WindowConflict] {
        WindowConflict.find(
            windows: slots,
            plans: [move.movedPlan].compactMap { $0 },
            now: now
        )
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
