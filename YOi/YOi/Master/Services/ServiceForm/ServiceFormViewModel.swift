import Foundation
import Observation

@MainActor
@Observable
final class ServiceFormViewModel: Identifiable {
    var name = ""
    var priceText = ""

    let mode: ServiceFormMode

    private(set) var errorMessage: String?
    private(set) var isSaving = false
    private(set) var savedService: Service?

    private let serviceRepository: ServiceRepository

    init(mode: ServiceFormMode, serviceRepository: ServiceRepository) {
        self.mode = mode
        self.serviceRepository = serviceRepository

        if case .edit(let service) = mode {
            name = service.name
            priceText = Self.formatPrice(service.price)
        }
    }

    var canSubmit: Bool {
        trimmedName.isEmpty == false && (Self.parsePrice(priceText) ?? 0) > 0
    }

    func submit() async -> Bool {
        guard isSaving == false else { return false }
        guard canSubmit, let price = Self.parsePrice(priceText) else { return false }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await save(price: price)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func save(price: Int) async throws {
        switch mode {
        case .add(let position):
            var service = Service(
                id: nil,
                name: trimmedName,
                price: price,
                isActive: true,
                position: position
            )
            service.id = try await serviceRepository.add(service)
            savedService = service

        case .edit(let service):
            try await serviceRepository.update(
                Service(
                    id: service.id,
                    name: trimmedName,
                    price: price,
                    isActive: service.isOffered,
                    position: service.position
                )
            )
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func parsePrice(_ text: String) -> Int? {
        Int(text)
    }

    private static func formatPrice(_ price: Int) -> String {
        String(price)
    }
}
