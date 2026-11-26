import FirebaseFirestore

final class FirestoreServiceRepository: ServiceRepository {
    private var db: Firestore { Firestore.firestore() }

    func observeServices() -> AsyncThrowingStream<[Service], Error> {
        .listening { try db.userCollection("services").addSnapshotListener($0) } read: { snapshot in
            snapshot.documents.compactMap { try? $0.data(as: Service.self) }
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
