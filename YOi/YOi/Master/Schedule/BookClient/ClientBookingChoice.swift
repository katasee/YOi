import Foundation
import Observation

@MainActor
@Observable
final class ClientBookingChoice {
    private(set) var hasWriteFailed = false
    private var picker = ClientPicker()
    private var clients: [Client]
    private var serviceChoice: ServiceChoice

    private let clientRepository: ClientRepository
    private let serviceRepository: ServiceRepository

    init(
        clients: [Client],
        services: [Service],
        clientRepository: ClientRepository,
        serviceRepository: ServiceRepository
    ) {
        self.clients = clients
        serviceChoice = ServiceChoice(services: services)
        self.clientRepository = clientRepository
        self.serviceRepository = serviceRepository
    }

    var searchText: String {
        get { picker.searchText }
        set { picker.searchText = newValue }
    }

    var options: [BookClientOption] {
        picker.options(from: clients)
    }

    var services: [ChoiceChip] {
        serviceChoice.chips
    }

    var selectedClientId: String? {
        picker.selectedId
    }

    var selectedService: Service? {
        serviceChoice.selectedService
    }

    func toggleClient(_ id: String) {
        picker.toggle(id)
    }

    func toggleService(_ id: String) {
        serviceChoice.toggle(id)
    }

    func moveService(_ id: String, to targetId: String) {
        serviceChoice.move(id, to: targetId)
    }

    func commitServiceOrder() {
        do {
            try serviceRepository.reorder(ids: serviceChoice.orderedIds)
        } catch {
            hasWriteFailed = true
        }
    }

    func makeNewClientForm() -> ClientFormViewModel {
        ClientFormViewModel(
            takenHandles: clients.takenHandles,
            phoneCountry: clients.defaultPhoneCountry(region: Locale.current.region),
            clientRepository: clientRepository
        )
    }

    func select(newClient: Client) {
        guard let id = newClient.id else { return }

        clients.append(newClient)
        picker.select(id)
    }

    func makeNewServiceForm() -> ServiceFormViewModel {
        ServiceFormViewModel(mode: .add(position: serviceChoice.nextPosition), serviceRepository: serviceRepository)
    }

    func select(newService: Service) {
        serviceChoice.select(newService: newService)
    }
}
