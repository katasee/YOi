#if DEBUG
enum PlansPreviewData {
    static let templates: [EventTemplate] = [
        EventTemplate(id: "plan-boxing", emoji: "🥊", name: "Бокс", isActive: true),
        EventTemplate(id: "plan-gym", emoji: "🏋️", name: "Зал", isActive: true),
        EventTemplate(id: "plan-dentist", emoji: "🦷", name: "Стоматолог", isActive: true),
        EventTemplate(id: "plan-hairdresser", emoji: "💇‍♀️", name: "Перукар", isActive: false),
        EventTemplate(id: "plan-course", emoji: "🎓", name: "Курс з дизайну нігтів", isActive: true)
    ]

    static let events: [PlanEvent] = [
        PlanEvent(id: "boxing-1", date: "2026-11-19", startTime: "18:00", endTime: "19:30", templateId: "plan-boxing", emoji: "🥊", name: "Бокс"),
        PlanEvent(id: "boxing-2", date: "2026-11-26", startTime: "18:00", endTime: "19:30", templateId: "plan-boxing", emoji: "🥊", name: "Бокс"),
        PlanEvent(id: "boxing-3", date: "2026-12-03", startTime: "09:00", endTime: "10:00", templateId: "plan-boxing", emoji: "🥊", name: "Бокс")
    ]
}
#endif
