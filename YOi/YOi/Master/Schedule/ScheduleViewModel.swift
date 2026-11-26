import Foundation
import Observation

@MainActor
@Observable
final class ScheduleViewModel {
    var selectedDate = Date.now

    private(set) var hasLoaded = false
    private(set) var hasFailed = false
    private var slots: [Slot] = []
    private var directory = ClientDirectory(clients: [], isLoaded: false)
    private var services: [Service] = []
    private var templates: [EventTemplate] = []
    private var plans: [PlanEvent] = []
    private var messageTemplate = MessageTemplate()

    private let slotRepository: SlotRepository
    private let clientRepository: ClientRepository
    private let serviceRepository: ServiceRepository
    private let templateRepository: EventTemplateRepository
    private let eventRepository: EventRepository
    private let messageTemplateRepository: MessageTemplateRepository

    var monthTitle: String {
        DateFormat.monthYear.string(from: selectedDate).capitalized
    }

    var areSlotsReady: Bool {
        hasLoaded && hasFailed == false
    }

    private var selectedDayId: String {
        DateFormat.date.string(from: selectedDate)
    }

    init(
        slotRepository: SlotRepository = FirestoreSlotRepository(),
        clientRepository: ClientRepository = FirestoreClientRepository(),
        serviceRepository: ServiceRepository = FirestoreServiceRepository(),
        templateRepository: EventTemplateRepository = FirestoreEventTemplateRepository(),
        eventRepository: EventRepository = FirestoreEventRepository(),
        messageTemplateRepository: MessageTemplateRepository = FirestoreMessageTemplateRepository()
    ) {
        self.slotRepository = slotRepository
        self.clientRepository = clientRepository
        self.serviceRepository = serviceRepository
        self.templateRepository = templateRepository
        self.eventRepository = eventRepository
        self.messageTemplateRepository = messageTemplateRepository
    }

    func items(now: Date, currency: Currency) -> [ScheduleItem] {
        ScheduleDayItems.make(
            day: selectedDayId,
            slots: slots,
            plans: plans,
            clientName: directory.name(for:),
            now: now,
            currency: currency
        )
    }

    func addPlans(_ newPlans: [PlanEvent]) -> AddedNotice? {
        guard newPlans.isEmpty == false else { return nil }

        do {
            try eventRepository.add(newPlans)
            return AddedNotice(kind: .plans, outcome: .saved(dates: newPlans.map(\.date)))
        } catch {
            return AddedNotice(kind: .plans, outcome: .failed)
        }
    }

    func replaceWindows(_ windowIds: [String], with newPlans: [PlanEvent]) -> AddedNotice? {
        let notice = addPlans(newPlans)

        if notice?.isSaved == true {
            deleteWindows(windowIds)
        }

        return notice
    }

    func applyingCuts(_ replacement: WindowReplacement, to notice: AddedNotice?) -> AddedNotice? {
        if notice?.isSaved == true {
            cutPlans(replacement)
        }

        return notice
    }

    func cutPlans(_ replacement: WindowReplacement) {
        for plan in replacement.trimmedPlans {
            updatePlan(plan)
        }

        for id in replacement.deletedPlanIds {
            deletePlan(id: id)
        }
    }

    func updatePlan(_ plan: PlanEvent) {
        try? eventRepository.update(plan)
    }

    func replaceWindows(_ windowIds: [String], moving plan: PlanEvent) {
        guard (try? eventRepository.update(plan)) != nil else { return }

        deleteWindows(windowIds)
    }

    func deletePlan(id: String) {
        try? eventRepository.delete(id: id)
    }

    func observeSlots() async {
        hasFailed = false

        do {
            for try await updatedSlots in slotRepository.observeSlots() {
                slots = updatedSlots
                hasLoaded = true
            }
        } catch {
            slots = []
            hasFailed = true
            hasLoaded = true
        }
    }

    func observePlans() async {
        do {
            for try await updatedPlans in eventRepository.observeEvents() {
                plans = updatedPlans
            }
        } catch {
            plans = []
        }
    }

    func observeTemplates() async {
        do {
            for try await updatedTemplates in templateRepository.observeTemplates() {
                templates = updatedTemplates
            }
        } catch {
            templates = []
        }
    }

    func observeClients() async {
        do {
            for try await clients in clientRepository.observeClients() {
                directory = ClientDirectory(clients: clients, isLoaded: true)
            }
        } catch {
            directory = ClientDirectory(clients: [], isLoaded: false)
        }
    }

    func observeMessageTemplate() async {
        do {
            for try await template in messageTemplateRepository.observe() {
                messageTemplate = template
            }
        } catch {}
    }

    func observeServices() async {
        do {
            for try await updatedServices in serviceRepository.observeServices() {
                services = updatedServices
            }
        } catch {
            services = []
        }
    }

    func select(dayId: String) {
        guard let date = DateFormat.date.date(from: dayId) else { return }

        selectedDate = date
    }

    func firstFreeSlotId(in items: [ScheduleItem]) -> String? {
        for case .slot(let slot) in items where slot.booking == nil && slot.isPast == false {
            return slot.id
        }

        return nil
    }

    func showNearestFreeWindow(now: Date = .now) {
        let nearest = slots
            .filter { $0.clientId == nil && $0.isPast(now: now) == false }
            .min { ($0.date, $0.time) < ($1.date, $1.time) }

        guard let nearest else { return }

        select(dayId: nearest.date)
    }

    func completedOnboardingSteps(now: Date) -> Set<OnboardingStep> {
        let upcoming = slots.filter { $0.isPast(now: now) == false }
        var steps: Set<OnboardingStep> = []

        if services.isEmpty == false {
            steps.insert(.services)
        }

        if directory.clients.isEmpty == false {
            steps.insert(.client)
        }

        if upcoming.isEmpty == false {
            steps.insert(.windows)
        }

        if upcoming.contains(where: \.isBooked) {
            steps.insert(.booking)
        }

        return steps
    }

    func delete(id: String) {
        try? slotRepository.delete(id: id)
    }

    private func deleteWindows(_ ids: [String]) {
        for id in ids {
            delete(id: id)
        }
    }

    func makeFillMonthViewModel(now: Date = .now) -> FillMonthViewModel {
        FillMonthViewModel(
            month: selectedDate,
            existing: slots,
            plans: plans,
            now: now,
            slotRepository: slotRepository
        )
    }

    func makeAddPlanViewModel(currency: Currency, now: Date = .now) -> AddPlanViewModel {
        AddPlanViewModel(
            month: selectedDate,
            templates: templates,
            plannedDays: Set(plans.map(\.date)),
            slots: slots,
            now: now,
            directory: directory,
            currency: currency
        )
    }

    func canQuickAdd(now: Date) -> Bool {
        areSlotsReady && selectedDayId >= DateFormat.date.string(from: Slot.liveMonthsStartDate(now: now))
    }

    func makeQuickBookViewModel(now: Date = .now) -> QuickBookViewModel {
        QuickBookViewModel(
            day: selectedDate,
            slots: slots,
            plans: plans,
            clients: directory.clients,
            services: services,
            now: now,
            slotRepository: slotRepository,
            clientRepository: clientRepository,
            serviceRepository: serviceRepository
        )
    }

    func makeQuickAddPlanViewModel(currency: Currency, now: Date = .now) -> AddPlanViewModel? {
        guard selectedDayId >= DateFormat.date.string(from: now) else { return nil }

        return AddPlanViewModel(
            day: selectedDate,
            templates: templates,
            plannedDays: Set(plans.map(\.date)),
            slots: slots,
            now: now,
            directory: directory,
            currency: currency
        )
    }

    func makeBookClientViewModel(slotId: String) -> BookClientViewModel? {
        guard let slot = slots.first(where: { $0.id == slotId }), slot.isBooked == false else { return nil }

        return BookClientViewModel(
            slot: slot,
            clients: directory.clients,
            services: services,
            slotRepository: slotRepository,
            clientRepository: clientRepository,
            serviceRepository: serviceRepository
        )
    }

    func makeBookingActionsViewModel(slotId: String, now: Date = .now) -> BookingActionsViewModel? {
        guard
            directory.isLoaded,
            let slot = slots.first(where: { $0.id == slotId }),
            let clientId = slot.clientId
        else { return nil }

        return BookingActionsViewModel(
            slot: slot,
            client: directory.client(for: clientId),
            services: services,
            slots: slots,
            plans: plans,
            now: now,
            slotRepository: slotRepository,
            serviceRepository: serviceRepository
        )
    }

    func makePlanActionsViewModel(
        planId: String,
        currency: Currency,
        now: Date = .now
    ) -> PlanActionsViewModel? {
        guard let plan = plans.first(where: { $0.id == planId }) else { return nil }

        return PlanActionsViewModel(
            plan: plan,
            templates: templates,
            plannedDays: Set(plans.map(\.date)),
            slots: slots,
            now: now,
            directory: directory,
            currency: currency
        )
    }

    func makeClientCardViewModel(clientId: String) -> ClientCardViewModel {
        ClientCardViewModel(
            clientId: clientId,
            takenHandles: directory.clients.takenHandles,
            clientRepository: clientRepository,
            slotRepository: slotRepository
        )
    }

    func makeSendScheduleViewModel(now: Date = .now) -> SendScheduleViewModel {
        SendScheduleViewModel(
            slots: slots,
            clients: directory.clients,
            now: now,
            template: messageTemplate,
            repository: messageTemplateRepository
        )
    }

    func makeJumpToDateViewModel(now: Date = .now) -> JumpToDateViewModel {
        JumpToDateViewModel(
            selectedDate: selectedDate,
            datesWithSlots: Set(slots.map(\.date)),
            now: now
        )
    }
}
