import Foundation
import Observation

enum SendScheduleMode {
    case text
    case recipient
    case contacts(ClientItem)
}

@MainActor
@Observable
final class SendScheduleViewModel: Identifiable {
    let id = UUID()

    private(set) var mode = SendScheduleMode.text
    private(set) var text: String?
    private var pager: MonthPager
    private var clientPicker = ClientPicker()

    private let slots: [Slot]
    private let clients: [Client]
    private let now: Date

    init(
        slots: [Slot],
        clients: [Client],
        now: Date
    ) {
        self.slots = slots
        self.clients = clients
        self.now = now
        pager = MonthPager(showing: now, earliest: now)
        updateText()
    }

    var searchText: String {
        get { clientPicker.searchText }
        set { clientPicker.searchText = newValue }
    }

    var monthTitle: String {
        DateFormat.monthYear.string(from: pager.grid.start).capitalized
    }

    var canGoBack: Bool {
        pager.canGoBack
    }

    var options: [BookClientOption] {
        clientPicker.options(from: clients)
    }

    func showPreviousMonth() {
        pager.showPrevious()
        updateText()
    }

    func showNextMonth() {
        pager.showNext()
        updateText()
    }

    func startSending() {
        mode = .recipient
    }

    func pick(_ clientId: String) {
        guard let client = clients.first(where: { $0.id == clientId }) else { return }

        mode = .contacts(ClientItem(client: client))
    }

    func back() {
        switch mode {
        case .text:
            break
        case .recipient:
            searchText = ""
            mode = .text
        case .contacts:
            mode = .recipient
        }
    }

    private func updateText() {
        text = ScheduleMessage.text(
            slots: slots,
            month: pager.grid,
            now: now,
            template: MessageTemplate()
        )
    }
}
