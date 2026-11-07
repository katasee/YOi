import Foundation

struct AddedNotice: Equatable {
    enum Kind {
        case windows
        case plans
    }

    enum Outcome: Equatable {
        case saved(dates: [String])
        case failed
    }

    let kind: Kind
    let outcome: Outcome

    var dayId: String? {
        guard case .saved(let dates) = outcome, Set(dates).count == 1 else { return nil }

        return dates.first
    }

    var toast: ToastMessage {
        switch outcome {
        case .saved(let dates): ToastMessage(text: savedText(dates.count), style: .success)
        case .failed: ToastMessage(text: failedText, style: .failure)
        }
    }

    private func savedText(_ count: Int) -> String {
        switch kind {
        case .windows: String(localized: "schedule.added.windows \(count)")
        case .plans: String(localized: "schedule.added.plans \(count)")
        }
    }

    private var failedText: String {
        switch kind {
        case .windows: String(localized: "schedule.added.windowsFailed")
        case .plans: String(localized: "schedule.added.plansFailed")
        }
    }
}
