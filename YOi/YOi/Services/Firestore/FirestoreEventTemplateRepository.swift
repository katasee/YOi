import FirebaseFirestore

final class FirestoreEventTemplateRepository: EventTemplateRepository {
    private let db = Firestore.firestore()

    func observeTemplates() -> AsyncThrowingStream<[EventTemplate], Error> {
        .listening { try db.userCollection("eventTemplates").addSnapshotListener($0) } read: { snapshot in
            snapshot.documents.compactMap { try? $0.data(as: EventTemplate.self) }
        }
    }

    func observeTemplate(id: String) -> AsyncThrowingStream<EventTemplate?, Error> {
        .listening { try db.userCollection("eventTemplates").document(id).addSnapshotListener($0) } read: { snapshot in
            try? snapshot.data(as: EventTemplate.self)
        }
    }

    func add(_ template: EventTemplate) throws {
        let encoded = try Firestore.Encoder().encode(template)
        try db.userCollection("eventTemplates").addDocument(data: encoded, completion: nil)
    }

    func update(_ template: EventTemplate) throws {
        guard let id = template.id else {
            throw NSError(
                domain: "EventTemplateRepository",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Cannot update a template without an id"]
            )
        }
        let encoded = try Firestore.Encoder().encode(template)
        try db.userCollection("eventTemplates").document(id).updateData(encoded, completion: nil)
    }

    func delete(id: String) throws {
        try db.userCollection("eventTemplates").document(id).delete(completion: nil)
    }
}
