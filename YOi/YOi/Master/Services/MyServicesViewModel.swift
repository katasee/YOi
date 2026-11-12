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

    private let serviceRepository: ServiceRepository

    init(serviceRepository: ServiceRepository = FirestoreServiceRepository()) {
        self.serviceRepository = serviceRepository
    }

    func observeServices() async {
        for await updatedServices in serviceRepository.observeServices() {
            services = updatedServices.sortedByOrder()
            hasLoaded = true
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
