import SwiftUI

enum ServiceFormMode: Identifiable {
    case add(position: Int)
    case edit(Service)

    var id: String {
        switch self {
        case .add: "add"
        case .edit(let service): service.id ?? "edit"
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .add: "services.add.title"
        case .edit: "services.edit.title"
        }
    }

    var submitKey: LocalizedStringKey {
        switch self {
        case .add: "services.add.submit"
        case .edit: "services.edit.submit"
        }
    }
}
