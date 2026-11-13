import Foundation

enum PlanCut: Equatable {
    case trim(endMinute: Int)
    case delete

    init?(planStart: Int, planEnd: Int, firstWindowMinute: Int) {
        guard planStart <= firstWindowMinute, firstWindowMinute < planEnd else { return nil }

        self = firstWindowMinute == planStart ? .delete : .trim(endMinute: firstWindowMinute)
    }
}

struct WindowReplacement: ScheduleReplacement {
    let trimmedPlans: [PlanEvent]
    let deletedPlanIds: [String]
    let entries: [ConflictEntry]

    init?(_ conflicts: [WindowConflict]) {
        let overlapsByPlan = Dictionary(grouping: conflicts.filter { $0.level == .overlap }) { $0.plan.id }

        var trimmedPlans: [PlanEvent] = []
        var deletedPlanIds: [String] = []
        var entries: [ConflictEntry] = []

        for overlaps in overlapsByPlan.values.sorted(by: { $0[0].plan.startTime < $1[0].plan.startTime }) {
            let plan = overlaps[0].plan

            guard
                let planId = plan.id,
                let start = DateFormat.minutesOfDay(plan.startTime),
                let end = DateFormat.minutesOfDay(plan.endTime),
                let firstWindow = overlaps.compactMap({ DateFormat.minutesOfDay($0.window.time) }).min(),
                let cut = PlanCut(planStart: start, planEnd: end, firstWindowMinute: firstWindow)
            else { continue }

            switch cut {
            case .delete:
                deletedPlanIds.append(planId)
                entries.append(ConflictEntry(id: planId, text: Self.deletedText(plan)))
            case .trim(let endMinute):
                var trimmed = plan
                trimmed.endTime = DateFormat.storageTime(minutesOfDay: endMinute)
                trimmedPlans.append(trimmed)
                entries.append(ConflictEntry(id: planId, text: Self.trimmedText(plan, to: trimmed)))
            }
        }

        guard entries.isEmpty == false else { return nil }

        self.trimmedPlans = trimmedPlans
        self.deletedPlanIds = deletedPlanIds
        self.entries = entries
    }

    var message: String {
        String(localized: "schedule.replace.plansMessage")
    }

    private static func title(_ plan: PlanEvent) -> String {
        "\(plan.emoji) \(plan.name)"
    }

    private static func range(_ plan: PlanEvent) -> String {
        "\(DateFormat.displayTime(plan.startTime))–\(DateFormat.displayTime(plan.endTime))"
    }

    private static func deletedText(_ plan: PlanEvent) -> String {
        String(localized: "schedule.replace.planDeleted \(title(plan)) \(range(plan))")
    }

    private static func trimmedText(_ plan: PlanEvent, to trimmed: PlanEvent) -> String {
        "\(title(plan)) · \(range(plan)) → \(range(trimmed))"
    }
}
