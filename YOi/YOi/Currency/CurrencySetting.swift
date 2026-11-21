import Foundation
import Observation

@MainActor
@Observable
final class CurrencySetting {
    private(set) var currency: Currency
    private let repository: CurrencyRepository

    init(currency: Currency, repository: CurrencyRepository = FirestoreCurrencyRepository()) {
        self.currency = currency
        self.repository = repository
    }

    func select(_ currency: Currency) {
        guard currency != self.currency else { return }

        self.currency = currency
        try? repository.save(currency)
    }
}
