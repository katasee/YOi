import SwiftUI

private enum SchedulePopup: Identifiable {
    case fillMonth(FillMonthViewModel, AddPlanViewModel)
    case jumpToDate(JumpToDateViewModel)
    case sendSchedule(SendScheduleViewModel)
    case bookClient(BookClientViewModel)
    case bookingActions(BookingActionsViewModel)
    case planActions(PlanActionsViewModel)
    case quickAdd(QuickBookViewModel, AddPlanViewModel)

    var id: ObjectIdentifier {
        switch self {
        case .fillMonth(let viewModel, _): viewModel.id
        case .jumpToDate(let viewModel): viewModel.id
        case .sendSchedule(let viewModel): viewModel.id
        case .bookClient(let viewModel): viewModel.id
        case .bookingActions(let viewModel): viewModel.id
        case .planActions(let viewModel): viewModel.id
        case .quickAdd(let viewModel, _): viewModel.id
        }
    }
}

struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel
    @State private var openRowId: String?
    @State private var popup: SchedulePopup?
    @State private var pendingCardClientId: String?
    @State private var pendingDayId: String?
    @State private var pendingNotice: AddedNotice?
    @State private var toast: ToastMessage?
    @State private var openCardClientId: String?
    @State private var pendingDelete: SlotItem?
    @State private var isConfirmingDelete = false

    init(viewModel: ScheduleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                LargeTitleHeader(titleKey: "schedule.title") {
                    RoundIconButton(
                        systemImage: "paperplane",
                        accessibilityLabel: "schedule.action.sendSchedule",
                        action: openSendSchedule
                    )
                    .disabled(viewModel.areSlotsReady == false)

                    RoundIconButton(
                        systemImage: "plus",
                        accessibilityLabel: "schedule.action.addSlots",
                        action: openFillMonth
                    )
                    .disabled(viewModel.areSlotsReady == false)
                }

                ScheduleMonthButton(title: viewModel.monthTitle, action: openJumpToDate)

                WeekDayStrip(selectedDate: $viewModel.selectedDate)
                    .padding(.vertical, ScheduleMetrics.Spacing.stripVerticalPadding)

                TimelineView(.everyMinute) { context in
                    content(
                        viewModel.items(now: context.date),
                        canQuickAdd: viewModel.canQuickAdd(now: context.date)
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .toast($toast)
            .weekSwipe(selectedDate: $viewModel.selectedDate)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $openCardClientId) { clientId in
                ClientCardView(viewModel: viewModel.makeClientCardViewModel(clientId: clientId))
            }
            .simultaneousGesture(TapGesture().onEnded(closeOpenRow))
            .task {
                await viewModel.observeSlots()
            }
            .task {
                await viewModel.observeClients()
            }
            .task {
                await viewModel.observeServices()
            }
            .task {
                await viewModel.observePlans()
            }
            .task {
                await viewModel.observeTemplates()
            }
            .onChange(of: viewModel.selectedDate, closeOpenRow)
            .fullScreenCover(item: $popup, onDismiss: applyPending) { popup in
                popupView(popup)
                    .presentationBackground(.clear)
            }
            .alert(
                "schedule.delete.booked.title",
                isPresented: $isConfirmingDelete,
                presenting: pendingDelete
            ) { item in
                Button("schedule.delete.booked.action", role: .destructive) {
                    delete(item)
                }

                Button("common.action.cancel", role: .cancel) {}
            } message: { item in
                Text("schedule.delete.booked.message \(item.booking?.clientName ?? "")")
            }
        }
    }

    @ViewBuilder
    private func popupView(_ popup: SchedulePopup) -> some View {
        switch popup {
        case .fillMonth(let fillMonth, let addPlan):
            FillMonthPopup(
                viewModel: fillMonth,
                addPlan: addPlan,
                onAddPlans: viewModel.addPlans,
                onAdded: { pendingNotice = $0 },
                onDismiss: closePopup
            )
        case .jumpToDate(let jumpToDate):
            JumpToDatePopup(
                viewModel: jumpToDate,
                onPick: viewModel.select(dayId:),
                onDismiss: closePopup
            )
        case .sendSchedule(let sendSchedule):
            SendSchedulePopup(viewModel: sendSchedule, onDismiss: closePopup)
        case .bookClient(let bookClient):
            BookClientPopup(viewModel: bookClient, onDismiss: closePopup)
        case .bookingActions(let bookingActions):
            BookingActionsPopup(
                viewModel: bookingActions,
                onOpenCard: { pendingCardClientId = $0 },
                onRescheduled: { pendingDayId = $0 },
                onDismiss: closePopup
            )
        case .planActions(let planActions):
            PlanActionsPopup(
                viewModel: planActions,
                onUpdate: { plan in
                    viewModel.updatePlan(plan)
                    pendingDayId = plan.date
                },
                onDelete: viewModel.deletePlan(id:),
                onDismiss: closePopup
            )
        case .quickAdd(let book, let addPlan):
            QuickAddPopup(
                book: book,
                addPlan: addPlan,
                onAddPlans: viewModel.addPlans,
                onAdded: { pendingNotice = $0 },
                onDismiss: closePopup
            )
        }
    }

    private func content(_ items: [ScheduleItem], canQuickAdd: Bool) -> some View {
        ZStack {
            if items.isEmpty == false {
                list(items, canQuickAdd: canQuickAdd)
            }

            if items.isEmpty && canQuickAdd {
                VStack(spacing: ScheduleMetrics.Spacing.quickAddSpacing) {
                    statusOverlay(isEmpty: true)
                        .fixedSize(horizontal: false, vertical: true)

                    QuickAddDayButton(action: openQuickAdd)
                }
                .padding(.horizontal, ScheduleMetrics.Spacing.horizontalPadding)
            } else {
                statusOverlay(isEmpty: items.isEmpty)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func statusOverlay(isEmpty: Bool) -> some View {
        ListStatusOverlay(
            hasLoaded: viewModel.hasLoaded,
            isEmpty: isEmpty,
            titleKey: emptyTitleKey,
            messageKey: emptyMessageKey
        )
    }

    private var emptyTitleKey: LocalizedStringKey {
        viewModel.hasFailed ? "schedule.loadFailed.title" : "schedule.empty.title"
    }

    private var emptyMessageKey: LocalizedStringKey {
        viewModel.hasFailed ? "schedule.loadFailed.message" : "schedule.empty.message"
    }

    private func list(_ items: [ScheduleItem], canQuickAdd: Bool) -> some View {
        ScrollView {
            LazyVStack(spacing: ScheduleMetrics.Spacing.rowSpacing) {
                ForEach(items) { item in
                    switch item {
                    case .slot(let slot):
                        slotRow(slot)
                    case .plan(let plan):
                        planRow(plan)
                    }
                }

                if canQuickAdd {
                    QuickAddDayButton(action: openQuickAdd)
                        .padding(.top, ScheduleMetrics.Spacing.quickAddTopPadding)
                }
            }
            .padding(.horizontal, ScheduleMetrics.Spacing.horizontalPadding)
            .padding(.top, ScheduleMetrics.Spacing.listTopPadding)
            .padding(.bottom, ScheduleMetrics.Spacing.contentBottomPadding)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
    }

    private func slotRow(_ item: SlotItem) -> some View {
        SwipeToDelete(
            id: item.id,
            openId: $openRowId,
            cornerRadius: ScheduleMetrics.Size.rowCornerRadius,
            onDelete: { requestDelete(item) }
        ) {
            ScheduleSlotRow(
                item: item,
                onBook: { openBookClient(item) },
                onOpenActions: { openBookingActions(item) }
            )
            .accessibilityAction(named: Text("schedule.action.deleteSlot")) {
                requestDelete(item)
            }
        }
    }

    private func planRow(_ item: PlanItem) -> some View {
        SwipeToDelete(
            id: item.id,
            openId: $openRowId,
            cornerRadius: ScheduleMetrics.Size.rowCornerRadius,
            onDelete: { deletePlan(item) }
        ) {
            SchedulePlanRow(item: item, onOpenActions: { openPlanActions(item) })
                .accessibilityAction(named: Text("schedule.action.deletePlan")) {
                    deletePlan(item)
                }
        }
    }

    private func closeOpenRow() {
        openRowId = nil
    }

    private func openFillMonth() {
        open(.fillMonth(viewModel.makeFillMonthViewModel(), viewModel.makeAddPlanViewModel()))
    }

    private func openQuickAdd() {
        open(.quickAdd(viewModel.makeQuickBookViewModel(), viewModel.makeQuickAddPlanViewModel()))
    }

    private func openSendSchedule() {
        open(.sendSchedule(viewModel.makeSendScheduleViewModel()))
    }

    private func openJumpToDate() {
        open(.jumpToDate(viewModel.makeJumpToDateViewModel()))
    }

    private func openBookClient(_ item: SlotItem) {
        open(viewModel.makeBookClientViewModel(slotId: item.id).map(SchedulePopup.bookClient))
    }

    private func openBookingActions(_ item: SlotItem) {
        open(viewModel.makeBookingActionsViewModel(slotId: item.id).map(SchedulePopup.bookingActions))
    }

    private func openPlanActions(_ item: PlanItem) {
        open(viewModel.makePlanActionsViewModel(planId: item.id).map(SchedulePopup.planActions))
    }

    private func open(_ popup: SchedulePopup?) {
        withoutPresentationAnimation {
            self.popup = popup
        }
    }

    private func closePopup() {
        withoutPresentationAnimation {
            popup = nil
        }
    }

    private func applyPending() {
        if let pendingDayId {
            viewModel.select(dayId: pendingDayId)
            self.pendingDayId = nil
        }

        if let pendingCardClientId {
            openCardClientId = pendingCardClientId
            self.pendingCardClientId = nil
        }

        if let pendingNotice {
            if let dayId = pendingNotice.dayId {
                viewModel.select(dayId: dayId)
            }

            toast = pendingNotice.toast
            self.pendingNotice = nil
        }
    }

    private func requestDelete(_ item: SlotItem) {
        guard item.booking != nil else {
            delete(item)
            return
        }

        pendingDelete = item
        isConfirmingDelete = true
    }

    private func delete(_ item: SlotItem) {
        viewModel.delete(id: item.id)
    }

    private func deletePlan(_ item: PlanItem) {
        viewModel.deletePlan(id: item.id)
    }
}
