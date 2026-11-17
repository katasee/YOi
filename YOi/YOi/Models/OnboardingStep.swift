enum OnboardingStep: String, Codable, CaseIterable {
    case welcome
    case services
    case client
    case windows
    case sendSchedule
    case booking
    case finished

    var next: OnboardingStep {
        switch self {
        case .welcome: .services
        case .services: .client
        case .client: .windows
        case .windows: .sendSchedule
        case .sendSchedule: .booking
        case .booking, .finished: .finished
        }
    }
}
