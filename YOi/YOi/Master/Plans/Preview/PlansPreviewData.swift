#if DEBUG
enum PlansPreviewData {
    static let templates: [EventTemplate] = [
        EventTemplate(id: "plan-boxing", emoji: "🥊", name: "Бокс"),
        EventTemplate(id: "plan-gym", emoji: "🏋️", name: "Зал"),
        EventTemplate(id: "plan-dentist", emoji: "🦷", name: "Стоматолог"),
        EventTemplate(id: "plan-hairdresser", emoji: "💇‍♀️", name: "Перукар"),
        EventTemplate(id: "plan-course", emoji: "🎓", name: "Курс з дизайну нігтів")
    ]

    static let events: [PlanEvent] = [
        PlanEvent(id: "boxing-1", date: "2026-11-19", startTime: "18:00", endTime: "19:30", templateId: "plan-boxing", emoji: "🥊", name: "Бокс"),
        PlanEvent(id: "boxing-2", date: "2026-11-26", startTime: "18:00", endTime: "19:30", templateId: "plan-boxing", emoji: "🥊", name: "Бокс"),
        PlanEvent(id: "boxing-3", date: "2026-12-03", startTime: "09:00", endTime: "10:00", templateId: "plan-boxing", emoji: "🥊", name: "Бокс")
    ]
}
#endif
