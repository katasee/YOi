import FirebaseFirestore

final class FirestoreServiceRepository: ServiceRepository {
    private let db = Firestore.firestore()

    func observeServices() -> AsyncStream<[Service]> {
        AsyncStream { continuation in
            guard let services = try? db.userCollection("services") else {
                continuation.finish()
                return
            }

            let listener = services.addSnapshotListener { snapshot, _ in
                let services = snapshot?.documents.compactMap { try? $0.data(as: Service.self) } ?? []
                continuation.yield(services)
            }
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    func add(_ service: Service) throws -> String {
        let encoded = try Firestore.Encoder().encode(service)

        return try db.userCollection("services").addDocument(data: encoded, completion: nil).documentID
    }

    func update(_ service: Service) async throws {
        guard let id = service.id else {
            throw NSError(
                domain: "ServiceRepository",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Cannot update a service without an id"]
            )
        }
        let encoded = try Firestore.Encoder().encode(service)
        try await db.userCollection("services").document(id).setData(encoded)
    }

    func delete(id: String) async throws {
        try await db.userCollection("services").document(id).delete()
    }

    func reorder(ids: [String]) throws {
        let services = try db.userCollection("services")
        let batch = db.batch()

        for (index, id) in ids.enumerated() {
            batch.updateData(["position": index], forDocument: services.document(id))
        }

        batch.commit(completion: nil)
    }
}
