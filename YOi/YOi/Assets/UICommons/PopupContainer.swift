import SwiftUI

enum PopupContainerLayout {
    static let cornerRadius: CGFloat = 28
    static let cardPadding: CGFloat = 22
    static let rowSpacing: CGFloat = 16
    static let horizontalInset: CGFloat = 16
    static let shadowOpacity: Double = 0.25
    static let shadowRadius: CGFloat = 30
    static let shadowY: CGFloat = 24
    static let fade = Animation.easeOut(duration: 0.2)
}

struct PopupContainer<Content: View>: View {
    var blursBackground = false
    let onDismiss: () -> Void
    @ViewBuilder let content: (_ dismiss: @escaping () -> Void) -> Content

    @State private var isVisible = false

    var body: some View {
        ZStack {
            backdrop
            card
        }
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(PopupContainerLayout.fade) {
                isVisible = true
            }
        }
    }

    private var backdrop: some View {
        Rectangle()
            .fill(Color.backdrop)
            .background {
                if blursBackground {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
            }
            .ignoresSafeArea()
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            content(fadeOutAndDismiss)
        }
        .padding(PopupContainerLayout.cardPadding)
        .background {
            RoundedRectangle(cornerRadius: PopupContainerLayout.cornerRadius)
                .fill(Color.card)
                .shadow(
                    color: Color.shadow.opacity(PopupContainerLayout.shadowOpacity),
                    radius: PopupContainerLayout.shadowRadius,
                    x: 0,
                    y: PopupContainerLayout.shadowY
                )
        }
        .padding(.horizontal, PopupContainerLayout.horizontalInset)
    }

    private func fadeOutAndDismiss() {
        withAnimation(PopupContainerLayout.fade) {
            isVisible = false
        } completion: {
            onDismiss()
        }
    }
}
