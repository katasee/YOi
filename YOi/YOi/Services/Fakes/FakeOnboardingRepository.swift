import Foundation

#if DEBUG
final class FakeOnboardingRepository: OnboardingRepository {
    private(set) var saved: [OnboardingStep] = []

    func save(_ step: OnboardingStep) throws {
        saved.append(step)
    }
}
#endif
