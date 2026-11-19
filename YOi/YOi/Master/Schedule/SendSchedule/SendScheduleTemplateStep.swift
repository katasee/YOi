import SwiftUI

private extension MessageDayStyle {
    var titleKey: LocalizedStringKey {
        switch self {
        case .dash: "schedule.send.format.dash"
        case .weekday: "schedule.send.format.weekday"
        case .list: "schedule.send.format.list"
        case .compact: "schedule.send.format.compact"
        }
    }
}

struct SendScheduleTemplateStep: View {
    @Bindable var viewModel: SendScheduleViewModel
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PopupContainerLayout.rowSpacing) {
            header

            textField(
                titleKey: "schedule.send.template.header",
                text: $viewModel.headerText,
                canReset: viewModel.hasCustomHeader,
                onReset: viewModel.resetHeader
            )

            textField(
                titleKey: "schedule.send.template.footer",
                text: $viewModel.footerText,
                canReset: viewModel.hasCustomFooter,
                onReset: viewModel.resetFooter
            )

            SendScheduleMessageCard(text: viewModel.text, height: ScheduleMetrics.Size.templatePreviewHeight)

            format

            CapsuleButton(
                titleKey: "common.action.done",
                role: .primary,
                fillsWidth: true,
                action: onDone
            )
        }
    }

    private var header: some View {
        HStack(spacing: ScheduleMetrics.Spacing.sendTitleSpacing) {
            Text("schedule.send.template.title")
                .font(.elmsSans(.bold, ScheduleMetrics.Size.fillTitle))
                .foregroundStyle(Color.ink)

            Spacer()

            SendScheduleLanguageMenu(language: $viewModel.language)
        }
    }

    private func textField(
        titleKey: LocalizedStringKey,
        text: Binding<String>,
        canReset: Bool,
        onReset: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.templateLabelSpacing) {
            HStack {
                SectionLabel(titleKey: titleKey)

                Spacer()

                Button("schedule.send.template.reset", action: onReset)
                    .font(.elmsSans(.semiBold, ScheduleMetrics.Size.templateReset))
                    .foregroundStyle(Color.accentColor)
                    .opacity(canReset ? 1 : ScheduleMetrics.Size.templateResetDisabledOpacity)
                    .disabled(canReset == false)
            }

            TextField("", text: text)
                .submitLabel(.done)
                .inputFieldStyle()
        }
    }

    private var format: some View {
        VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.templateLabelSpacing) {
            VStack(spacing: ScheduleMetrics.Spacing.templateTickSpacing) {
                Slider(
                    value: $viewModel.styleIndex,
                    in: 0...Double(MessageDayStyle.allCases.count - 1),
                    step: 1
                )

                ticks
            }
            .padding(.horizontal, ScheduleMetrics.Spacing.templateSliderPadding)
            .padding(.vertical, ScheduleMetrics.Spacing.templateSliderVerticalPadding)
            .raisedSurface(.rect(cornerRadius: ScheduleMetrics.Size.templateSliderCornerRadius))

            Text("schedule.send.format \(Text(viewModel.dayStyle.titleKey))")
                .font(.elmsSans(.regular, ScheduleMetrics.Size.templateCaption))
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var ticks: some View {
        HStack {
            ForEach(MessageDayStyle.allCases) { style in
                Circle()
                    .fill(Color.textSecondary)
                    .frame(width: ScheduleMetrics.Size.templateTick, height: ScheduleMetrics.Size.templateTick)

                if style != MessageDayStyle.allCases.last {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, tickInset)
    }

    private var tickInset: CGFloat {
        if #available(iOS 26, *) {
            ScheduleMetrics.Spacing.templateTickInset
        } else {
            ScheduleMetrics.Spacing.templateTickInsetLegacy
        }
    }
}

#if DEBUG
#Preview {
    SendScheduleTemplateStep(viewModel: SchedulePreviewData.sendSchedule, onDone: {})
        .padding()
        .background(Color.card)
}
#endif
