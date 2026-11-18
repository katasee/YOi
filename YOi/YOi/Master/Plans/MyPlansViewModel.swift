import Foundation
import Observation

@MainActor
@Observable
final class MyPlansViewModel {
    private(set) var templates: [EventTemplate] = []
    private(set) var hasLoaded = false
    private(set) var hasFailed = false
    private(set) var failure: PlansFailure?

    var hasFailure: Bool {
        get { failure != nil }
        set { if newValue == false { failure = nil } }
    }

    private let templateRepository: EventTemplateRepository
    private let eventRepository: EventRepository

    init(
        templateRepository: EventTemplateRepository = FirestoreEventTemplateRepository(),
        eventRepository: EventRepository = FirestoreEventRepository()
    ) {
        self.templateRepository = templateRepository
        self.eventRepository = eventRepository
    }

    func observeTemplates() async {
        hasFailed = false

        do {
            for try await updatedTemplates in templateRepository.observeTemplates() {
                templates = updatedTemplates.sortedByName()
                hasLoaded = true
            }
        } catch {
            hasFailed = true
            hasLoaded = true
        }
    }

    func makeHistoryViewModel(templateId: String) -> PlanHistoryViewModel {
        PlanHistoryViewModel(
            templateId: templateId,
            templateRepository: templateRepository,
            eventRepository: eventRepository
        )
    }

    func add(_ template: EventTemplate) {
        do {
            try templateRepository.add(template)
        } catch {
            failure = .save
        }
    }

    func delete(_ template: EventTemplate) {
        guard let id = template.id else { return }

        do {
            try templateRepository.delete(id: id)
        } catch {
            failure = .delete
        }
    }
}
