import Foundation

struct AddedNotice: Equatable {
    enum Kind {
        case windows
        case plans
    }

    enum Outcome: Equatable {
        case saved(count: Int)
        case failed
    }

    let kind: Kind
    let outcome: Outcome

    var toast: ToastMessage {
        switch outcome {
        case .saved(let count): ToastMessage(text: savedText(count), style: .success)
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
