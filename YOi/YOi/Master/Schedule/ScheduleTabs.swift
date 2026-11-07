import SwiftUI

private struct ScheduleTabLens: View {
    var body: some View {
        if #available(iOS 26, *) {
            Color.clear
                .glassEffect(.regular, in: .capsule)
        } else {
            Capsule()
                .fill(Color.raised)
                .strokeBorder(Color.hairline)
                .brandShadow()
        }
    }
}

struct ScheduleTabs<Tab: ScheduleTab>: View {
    @Binding var selection: Tab

    @Namespace private var lens

    var body: some View {
        HStack(spacing: ScheduleMetrics.Spacing.tabTrackPadding) {
            ForEach(Tab.allCases) { tab in
                Button {
                    select(tab)
                } label: {
                    Text(tab.titleKey)
                        .font(.elmsSans(.semiBold, ScheduleMetrics.Size.tabTitle))
                        .foregroundStyle(tab == selection ? Color.ink : Color.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: ScheduleMetrics.Size.tabHeight)
                        .background {
                            if tab == selection {
                                ScheduleTabLens()
                                    .matchedGeometryEffect(id: "lens", in: lens)
                            }
                        }
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(tab == selection ? .isSelected : [])
            }
        }
        .padding(ScheduleMetrics.Spacing.tabTrackPadding)
        .raisedSurface(.capsule)
    }

    private func select(_ tab: Tab) {
        withAnimation(.snappy) {
            selection = tab
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selection = FillMonthTab.plans

    ScheduleTabs(selection: $selection)
        .padding()
        .background(Color.card)
}
#endif
