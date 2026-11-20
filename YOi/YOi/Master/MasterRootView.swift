import SwiftUI

struct MasterRootView: View {
    let profile: UserProfile
    let onSignOut: () -> Void
    let onAccountDeleted: () -> Void

    @State private var selectedTab: MasterTab = .schedule
    @State private var scheduleViewModel = ScheduleViewModel()
    @State private var statsViewModel = StatsViewModel()
    @State private var clientListViewModel = ClientListViewModel()
    @State private var tour: OnboardingTour
    @State private var currencySetting: CurrencySetting
    @State private var contentBottomInset: CGFloat = 0
    @State private var homeIndicatorInset: CGFloat = 0

    init(
        profile: UserProfile,
        onSignOut: @escaping () -> Void,
        onAccountDeleted: @escaping () -> Void
    ) {
        self.profile = profile
        self.onSignOut = onSignOut
        self.onAccountDeleted = onAccountDeleted
        _tour = State(initialValue: OnboardingTour(step: profile.tourStep))
        _currencySetting = State(initialValue: CurrencySetting(currency: profile.selectedCurrency))
    }

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
                                onSelectCurrency: currencySetting.select,
                                onSignOut: onSignOut,
                                onAccountDeleted: onAccountDeleted
                            )
                        }
                    }
                    .tint(Color.accentColor)
                    .environment(tour)
                    .environment(\.currency, currencySetting.currency)
                    .environment(\.popupPresenceChanged) { [tour] isOpen in
                        tour.popupPresenceChanged(isOpen)
                    }
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
