import SwiftUI

struct ChoiceChipsEditor<Accessory: View>: View {
    let titleKey: LocalizedStringKey
    let chips: [ChoiceChip]
    let add: ChoiceChipsAdd?
    let canSave: Bool
    let onToggle: (String) -> Void
    let onBack: () -> Void
    let onSave: () -> Void
    let accessory: Accessory

    @State private var chipsHeight: CGFloat?

    init(
        titleKey: LocalizedStringKey,
        chips: [ChoiceChip],
        add: ChoiceChipsAdd? = nil,
        canSave: Bool,
        onToggle: @escaping (String) -> Void,
        onBack: @escaping () -> Void,
        onSave: @escaping () -> Void,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.titleKey = titleKey
        self.chips = chips
        self.add = add
        self.canSave = canSave
        self.onToggle = onToggle
        self.onBack = onBack
        self.onSave = onSave
        self.accessory = accessory()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            SectionLabel(titleKey: titleKey)

            ScrollView {
                ChoiceChips(chips: chips, onToggle: onToggle, add: add)
                    .padding(ScheduleMetrics.Spacing.scrollShadowInset)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        chipsHeight = height
                    }
            }
            .frame(maxHeight: chipsHeight)
            .opacity(chipsHeight == nil ? 0 : 1)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .padding(-ScheduleMetrics.Spacing.scrollShadowInset)

            accessory

            HStack {
                PopupDismissButton(titleKey: "common.action.back", action: onBack)

                Spacer()

                CapsuleButton(
                    titleKey: "schedule.actions.save",
                    role: .primary,
                    isEnabled: canSave,
                    action: onSave
                )
            }
        }
    }
}

extension ChoiceChipsEditor where Accessory == EmptyView {
    init(
        titleKey: LocalizedStringKey,
        chips: [ChoiceChip],
        add: ChoiceChipsAdd? = nil,
        canSave: Bool,
        onToggle: @escaping (String) -> Void,
        onBack: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) {
        self.init(
            titleKey: titleKey,
            chips: chips,
            add: add,
            canSave: canSave,
            onToggle: onToggle,
            onBack: onBack,
            onSave: onSave
        ) {
            EmptyView()
        }
    }
}

#if DEBUG
#Preview {
    ChoiceChipsEditor(
        titleKey: "schedule.book.service",
        chips: SchedulePreviewData.serviceChips,
        add: ChoiceChipsAdd(titleKey: "schedule.book.newService", action: {}),
        canSave: true,
        onToggle: { _ in },
        onBack: {},
        onSave: {}
    )
    .padding()
    .background(Color.card)
}
#endif
