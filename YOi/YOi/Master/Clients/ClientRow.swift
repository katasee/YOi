import SwiftUI

struct ClientRoute: Hashable {
    let id: String
}

struct ClientRow: View {
    let item: ClientItem

    var body: some View {
        HStack(spacing: ClientsMetrics.Spacing.rowContentSpacing) {
            NavigationLink(value: ClientRoute(id: item.id)) {
                HStack(spacing: ClientsMetrics.Spacing.rowContentSpacing) {
                    ClientAvatar(initial: item.initial, size: ClientsMetrics.Size.rowAvatar)

                    VStack(alignment: .leading, spacing: ClientsMetrics.Spacing.rowTextSpacing) {
                        Text(verbatim: item.title)
                            .font(.elmsSans(.semiBold, ClientsMetrics.Size.rowName))
                            .foregroundStyle(Color.ink)
                            .lineLimit(1)

                        if let subtitle = item.subtitle {
                            Text(verbatim: subtitle)
                                .font(.elmsSans(.regular, ClientsMetrics.Size.rowSubtitle))
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)

            if item.contacts.isEmpty == false {
                ClientContactMenu(contacts: item.contacts) {
                    RoundIconLabel(systemImage: "bubble.left")
                }
                .accessibilityLabel(Text("clients.contact.action"))
            }
        }
        .padding(.horizontal, ClientsMetrics.Spacing.rowHorizontalPadding)
        .padding(.vertical, ClientsMetrics.Spacing.rowVerticalPadding)
        .cardSurface(padding: 0, cornerRadius: ClientsMetrics.Size.rowCornerRadius)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        VStack(spacing: ClientsMetrics.Spacing.rowSpacing) {
            ForEach(ClientsPreviewData.clients.map(ClientItem.init)) { item in
                ClientRow(item: item)
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color.background)
    }
}
#endif
