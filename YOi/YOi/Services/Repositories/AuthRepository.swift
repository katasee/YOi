protocol AuthRepository {
    var currentUserId: String? { get }
    var currentEmail: String? { get }
    var isEmailVerified: Bool { get }
    func signUp(email: String, password: String, name: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() async throws
    func fetchProfile() async throws -> UserProfile
    func createProfile(name: String) async throws
    func reloadUser() async throws
    func refreshIdToken() async throws
    func sendEmailVerification() async throws
    func sendPasswordReset(email: String) async throws
    func reauthenticate(password: String) async throws
    func updatePassword(to newPassword: String) async throws
    func deleteAccount() async throws
}
