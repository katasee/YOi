protocol EventTemplateRepository {
    func observeTemplates() -> AsyncThrowingStream<[EventTemplate], Error>
    func observeTemplate(id: String) -> AsyncThrowingStream<EventTemplate?, Error>
    func add(_ template: EventTemplate) throws
    func update(_ template: EventTemplate) throws
    func delete(id: String) throws
}
