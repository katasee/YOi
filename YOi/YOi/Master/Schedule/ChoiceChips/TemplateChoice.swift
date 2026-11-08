import Foundation

struct TemplateChoice {
    private(set) var selectedId: String?
    var own = OwnPlan() {
        didSet {
            if own.isFilled {
                selectedId = nil
            }
        }
    }

    private let offered: [EventTemplate]
    private let pinned: EventTemplate?

    init(templates: [EventTemplate], pinning plan: PlanEvent? = nil) {
        let offered = templates.filter(\.isActive).sortedByName()

        self.offered = offered
        selectedId = plan?.templateId
        pinned = plan.flatMap { Self.snapshot(of: $0, outside: offered) }
    }

    var chips: [ChoiceChip] {
        ([pinned].compactMap { $0 } + offered).compactMap { template in
            template.id.map { id in
                ChoiceChip(
                    id: id,
                    title: "\(template.emoji) \(template.name)",
                    isSelected: id == selectedId
                )
            }
        }
    }

    var selectedTemplate: EventTemplate? {
        offered.first { $0.id == selectedId }
    }

    var isEmpty: Bool {
        chips.isEmpty
    }

    mutating func select(_ id: String) {
        selectedId = id
        own.name = ""
    }

    private static func snapshot(of plan: PlanEvent, outside offered: [EventTemplate]) -> EventTemplate? {
        guard offered.contains(where: { $0.id == plan.templateId }) == false else { return nil }

        return EventTemplate(
            id: plan.templateId,
            emoji: plan.emoji,
            name: plan.name,
            isActive: false
        )
    }
}
