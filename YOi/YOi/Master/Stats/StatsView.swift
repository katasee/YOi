import SwiftUI

struct StatsView: View {
    @State private var viewModel: StatsViewModel
    @State private var path: [StatsRoute] = []
    @Environment(\.currency) private var currency

    private let profile: UserProfile
    private let onSelectCurrency: (Currency) -> Void
    private let onSignOut: () -> Void
    private let onAccountDeleted: () -> Void

    init(
        viewModel: StatsViewModel,
        profile: UserProfile,
        onSelectCurrency: @escaping (Currency) -> Void,
        onSignOut: @escaping () -> Void,
        onAccountDeleted: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.profile = profile
        self.onSelectCurrency = onSelectCurrency
        self.onSignOut = onSignOut
        self.onAccountDeleted = onAccountDeleted
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                LargeTitleHeader(titleKey: "stats.title") {
                    RoundIconButton(
                        systemImage: "person.crop.circle",
                        accessibilityLabel: "profile.action.open",
                        action: showProfile
                    )
                }

                monthRow

                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: StatsRoute.self) { route in
                switch route {
                case .services:
                    MyServicesView(viewModel: MyServicesViewModel())
                case .plans:
                    MyPlansView(viewModel: MyPlansViewModel())
                case .profile:
                    ProfileView(
                        profile: profile,
                        onSelectCurrency: onSelectCurrency,
                        onSignOut: onSignOut,
                        onAccountDeleted: onAccountDeleted
                    )
                }
            }
            .task {
                await viewModel.observeSlots()
            }
            .task {
                await viewModel.observeSummaries()
            }
            .task {
                await viewModel.refreshStats()
            }
        }
    }

    private func showProfile() {
        path.append(.profile)
    }

    private var monthRow: some View {
        MonthHeader(
            title: viewModel.monthTitle,
            canGoBack: viewModel.canGoBack,
            canGoForward: viewModel.canGoForward,
            onPrevious: viewModel.showPreviousMonth,
            onNext: viewModel.showNextMonth
        )
        .padding(.horizontal, StatsMetrics.Spacing.horizontalPadding)
        .padding(.top, StatsMetrics.Spacing.monthTopPadding)
    }

    private var content: some View {
        ScrollViewReader { proxy in
            scrollContent
                .environment(\.onboardingScroll, proxy)
        }
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: StatsMetrics.Spacing.cardSpacing) {
                if let stats = viewModel.stats(currency: currency) {
                    MonthStatsCards(stats: stats, onSelectCurrency: onSelectCurrency)
                } else {
                    ContentUnavailableView {
                        Text("stats.noData")
                            .font(.elmsSans(.bold, 18))
                            .foregroundStyle(Color.ink)
                    }
                }

                servicesLink
                plansLink
            }
            .padding(.horizontal, StatsMetrics.Spacing.horizontalPadding)
            .padding(.top, StatsMetrics.Spacing.contentTopPadding)
            .padding(.bottom, StatsMetrics.Spacing.contentBottomPadding)
        }
        .scrollIndicators(.hidden)
        .overlay {
            if viewModel.hasLoaded == false {
                ProgressView()
                    .tint(Color.ink)
            }
        }
    }

    private var servicesLink: some View {
        StatsLinkRow(
            titleKey: "services.action.open",
            iconName: "list.bullet.rectangle",
            route: .services
        )
        .onboardingTarget(.servicesRow)
    }

    private var plansLink: some View {
        StatsLinkRow(
            titleKey: "plans.action.open",
            iconName: "checklist",
            route: .plans
        )
    }
}

#if DEBUG
#Preview {
    StatsView(
        viewModel: StatsViewModel(
            slotRepository: FakeSlotRepository(slots: StatsPreviewData.slots),
            summaryRepository: FakeMonthlySummaryRepository(summaries: StatsPreviewData.summaries)
        ),
        profile: ProfilePreviewData.profile,
        onSelectCurrency: { _ in },
        onSignOut: {},
        onAccountDeleted: {}
    )
}
#endif
