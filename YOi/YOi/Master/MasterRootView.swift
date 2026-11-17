import SwiftUI

struct MasterRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void
    let onAccountDeleted: () -> Void

    @State private var selectedTab: MasterTab = .schedule
    @State private var scheduleViewModel = ScheduleViewModel()
    @State private var statsViewModel = StatsViewModel()
    @State private var clientListViewModel = ClientListViewModel()
    @State private var tour = OnboardingTour(step: .services)
    @State private var contentBottomInset: CGFloat = 0
    @State private var homeIndicatorInset: CGFloat = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MasterTab.allCases) { tab in
                Tab(
                    tab.titleKey,
                    systemImage: tab.systemImage,
                    value: tab
                ) {
                    Group {
                        switch tab {
                        case .schedule:
                            ScheduleView(viewModel: scheduleViewModel)
                        case .clients:
                            ClientsView(viewModel: clientListViewModel)
                        case .stats:
                            StatsView(
                                viewModel: statsViewModel,
                                profile: profile,
                                onSignOut: onSignOut,
                                onAccountDeleted: onAccountDeleted
                            )
                        }
                    }
                    .tint(Color.accentColor)
                    .environment(tour)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.safeAreaInsets.bottom
                    } action: { inset in
                        contentBottomInset = inset
                    }
                }
            }
        }
        .tint(Color.ink)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.safeAreaInsets.bottom
        } action: { inset in
            homeIndicatorInset = inset
        }
        .overlay {
            OnboardingOverlay(
                tour: tour,
                selectedTab: selectedTab,
                contentBottomInset: contentBottomInset,
                homeIndicatorInset: homeIndicatorInset
            )
        }
        .task {
            await statsViewModel.syncMonthArchive()
        }
    }
}

#if DEBUG
#Preview {
    MasterRootView(
        profile: ProfilePreviewData.profile,
        onSignOut: {},
        onAccountDeleted: {}
    )
}
#endif
