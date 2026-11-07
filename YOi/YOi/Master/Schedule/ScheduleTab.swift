import SwiftUI

protocol ScheduleTab: CaseIterable, Identifiable, Hashable where AllCases: RandomAccessCollection {
    var titleKey: LocalizedStringKey { get }
}
