import Foundation

struct SlotBookingItem {
    let clientName: String
    let serviceText: String

    init(
        slot: Slot,
        clientName: String,
        currency: Currency
    ) {
        self.clientName = clientName
        serviceText = ServiceFormat.summary(
            name: slot.serviceName,
            price: slot.servicePrice,
            currency: currency
        )
    }
}

struct SlotItem: Identifiable {
    let id: String
    let timeText: String
    let isPast: Bool
    let booking: SlotBookingItem?
    let conflict: PlanConflict?

    init(
        slot: Slot,
        clientName: String,
        conflict: PlanConflict?,
        now: Date,
        currency: Currency
    ) {
        id = slot.id ?? Slot.documentId(date: slot.date, time: slot.time)
        timeText = DateFormat.displayTime(slot.time)
        isPast = slot.isPast(now: now)
        booking = slot.isBooked
            ? SlotBookingItem(
                slot: slot,
                clientName: clientName,
                currency: currency
            )
            : nil
        self.conflict = conflict
    }
}
