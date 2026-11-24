import SwiftUI

struct RootView: View {
    @State private var viewModel = RootViewModel()
    @AppStorage(AppAppearance.storageKey) private var appearance: AppAppearance = .system

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LaunchView()
            case .signedOut:
                VStack(spacing: 0) {
                    if let failure = viewModel.failure {
                        Text(failure.messageKey)
                            .font(.elmsSans(.regular, 13))
                            .foregroundStyle(.red)
                            .padding()
                    }
                    AuthView {
                        await viewModel.refresh()
                    }
                }
            case .awaitingVerification(let email):
                VerifyEmailView(
                    viewModel: VerifyEmailViewModel(email: email),
                    onVerified: { await viewModel.refresh() },
                    onSignOut: viewModel.signOut
                )
                .id(email)
            case .signedIn(let profile):
                MasterRootView(
                    profile: profile,
                    onSignOut: viewModel.signOut,
                    onAccountDeleted: viewModel.reset
                )
                .id(profile.uid)
            }
        }
        .preferredColorScheme(appearance.colorScheme)
        .task {
            await viewModel.refresh()
        }
    }
}

#Preview {
    RootView()
}
