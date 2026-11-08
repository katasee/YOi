struct PlanPick: Equatable {
    let templateId: String?
    let emoji: String
    let name: String

    func changes(_ plan: PlanEvent) -> Bool {
        guard templateId == nil, plan.templateId == nil else { return templateId != plan.templateId }

        return (emoji, name) != (plan.emoji, plan.name)
    }
}
