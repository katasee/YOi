extension OnboardingStep {
    var tab: MasterTab? {
        switch self {
        case .services: .stats
        case .client: .clients
        case .windows, .sendSchedule: .schedule
        case .finished: nil
        }
    }

    var targets: [OnboardingTarget] {
        switch self {
        case .services: [.servicesRow, .addService]
        case .client: [.addClient]
        case .windows: [.fillMonth]
        case .sendSchedule: [.sendSchedule]
        case .finished: []
        }
    }
}
