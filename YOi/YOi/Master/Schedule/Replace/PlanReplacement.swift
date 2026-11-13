import Foundation

struct PlanReplacement: ScheduleReplacement {
    let windowIds: [String]
    let entries: [ConflictEntry]

    init?(_ conflicts: [WindowConflict], directory: ClientDirectory) {
        var seen = Set<String>()
        let windows = conflicts
            .filter { $0.level == .overlap }
            .map(\.window)
            .filter { seen.insert(Self.id(of: $0)).inserted }

        guard windows.isEmpty == false else { return nil }

        windowIds = windows.map(Self.id(of:))
        entries = windows.map { window in
            ConflictEntry(id: Self.id(of: window), text: Self.text(of: window, directory: directory))
        }
    }

    var message: String {
        String(localized: "schedule.replace.windowsMessage")
    }

    private static func text(of window: Slot, directory: ClientDirectory) -> String {
        let details = window.clientId.map { clientId in
            [
                directory.name(for: clientId),
                ServiceFormat.summary(name: window.serviceName, price: window.servicePrice)
            ]
        } ?? [String(localized: "schedule.replace.freeWindow")]

        return ([DateFormat.displayTime(window.time)] + details)
            .filter { $0.isEmpty == false }
            .joined(separator: " · ")
    }

    private static func id(of window: Slot) -> String {
        window.id ?? Slot.documentId(date: window.date, time: window.time)
    }
}
