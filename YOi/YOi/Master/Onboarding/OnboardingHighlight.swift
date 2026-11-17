import CoreGraphics

enum OnboardingHighlight: Equatable {
    case welcome
    case tab(MasterTab)
    case target(OnboardingTarget, CGRect)
    case finished
}
