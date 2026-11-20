import FirebaseFirestore

final class FirestoreMessageTemplateRepository: MessageTemplateRepository {
    private let db = Firestore.firestore()

    func observe() -> AsyncThrowingStream<MessageTemplate, Error> {
        .listening { try document().addSnapshotListener($0) } read: { snapshot in
            guard snapshot.exists else { return MessageTemplate() }

            return (try? snapshot.data(as: MessageTemplate.self)) ?? MessageTemplate()
        }
    }

    func save(_ template: MessageTemplate) throws {
        let encoded = try Firestore.Encoder().encode(template)

        try document().setData(encoded, completion: nil)
    }

    private func document() throws -> DocumentReference {
        try db.userCollection("settings").document("sendSchedule")
    }
}
