import Foundation

extension Sequence where Element == Client {
    func defaultPhoneCountry(region: Locale.Region?) -> PhoneCountry {
        sortedNewestFirst().lazy.compactMap { PhoneCountry(stored: $0.phone) }.first ?? .regional(region)
    }
}
