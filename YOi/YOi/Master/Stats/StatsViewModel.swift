import Foundation
import Observation

@MainActor
@Observable
final class StatsViewModel {
    private static let refreshInterval = 60

    private(set) var stats: MonthlyStats?
    private(set) var monthTitle: String
    private(set) var hasLoaded = false

    private let slotRepository: SlotRepository
    private let summaryRepository: MonthlySummaryRepository

    private var slots: [Slot] = [] {
        didSet { rebuild() }
    }

    private var summaries: [String: MonthlySummary] = [:] {
        didSet { rebuild() }
    }

    private var oldestStoredMonth: Date?

    private var monthStart: Date {
        didSet {
            monthTitle = DateFormat.monthYear.string(from: monthStart)
            rebuild()
        }
    }

    init(
        slotRepository: SlotRepository = FirestoreSlotRepository(),
        summaryRepository: MonthlySummaryRepository = FirestoreMonthlySummaryRepository()
    ) {
        let start = StatsCalculator.monthStart(containing: .now)

        self.slotRepository = slotRepository
        self.summaryRepository = summaryRepository
        self.monthStart = start
        self.monthTitle = DateFormat.monthYear.string(from: start)
        self.stats = MonthlyStats(
            totals: StatsCalculator.totals(
                slots: [],
                monthStart: start,
                previous: nil,
                now: .now
            )
        )
    }

    var canGoBack: Bool {
        monthStart > oldestMonthStart
    }

    var canGoForward: Bool {
        monthStart < StatsCalculator.monthStart(containing: .now)
    }

    func observeSlots() async {
        do {
            for try await updatedSlots in slotRepository.observeSlots() {
                slots = updatedSlots
                hasLoaded = true
            }
        } catch {
            hasLoaded = true
        }
    }

    func observeSummaries() async {
        do {
            for try await updatedSummaries in summaryRepository.observeSummaries() {
                oldestStoredMonth = updatedSummaries
                    .compactMap(\.id)
                    .min()
                    .flatMap(DateFormat.month.date(from:))
                summaries = updatedSummaries.reduce(into: [:]) { byId, summary in
                    guard let id = summary.id else { return }

                    byId[id] = summary
                }
            }
        } catch {}
    }

    func archiveFinishedMonths() async {
        let now = Date.now

        do {
            let storedIds = try await summaryRepository.fetchSummaryIds()
            let staleIds = StatsCalculator.staleMonthIds(storedIds: storedIds, now: now)

            if staleIds.isEmpty == false {
                try Task.checkCancellation()
                try summaryRepository.delete(ids: staleIds)
            }

            let missing = StatsCalculator.missingMonths(storedIds: storedIds, now: now)

            guard let firstMissing = missing.first else { return }

            let slots = try await slotRepository.fetchSlots(
                from: DateFormat.date.string(from: firstMissing),
                to: DateFormat.date.string(from: Slot.liveMonthsStartDate(now: now))
            )
            let summaries = StatsCalculator.summariesToArchive(
                slots: slots,
                storedIds: storedIds,
                now: now
            )

            try Task.checkCancellation()
            try summaryRepository.add(summaries)
        } catch {}
    }

    func refreshStats() async {
        while Task.isCancelled == false {
            rebuild()

            try? await Task.sleep(for: .seconds(Self.refreshInterval))
        }
    }

    func showPreviousMonth() {
        guard canGoBack else { return }
        guard let previous = DateFormat.salonCalendar.date(
            byAdding: .month,
            value: -1,
            to: monthStart
        ) else { return }

        monthStart = previous
    }

    func showNextMonth() {
        guard canGoForward else { return }
        guard let next = DateFormat.salonCalendar.date(
            byAdding: .month,
            value: 1,
            to: monthStart
        ) else { return }

        monthStart = next
    }

    private var oldestMonthStart: Date {
        let earliest = Slot.liveMonthsStartDate(now: .now)

        guard let oldestStoredMonth else { return earliest }

        return min(earliest, oldestStoredMonth)
    }

    private func rebuild() {
        let now = Date.now
        let previous = DateFormat.salonCalendar
            .date(byAdding: .month, value: -1, to: monthStart)
            .flatMap { summaries[StatsCalculator.monthId($0)] }

        if monthStart >= Slot.liveMonthsStartDate(now: now) {
            stats = MonthlyStats(
                totals: StatsCalculator.totals(
                    slots: slots,
                    monthStart: monthStart,
                    previous: previous,
                    now: now
                )
            )
        } else if let summary = summaries[StatsCalculator.monthId(monthStart)] {
            stats = MonthlyStats(totals: StatsCalculator.totals(summary: summary, previous: previous))
        } else {
            stats = nil
        }
    }
}
