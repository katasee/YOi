import FirebaseAuth
import FirebaseFirestore

final class FirebaseAuthRepository: AuthRepository {
    private let db = Firestore.firestore()

    var currentUserId: String? { Auth.auth().currentUser?.uid }

    var currentEmail: String? { Auth.auth().currentUser?.email }

    var isEmailVerified: Bool { Auth.auth().currentUser?.isEmailVerified ?? false }

    func signUp(
        email: String,
        password: String,
        name: String
    ) async throws {
        let result: AuthDataResult

        do {
            result = try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            throw Self.accountError(from: error)
        }

        try await writeProfile(
            uid: result.user.uid,
            name: name,
            email: email
        )

        Auth.auth().useAppLanguage()
        try? await result.user.sendEmailVerification()
    }

    func signIn(email: String, password: String) async throws {
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw Self.accountError(from: error)
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func fetchProfile() async throws -> UserProfile {
        guard let uid = currentUserId else { throw AccountError.profileNotFound }

        let snapshot = try await db.collection("users").document(uid).getDocument()

        guard snapshot.exists else { throw AccountError.profileNotFound }

        return try snapshot.data(as: UserProfile.self)
    }

    func createProfile(name: String) async throws {
        guard let user = Auth.auth().currentUser else { throw AccountError.profileNotFound }

        try await writeProfile(
            uid: user.uid,
            name: name,
            email: user.email ?? ""
        )
    }

    func reloadUser() async throws {
        let user = try currentUser()

        do {
            try await user.reload()
        } catch {
            throw Self.accountError(from: error)
        }
    }

    func refreshIdToken() async throws {
        let user = try currentUser()

        do {
            _ = try await user.getIDTokenResult(forcingRefresh: true)
        } catch {
            throw Self.accountError(from: error)
        }
    }

    func sendEmailVerification() async throws {
        let user = try currentUser()
        Auth.auth().useAppLanguage()

        do {
            try await user.sendEmailVerification()
        } catch {
            throw Self.accountError(from: error)
        }
    }

    func sendPasswordReset(email: String) async throws {
        Auth.auth().useAppLanguage()

        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as NSError where error.domain == AuthErrors.domain
            && error.code == AuthErrorCode.userNotFound.rawValue {
        } catch {
            throw Self.accountError(from: error)
        }
    }

    func reauthenticate(password: String) async throws {
        let user = try currentUser()

        guard let email = user.email else { throw AccountError.generic }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        do {
            _ = try await user.reauthenticate(with: credential)
        } catch {
            throw Self.accountError(from: error)
        }
    }

    func updatePassword(to newPassword: String) async throws {
        let user = try currentUser()

        do {
            try await user.updatePassword(to: newPassword)
        } catch {
            throw Self.accountError(from: error)
        }
    }

    func deleteAccount() async throws {
        let user = try currentUser()

        do {
            try await user.delete()
        } catch {
            throw Self.accountError(from: error)
        }
    }

    private func currentUser() throws -> User {
        guard let user = Auth.auth().currentUser else { throw AccountError.requiresRecentLogin }

        return user
    }

    private func writeProfile(
        uid: String,
        name: String,
        email: String
    ) async throws {
        let profile = UserProfile(
            uid: uid,
            name: name,
            email: email,
            onboardingStep: OnboardingStep.welcome.rawValue,
            currency: Currency.regional(Locale.current.region).rawValue
        )
        let encoded = try Firestore.Encoder().encode(profile)
        try await db.collection("users")
            .document(uid)
            .setData(encoded)
    }

    private static func accountError(from error: Error) -> AccountError {
        let error = error as NSError

        guard error.domain == AuthErrors.domain,
              let code = AuthErrorCode(rawValue: error.code) else { return .generic }

        switch code {
        case .wrongPassword, .invalidCredential, .userMismatch:
            return .wrongPassword
        case .weakPassword:
            return .weakPassword
        case .requiresRecentLogin:
            return .requiresRecentLogin
        case .invalidEmail:
            return .invalidEmail
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .tooManyRequests:
            return .tooManyRequests
        case .networkError:
            return .network
        default:
            return .generic
        }
    }
}
