import Foundation

enum Currency: String, CaseIterable, Identifiable {
    case pln = "PLN"
    case uah = "UAH"
    case usd = "USD"
    case eur = "EUR"

    var id: String { rawValue }

    static func regional(_ region: Locale.Region?) -> Currency {
        region == .ukraine ? .uah : .pln
    }
}
