import FirebaseAuth
import FirebaseFirestore

final class FirestoreUserDataRepository: UserDataRepository {
    static let collections = ["services", "clients", "slots", "eventTemplates", "events", "monthlyStats", "settings"]

    private static let batchLimit = 500

    private var db: Firestore { Firestore.firestore() }

    func deleteAllData() async throws {
        for name in Self.collections {
            try await deleteDocuments(in: db.userCollection(name))
        }

        guard let uid = Auth.auth().currentUser?.uid else { throw AccountError.profileNotFound }

        try await db.collection("users").document(uid).delete()
    }

    private func deleteDocuments(in collection: CollectionReference) async throws {
        while true {
            let snapshot = try await collection.limit(to: Self.batchLimit).getDocuments()

            guard snapshot.isEmpty == false else { return }

            let batch = db.batch()

            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }

            try await batch.commit()
        }
    }
}
