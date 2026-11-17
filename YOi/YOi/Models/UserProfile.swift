import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String { uid }
    let uid: String
    var name: String
    var email: String
    var onboardingStep: String?

    var tourStep: OnboardingStep? {
        onboardingStep.flatMap(OnboardingStep.init(rawValue:))
    }
}
