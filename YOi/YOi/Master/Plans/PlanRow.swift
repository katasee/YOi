import SwiftUI

struct PlanRow: View {
    let template: EventTemplate

    var body: some View {
        HStack(spacing: PlansMetrics.Spacing.rowContentSpacing) {
            PlanEmojiTile(emoji: template.emoji)
            name

            Spacer(minLength: 0)
        }
        .padding(.horizontal, PlansMetrics.Spacing.rowHorizontalPadding)
        .padding(.vertical, PlansMetrics.Spacing.rowVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: 0, cornerRadius: PlansMetrics.Size.rowCornerRadius)
    }

    private var name: some View {
        Text(template.name)
            .font(.elmsSans(.medium, 16))
            .foregroundStyle(Color.ink)
            .lineLimit(2)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: PlansMetrics.Spacing.rowSpacing) {
        ForEach(PlansPreviewData.templates) { template in
            PlanRow(template: template)
        }
    }
    .padding()
    .background(Color.background)
}
#endif
