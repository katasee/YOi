import CoreGraphics
import Observation

@MainActor
@Observable
final class OnboardingTour {
    private(set) var step: OnboardingStep?
    private(set) var frames: [OnboardingTarget: CGRect] = [:]
    private(set) var openPopups = 0
    private var completed: Set<OnboardingStep> = []
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

    func record(_ done: Set<OnboardingStep>) {
        guard let step, done.isSubset(of: completed) == false else { return }

        completed.formUnion(done)

        guard completed.contains(step) else { return }

        move(to: firstOpenStep(after: step))
    }

    func popupPresenceChanged(_ isOpen: Bool) {
        openPopups = max(openPopups + (isOpen ? 1 : -1), 0)
    }

    func advance() {
        guard let step else { return }

        move(to: firstOpenStep(after: step))
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

    private func firstOpenStep(after step: OnboardingStep) -> OnboardingStep {
        var next = step.next

        while next != .finished, completed.contains(next) {
            next = next.next
        }

        return next
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
