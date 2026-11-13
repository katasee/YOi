import SwiftUI

enum CapsuleButtonRole {
    case primary
    case secondary
    case destructive
    case warning
}

struct CapsuleButton: View {
    let titleKey: LocalizedStringKey
    let role: CapsuleButtonRole
    var systemImage: String?
    var isIconOnly = false
    var isLoading = false
    var isEnabled = true
    var fillsWidth = false
    let action: () -> Void

    private enum Layout {
        static let minHeight: CGFloat = 50
        static let horizontalPadding: CGFloat = 22
        static let iconSpacing: CGFloat = 6
        static let title: CGFloat = 16
        static let icon: CGFloat = 14
        static let titleScale: CGFloat = 0.8
        static let disabledOpacity: Double = 0.4
        static let destructiveShadowOpacity: Double = 0.25
        static let destructiveShadowRadius: CGFloat = 8
        static let destructiveShadowY: CGFloat = 6
        static let warningOutline: CGFloat = 1.5
    }

    private var labelColor: Color {
        switch role {
        case .primary, .destructive: Color.onPrimary
        case .secondary: Color.ink
        case .warning: Color.warning
        }
    }

    private var isDisabled: Bool {
        isLoading || isEnabled == false
    }

    var body: some View {
        styledButton
            .accessibilityLabel(Text(titleKey))
            .foregroundStyle(labelColor)
            .disabled(isDisabled)
            .opacity(isDisabled ? Layout.disabledOpacity : 1)
    }

    @ViewBuilder
    private var styledButton: some View {
        if #available(iOS 26, *) {
            Button(action: action) {
                sizedLabel
                    .glassEffect(glass, in: .capsule)
                    .overlay { outline }
                    .contentShape(.capsule)
            }
            .buttonStyle(.plain)
        } else {
            Button(action: action) {
                sizedLabel
                    .background { background }
                    .contentShape(.capsule)
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private var sizedLabel: some View {
        label
            .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: Layout.minHeight)
            .padding(.horizontal, Layout.horizontalPadding)
    }

    @available(iOS 26, *)
    private var glass: Glass {
        switch role {
        case .primary:
            .primary.interactive()
        case .secondary, .warning:
            .regular.interactive()
        case .destructive:
            .destructive.interactive()
        }
    }

    @ViewBuilder
    private var label: some View {
        if isLoading {
            ProgressView()
                .tint(labelColor)
        } else {
            HStack(spacing: Layout.iconSpacing) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.elmsSans(.bold, isIconOnly ? Layout.title : Layout.icon))
                        .accessibilityHidden(true)
                }

                if isIconOnly == false {
                    Text(titleKey)
                        .font(.elmsSans(.semiBold, Layout.title))
                        .lineLimit(1)
                        .minimumScaleFactor(Layout.titleScale)
                }
            }
        }
    }

    @ViewBuilder
    private var background: some View {
        switch role {
        case .primary:
            Capsule()
                .fill(Color.primaryFill)
                .brandShadow(isDisabled == false)
        case .secondary:
            Color.clear
                .raisedSurface(.capsule)
        case .warning:
            Color.clear
                .raisedSurface(.capsule)
                .overlay { outline }
        case .destructive:
            Capsule()
                .fill(Color.destructiveFill)
                .shadow(
                    color: Color.destructiveFill.opacity(isDisabled ? 0 : Layout.destructiveShadowOpacity),
                    radius: Layout.destructiveShadowRadius,
                    x: 0,
                    y: Layout.destructiveShadowY
                )
        }
    }

    @ViewBuilder
    private var outline: some View {
        if role == .warning {
            Capsule()
                .strokeBorder(Color.warning, lineWidth: Layout.warningOutline)
        }
    }
}

private struct PressableButtonStyle: ButtonStyle {
    private enum Layout {
        static let pressedScale: CGFloat = 0.97
        static let pressedOpacity: Double = 0.75
        static let press = Animation.easeOut(duration: 0.12)
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? Layout.pressedScale : 1)
            .opacity(configuration.isPressed ? Layout.pressedOpacity : 1)
            .animation(Layout.press, value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 12) {
        CapsuleButton(titleKey: "common.action.done", role: .primary, action: {})

        CapsuleButton(
            titleKey: "common.action.done",
            role: .primary,
            isEnabled: false,
            action: {}
        )

        CapsuleButton(
            titleKey: "common.action.signOut",
            role: .destructive,
            isLoading: true,
            action: {}
        )

        CapsuleButton(titleKey: "schedule.replace.action", role: .warning, action: {})

        HStack(spacing: 10) {
            CapsuleButton(
                titleKey: "common.action.cancel",
                role: .secondary,
                fillsWidth: true,
                action: {}
            )

            CapsuleButton(
                titleKey: "common.action.ok",
                role: .primary,
                systemImage: "checkmark",
                fillsWidth: true,
                action: {}
            )
        }

        HStack(spacing: 10) {
            CapsuleButton(
                titleKey: "common.action.cancel",
                role: .secondary,
                isLoading: true,
                fillsWidth: true,
                action: {}
            )

            CapsuleButton(
                titleKey: "common.action.ok",
                role: .primary,
                isEnabled: false,
                fillsWidth: true,
                action: {}
            )
        }
    }
    .padding()
    .background(Color.background)
}
