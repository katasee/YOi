import SwiftUI

struct ChoiceChipLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.elmsSans(.semiBold, ScheduleMetrics.Size.choiceChipTitle))
            .lineLimit(1)
            .padding(.horizontal, ScheduleMetrics.Spacing.bookRowPadding)
            .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.chipHeight)
    }
}

extension View {
    func choiceChipLabel() -> some View {
        modifier(ChoiceChipLabel())
    }
}
