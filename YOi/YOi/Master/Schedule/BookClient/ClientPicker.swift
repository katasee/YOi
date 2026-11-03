import Foundation

struct ClientPicker {
    static let maxOptions = 5

    var searchText = ""
    private(set) var selectedId: String?

    func options(from clients: [Client]) -> [BookClientOption] {
        let selected = clients.first { $0.id == selectedId }
        let matches = isSearchTextEmpty ? [] : clients
            .filter { $0.id != selectedId && $0.matches(searchText) }
            .sortedNewestFirst()
            .prefix(Self.maxOptions - (selected == nil ? 0 : 1))

        return ([selected].compactMap { $0 } + matches).map(option)
    }

    mutating func toggle(_ id: String) {
        if selectedId == id {
            selectedId = nil
        } else {
            select(id)
        }
    }

    mutating func select(_ id: String) {
        selectedId = id
        searchText = ""
    }

    private var isSearchTextEmpty: Bool {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func option(for client: Client) -> BookClientOption {
        let item = ClientItem(client: client)

        return BookClientOption(
            id: item.id,
            title: item.title,
            subtitle: item.subtitle,
            initial: item.initial,
            isSelected: client.id == selectedId
        )
    }
}
