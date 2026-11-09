import Foundation

struct OwnPlan {
    var emoji = EventTemplate.defaultEmoji
    var name = ""

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isFilled: Bool {
        trimmedName.isEmpty == false
    }
}
