import Foundation

enum ScheduleDayItems {
    private enum Order: Int {
        case slot
        case plan
    }

    static func make(
        day: String,
        slots: [Slot],
        plans: [PlanEvent],
        clientName: (String) -> String,
        now: Date,
        currency: Currency
    ) -> [ScheduleItem] {
        let daySlots = slots.filter { $0.date == day }
        let dayPlans = plans.filter { $0.date == day }
        let conflicts = WindowConflict.worstLevels(
            WindowConflict.find(windows: daySlots, plans: dayPlans, now: now),
            by: { Slot.documentId(date: $0.window.date, time: $0.window.time) }
        )

        let slotRows = daySlots
            .map { slot in
                (
                    key: (slot.time, Order.slot.rawValue, slot.id ?? ""),
                    item: ScheduleItem.slot(
                        SlotItem(
                            slot: slot,
                            clientName: slot.clientId.map(clientName) ?? "",
                            conflict: conflicts[Slot.documentId(date: slot.date, time: slot.time)],
                            now: now,
                            currency: currency
                        )
                    )
                )
            }

        let planRows = dayPlans
            .map { plan in
                (
                    key: (plan.startTime, Order.plan.rawValue, plan.id ?? ""),
                    item: ScheduleItem.plan(PlanItem(plan: plan, now: now))
                )
            }

        return (slotRows + planRows)
            .sorted { $0.key < $1.key }
            .map(\.item)
    }
}
