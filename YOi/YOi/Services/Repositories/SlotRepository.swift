protocol SlotRepository {
    func observeSlots() -> AsyncThrowingStream<[Slot], Error>
    func fetchSlots(from: String, to: String) async throws -> [Slot]
    func add(_ slots: [Slot]) throws
    func book(slotId: String, _ booking: SlotBooking) throws
    func addBooked(
        date: String,
        time: String,
        _ booking: SlotBooking
    ) throws
    func clearBooking(slotId: String) throws
    func reschedule(
        slotId: String,
        _ booking: SlotBooking,
        toDate date: String,
        time: String
    ) throws
    func delete(id: String) throws
}
