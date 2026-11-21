import Foundation

struct ClientVisitItem: Identifiable {
    let id: String
    let dateText: String
    let timeText: String
    let serviceText: String

    init(slot: Slot, currency: Currency) {
        id = slot.id ?? Slot.documentId(date: slot.date, time: slot.time)
        dateText = DateFormat.date.date(from: slot.date).map(DateFormat.dayMonth.string(from:)) ?? slot.date
        timeText = DateFormat.displayTime(slot.time)
        serviceText = ServiceFormat.summary(
            name: slot.serviceName,
            price: slot.servicePrice,
            currency: currency
        )
    }
}
