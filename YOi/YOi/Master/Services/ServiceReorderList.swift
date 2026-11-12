import SwiftUI

private struct ScrollMetrics: Equatable {
    var offsetY: CGFloat = 0
    var minOffsetY: CGFloat = 0
    var maxOffsetY: CGFloat = 0
    var viewportHeight: CGFloat = 0

    init() {}

    init(_ geometry: ScrollGeometry) {
        offsetY = geometry.contentOffset.y
        minOffsetY = -geometry.contentInsets.top
        maxOffsetY = max(
            geometry.contentSize.height + geometry.contentInsets.bottom - geometry.containerSize.height,
            minOffsetY
        )
        viewportHeight = geometry.containerSize.height
    }
}

private struct FingerTrack {
    var startY: CGFloat = 0
    var currentY: CGFloat = 0
    var startOffsetY: CGFloat = 0
}

struct ServiceReorderList: View {
    let services: [Service]
    @Binding var openRowId: String?
    let onBegin: () -> Void
    let onFinish: (Int, Int) -> Void
    let onEdit: (Service) -> Void
    let onToggleActive: (Service) -> Void
    let onDelete: (Service) -> Void

    @State private var rowFrames: [String: CGRect] = [:]
    @State private var drag: RowDrag?
    @State private var raisedId: String?
    @State private var scrollPosition = ScrollPosition()
    @State private var scroll = ScrollMetrics()
    @State private var finger = FingerTrack()
    @State private var scrollTask: Task<Void, Never>?
    @GestureState private var isTouching = false

    private static let stackSpace = "serviceStack"
    private static let viewportSpace = "serviceViewport"

    var body: some View {
        ScrollView {
            VStack(spacing: ServicesMetrics.Spacing.rowSpacing) {
                ForEach(Array(services.enumerated()), id: \.element.id) { index, service in
                    row(service, at: index)
                }
            }
            .coordinateSpace(.named(Self.stackSpace))
            .padding(.horizontal, ServicesMetrics.Spacing.horizontalPadding)
            .padding(.top, ServicesMetrics.Spacing.listTopPadding)
            .padding(.bottom, ServicesMetrics.Spacing.listBottomPadding)
        }
        .coordinateSpace(.named(Self.viewportSpace))
        .scrollPosition($scrollPosition)
        .onScrollGeometryChange(for: ScrollMetrics.self) { geometry in
            ScrollMetrics(geometry)
        } action: { _, metrics in
            scroll = metrics
        }
        .scrollIndicators(.hidden)
        .scrollDisabled(drag != nil)
        .onChange(of: isTouching) {
            if isTouching == false {
                land()
            }
        }
        .onDisappear(perform: cancelDrag)
    }

    private func row(_ service: Service, at index: Int) -> some View {
        let id = service.id ?? ""
        let isLifted = drag?.id == id && drag?.isLifted == true

        return SwipeToDelete(
            id: id,
            openId: $openRowId,
            cornerRadius: ServicesMetrics.Size.rowCornerRadius,
            onDelete: { onDelete(service) }
        ) {
            ServiceRow(
                service: service,
                onToggleActive: { onToggleActive(service) }
            ) {
                handle(id: id, index: index)
            }
            .onTapGesture { onEdit(service) }
        }
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .named(Self.stackSpace))
        } action: { frame in
            rowFrames[id] = frame
        }
        .offset(y: drag?.offset(at: index) ?? 0)
        .scaleEffect(isLifted ? ServicesMetrics.Size.liftScale : 1)
        .zIndex(raisedId == id ? 1 : 0)
    }

    private func handle(id: String, index: Int) -> some View {
        Image(systemName: "line.3.horizontal")
            .font(.elmsSans(.semiBold, ServicesMetrics.Size.handleGlyph))
            .foregroundStyle(Color.textSecondary)
            .frame(
                width: ServicesMetrics.Size.handleWidth,
                height: ServicesMetrics.Size.handleHeight
            )
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named(Self.viewportSpace))
                    .updating($isTouching) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        follow(id: id, index: index, fingerY: value.location.y)
                    }
                    .onEnded { _ in
                        land()
                    }
            )
    }

    private func follow(id: String, index: Int, fingerY: CGFloat) {
        if drag == nil {
            lift(id: id, index: index, fingerY: fingerY)
        }

        guard let drag, drag.id == id, drag.isLanding == false else { return }

        finger.currentY = fingerY
        applyTranslation()
        updateAutoScroll()
    }

    private func lift(id: String, index: Int, fingerY: CGFloat) {
        let frames = services.map { rowFrames[$0.id ?? ""] }
        guard frames.allSatisfy({ $0 != nil }) else { return }

        openRowId = nil
        raisedId = id
        finger = FingerTrack(startY: fingerY, currentY: fingerY, startOffsetY: scroll.offsetY)
        drag = RowDrag(
            id: id,
            source: index,
            frames: frames.compactMap { $0 },
            spacing: ServicesMetrics.Spacing.rowSpacing
        )
        onBegin()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.snappy) {
            drag?.isLifted = true
        }
    }

    private func applyTranslation() {
        guard var updated = drag else { return }

        updated.translation = finger.currentY - finger.startY + scroll.offsetY - finger.startOffsetY
        drag?.translation = updated.translation

        if updated.updateTarget() {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(.snappy) {
                drag = updated
            }
        }
    }

    private func updateAutoScroll() {
        guard autoScrollStep != 0 else {
            stopAutoScroll()
            return
        }
        guard scrollTask == nil else { return }

        scrollTask = Task { @MainActor in
            while Task.isCancelled == false {
                stepAutoScroll()
                try? await Task.sleep(for: .milliseconds(16))
            }
        }
    }

    private func stepAutoScroll() {
        guard drag?.isLanding == false, autoScrollStep != 0 else {
            stopAutoScroll()
            return
        }

        let offsetY = min(max(scroll.offsetY + autoScrollStep, scroll.minOffsetY), scroll.maxOffsetY)
        guard offsetY != scroll.offsetY else { return }

        scrollPosition.scrollTo(y: offsetY)
        scroll.offsetY = offsetY
        applyTranslation()
    }

    private var autoScrollStep: CGFloat {
        AutoScroll.step(
            fingerY: finger.currentY,
            viewportHeight: scroll.viewportHeight,
            zone: ServicesMetrics.Size.autoScrollZone,
            maxStep: ServicesMetrics.Size.autoScrollMaxStep
        )
    }

    private func stopAutoScroll() {
        scrollTask?.cancel()
        scrollTask = nil
    }

    private func cancelDrag() {
        stopAutoScroll()

        if let drag {
            onFinish(drag.source, drag.source)
            self.drag = nil
        }
    }

    private func land() {
        guard let current = drag, current.isLanding == false else { return }

        stopAutoScroll()
        drag?.isLanding = true

        withAnimation(.snappy, completionCriteria: .removed) {
            drag?.translation = current.landingTranslation
            drag?.isLifted = false
        } completion: {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                onFinish(current.source, current.target)
                drag = nil
            }
        }
    }
}
