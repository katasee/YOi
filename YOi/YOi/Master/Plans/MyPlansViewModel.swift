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

    init(templateRepository: EventTemplateRepository = FirestoreEventTemplateRepository()) {
        self.templateRepository = templateRepository
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

    func save(_ template: EventTemplate) {
        do {
            if template.id == nil {
                try templateRepository.add(template)
            } else {
                try templateRepository.update(template)
            }
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
