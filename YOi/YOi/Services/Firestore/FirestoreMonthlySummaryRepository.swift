import FirebaseFirestore

final class FirestoreMonthlySummaryRepository: MonthlySummaryRepository {
    private let db = Firestore.firestore()

    func observeSummaries() -> AsyncThrowingStream<[MonthlySummary], Error> {
        .listening { try db.userCollection("monthlyStats").addSnapshotListener($0) } read: { snapshot in
            snapshot.documents.compactMap { try? $0.data(as: MonthlySummary.self) }
        }
    }

    func fetchSummaryIds() async throws -> Set<String> {
        let snapshot = try await db.userCollection("monthlyStats").getDocuments(source: .server)

        return Set(snapshot.documents.map(\.documentID))
    }

    func add(_ summaries: [MonthlySummary]) throws {
        let collection = try db.userCollection("monthlyStats")
        let batch = db.batch()

        for summary in summaries {
            guard let id = summary.id else { continue }

            batch.setData(
                try Firestore.Encoder().encode(summary),
                forDocument: collection.document(id)
            )
        }

        batch.commit(completion: nil)
    }

    func delete(ids: [String]) throws {
        let collection = try db.userCollection("monthlyStats")
        let batch = db.batch()

        for id in ids {
            batch.deleteDocument(collection.document(id))
        }

        batch.commit(completion: nil)
    }
}
