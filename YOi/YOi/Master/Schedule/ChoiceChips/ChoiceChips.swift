import SwiftUI

struct ChoiceChipsAdd {
    let titleKey: LocalizedStringKey
    let action: () -> Void
}

struct ChoiceChipsReorder {
    let move: (String, String) -> Void
    let commit: () -> Void
}

struct ChoiceChips: View {
    let chips: [ChoiceChip]
    let onToggle: (String) -> Void
    var add: ChoiceChipsAdd?
    var reorder: ChoiceChipsReorder?

    @State private var frames: [String: CGRect] = [:]
    @State private var drag: ChipDrag?
    @State private var gridSize: CGSize = .zero
    @GestureState private var isTouching = false

    private static let space = "choiceChips"

    var body: some View {
        ChoiceChipsLayout(spacing: ScheduleMetrics.Spacing.chipSpacing) {
            ForEach(chips) { chip in
                if reorder == nil {
                    Button {
                        onToggle(chip.id)
                    } label: {
                        label(for: chip)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(chip.isSelected ? .isSelected : [])
                } else {
                    movableChip(chip)
                }
            }

            if let add {
                Button(action: add.action) {
                    Label(add.titleKey, systemImage: "plus")
                        .choiceChipLabel()
                        .foregroundStyle(Color.textSecondary)
                        .overlay {
                            Capsule()
                                .strokeBorder(
                                    Color.stroke,
                                    style: StrokeStyle(
                                        lineWidth: ScheduleMetrics.Size.rowBorderWidth,
                                        dash: ScheduleMetrics.Size.rowDash
                                    )
                                )
                        }
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .layoutValue(key: ChoiceChipTrailing.self, value: true)
            }
        }
        .coordinateSpace(.named(Self.space))
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            gridSize = size
        }
        .glassEffectGroup()
        .overlay(alignment: .topLeading) {
            floatingChip
        }
        .onChange(of: isTouching) {
            if isTouching == false {
                land()
            }
        }
    }

    private func label(for chip: ChoiceChip) -> some View {
        Text(verbatim: chip.title)
            .choiceChipLabel()
            .foregroundStyle(chip.isSelected ? Color.onPrimary : Color.ink)
            .selectableSurface(isSelected: chip.isSelected, in: .capsule)
            .contentShape(.capsule)
    }

    private func movableChip(_ chip: ChoiceChip) -> some View {
        ZStack {
            if drag?.id == chip.id {
                Text(verbatim: chip.title)
                    .choiceChipLabel()
                    .hidden()
            } else {
                label(for: chip)
            }
        }
        .contentShape(.capsule)
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .named(Self.space))
        } action: { frame in
            frames[chip.id] = frame
        }
        .onTapGesture { onToggle(chip.id) }
        .gesture(moveGesture(for: chip))
    }

    @ViewBuilder
    private var floatingChip: some View {
        if let drag, let chip = chips.first(where: { $0.id == drag.id }) {
            label(for: chip)
                .frame(width: drag.size.width, height: drag.size.height)
                .scaleEffect(drag.isLifted ? ScheduleMetrics.Size.chipLiftScale : 1)
                .offset(x: drag.origin.x, y: drag.origin.y)
                .allowsHitTesting(false)
        }
    }

    private func moveGesture(for chip: ChoiceChip) -> some Gesture {
        LongPressGesture(minimumDuration: ScheduleMetrics.Size.chipLongPress)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .named(Self.space)))
            .updating($isTouching) { _, state, _ in
                state = true
            }
            .onChanged { value in
                guard case .second(true, let dragValue) = value else { return }

                lift(chip)

                if let dragValue {
                    follow(chip, to: dragValue.location)
                }
            }
            .onEnded { _ in
                land()
            }
    }

    private func lift(_ chip: ChoiceChip) {
        guard drag == nil, chip.isMovable, let frame = frames[chip.id] else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        drag = ChipDrag(id: chip.id, size: frame.size, origin: frame.origin)
        withAnimation(.snappy) {
            drag?.isLifted = true
        }
    }

    private func follow(_ chip: ChoiceChip, to location: CGPoint) {
        guard
            var updated = drag,
            updated.id == chip.id,
            updated.isLanding == false,
            let frame = frames[updated.id]
        else { return }

        updated.follow(to: location, frame: frame, bounds: gridSize)
        let target = updated.swapTarget(at: location, in: swapFrames(excluding: updated.id))
        drag = updated

        guard let target else { return }

        UISelectionFeedbackGenerator().selectionChanged()
        withAnimation(.snappy) {
            reorder?.move(updated.id, target)
        }
    }

    private func swapFrames(excluding id: String) -> [String: CGRect] {
        let movableIds = Set(chips.filter { $0.isMovable && $0.id != id }.map(\.id))

        return frames.filter { movableIds.contains($0.key) }
    }

    private func land() {
        guard let current = drag, current.isLanding == false else { return }
        guard let target = frames[current.id] else {
            drag = nil
            return
        }

        drag?.isLanding = true

        withAnimation(.snappy, completionCriteria: .removed) {
            drag?.origin = target.origin
            drag?.isLifted = false
        } completion: {
            drag = nil

            if current.didMove {
                reorder?.commit()
            }
        }
    }
}

#if DEBUG
#Preview {
    ChoiceChips(
        chips: SchedulePreviewData.serviceChips,
        onToggle: { _ in },
        add: ChoiceChipsAdd(titleKey: "schedule.book.newService", action: {})
    )
        .padding()
        .background(Color.card)
}
#endif
