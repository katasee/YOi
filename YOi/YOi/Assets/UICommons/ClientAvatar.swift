import SwiftUI

struct ClientAvatar: View {
    let initial: String
    let size: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    private enum Layout {
        static let glyphRatio: CGFloat = 0.36
    }

    var body: some View {
        if #available(iOS 26, *) {
            letter
                .glassEffect(.regular.tint(Color.wineSoft), in: .circle)
                .id(colorScheme)
        } else {
            letter
                .background(Color.wineSoft, in: .circle)
        }
    }

    private var letter: some View {
        Text(verbatim: initial)
            .font(.elmsSans(.semiBold, size * Layout.glyphRatio))
            .foregroundStyle(Color.wine)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 16) {
        ClientAvatar(initial: "О", size: 44)
        ClientAvatar(initial: "S", size: 84)
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.background)
}
