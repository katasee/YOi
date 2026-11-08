import FirebaseFirestore

struct PlanEvent: Identifiable, Codable {
    @DocumentID var id: String?
    var date: String
    var startTime: String
    var endTime: String
    var templateId: String?
    var emoji: String
    var name: String
}
