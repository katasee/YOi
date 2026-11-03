import Foundation

struct ClientItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let initial: String
    let contacts: [ClientContact]

    init(client: Client) {
        id = client.id ?? client.createdAt.formatted(.iso8601)
        title = client.displayName
        subtitle = Self.makeSubtitle(for: client)
        initial = Self.makeInitial(from: client.displayName)
        contacts = client.contacts
    }

    private static func makeSubtitle(for client: Client) -> String? {
        let phone = client.phone.flatMap { $0.isEmpty ? nil : PhoneFormat.display($0) }

        guard
            client.name?.isEmpty == false,
            let instagram = client.instagram,
            instagram.isEmpty == false
        else { return phone }

        return "@" + instagram
    }

    private static func makeInitial(from title: String) -> String {
        let letter = title.first { $0.isLetter || $0.isNumber }

        return letter.map { String($0).uppercased() } ?? "?"
    }
}
