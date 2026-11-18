import FirebaseFirestore

struct EventTemplate: Identifiable, Codable, Named {
    @DocumentID var id: String?
    var emoji: String
    var name: String
}
