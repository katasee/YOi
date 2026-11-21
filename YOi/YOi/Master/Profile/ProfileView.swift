import SwiftUI

private struct ProfileActionRow: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    var tint: Color = .ink
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ProfileMetrics.Spacing.rowSpacing) {
                Image(systemName: systemImage)
                    .font(.elmsSans(.medium, ProfileMetrics.Size.rowIcon))
                    .frame(width: ProfileMetrics.Size.rowIconColumn)
                    .accessibilityHidden(true)

                Text(titleKey)
                    .font(.elmsSans(.semiBold, 15))

                Spacer(minLength: 0)
            }
            .foregroundStyle(tint)
            .frame(minHeight: ProfileMetrics.Size.rowMinHeight)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

struct ProfileView: View {
    private enum Popup: String, Identifiable {
        case changePassword
        case deleteAccount

        var id: String { rawValue }
    }

    @State private var popup: Popup?
    @Environment(\.openURL) private var openURL
    @Environment(\.currency) private var currency

    let profile: UserProfile
    let onSelectCurrency: (Currency) -> Void
    let onSignOut: () -> Void
    let onAccountDeleted: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: ProfileMetrics.Spacing.sectionSpacing) {
                    profileCard
                    themeSection
                    currencySection
                    accountSection
                    aboutSection
                }
                .padding(.horizontal, ProfileMetrics.Spacing.horizontalPadding)
                .padding(.top, ProfileMetrics.Spacing.contentTopPadding)
                .padding(.bottom, ProfileMetrics.Spacing.contentBottomPadding)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("profile.title")
                    .font(.elmsSans(.semiBold, 17))
                    .foregroundStyle(Color.ink)
            }
        }
        .fullScreenCover(item: $popup) { popup in
            popupContent(popup)
                .presentationBackground(.clear)
        }
    }

    private var profileCard: some View {
        HStack(spacing: ProfileMetrics.Spacing.profileSpacing) {
            IconBadge(systemName: "person")

            VStack(alignment: .leading, spacing: ProfileMetrics.Spacing.nameEmailSpacing) {
                Text(profile.name)
                    .font(.elmsSans(.semiBold, 17))
                    .foregroundStyle(Color.ink)

                Text(profile.email)
                    .font(.elmsSans(.regular, 14))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .cardSurface(
            padding: ProfileMetrics.Spacing.cardPadding,
            cornerRadius: ProfileMetrics.Size.cardCornerRadius
        )
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: ProfileMetrics.Spacing.sectionLabelSpacing) {
            SectionLabel(titleKey: "profile.section.theme")

            AppearancePicker()
                .padding(.horizontal, ProfileMetrics.Spacing.cardPadding)
                .padding(.vertical, ProfileMetrics.Spacing.listVerticalPadding)
                .cardSurface(padding: 0, cornerRadius: ProfileMetrics.Size.cardCornerRadius)
        }
    }

    private var currencySection: some View {
        HStack(spacing: ProfileMetrics.Spacing.rowSpacing) {
            Text("profile.currency.title")
                .font(.elmsSans(.semiBold, 15))
                .foregroundStyle(Color.ink)

            Spacer(minLength: 0)

            CurrencyPicker(selected: currency, onSelect: onSelectCurrency)
        }
        .padding(.horizontal, ProfileMetrics.Spacing.cardPadding)
        .cardSurface(padding: 0, cornerRadius: ProfileMetrics.Size.cardCornerRadius)
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: ProfileMetrics.Spacing.sectionLabelSpacing) {
            SectionLabel(titleKey: "profile.section.account")

            VStack(spacing: 0) {
                ProfileActionRow(
                    titleKey: "account.action.changePassword",
                    systemImage: "key",
                    action: showChangePassword
                )

                divider

                ProfileActionRow(
                    titleKey: "common.action.signOut",
                    systemImage: "rectangle.portrait.and.arrow.right",
                    action: onSignOut
                )

                divider

                ProfileActionRow(
                    titleKey: "account.action.delete",
                    systemImage: "trash",
                    tint: .destructive,
                    action: showDeleteAccount
                )
            }
            .padding(.horizontal, ProfileMetrics.Spacing.cardPadding)
            .padding(.vertical, ProfileMetrics.Spacing.listVerticalPadding)
            .cardSurface(padding: 0, cornerRadius: ProfileMetrics.Size.cardCornerRadius)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: ProfileMetrics.Spacing.sectionLabelSpacing) {
            SectionLabel(titleKey: "profile.section.about")

            ProfileActionRow(
                titleKey: "profile.action.privacy",
                systemImage: "hand.raised",
                action: openPrivacyPolicy
            )
            .padding(.horizontal, ProfileMetrics.Spacing.cardPadding)
            .padding(.vertical, ProfileMetrics.Spacing.listVerticalPadding)
            .cardSurface(padding: 0, cornerRadius: ProfileMetrics.Size.cardCornerRadius)
        }
    }

    private var divider: some View {
        Color.hairline
            .frame(height: ProfileMetrics.Size.dividerHeight)
    }

    @ViewBuilder
    private func popupContent(_ popup: Popup) -> some View {
        switch popup {
        case .changePassword:
            ChangePasswordPopup(viewModel: ChangePasswordViewModel(), onDismiss: hidePopup)
        case .deleteAccount:
            DeleteAccountPopup(
                viewModel: DeleteAccountViewModel(),
                onDeleted: onAccountDeleted,
                onDismiss: hidePopup
            )
        }
    }

    private func openPrivacyPolicy() {
        openURL(AppLinks.privacyPolicy)
    }

    private func showChangePassword() {
        show(.changePassword)
    }

    private func showDeleteAccount() {
        show(.deleteAccount)
    }

    private func show(_ popup: Popup) {
        withoutPresentationAnimation {
            self.popup = popup
        }
    }

    private func hidePopup() {
        withoutPresentationAnimation {
            popup = nil
        }
    }
}

#if DEBUG
#Preview("Профіль") {
    NavigationStack {
        ProfileView(
            profile: ProfilePreviewData.profile,
            onSelectCurrency: { _ in },
            onSignOut: {},
            onAccountDeleted: {}
        )
    }
}
#endif
