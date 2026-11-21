import Foundation
import Observation

@MainActor
@Observable
final class ClientFormViewModel: Identifiable {
    var fields = ClientFormFields()

    private(set) var isSaving = false
    private(set) var savedClient: Client?
    private var hasSubmitted = false
    private var hasSaveFailed = false

    private let original: Client?
    private let takenHandles: Set<String>
    private let clientRepository: ClientRepository

    init(
        takenHandles: Set<String>,
        phoneCountry: PhoneCountry,
        clientRepository: ClientRepository
    ) {
        original = nil
        fields = ClientFormFields(country: phoneCountry)
        self.takenHandles = takenHandles
        self.clientRepository = clientRepository
    }

    init(
        editing client: Client,
        takenHandles: Set<String>,
        clientRepository: ClientRepository
    ) {
        var otherHandles = takenHandles

        if let instagram = client.instagram {
            otherHandles.remove(Client.normalizedInstagram(instagram))
        }

        original = client
        fields = ClientFormFields(client: client, fallbackCountry: .regional(Locale.current.region))
        self.takenHandles = otherHandles
        self.clientRepository = clientRepository
    }

    var mode: ClientFormMode {
        original == nil ? .add : .edit
    }

    var errors: ClientFormErrors {
        ClientFormErrors(
            instagram: instagramError,
            phone: hasSubmitted ? phoneError : nil,
            save: hasSaveFailed ? .saveFailed : nil
        )
    }

    func applyMasks() {
        let instagram = Client.normalizedInstagram(fields.instagram)
        let phone = PhoneFormat.grouped(nationalPhone, country: fields.country)

        if fields.instagram != instagram {
            fields.instagram = instagram
        }

        if fields.phone != phone {
            fields.phone = phone
        }
    }

    func submit() async -> Bool {
        guard isSaving == false else { return false }

        hasSubmitted = true
        hasSaveFailed = false

        guard let client = makeClient() else { return false }

        isSaving = true
        defer { isSaving = false }

        do {
            if original == nil {
                var saved = client
                saved.id = try await clientRepository.add(client)
                savedClient = saved
            } else {
                try await clientRepository.update(client)
            }
            return true
        } catch {
            hasSaveFailed = true
            return false
        }
    }

    func delete() async -> Bool {
        guard isSaving == false, let id = original?.id else { return false }

        hasSaveFailed = false
        isSaving = true
        defer { isSaving = false }

        do {
            try await clientRepository.delete(id: id)
            return true
        } catch {
            hasSaveFailed = true
            return false
        }
    }

    private var handle: String? {
        Self.nonEmpty(Client.normalizedInstagram(fields.instagram))
    }

    private var name: String? {
        Self.nonEmpty(fields.name.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var nationalPhone: String {
        PhoneFormat.national(from: fields.phone, country: fields.country)
    }

    private var instagramError: ClientFormError? {
        if let handle, takenHandles.contains(handle) {
            .duplicateHandle
        } else if hasSubmitted, handle == nil, name == nil {
            .missingNameOrHandle
        } else {
            nil
        }
    }

    private var phoneError: ClientFormError? {
        nationalPhone.isEmpty || PhoneFormat.isComplete(nationalPhone, country: fields.country) ? nil : .incompletePhone
    }

    private func makeClient() -> Client? {
        guard instagramError == nil, phoneError == nil else { return nil }

        var client = original ?? Client(
            id: nil,
            name: nil,
            instagram: nil,
            phone: nil,
            createdAt: .now
        )
        client.name = name
        client.instagram = handle
        client.phone = PhoneFormat.stored(national: nationalPhone, country: fields.country)

        return client
    }

    private static func nonEmpty(_ text: String) -> String? {
        text.isEmpty ? nil : text
    }
}
