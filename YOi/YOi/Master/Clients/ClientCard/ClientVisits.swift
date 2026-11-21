import Foundation

struct ClientVisits {
    let planned: [ClientVisitItem]
    let history: [ClientVisitItem]

    var showsHistory: Bool {
        history.isEmpty == false || planned.isEmpty
    }

    init(
        slots: [Slot],
        now: Date,
        currency: Currency
    ) {
        let sorted = slots.sorted(by: Slot.chronologically)

        planned = sorted
            .filter { $0.isPast(now: now) == false }
            .map { ClientVisitItem(slot: $0, currency: currency) }
        history = sorted
            .filter { $0.isPast(now: now) }
            .reversed()
            .map { ClientVisitItem(slot: $0, currency: currency) }
    }
}
