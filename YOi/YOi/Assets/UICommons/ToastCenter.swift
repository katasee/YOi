import Observation

@MainActor
@Observable
final class ToastCenter {
    var message: ToastMessage?
    private var pending: ToastMessage?
    private var openPopups = 0

    func show(_ message: ToastMessage) {
        guard pending?.style != .failure || message.style == .failure else { return }

        pending = message
        showIfIdle()
    }

    func reportSaveFailure() {
        show(.saveFailed)
    }

    func popupPresenceChanged(_ isOpen: Bool) {
        openPopups = max(openPopups + (isOpen ? 1 : -1), 0)
        showIfIdle()
    }

    private func showIfIdle() {
        guard openPopups == 0, let pending else { return }

        message = pending
        self.pending = nil
    }
}
