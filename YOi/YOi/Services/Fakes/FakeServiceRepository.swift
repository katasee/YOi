import Foundation

#if DEBUG
final class FakeServiceRepository: ServiceRepository {
    private var services: [Service]
    private var continuations: [UUID: AsyncStream<[Service]>.Continuation] = [:]

    init(services: [Service] = []) {
        self.services = services
    }

    func observeServices() -> AsyncStream<[Service]> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation
            continuation.yield(services)
        }
    }

    func add(_ service: Service) async throws -> String {
        let id = service.id ?? UUID().uuidString
        var stored = service
        stored.id = id
        services.append(stored)
        broadcast()

        return id
    }

    func update(_ service: Service) async throws {
        guard
            let id = service.id,
            let index = services.firstIndex(where: { $0.id == id })
        else { return }

        services[index] = service
        broadcast()
    }

    func delete(id: String) async throws {
        services.removeAll { $0.id == id }
        broadcast()
    }

    private func broadcast() {
        for continuation in continuations.values {
            continuation.yield(services)
        }
    }
}
#endif
