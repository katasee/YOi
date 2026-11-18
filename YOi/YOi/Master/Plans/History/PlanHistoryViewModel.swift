import Foundation
import Observation

@MainActor
@Observable
final class PlanHistoryViewModel {
    private(set) var template: EventTemplate
    private(set) var events: [PlanEvent]

    init(template: EventTemplate) {
        self.template = template
        events = Self.inMemoryEvents(for: template, now: .now)
    }

    func history(now: Date) -> PlanHistory {
        PlanHistory(events: events, now: now)
    }

    func apply(_ edited: EventTemplate) {
        template = edited
    }

    private static func inMemoryEvents(for template: EventTemplate, now: Date) -> [PlanEvent] {
        let calendar = DateFormat.salonCalendar
        let today = calendar.startOfDay(for: now)
        let templateId = template.id ?? ""

        return [2, 9, -5, -12, -19].compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { return nil }

            return PlanEvent(
                id: "\(templateId)-\(offset)",
                date: DateFormat.date.string(from: day),
                startTime: "18:00",
                endTime: "19:30",
                templateId: templateId,
                emoji: template.emoji,
                name: template.name
            )
        }
    }
}
