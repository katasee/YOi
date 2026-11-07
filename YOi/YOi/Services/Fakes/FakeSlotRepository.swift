import Foundation
import Synchronization

#if DEBUG
final class FakeSlotRepository: SlotRepository {
    private struct State {
        var slots: [Slot]
        var observers: [UUID: ([Slot]) -> Void] = [:]
    }

    private let state: Mutex<State>

    init(slots: [Slot] = []) {
        state = Mutex(State(slots: slots))
    }

    func observeSlots() -> AsyncThrowingStream<[Slot], Error> {
        let key = UUID()
        let (stream, continuation) = AsyncThrowingStream.makeStream(
            of: [Slot].self,
            bufferingPolicy: .bufferingNewest(1)
        )

        continuation.onTermination = { [weak self] _ in
            self?.state.withLock { $0.observers[key] = nil }
        }

        state.withLock { state in
            state.observers[key] = { continuation.yield($0) }
            continuation.yield(state.slots)
        }

        return stream
    }

    func fetchSlots(from: String, to: String) async throws -> [Slot] {
        state.withLock { state in
            state.slots.filter { $0.date >= from && $0.date < to }
        }
    }

    func add(_ slots: [Slot]) throws {
        change { stored in
            for slot in slots {
                let id = Slot.documentId(date: slot.date, time: slot.time)

                guard stored.contains(where: { $0.id == id }) == false else { continue }

                stored.append(Slot(id: id, date: slot.date, time: slot.time))
            }
        }
    }

    func book(slotId: String, _ booking: SlotBooking) throws {
        changeSlot(slotId) { Self.apply(booking, to: &$0) }
    }

    func addBooked(
        date: String,
        time: String,
        _ booking: SlotBooking
    ) throws {
        change { Self.book(booking, date: date, time: time, in: &$0) }
    }

    func clearBooking(slotId: String) throws {
        changeSlot(slotId) { Self.apply(nil, to: &$0) }
    }

    func reschedule(
        slotId: String,
        _ booking: SlotBooking,
        toDate date: String,
        time: String
    ) throws {
        change { stored in
            if let index = stored.firstIndex(where: { $0.id == slotId }) {
                Self.apply(nil, to: &stored[index])
            }

            Self.book(booking, date: date, time: time, in: &stored)
        }
    }

    func delete(id: String) throws {
        change { $0.removeAll { $0.id == id } }
    }

    private static func book(
        _ booking: SlotBooking,
        date: String,
        time: String,
        in stored: inout [Slot]
    ) {
        let id = Slot.documentId(date: date, time: time)

        if let index = stored.firstIndex(where: { $0.id == id }) {
            apply(booking, to: &stored[index])
        } else {
            var slot = Slot(id: id, date: date, time: time)
            apply(booking, to: &slot)
            stored.append(slot)
        }
    }

    private static func apply(_ booking: SlotBooking?, to slot: inout Slot) {
        slot.clientId = booking?.clientId
        slot.serviceId = booking?.serviceId
        slot.serviceName = booking?.serviceName
        slot.servicePrice = booking?.servicePrice
    }

    private func changeSlot(_ id: String, _ apply: (inout Slot) -> Void) {
        change { stored in
            guard let index = stored.firstIndex(where: { $0.id == id }) else { return }

            apply(&stored[index])
        }
    }

    private func change(_ apply: (inout [Slot]) -> Void) {
        state.withLock { state in
            apply(&state.slots)

            for observer in state.observers.values {
                observer(state.slots)
            }
        }
    }
}
#endif
