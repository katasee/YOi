import SwiftUI

struct PhoneCountryMenu: View {
    @Binding var country: PhoneCountry

    var body: some View {
        Menu {
            Picker(selection: $country) {
                ForEach(PhoneCountry.allCases) { country in
                    Text(verbatim: country.title)
                        .tag(country)
                }
            } label: {
                EmptyView()
            }
        } label: {
            HStack(spacing: ClientsMetrics.Spacing.countryMenuSpacing) {
                Text(verbatim: country.title)
                    .foregroundStyle(Color.ink)

                Image(systemName: "chevron.down")
                    .font(.elmsSans(.semiBold, ClientsMetrics.Size.countryChevron))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}

private extension PhoneCountry {
    var flag: String {
        switch self {
        case .poland: "🇵🇱"
        case .ukraine: "🇺🇦"
        }
    }

    var title: String {
        flag + " " + code
    }
}

#if DEBUG
#Preview {
    @Previewable @State var country = PhoneCountry.ukraine

    PhoneCountryMenu(country: $country)
        .inputFieldStyle()
        .padding()
        .background(Color.background)
}
#endif
