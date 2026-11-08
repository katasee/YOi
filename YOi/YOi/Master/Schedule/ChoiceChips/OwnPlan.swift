import Foundation

struct OwnPlan: Equatable {
    var emoji = EventTemplate.defaultEmoji
    var name = ""

    var isFilled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}
