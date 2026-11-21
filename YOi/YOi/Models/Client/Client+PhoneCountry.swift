import Foundation

extension Sequence where Element == Client {
    func defaultPhoneCountry(region: Locale.Region?) -> PhoneCountry {
        let newest = sortedNewestFirst().lazy.compactMap { PhoneFormat.parsed($0.phone)?.country }.first

        return newest ?? .regional(region)
    }
}
