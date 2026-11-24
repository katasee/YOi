import Foundation

#if DEBUG
final class FakeAuthRepository: AuthRepository {
    private let profile: UserProfile
    private var password: String
    private var isDeleted = false

    let isEmailVerified: Bool

    init(
        profile: UserProfile,
        password: String,
        isEmailVerified: Bool = true
    ) {
        self.profile = profile
        self.password = password
        self.isEmailVerified = isEmailVerified
    }

    var currentUserId: String? { isDeleted ? nil : profile.uid }

    var currentEmail: String? { isDeleted ? nil : profile.email }

    func signUp(
        email: String,
        password: String,
        name: String
    ) async throws {}

    func signIn(email: String, password: String) async throws {}

    func signOut() async throws {}

    func fetchProfile() async throws -> UserProfile {
        guard isDeleted == false else { throw AccountError.profileNotFound }

        return profile
    }

    func createProfile(name: String) async throws {
        isDeleted = false
    }

    func reloadUser() async throws {}

    func refreshIdToken() async throws {}

    func sendEmailVerification() async throws {}

    func sendPasswordReset(email: String) async throws {}

    func reauthenticate(password: String) async throws {
        guard password == self.password else { throw AccountError.wrongPassword }
    }

    func updatePassword(to newPassword: String) async throws {
        password = newPassword
    }

    func deleteAccount() async throws {
        isDeleted = true
    }
}
#endif
