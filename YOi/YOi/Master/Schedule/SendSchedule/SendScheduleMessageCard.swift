import SwiftUI

struct SendScheduleMessageCard: View {
    let text: String?
    let height: CGFloat

    var body: some View {
        if let text {
            ScrollView {
                Text(verbatim: text)
                    .font(.elmsSans(.regular, ScheduleMetrics.Size.sendText))
                    .foregroundStyle(Color.ink)
                    .lineSpacing(ScheduleMetrics.Spacing.sendLineSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(ScheduleMetrics.Spacing.sendCardPadding)
            }
            .frame(height: height)
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .cardSurface(padding: 0, cornerRadius: ScheduleMetrics.Size.sendCardCornerRadius)
        } else {
            Text("schedule.send.empty")
                .font(.elmsSans(.regular, ScheduleMetrics.Size.sendText))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .cardSurface(padding: 0, cornerRadius: ScheduleMetrics.Size.sendCardCornerRadius)
        }
    }
}

#if DEBUG
#Preview {
    SendScheduleMessageCard(
        text: SchedulePreviewData.sendSchedule.text,
        height: ScheduleMetrics.Size.sendCardHeight
    )
    .padding()
    .background(Color.card)
}
#endif
