import Foundation
import Observation

@MainActor
@Observable
final class ClientCardViewModel {
    private(set) var isDeleted = false
    private var client: Client?
    private var visitSlots: [Slot]?

    private let clientId: String
    private let takenHandles: Set<String>
    private let clientRepository: ClientRepository
    private let slotRepository: SlotRepository

    init(
        clientId: String,
        takenHandles: Set<String>,
        clientRepository: ClientRepository,
        slotRepository: SlotRepository
    ) {
        self.clientId = clientId
        self.takenHandles = takenHandles
        self.clientRepository = clientRepository
        self.slotRepository = slotRepository
    }

    var card: ClientCard? {
        if let client {
            ClientCard(client: client)
        } else {
            nil
        }
    }

    func observeClient() async {
        do {
            for try await updatedClient in clientRepository.observeClient(id: clientId) {
                if let updatedClient {
                    client = updatedClient
                } else if client != nil {
                    isDeleted = true
                }
            }
        } catch {
            return
        }
    }

    func visits(now: Date, currency: Currency) -> ClientVisits? {
        visitSlots.map {
            ClientVisits(
                slots: $0,
                now: now,
                currency: currency
            )
        }
    }

    func observeVisits() async {
        do {
            for try await slots in slotRepository.observeSlots() {
                visitSlots = slots.filter { $0.clientId == clientId }
            }
        } catch {
            visitSlots = nil
        }
    }

    func makeEditFormViewModel() -> ClientFormViewModel? {
        guard let client else { return nil }

        return ClientFormViewModel(
            editing: client,
            fallbackCountry: .regional(Locale.current.region),
            takenHandles: takenHandles,
            clientRepository: clientRepository
        )
    }
}
