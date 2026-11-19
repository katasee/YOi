import Foundation

enum MessageDayStyle: String, CaseIterable, Identifiable {
    case dash
    case weekday
    case list
    case compact

    static let standard = MessageDayStyle.weekday

    var id: String {
        rawValue
    }
}
