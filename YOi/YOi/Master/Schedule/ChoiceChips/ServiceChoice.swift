import Foundation

struct ServiceChoice {
    private(set) var selectedId: String?

    private var offered: [Service]
    private let pinned: Service?

    init(services: [Service], pinning slot: Slot? = nil) {
        let offered = services.filter(\.isOffered).sortedByName()

        self.offered = offered
        selectedId = slot?.serviceId
        pinned = slot.flatMap { Self.snapshot(of: $0, outside: offered) }
    }

    var chips: [ChoiceChip] {
        ([pinned].compactMap { $0 } + offered).compactMap { service in
            service.id.map { id in
                ChoiceChip(
                    id: id,
                    title: service.name,
                    isSelected: id == selectedId
                )
            }
        }
    }

    var selectedService: Service? {
        offered.first { $0.id == selectedId }
    }

    mutating func toggle(_ id: String) {
        selectedId = selectedId == id ? nil : id
    }

    mutating func add(_ service: Service) {
        guard let id = service.id, offered.contains(where: { $0.id == id }) == false else { return }

        offered = (offered + [service]).sortedByName()
    }

    mutating func select(newService: Service) {
        add(newService)
        selectedId = newService.id
    }

    private static func snapshot(of slot: Slot, outside offered: [Service]) -> Service? {
        guard
            let id = slot.serviceId,
            offered.contains(where: { $0.id == id }) == false,
            let name = slot.serviceName,
            let price = slot.servicePrice
        else { return nil }

        return Service(id: id, name: name, price: price)
    }
}
