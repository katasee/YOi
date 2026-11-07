import Foundation
import Observation

@MainActor
@Observable
final class QuickBookViewModel: Identifiable {
    let id = UUID()
    let choice: ClientBookingChoice
    var time = WorkHours.defaultCustomTime

    private let day: Date

    init(
        day: Date,
        clients: [Client],
        services: [Service],
        clientRepository: ClientRepository
    ) {
        self.day = day
        choice = ClientBookingChoice(
            clients: clients,
            services: services,
            clientRepository: clientRepository
        )
    }

    var subtitle: String {
        DateFormat.weekdayDayMonth.string(from: day)
    }

    var canBook: Bool {
        choice.selectedClientId != nil
    }
}
