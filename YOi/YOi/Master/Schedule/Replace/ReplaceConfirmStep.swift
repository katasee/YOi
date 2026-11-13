import SwiftUI

struct ReplaceConfirmStep: View {
    let message: String
    let entries: [ConflictEntry]
    let onBack: () -> Void
    let onConfirm: () -> Void

    private let mark = ConflictMark(.overlap)

    init(
        message: String,
        entries: [ConflictEntry],
        onBack: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) {
        self.message = message
        self.entries = entries
        self.onBack = onBack
        self.onConfirm = onConfirm
    }

    init(
        replacement: some ScheduleReplacement,
        onBack: @escaping () -> Void,
        onConfirm: @escaping () -> Void
    ) {
        self.init(
            message: replacement.message,
            entries: replacement.entries,
            onBack: onBack,
            onConfirm: onConfirm
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            SchedulePopupHeader(
                title: String(localized: "schedule.replace.title"),
                subtitle: message
            )

            ConflictEntryList(entries: entries, mark: mark)
                .padding(ScheduleMetrics.Spacing.conflictPadding)
                .background(mark.softColor, in: .rect(cornerRadius: ScheduleMetrics.Size.conflictCornerRadius))

            HStack {
                PopupDismissButton(titleKey: "common.action.back", action: onBack)

                Spacer()

                CapsuleButton(
                    titleKey: "schedule.replace.action",
                    role: .destructive,
                    action: onConfirm
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    ReplaceConfirmStep(
        message: String(localized: "schedule.replace.windowsMessage"),
        entries: SchedulePreviewData.replacedWindows,
        onBack: {},
        onConfirm: {}
    )
    .padding()
    .background(Color.card)
}
#endif
