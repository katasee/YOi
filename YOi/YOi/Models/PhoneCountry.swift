import Foundation

enum PhoneCountry: CaseIterable, Identifiable {
    case poland
    case ukraine

    var id: Self { self }

    var code: String {
        switch self {
        case .poland: "+48"
        case .ukraine: "+380"
        }
    }

    var nationalLength: Int { 9 }

    var groupSizes: [Int] {
        switch self {
        case .poland: [3, 3, 3]
        case .ukraine: [2, 3, 2, 2]
        }
    }

    var trunkPrefix: String? {
        switch self {
        case .poland: nil
        case .ukraine: "0"
        }
    }

    static func regional(_ region: Locale.Region?) -> PhoneCountry {
        region == .ukraine ? .ukraine : .poland
    }
}
