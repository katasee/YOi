import SwiftUI

struct BookClientRow: View {
    let option: BookClientOption
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ScheduleMetrics.Spacing.bookRowContentSpacing) {
                ClientAvatar(initial: option.initial, size: ScheduleMetrics.Size.bookAvatar)

                VStack(alignment: .leading, spacing: ScheduleMetrics.Spacing.bookRowTextSpacing) {
                    Text(verbatim: option.title)
                        .font(.elmsSans(.semiBold, ScheduleMetrics.Size.rowName))
                        .foregroundStyle(Color.ink)
                        .lineLimit(1)

                    if let subtitle = option.subtitle {
                        Text(verbatim: subtitle)
                            .font(.elmsSans(.regular, ScheduleMetrics.Size.bookRowSubtitle))
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                if option.isSelected {
                    Image(systemName: "checkmark")
                        .font(.elmsSans(.bold, ScheduleMetrics.Size.bookCheck))
                        .foregroundStyle(Color.wine)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, ScheduleMetrics.Spacing.bookRowPadding)
            .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.bookRowHeight)
            .background(
                option.isSelected ? Color.wineSoft : Color.clear,
                in: .rect(cornerRadius: ScheduleMetrics.Size.bookRowCornerRadius)
            )
            .contentShape(.rect(cornerRadius: ScheduleMetrics.Size.bookRowCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(option.isSelected ? .isSelected : [])
    }
}

#if DEBUG
#Preview {
    VStack(spacing: ScheduleMetrics.Spacing.bookOptionSpacing) {
        BookClientRow(option: SchedulePreviewData.options[0], action: {})
        BookClientRow(option: SchedulePreviewData.options[1], action: {})
    }
    .padding()
    .background(Color.card)
}
#endif
