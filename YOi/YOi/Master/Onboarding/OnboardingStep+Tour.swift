extension OnboardingStep {
    static let guided: [OnboardingStep] = [.services, .client, .windows, .sendSchedule, .booking]

    var progressIndex: Int? {
        Self.guided.firstIndex(of: self)
    }

    var tab: MasterTab? {
        switch self {
        case .services: .stats
        case .client: .clients
        case .windows, .sendSchedule, .booking: .schedule
        case .welcome, .finished: nil
        }
    }

    var targets: [OnboardingTarget] {
        switch self {
        case .services: [.servicesRow, .addService]
        case .client: [.addClient]
        case .windows: [.fillMonth]
        case .sendSchedule: [.sendSchedule]
        case .booking: [.freeSlot]
        case .welcome, .finished: []
        }
    }
}
