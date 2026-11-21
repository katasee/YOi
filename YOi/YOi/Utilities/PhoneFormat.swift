import Foundation

enum PhoneFormat {
    static func national(from text: String, country: PhoneCountry) -> String {
        var digits = text.filter(\.isNumber)
        let countryDigits = String(country.code.dropFirst())

        if digits.count == country.nationalLength + countryDigits.count, digits.hasPrefix(countryDigits) {
            digits.removeFirst(countryDigits.count)
        } else if
            let trunk = country.trunkPrefix,
            digits.count == country.nationalLength + trunk.count,
            digits.hasPrefix(trunk)
        {
            digits.removeFirst(trunk.count)
        }

        return String(digits.prefix(country.nationalLength))
    }

    static func isComplete(_ national: String, country: PhoneCountry) -> Bool {
        national.count == country.nationalLength
    }

    static func stored(national: String, country: PhoneCountry) -> String? {
        guard isComplete(national, country: country) else { return nil }

        return country.code + national
    }

    static func grouped(_ national: String, country: PhoneCountry) -> String {
        var rest = Substring(national)

        let groups = country.groupSizes.compactMap { size -> String? in
            let group = rest.prefix(size)
            rest = rest.dropFirst(size)

            return group.isEmpty ? nil : String(group)
        }

        return groups.joined(separator: " ")
    }

    static func parsed(_ stored: String?) -> (country: PhoneCountry, national: String)? {
        guard let stored else { return nil }

        for country in PhoneCountry.allCases where stored.hasPrefix(country.code) {
            let national = String(stored.dropFirst(country.code.count))

            if isComplete(national, country: country), national.allSatisfy(\.isNumber) {
                return (country, national)
            }
        }

        return nil
    }

    static func display(_ stored: String?) -> String? {
        guard let phone = parsed(stored) else { return stored }

        return phone.country.code + " " + grouped(phone.national, country: phone.country)
    }
}
