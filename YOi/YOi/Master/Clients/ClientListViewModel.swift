import Foundation
import Observation

@MainActor
@Observable
final class ClientListViewModel {
    var searchText = ""

    private(set) var hasLoaded = false
    private(set) var hasFailed = false
    private var clients: [Client] = []

    private let clientRepository: ClientRepository
    private let slotRepository: SlotRepository

    init(
        clientRepository: ClientRepository = FirestoreClientRepository(),
        slotRepository: SlotRepository = FirestoreSlotRepository()
    ) {
        self.clientRepository = clientRepository
        self.slotRepository = slotRepository
    }

    var items: [ClientItem] {
        clients
            .filter { $0.matches(searchText) }
            .map(ClientItem.init)
    }

    var totalCount: Int {
        clients.count
    }

    func observeClients() async {
        hasFailed = false

        do {
            for try await updatedClients in clientRepository.observeClients() {
                clients = updatedClients.sortedNewestFirst()
                hasLoaded = true
            }
        } catch {
            hasFailed = true
            hasLoaded = true
        }
    }

    func makeAddFormViewModel() -> ClientFormViewModel {
        ClientFormViewModel(
            takenHandles: clients.takenHandles,
            phoneCountry: clients.defaultPhoneCountry(region: Locale.current.region),
            clientRepository: clientRepository
        )
    }

    func makeCardViewModel(id: String) -> ClientCardViewModel {
        ClientCardViewModel(
            clientId: id,
            takenHandles: clients.takenHandles,
            clientRepository: clientRepository,
            slotRepository: slotRepository
        )
    }
}
