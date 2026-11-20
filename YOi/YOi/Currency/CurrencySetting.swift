import Foundation
import Observation

@MainActor
@Observable
final class CurrencySetting {
    private(set) var currency: Currency

    init(currency: Currency) {
        self.currency = currency
    }

    func select(_ currency: Currency) {
        self.currency = currency
    }
}
