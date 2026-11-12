import Foundation

struct ServiceChoice {
    private(set) var selectedId: String?

    private var all: [Service]
    private let pinned: Service?

    init(services: [Service], pinning slot: Slot? = nil) {
        let all = services.sortedByOrder()

        self.all = all
        selectedId = slot?.serviceId
        pinned = slot.flatMap { Self.snapshot(of: $0, outside: all.filter(\.isOffered)) }
    }

    var chips: [ChoiceChip] {
        let pinnedChip = pinned.flatMap { chip(for: $0, isMovable: false) }

        return [pinnedChip].compactMap { $0 } + offered.compactMap { chip(for: $0, isMovable: true) }
    }

    var selectedService: Service? {
        offered.first { $0.id == selectedId }
    }

    var nextPosition: Int {
        all.nextPosition
    }

    var orderedIds: [String] {
        all.ids
    }

    mutating func toggle(_ id: String) {
        selectedId = selectedId == id ? nil : id
    }

    mutating func move(_ id: String, to targetId: String) {
        all = all.moving(id, to: targetId)
    }

    mutating func add(_ service: Service) {
        guard let id = service.id, all.contains(where: { $0.id == id }) == false else { return }

        all.append(service)
    }

    mutating func select(newService: Service) {
        add(newService)
        selectedId = newService.id
    }

    private var offered: [Service] {
        all.filter(\.isOffered)
    }

    private func chip(for service: Service, isMovable: Bool) -> ChoiceChip? {
        service.id.map { id in
            ChoiceChip(
                id: id,
                title: service.name,
                isSelected: id == selectedId,
                isMovable: isMovable
            )
        }
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
