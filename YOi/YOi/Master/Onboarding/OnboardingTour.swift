import CoreGraphics
import Observation

@MainActor
@Observable
final class OnboardingTour {
    private(set) var step: OnboardingStep?
    private(set) var frames: [OnboardingTarget: CGRect] = [:]
    private(set) var openPopups = 0
    private let repository: OnboardingRepository

    init(step: OnboardingStep?, repository: OnboardingRepository = FirestoreOnboardingRepository()) {
        self.step = step == .finished ? nil : step
        self.repository = repository
    }

    func report(_ target: OnboardingTarget, frame: CGRect?) {
        guard step != nil, frames[target] != frame else { return }

        frames[target] = frame
    }

    func withdraw(_ target: OnboardingTarget, frame: CGRect?) {
        guard frames[target] == frame else { return }

        frames[target] = nil
    }

    func didTap(_ target: OnboardingTarget) {
        guard let step, step.targets.last == target else { return }

        move(to: step.next)
    }

    func popupPresenceChanged(_ isOpen: Bool) {
        openPopups = max(openPopups + (isOpen ? 1 : -1), 0)
    }

    func advance() {
        guard let step else { return }

        move(to: step.next)
    }

    func close() {
        guard step != nil else { return }

        move(to: nil)
        frames = [:]
    }

    private func move(to newStep: OnboardingStep?) {
        step = newStep
        try? repository.save(newStep ?? .finished)
    }

    func highlight(selectedTab: MasterTab) -> OnboardingHighlight? {
        guard let step, openPopups == 0 else { return nil }

        return Self.highlight(
            step: step,
            selectedTab: selectedTab,
            frames: frames
        )
    }

    static func highlight(
        step: OnboardingStep?,
        selectedTab: MasterTab,
        frames: [OnboardingTarget: CGRect]
    ) -> OnboardingHighlight? {
        guard let step else { return nil }

        guard let tab = step.tab else {
            return step == .welcome ? .welcome : .finished
        }

        if let target = step.targets.last(where: { frames[$0] != nil }), let frame = frames[target] {
            return .target(target, frame)
        }

        return selectedTab == tab ? nil : .tab(tab)
    }
}
