import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    enum Mode {
        case signIn
        case signUp
    }

    var mode: Mode = .signIn
    var email = "" {
        didSet { failure = nil }
    }
    var password = "" {
        didSet { failure = nil }
    }
    var name = "" {
        didSet { failure = nil }
    }
    private(set) var failure: AuthFailure?
    var isLoading = false

    private let repository: AuthRepository

    init(repository: AuthRepository = FirebaseAuthRepository()) {
        self.repository = repository
    }

    private var hasCredentials: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var canSubmit: Bool {
        switch mode {
        case .signIn: hasCredentials
        case .signUp: hasCredentials && !name.isEmpty
        }
    }

    func submit() async -> Bool {
        if mode == .signUp, password.count < PasswordPolicy.minimumLength {
            failure = .weakPassword
            return false
        }

        isLoading = true
        failure = nil
        defer { isLoading = false }

        do {
            switch mode {
            case .signIn:
                try await repository.signIn(email: email, password: password)
            case .signUp:
                try await repository.signUp(
                    email: email,
                    password: password,
                    name: name
                )
            }
            return true
        } catch let error as AccountError {
            failure = AuthFailure(error)
            return false
        } catch {
            failure = .generic
            return false
        }
    }
}
