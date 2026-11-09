import Foundation
import Observation

@MainActor
@Observable
final class BookClientViewModel: Identifiable {
    let id = UUID()
    let choice: ClientBookingChoice

    private let slot: Slot
    private let slotRepository: SlotRepository

    init(
        slot: Slot,
        clients: [Client],
        services: [Service],
        slotRepository: SlotRepository,
        clientRepository: ClientRepository,
        serviceRepository: ServiceRepository
    ) {
        self.slot = slot
        choice = ClientBookingChoice(
            clients: clients,
            services: services,
            clientRepository: clientRepository,
            serviceRepository: serviceRepository
        )
        self.slotRepository = slotRepository
    }

    var subtitle: String {
        SlotWhen.text(for: slot)
    }

    var canBook: Bool {
        choice.selectedClientId != nil
    }

    func book() {
        guard let slotId = slot.id, let clientId = choice.selectedClientId else { return }

        let booking = SlotBooking(clientId: clientId, service: choice.selectedService)

        try? slotRepository.book(slotId: slotId, booking)
    }
}
