enum OnboardingStep: String, Codable, CaseIterable {
    case services
    case client
    case windows
    case sendSchedule
    case finished

    var next: OnboardingStep {
        switch self {
        case .services: .client
        case .client: .windows
        case .windows: .sendSchedule
        case .sendSchedule, .finished: .finished
        }
    }

    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}
