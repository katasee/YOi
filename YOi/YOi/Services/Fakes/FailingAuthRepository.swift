import Foundation

#if DEBUG
final class FailingAuthRepository: AuthRepository {
    private let error: AccountError

    init(error: AccountError = .generic) {
        self.error = error
    }

    var currentUserId: String? { "failing-uid" }

    var currentEmail: String? { "failing@example.com" }

    var isEmailVerified: Bool { false }

    func signUp(
        email: String,
        password: String,
        name: String
    ) async throws {
        throw error
    }

    func signIn(email: String, password: String) async throws {
        throw error
    }

    func signOut() async throws {
        throw error
    }

    func fetchProfile() async throws -> UserProfile {
        throw error
    }

    func createProfile(name: String) async throws {
        throw error
    }

    func reloadUser() async throws {
        throw error
    }

    func refreshIdToken() async throws {
        throw error
    }

    func sendEmailVerification() async throws {
        throw error
    }

    func sendPasswordReset(email: String) async throws {
        throw error
    }

    func reauthenticate(password: String) async throws {
        throw error
    }

    func updatePassword(to newPassword: String) async throws {
        throw error
    }

    func deleteAccount() async throws {
        throw error
    }
}
#endif
