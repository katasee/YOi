import FirebaseFirestore

final class FirestoreClientRepository: ClientRepository {
    private var db: Firestore { Firestore.firestore() }

    func observeClients() -> AsyncThrowingStream<[Client], Error> {
        .listening { try db.userCollection("clients").addSnapshotListener($0) } read: { snapshot in
            snapshot.documents.compactMap { try? $0.data(as: Client.self) }
        }
    }

    func observeClient(id: String) -> AsyncThrowingStream<Client?, Error> {
        .listening { try db.userCollection("clients").document(id).addSnapshotListener($0) } read: { snapshot in
            try? snapshot.data(as: Client.self)
        }
    }

    func add(_ client: Client) throws -> String {
        let encoded = try Firestore.Encoder().encode(client)

        return try db.userCollection("clients").addDocument(data: encoded, completion: nil).documentID
    }

    func update(_ client: Client) throws {
        guard let id = client.id else {
            throw NSError(
                domain: "ClientRepository",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Cannot update a client without an id"]
            )
        }
        let encoded = try Firestore.Encoder().encode(client)
        try db.userCollection("clients").document(id).setData(encoded, completion: nil)
    }

    func delete(id: String) throws {
        try db.userCollection("clients").document(id).delete(completion: nil)
    }
}
