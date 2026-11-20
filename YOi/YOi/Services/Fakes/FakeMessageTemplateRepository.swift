import Foundation

#if DEBUG
final class FakeMessageTemplateRepository: MessageTemplateRepository {
    private var template: MessageTemplate
    private(set) var saved: [MessageTemplate] = []

    init(template: MessageTemplate = MessageTemplate()) {
        self.template = template
    }

    func observe() -> AsyncThrowingStream<MessageTemplate, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(template)
        }
    }

    func save(_ template: MessageTemplate) throws {
        self.template = template
        saved.append(template)
    }
}
#endif
