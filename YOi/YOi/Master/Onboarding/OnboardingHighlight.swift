import CoreGraphics

enum OnboardingHighlight: Equatable {
    case tab(MasterTab)
    case target(OnboardingTarget, CGRect)
    case finished
}
