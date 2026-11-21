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

    init?(stored: String?) {
        guard let stored else { return nil }

        let match = Self.allCases.first { country in
            let national = stored.dropFirst(country.code.count)

            return stored.hasPrefix(country.code)
                && national.count == country.nationalLength
                && national.allSatisfy(\.isNumber)
        }

        guard let match else { return nil }

        self = match
    }

    static func regional(_ region: Locale.Region?) -> PhoneCountry {
        region == .ukraine ? .ukraine : .poland
    }
}
