import SwiftUI

extension EnvironmentValues {
    @Entry var onboardingScroll: ScrollViewProxy?
}

private struct OnboardingTargetModifier: ViewModifier {
    let target: OnboardingTarget?

    @Environment(OnboardingTour.self) private var tour: OnboardingTour?
    @Environment(\.onboardingScroll) private var scroll
    @State private var frame: CGRect?

    func body(content: Content) -> some View {
        content
            .id(target)
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { newFrame in
                frame = newFrame
                reportStoredFrame()
            }
            .onAppear(perform: reportStoredFrame)
            .task(id: isActive) {
                scrollIntoView()
            }
            .onDisappear {
                withdraw(target)
            }
            .onChange(of: target) { oldTarget, _ in
                withdraw(oldTarget)
                reportStoredFrame()
            }
            .simultaneousGesture(TapGesture().onEnded(registerTap))
    }

    private func reportStoredFrame() {
        guard let target else { return }

        tour?.report(target, frame: frame)
    }

    private func withdraw(_ target: OnboardingTarget?) {
        guard let target else { return }

        tour?.withdraw(target, frame: frame)
    }

    private var isActive: Bool {
        guard let target else { return false }

        return tour?.step?.targets.contains(target) == true
    }

    private func scrollIntoView() {
        guard isActive, let target, let scroll else { return }

        withAnimation(.smooth) {
            scroll.scrollTo(target, anchor: .center)
        }
    }

    private func registerTap() {
        guard let target else { return }

        tour?.didTap(target)
    }
}

extension View {
    func onboardingTarget(_ target: OnboardingTarget?) -> some View {
        modifier(OnboardingTargetModifier(target: target))
    }
}
