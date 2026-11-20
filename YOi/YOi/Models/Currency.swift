import Foundation

enum Currency: String, CaseIterable, Identifiable {
    case pln = "PLN"
    case uah = "UAH"
    case usd = "USD"
    case eur = "EUR"

    var id: String { rawValue }
}
