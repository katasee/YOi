import SwiftUI

enum QuickAddTab: ScheduleTab {
    case client
    case plan

    var id: Self { self }

    var titleKey: LocalizedStringKey {
        switch self {
        case .client: "schedule.tab.client"
        case .plan: "schedule.tab.plans"
        }
    }
}
