protocol MessageTemplateRepository {
    func observe() -> AsyncThrowingStream<MessageTemplate, Error>
    func save(_ template: MessageTemplate) throws
}
