import Foundation

struct PlanChoice {
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

        if let plan, plan.templateId == nil {
            own = OwnPlan(emoji: plan.emoji, name: plan.name)
        }
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

    var pick: PlanPick? {
        if let template = selectedTemplate, let id = template.id {
            PlanPick(templateId: id, emoji: template.emoji, name: template.name)
        } else if own.isFilled {
            PlanPick(templateId: nil, emoji: own.emoji, name: own.trimmedName)
        } else {
            nil
        }
    }

    var isEmpty: Bool {
        chips.isEmpty
    }

    mutating func select(_ id: String) {
        selectedId = id
        own.name = ""
    }

    private var selectedTemplate: EventTemplate? {
        offered.first { $0.id == selectedId }
    }

    private static func snapshot(of plan: PlanEvent, outside offered: [EventTemplate]) -> EventTemplate? {
        guard
            let id = plan.templateId,
            offered.contains(where: { $0.id == id }) == false
        else { return nil }

        return EventTemplate(
            id: id,
            emoji: plan.emoji,
            name: plan.name,
            isActive: false
        )
    }
}
