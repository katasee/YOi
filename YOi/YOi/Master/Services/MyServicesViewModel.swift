import Foundation
import Observation

@MainActor
@Observable
final class MyServicesViewModel {
    private(set) var services: [Service] = []
    private(set) var hasLoaded = false
    private(set) var failure: ServicesFailure?

    var hasFailure: Bool {
        get { failure != nil }
        set { if newValue == false { failure = nil } }
    }

    var nextPosition: Int {
        services.nextPosition
    }

    private var isReordering = false
    private var deferred: [Service]?

    private let serviceRepository: ServiceRepository

    init(serviceRepository: ServiceRepository = FirestoreServiceRepository()) {
        self.serviceRepository = serviceRepository
    }

    func observeServices() async {
        for await updatedServices in serviceRepository.observeServices() {
            let sorted = updatedServices.sortedByOrder()

            if isReordering {
                deferred = sorted
            } else {
                services = sorted
            }
            hasLoaded = true
        }
    }

    func beginReorder() {
        isReordering = true
    }

    func finishReorder(from source: Int, to target: Int) {
        defer {
            isReordering = false
            deferred = nil
        }

        guard source != target else {
            if let deferred {
                services = deferred
            }
            return
        }

        services = services.moving(services[source].id ?? "", to: services[target].id ?? "")

        do {
            try serviceRepository.reorder(ids: services.ids)
        } catch {
            failure = .update
        }
    }

    func toggleActive(_ service: Service) async {
        var updated = service
        updated.isActive = service.isOffered == false

        do {
            try await serviceRepository.update(updated)
        } catch {
            failure = .update
        }
    }

    func delete(_ service: Service) async {
        guard let id = service.id else { return }

        do {
            try await serviceRepository.delete(id: id)
        } catch {
            failure = .delete
        }
    }

    func makeFormViewModel(for mode: ServiceFormMode) -> ServiceFormViewModel {
        ServiceFormViewModel(mode: mode, serviceRepository: serviceRepository)
    }
}
