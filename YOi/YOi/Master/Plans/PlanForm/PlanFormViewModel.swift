import Foundation
import Observation

@MainActor
@Observable
final class PlanFormViewModel {
    var name = ""
    var emoji = EventTemplate.defaultEmoji

    let mode: PlanFormMode

    init(mode: PlanFormMode) {
        self.mode = mode

        if case .edit(let template) = mode {
            name = template.name
            emoji = template.emoji
        }
    }

    var canSubmit: Bool {
        trimmedName.isEmpty == false
    }

    func makeTemplate() -> EventTemplate? {
        guard canSubmit else { return nil }

        switch mode {
        case .add:
            return EventTemplate(
                id: nil,
                emoji: emoji,
                name: trimmedName
            )

        case .edit(let template):
            return EventTemplate(
                id: template.id,
                emoji: emoji,
                name: trimmedName
            )
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
