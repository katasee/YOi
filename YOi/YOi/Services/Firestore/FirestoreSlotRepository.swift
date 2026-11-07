import FirebaseFirestore

final class FirestoreSlotRepository: SlotRepository {
    private let db = Firestore.firestore()

    func observeSlots() -> AsyncThrowingStream<[Slot], Error> {
        .listening {
            try db.userCollection("slots")
                .whereField("date", isGreaterThanOrEqualTo: Slot.historyStart(now: .now))
                .addSnapshotListener($0)
        } read: { snapshot in
            snapshot.documents.compactMap { try? $0.data(as: Slot.self) }
        }
    }

    func fetchSlots(from: String, to: String) async throws -> [Slot] {
        let snapshot = try await db.userCollection("slots")
            .whereField("date", isGreaterThanOrEqualTo: from)
            .whereField("date", isLessThan: to)
            .getDocuments(source: .server)

        return snapshot.documents.compactMap { try? $0.data(as: Slot.self) }
    }

    func add(_ slots: [Slot]) throws {
        let collection = try db.userCollection("slots")
        let batch = db.batch()

        for slot in slots {
            batch.setData(
                ["date": slot.date, "time": slot.time],
                forDocument: collection.document(Slot.documentId(date: slot.date, time: slot.time)),
                merge: true
            )
        }

        batch.commit(completion: nil)
    }

    func book(slotId: String, _ booking: SlotBooking) throws {
        try db.userCollection("slots").document(slotId).setData(
            bookingFields(booking),
            merge: true,
            completion: nil
        )
    }

    func addBooked(
        date: String,
        time: String,
        _ booking: SlotBooking
    ) throws {
        try db.userCollection("slots").document(Slot.documentId(date: date, time: time)).setData(
            bookingFields(booking).merging(["date": date, "time": time]) { $1 },
            merge: true,
            completion: nil
        )
    }

    func clearBooking(slotId: String) throws {
        try db.userCollection("slots").document(slotId).setData(
            clearedBookingFields,
            merge: true,
            completion: nil
        )
    }

    func reschedule(
        slotId: String,
        _ booking: SlotBooking,
        toDate date: String,
        time: String
    ) throws {
        let collection = try db.userCollection("slots")
        let target = collection.document(Slot.documentId(date: date, time: time))
        let batch = db.batch()

        batch.setData(
            bookingFields(booking).merging(["date": date, "time": time]) { $1 },
            forDocument: target,
            merge: true
        )
        batch.setData(
            clearedBookingFields,
            forDocument: collection.document(slotId),
            merge: true
        )
        batch.commit(completion: nil)
    }

    func delete(id: String) throws {
        try db.userCollection("slots").document(id).delete(completion: nil)
    }

    private func bookingFields(_ booking: SlotBooking) -> [String: Any] {
        [
            "clientId": booking.clientId,
            "serviceId": booking.serviceId ?? FieldValue.delete(),
            "serviceName": booking.serviceName ?? FieldValue.delete(),
            "servicePrice": booking.servicePrice ?? FieldValue.delete()
        ]
    }

    private var clearedBookingFields: [String: Any] {
        [
            "clientId": FieldValue.delete(),
            "serviceId": FieldValue.delete(),
            "serviceName": FieldValue.delete(),
            "servicePrice": FieldValue.delete()
        ]
    }
}
