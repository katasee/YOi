import Foundation
import Observation

@MainActor
@Observable
final class CurrencySetting {
    private(set) var currency: Currency
    private let repository: CurrencyRepository
    private let toastCenter: ToastCenter

    init(
        currency: Currency,
        toastCenter: ToastCenter,
        repository: CurrencyRepository = FirestoreCurrencyRepository()
    ) {
        self.currency = currency
        self.toastCenter = toastCenter
        self.repository = repository
    }

    func select(_ currency: Currency) {
        guard currency != self.currency else { return }

        self.currency = currency
        do {
            try repository.save(currency)
        } catch {
            toastCenter.reportSaveFailure()
        }
    }
}
