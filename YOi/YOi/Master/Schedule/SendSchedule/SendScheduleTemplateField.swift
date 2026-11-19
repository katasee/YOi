import SwiftUI

struct SendScheduleTemplateField: View {
    let titleKey: LocalizedStringKey
    @Binding var text: String
    let canReset: Bool
    let onReset: () -> Void

    var body: some View {
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

            TextField("", text: $text)
                .submitLabel(.done)
                .inputFieldStyle()
        }
    }
}

#Preview {
    @Previewable @State var text = "Вільні віконця:"

    SendScheduleTemplateField(
        titleKey: "schedule.send.template.header",
        text: $text,
        canReset: true,
        onReset: {}
    )
    .padding()
    .background(Color.card)
}
