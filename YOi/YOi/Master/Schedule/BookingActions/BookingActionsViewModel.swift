import Foundation
import Observation

enum BookingActionsMode {
    case actions
    case changeService
    case reschedule
    case rescheduled(message: String)
}

@MainActor
@Observable
final class BookingActionsViewModel: Identifiable {
    let id = UUID()

    private(set) var mode = BookingActionsMode.actions
    private var rescheduleChoice: RescheduleChoice
    private var serviceChoice: ServiceChoice

    private let slot: Slot
    private let client: Client?
    private let initialChoice: ServiceChoice
    private let initialReschedule: RescheduleChoice
    private let plans: [PlanEvent]
    private let now: Date
    private let slotRepository: SlotRepository

    init(
        slot: Slot,
        client: Client?,
        services: [Service],
        slots: [Slot],
        plans: [PlanEvent],
        now: Date,
        slotRepository: SlotRepository
    ) {
        self.slot = slot
        self.plans = plans
        self.now = now
        self.client = client
        self.slotRepository = slotRepository
        initialChoice = ServiceChoice(services: services, pinning: slot)
        serviceChoice = initialChoice
        initialReschedule = RescheduleChoice(booking: slot, slots: slots, now: now)
        rescheduleChoice = initialReschedule
    }

    var title: String {
        switch mode {
        case .reschedule: String(localized: "schedule.reschedule.title")
        case .actions, .changeService, .rescheduled: clientName
        }
    }

    var subtitle: String {
        switch mode {
        case .reschedule:
            return "\(clientName) · \(SlotWhen.text(for: slot))"
        case .rescheduled:
            return String(localized: "schedule.reschedule.copied")
        case .actions, .changeService:
            let service = slot.serviceName ?? String(localized: "service.none")

            return "\(SlotWhen.text(for: slot)) · \(service)"
        }
    }

    var contacts: [ClientContact] {
        client?.contacts ?? []
    }

    var cardClientId: String? {
        client?.id
    }

    var services: [ChoiceChip] {
        serviceChoice.chips
    }

    var hasServiceChanged: Bool {
        serviceChoice.selectedId != slot.serviceId
    }

    func startChangingService() {
        mode = .changeService
    }

    func stopChangingService() {
        serviceChoice = initialChoice
        mode = .actions
    }

    func toggleService(_ id: String) {
        serviceChoice.toggle(id)
    }

    func saveService() {
        guard hasServiceChanged, let slotId = slot.id, let clientId = slot.clientId else { return }

        let booking = SlotBooking(clientId: clientId, service: serviceChoice.selectedService)

        try? slotRepository.book(slotId: slotId, booking)
    }

    var rescheduleDay: Date {
        get { rescheduleChoice.day }
        set { rescheduleChoice.day = newValue }
    }

    var rescheduleDays: [Date] {
        rescheduleChoice.days
    }

    var rescheduleMarkedDays: Set<String> {
        rescheduleChoice.markedDays
    }

    var rescheduleDayText: String {
        rescheduleChoice.dayText
    }

    var rescheduleTimes: [TimeChipItem] {
        rescheduleChoice.times
    }

    var conflictNotice: ConflictNotice? {
        guard let target = rescheduleChoice.target else { return nil }

        return ConflictNotice(
            WindowConflict.find(
                windows: [Slot(date: target.date, time: target.time)],
                plans: plans,
                now: now
            ),
            subject: .window
        )
    }

    var canReschedule: Bool {
        rescheduleChoice.target != nil && conflictNotice?.blocksConfirm != true
    }

    func toggleRescheduleTime(_ time: String) {
        rescheduleChoice.toggle(time)
    }

    func addCustomRescheduleTime(_ time: ClockTime) {
        rescheduleChoice.setCustom(time)
    }

    func removeCustomRescheduleTime(_ time: String) {
        rescheduleChoice.removeCustom(time)
    }

    func startRescheduling() {
        rescheduleChoice = initialReschedule
        mode = .reschedule
    }

    func stopRescheduling() {
        mode = .actions
    }

    func reschedule() -> String? {
        guard
            let target = rescheduleChoice.target,
            let slotId = slot.id,
            let booking = SlotBooking(bookedSlot: slot)
        else { return nil }

        do {
            try slotRepository.reschedule(
                slotId: slotId,
                booking,
                toDate: target.date,
                time: target.time
            )
        } catch {
            return nil
        }

        mode = .rescheduled(message: RescheduleMessage.text(date: target.date, time: target.time))

        return target.date
    }

    func cancelBooking() {
        guard let slotId = slot.id else { return }

        try? slotRepository.clearBooking(slotId: slotId)
    }

    private var clientName: String {
        client?.displayName ?? String(localized: "schedule.slot.clientDeleted")
    }
}
