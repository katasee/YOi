import SwiftUI

enum FillMonthTab: ScheduleTab {
    case slots
    case plans

    var id: Self { self }

    var titleKey: LocalizedStringKey {
        switch self {
        case .slots: "schedule.tab.slots"
        case .plans: "schedule.tab.plans"
        }
    }
}
