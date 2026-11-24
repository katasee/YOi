import Foundation
import Observation

@MainActor
@Observable
final class RootViewModel {
    enum State {
        case loading
        case signedOut
        case awaitingVerification(email: String)
        case signedIn(UserProfile)
    }

    var state: State = .loading
    private(set) var failure: AuthFailure?

    private let repository: AuthRepository

    init(repository: AuthRepository = FirebaseAuthRepository()) {
        self.repository = repository
    }

    func refresh() async {
        guard repository.currentUserId != nil else {
            state = .signedOut
            return
        }

        if repository.isEmailVerified == false {
            try? await repository.reloadUser()

            guard repository.isEmailVerified else {
                failure = nil
                state = .awaitingVerification(email: repository.currentEmail ?? "")
                return
            }

            try? await repository.refreshIdToken()
        }

        do {
            let profile = try await loadProfile()
            failure = nil
            state = .signedIn(profile)
        } catch let error as AccountError {
            failure = AuthFailure(error)
            state = .signedOut
        } catch {
            failure = .generic
            state = .signedOut
        }
    }

    func reset() async {
        try? await repository.signOut()
        failure = nil
        state = .signedOut
    }

    func signOut() async {
        do {
            try await repository.signOut()
            failure = nil
            state = .signedOut
        } catch {
            failure = .generic
        }
    }

    private func loadProfile() async throws -> UserProfile {
        do {
            return try await repository.fetchProfile()
        } catch AccountError.profileNotFound {
            try await repository.createProfile(name: defaultName)
            return try await repository.fetchProfile()
        }
    }

    private var defaultName: String {
        let email = repository.currentEmail ?? ""
        return email.split(separator: "@").first.map(String.init) ?? email
    }
}
