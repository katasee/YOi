import CoreGraphics
import Observation

@MainActor
@Observable
final class OnboardingTour {
    private(set) var step: OnboardingStep?
    private(set) var frames: [OnboardingTarget: CGRect] = [:]

    init(step: OnboardingStep?) {
        self.step = step
    }

    func report(_ target: OnboardingTarget, frame: CGRect?) {
        frames[target] = frame
    }

    func didTap(_ target: OnboardingTarget) {
        guard let step, step.targets.last == target else { return }

        self.step = step.next
    }

    func skip() {
        step = step?.next
    }

    func close() {
        step = nil
    }

    func highlight(selectedTab: MasterTab) -> OnboardingHighlight? {
        Self.highlight(
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
        guard let tab = step.tab else { return .finished }

        if let target = step.targets.last(where: { frames[$0] != nil }), let frame = frames[target] {
            return .target(target, frame)
        }

        return selectedTab == tab ? nil : .tab(tab)
    }
}
