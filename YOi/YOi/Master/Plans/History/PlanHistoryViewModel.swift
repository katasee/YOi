import Foundation
import Observation

@MainActor
@Observable
final class PlanHistoryViewModel {
    private(set) var template: EventTemplate?
    private(set) var isDeleted = false
    private(set) var hasFailed = false
    private(set) var failure: PlansFailure?
    private var events: [PlanEvent]?

    var hasFailure: Bool {
        get { failure != nil }
        set { if newValue == false { failure = nil } }
    }

    private let templateId: String
    private let templateRepository: EventTemplateRepository
    private let eventRepository: EventRepository

    init(
        templateId: String,
        templateRepository: EventTemplateRepository,
        eventRepository: EventRepository
    ) {
        self.templateId = templateId
        self.templateRepository = templateRepository
        self.eventRepository = eventRepository
    }

    func observeTemplate() async {
        hasFailed = false

        do {
            for try await updatedTemplate in templateRepository.observeTemplate(id: templateId) {
                if let updatedTemplate {
                    template = updatedTemplate
                } else if template != nil {
                    isDeleted = true
                }
            }
        } catch {
            hasFailed = true
        }
    }

    func observeEvents() async {
        do {
            for try await updatedEvents in eventRepository.observeEvents() {
                events = updatedEvents.filter { $0.templateId == templateId }
            }
        } catch {
            events = nil
        }
    }

    func history(now: Date) -> PlanHistory? {
        events.map { PlanHistory(events: $0, now: now) }
    }

    func save(_ template: EventTemplate) {
        do {
            try templateRepository.update(template)
        } catch {
            failure = .save
        }
    }
}
