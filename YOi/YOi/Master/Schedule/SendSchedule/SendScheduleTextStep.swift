import SwiftUI

struct SendScheduleTextStep: View {
    let monthTitle: String
    let canGoBack: Bool
    let text: String?
    @Binding var language: MessageLanguage
    let onCustomize: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onCopy: () -> Void
    let onSend: () -> Void

    @State private var copyCount = 0

    private var isCopied: Bool {
        copyCount > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            header

            SendScheduleMessageCard(text: text, height: ScheduleMetrics.Size.sendCardHeight)

            buttons
        }
        .task(id: copyCount) {
            await clearCopiedLater()
        }
        .onChange(of: text) {
            copyCount = 0
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            HStack(spacing: ScheduleMetrics.Spacing.sendTitleSpacing) {
                Text("schedule.send.title")
                    .font(.elmsSans(.bold, ScheduleMetrics.Size.fillTitle))
                    .foregroundStyle(Color.ink)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                SendScheduleLanguageMenu(language: $language)

                RoundIconButton(
                    systemImage: "slider.horizontal.3",
                    size: .small,
                    accessibilityLabel: "schedule.send.customize",
                    action: onCustomize
                )
            }

            MonthHeader(
                title: monthTitle,
                canGoBack: canGoBack,
                canGoForward: true,
                onPrevious: onPrevious,
                onNext: onNext
            )
        }
    }

    private var buttons: some View {
        HStack(spacing: ScheduleMetrics.Spacing.sendButtonSpacing) {
            CapsuleButton(
                titleKey: isCopied ? "schedule.send.copied" : "schedule.send.copy",
                role: .secondary,
                systemImage: isCopied ? "checkmark" : nil,
                isIconOnly: isCopied,
                isEnabled: text != nil,
                fillsWidth: true,
                action: copy
            )

            CapsuleButton(
                titleKey: "schedule.send.send",
                role: .primary,
                isEnabled: text != nil,
                fillsWidth: true,
                action: onSend
            )
        }
    }

    private func copy() {
        copyCount += 1
        onCopy()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    @MainActor
    private func clearCopiedLater() async {
        guard copyCount > 0 else { return }

        do {
            try await Task.sleep(for: .seconds(2))
            copyCount = 0
        } catch {}
    }
}

#if DEBUG
#Preview {
    SendScheduleTextStep(
        monthTitle: "Жовтень 2026",
        canGoBack: false,
        text: SchedulePreviewData.sendSchedule.text,
        language: .constant(.uk),
        onCustomize: {},
        onPrevious: {},
        onNext: {},
        onCopy: {},
        onSend: {}
    )
    .padding()
    .background(Color.card)
}
#endif
