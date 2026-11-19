import Foundation
import Observation

enum SendScheduleMode {
    case text
    case recipient
    case contacts(ClientItem)
    case template
}

@MainActor
@Observable
final class SendScheduleViewModel: Identifiable {
    let id = UUID()

    private(set) var mode = SendScheduleMode.text
    private(set) var text: String?
    private(set) var template: MessageTemplate
    private var pager: MonthPager
    private var clientPicker = ClientPicker()

    private let slots: [Slot]
    private let clients: [Client]
    private let now: Date

    init(
        slots: [Slot],
        clients: [Client],
        now: Date,
        template: MessageTemplate = MessageTemplate()
    ) {
        self.slots = slots
        self.clients = clients
        self.now = now
        self.template = template
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

    var language: MessageLanguage {
        get { template.messageLanguage }
        set {
            template.setLanguage(newValue)
            updateText()
        }
    }

    var isEditingTemplate: Bool {
        if case .template = mode {
            true
        } else {
            false
        }
    }

    var dayStyle: MessageDayStyle {
        template.dayStyle
    }

    var styleIndex: Double {
        get { Double(MessageDayStyle.allCases.firstIndex(of: dayStyle) ?? 0) }
        set {
            let styles = MessageDayStyle.allCases
            let index = min(max(Int(newValue.rounded()), 0), styles.count - 1)

            guard styles[index] != dayStyle else { return }

            template.setDayStyle(styles[index])
            updateText()
        }
    }

    var headerText: String {
        get { template.header(for: language) }
        set {
            template.setHeader(newValue, for: language)
            updateText()
        }
    }

    var footerText: String {
        get { template.footer(for: language) }
        set {
            template.setFooter(newValue, for: language)
            updateText()
        }
    }

    var hasCustomHeader: Bool {
        template.hasHeader(for: language)
    }

    var hasCustomFooter: Bool {
        template.hasFooter(for: language)
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

    func resetHeader() {
        template.setHeader(nil, for: language)
        updateText()
    }

    func resetFooter() {
        template.setFooter(nil, for: language)
        updateText()
    }

    func customize() {
        mode = .template
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
        case .template:
            mode = .text
        }
    }

    private func updateText() {
        text = ScheduleMessage.text(
            slots: slots,
            month: pager.grid,
            now: now,
            template: template
        )
    }
}
