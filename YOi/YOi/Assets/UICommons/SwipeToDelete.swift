import SwiftUI

private enum SwipeToDeleteLayout {
    static let actionWidth: CGFloat = 72
    static let iconSize: CGFloat = 22
    static let openThreshold: CGFloat = 36
    static let shadowAllowance: CGFloat = 24
    static let snap = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let reducedMotionSnap = Animation.easeOut(duration: 0.15)
}

private struct HorizontalPan: UIGestureRecognizerRepresentable {
    let onChanged: (CGFloat) -> Void
    let onEnded: (CGFloat) -> Void

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = context.coordinator
        return recognizer
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        let width = context.converter.localTranslation?.x ?? 0

        switch recognizer.state {
        case .changed:
            onChanged(width)
        case .ended, .cancelled:
            onEnded(width)
        default:
            break
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }

            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y)
        }
    }
}

struct SwipeToDelete<Content: View>: View {
    let id: String
    @Binding var openId: String?
    let cornerRadius: CGFloat
    let onDelete: () -> Void
    @ViewBuilder let content: Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var offsetX: CGFloat = 0

    var body: some View {
        ZStack(alignment: .trailing) {
            deleteAction
            content
                .offset(x: offsetX)
                .gesture(HorizontalPan(onChanged: drag, onEnded: release))
        }
        .background(
            Color.destructiveFill.opacity(isRevealed ? 1 : 0),
            in: .rect(cornerRadius: cornerRadius)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: cornerRadius)
                .inset(by: isRevealed ? 0 : -SwipeToDeleteLayout.shadowAllowance)
        )
        .onChange(of: openId) {
            withAnimation(snap) {
                offsetX = restingOffset
            }
        }
    }

    private var deleteAction: some View {
        Button(action: delete) {
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(
                    width: SwipeToDeleteLayout.iconSize,
                    height: SwipeToDeleteLayout.iconSize
                )
                .foregroundStyle(Color.onPrimary)
                .frame(width: SwipeToDeleteLayout.actionWidth)
                .frame(maxHeight: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .opacity(isRevealed ? 1 : 0)
        .accessibilityHidden(isRevealed == false)
    }

    private func drag(_ width: CGFloat) {
        offsetX = clamped(restingOffset + width)
    }

    private func release(_ width: CGFloat) {
        let shouldOpen = clamped(restingOffset + width) < -SwipeToDeleteLayout.openThreshold

        withAnimation(snap) {
            offsetX = shouldOpen ? -SwipeToDeleteLayout.actionWidth : 0
        }

        openId = shouldOpen ? id : nil
    }

    private var isOpen: Bool {
        openId == id
    }

    private var isRevealed: Bool {
        offsetX < 0
    }

    private var restingOffset: CGFloat {
        isOpen ? -SwipeToDeleteLayout.actionWidth : 0
    }

    private var snap: Animation {
        reduceMotion ? SwipeToDeleteLayout.reducedMotionSnap : SwipeToDeleteLayout.snap
    }

    private func clamped(_ value: CGFloat) -> CGFloat {
        min(max(value, -SwipeToDeleteLayout.actionWidth), 0)
    }

    private func delete() {
        openId = nil
        onDelete()
    }
}

#Preview {
    @Previewable @State var openId: String?

    SwipeToDelete(id: "preview", openId: $openId, cornerRadius: 18, onDelete: {}) {
        Text("Swipe me")
            .frame(maxWidth: .infinity, minHeight: 80)
            .cardSurface(padding: 0, cornerRadius: 18)
    }
    .padding()
    .background(Color.background)
}
