import SwiftUI

struct ServiceRow<Handle: View>: View {
    let service: Service
    let onToggleActive: () -> Void
    @ViewBuilder let handle: Handle

    var body: some View {
        HStack(spacing: ServicesMetrics.Spacing.rowContentSpacing) {
            icon
            details

            Spacer(minLength: 0)

            price
            handle
        }
        .padding(.horizontal, ServicesMetrics.Spacing.rowHorizontalPadding)
        .padding(.vertical, ServicesMetrics.Spacing.rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: 0, cornerRadius: ServicesMetrics.Size.rowCornerRadius)
    }

    private var icon: some View {
        Button(action: onToggleActive) {
            if #available(iOS 26, *) {
                star
                    .glassEffect(.regular.interactive(), in: .circle)
            } else {
                star
                    .raisedSurface(.circle)
            }
        }
        .buttonStyle(.plain)
    }

    private var star: some View {
        Image(systemName: service.isOffered ? "star.fill" : "star")
            .font(.elmsSans(.regular, ServicesMetrics.Size.rowIconGlyph))
            .foregroundStyle(Color.ink)
            .frame(
                width: ServicesMetrics.Size.rowIcon,
                height: ServicesMetrics.Size.rowIcon
            )
            .contentShape(.circle)
    }

    private var details: some View {
        Text(service.name)
            .font(.elmsSans(.medium, 16))
            .foregroundStyle(Color.ink)
            .lineLimit(2)
    }

    private var price: some View {
        Text(ServiceFormat.price(service.price))
            .font(.elmsSans(.bold, 17))
            .foregroundStyle(Color.ink)
            .lineLimit(1)
            .layoutPriority(1)
    }
}

extension ServiceRow where Handle == EmptyView {
    init(service: Service, onToggleActive: @escaping () -> Void) {
        self.init(service: service, onToggleActive: onToggleActive) {}
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ServicesMetrics.Spacing.rowSpacing) {
        ForEach(ServicesPreviewData.services) { service in
            ServiceRow(service: service, onToggleActive: {})
        }
    }
    .padding()
    .background(Color.background)
}
#endif
