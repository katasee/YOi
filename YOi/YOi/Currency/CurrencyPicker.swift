import SwiftUI

struct CurrencyPicker: View {
    private enum Layout {
        static let wheelWidth: CGFloat = 110
        static let wheelHeight: CGFloat = 100
        static let font: CGFloat = 17
    }

    @State private var selection: Currency

    private let onSelect: (Currency) -> Void

    init(selected: Currency, onSelect: @escaping (Currency) -> Void) {
        _selection = State(initialValue: selected)
        self.onSelect = onSelect
    }

    var body: some View {
        Picker("profile.currency.title", selection: $selection) {
            ForEach(Currency.allCases) { currency in
                Text(verbatim: currency.rawValue)
                    .font(.elmsSans(.semiBold, Layout.font))
                    .tag(currency)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .frame(width: Layout.wheelWidth, height: Layout.wheelHeight)
        .clipped()
        .onChange(of: selection) {
            onSelect(selection)
        }
    }
}

#Preview {
    CurrencyPicker(selected: .uah, onSelect: { _ in })
        .padding()
        .background(Color.background)
}
