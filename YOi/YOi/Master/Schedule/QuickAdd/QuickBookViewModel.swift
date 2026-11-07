import Foundation
import Observation

@MainActor
@Observable
final class QuickBookViewModel: Identifiable {
    let id = UUID()
    let choice: ClientBookingChoice
    var time = WorkHours.defaultCustomTime

    private let day: Date
    private let dayId: String
    private let bookedIds: Set<String>
    private let plans: [PlanEvent]
    private let now: Date
    private let slotRepository: SlotRepository

    init(
        day: Date,
        slots: [Slot],
        plans: [PlanEvent],
        clients: [Client],
        services: [Service],
        now: Date,
        slotRepository: SlotRepository,
        clientRepository: ClientRepository
    ) {
        self.day = day
        dayId = DateFormat.date.string(from: day)
        bookedIds = Set(
            slots
                .filter(\.isBooked)
                .map { Slot.documentId(date: $0.date, time: $0.time) }
        )
        self.plans = plans
        self.now = now
        self.slotRepository = slotRepository
        choice = ClientBookingChoice(
            clients: clients,
            services: services,
            clientRepository: clientRepository
        )
    }

    var subtitle: String {
        DateFormat.weekdayDayMonth.string(from: day)
    }

    var notice: ConflictNotice? {
        if bookedIds.contains(candidateId) {
            let text = String(localized: "schedule.quickAdd.taken \(DateFormat.displayTime(candidate.time))")

            return .overlap(ConflictEntry(id: "taken", text: text))
        }

        return ConflictNotice(
            WindowConflict.find(
                windows: [candidate],
                plans: plans,
                now: now
            ),
            subject: .window
        )
    }

    var canBook: Bool {
        choice.selectedClientId != nil && notice?.blocksConfirm != true
    }

    func book() {
        guard canBook, let clientId = choice.selectedClientId else { return }

        let booking = SlotBooking(clientId: clientId, service: choice.selectedService)

        try? slotRepository.addBooked(
            date: candidate.date,
            time: candidate.time,
            booking
        )
    }

    private var candidate: Slot {
        Slot(date: dayId, time: DateFormat.storageTime(minutesOfDay: time.minutesOfDay))
    }

    private var candidateId: String {
        Slot.documentId(date: candidate.date, time: candidate.time)
    }
}
