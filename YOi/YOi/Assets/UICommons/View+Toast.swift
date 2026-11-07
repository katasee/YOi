import SwiftUI

struct ToastMessage: Equatable {
    enum Style {
        case success
        case failure

        var feedback: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: .success
            case .failure: .error
            }
        }
    }

    let text: String
    let style: Style
}

private struct ToastLabel: View {
    let message: ToastMessage

    private enum Layout {
        static let padding: CGFloat = 14
        static let cornerRadius: CGFloat = 20
        static let spacing: CGFloat = 10
        static let iconSize: CGFloat = 17
    }

    var body: some View {
        HStack(spacing: Layout.spacing) {
            Image(systemName: systemImage)
                .font(.elmsSans(.medium, Layout.iconSize))
                .foregroundStyle(iconColor)

            Text(verbatim: message.text)
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.ink)
        }
        .cardSurface(padding: Layout.padding, cornerRadius: Layout.cornerRadius)
    }

    private var systemImage: String {
        switch message.style {
        case .success: "checkmark.circle.fill"
        case .failure: "exclamationmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch message.style {
        case .success: .statusConfirmed
        case .failure: .destructive
        }
    }
}

struct ToastModifier: ViewModifier {
    @Binding var message: ToastMessage?

    private enum Layout {
        static let topPadding: CGFloat = 8
        static let duration: Duration = .seconds(2)
        static let animation = Animation.snappy
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack {
                    if let message {
                        ToastLabel(message: message)
                            .padding(.top, Layout.topPadding)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(Layout.animation, value: message)
                .allowsHitTesting(false)
            }
            .task(id: message) {
                guard message != nil, (try? await Task.sleep(for: Layout.duration)) != nil else { return }

                message = nil
            }
    }
}

extension View {
    func toast(_ message: Binding<ToastMessage?>) -> some View {
        modifier(ToastModifier(message: message))
    }
}

#Preview {
    @Previewable @State var message: ToastMessage? = ToastMessage(text: "Додано 12 вікон", style: .success)

    Button {
        message = ToastMessage(text: "Не вдалося додати вікна", style: .failure)
    } label: {
        Text(verbatim: "Показати помилку")
            .font(.elmsSans(.medium, 15))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
    .toast($message)
}
