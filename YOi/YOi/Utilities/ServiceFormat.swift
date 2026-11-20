import Foundation

enum ServiceFormat {
    static func price(_ value: Int, currency: Currency) -> String {
        value.formatted(
            .currency(code: currency.rawValue)
            .precision(.fractionLength(0))
        )
    }

    static func summary(
        name: String?,
        price: Int?,
        currency: Currency
    ) -> String {
        if let name, let price {
            "\(name) · \(self.price(price, currency: currency))"
        } else {
            String(localized: "service.none")
        }
    }
}
