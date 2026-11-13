# Architecture

**MVVM + Repository pattern, dependency injection via initializers — no singletons of our own.**

- ViewModels use the **`@Observable` macro** (Swift Observation, iOS 17+), not the older
  `ObservableObject`/`@Published` pair — plain `var` properties, no `@Published`. Views hold them
  with `@State private var viewModel = SomeViewModel()`, not `@StateObject`. Deployment target is
  iOS 18.1 so this is available everywhere; don't reach for `ObservableObject` out of habit.
- Views/ViewModels are organized **by feature, not by layer** — e.g. `YOi/YOi/Auth/` holds
  `AuthView.swift` and `AuthViewModel.swift` together, rather than spreading them across generic
  top-level `Views/`/`ViewModels` folders. A model only lives inside a feature folder if it's
  genuinely private to that feature; anything referenced from more than one feature belongs in
  `YOi/YOi/Models/` instead — that's where `Service` and `Slot` live, since each is read
  by more than one feature (`Service` by Мої послуги and, from M-34, booking; `Slot` by Розклад
  now and Заповнити місяць, booking and Статистика), not just by the screen that created
  it — `Client` (Клієнтки now, the booking flow in M-34), and `UserProfile`, the account model `Root/`
  reads. `Models/` is the
  **domain layer** — the M of MVVM — not "files that contain a struct": it also holds derived properties of
  domain types (`Slot/Slot+StartDate.swift`, `Slot/Slot+Past.swift`) and domain
  configuration with no fields at all (`WorkHours.swift`: the Заповнити місяць hour chips, the
  "Свій час" wheel range and minute step, and a new plan's default start and length). **A domain rule that two features must
  agree on lives here too, even when it is one line.** `Block+Completed.swift`
  (`isCompleted(now:)` — `confirmed` and already ended; `Block` was deleted in M-38) was read by
  both the master's `StatsCalculator` and the client's `AccountStats` (the client cabinet, removed
  in M-30 — the extraction rule stands); it started as a private helper inside the
  former and was extracted the moment the latter needed the same answer. Two copies that happen to
  agree today is not the same thing as one predicate that cannot disagree — and the design doc for
  the second consumer had in fact already drifted to a different definition before the extraction
  caught it. The rule for extensions is **an extension
  of our type lives beside the type; an extension of a foreign type lives where it's used** — which
  is why `View+Shadow.swift` and `Extension+ElmsSans.swift` sit in `Assets/UICommons/` next to the
  components that consume them, and not in some `Extensions/` folder. A folder grouping files by
  the `extension` keyword would organize by language construct, exactly the layer-first mistake this
  section rejects. One exception: an extension of a **domain** type that only adds **presentation**
  (a title key, an SF Symbol) for a single view is a `private extension` in that view's file —
  `Models/` stays free of UI, and `private` keeps every other screen from depending on them. Once a
  second screen needs the same look, promote it to a presentation model (`ClientItem`-style), not
  to an `internal` extension — `ClientContact`'s title keys and icons started as a private
  extension in `ClientContactMenu.swift` and became `ClientContactItem` (`Master/Clients/`) when
  the "Надіслати графік" contacts step needed them (M-35.1). A feature view another feature
  reuses stays in its own feature folder, as `ClientContactMenu` and `ClientNoContactsPlate` do
  for Розклад; it moves to `Assets/UICommons/` only once it no longer depends on that feature's
  types (`ClientsMetrics`, keys). A type gets its own subfolder (`Models/Slot/`) once it spans more than one file;
  single-file types stay flat. **A type that exists only to serve one neighbour lives in that
  neighbour's file, not in its own** — `StatsRoute` sits with `StatsLinkRow`, `MonthlyTotals`
  with `StatsCalculator`. Order inside such a file is supporting type first, the file's namesake second. This is not a licence to pile unrelated
  types together: the test is whether the type would ever be referenced without its host, and a
  three-line enum that only feeds one `navigationDestination` would not. A feature also owns
  **presentation models** — `MonthlyStats`, `SlotItem`, `ClientItem` — built from a persistence
  model and never written back. They carry ready-made
  display strings so views never touch `DateFormat` or a raw stored value, and they keep persistence
  fields the screen has no business with (`status`, `clientId`) out of reach of the view.
  **The arithmetic that feeds a presentation model does not format it.** A pure calculator
  (`StatsCalculator`) returns numbers — `MonthlyTotals` is `Int`s — and the presentation model's
  `init(totals:)` does every `ServiceFormat.price`, `.formatted()` and percent string. Mixing the
  two has a concrete cost, not just a stylistic one: with no test target the only way to check a
  figure is a temporary text `#Preview`, and comparing *formatted* output makes that check depend on
  the device locale. Rules about what to *show* (hide the comparison when the previous month was
  zero) belong on the presentation side too — that is a display decision, not a sum. The same
  principle applies
  to reusable *views*: a component used (or reusable) across more than one feature lives in
  `YOi/YOi/Assets/UICommons/` (e.g. `WeekDayStrip`, `TimeWheel`, `View+BrandShadow`, the
  `ElmsSans` font extension), not in a feature folder, and must not depend on any feature's types
  (e.g. a feature's `*Metrics`) — give it its own private constants or take them as parameters.
  Those constants are a `private enum Layout` **nested inside the component's struct** — the
  pattern of every non-generic component there (`CapsuleButton`, `WeekDayStrip`,
  `LargeTitleHeader`, …). It moves to file scope as `private enum <Name>Layout` only when nesting
  is impossible: a generic type (below) or a bare `View` extension with no struct to nest in
  (`View+InputField`). `PopupContainerLayout` is file-scope *and* internal because callers reuse
  its `fade`.
  **When several cards repeat themselves, extract the chrome, not the card.** Cards that differ in
  structure — centred vs leading, a row with a chevron, one of them a `NavigationLink` — stay
  separate views; folding them into one configurable card trades short honest files for a chain of
  `if`s behind a growing set of flags. What is genuinely shared is the surface: padding, fill,
  corner radius, shadow. That lives in `.cardSurface(fill:padding:cornerRadius:fillsHeight:)`, and
  the repeated glyph tile in `IconBadge` (wine glyph on `WineSoft`; see the wine accent in
  `code-style.md`). Note `fillsHeight`: the frame that equalizes heights in
  a `GridRow` must sit *between* the padding and the background, which a caller cannot reproduce
  from outside, so the modifier branches internally instead of exposing the order.
  A feature folder holds only that feature's View, view model, feature-private model, subviews, and
  a feature-local metrics file (e.g. `Schedule/ScheduleMetrics.swift`, `Stats/StatsMetrics.swift`).
  A metrics file holds **layout** numbers only — anything the view model needs to reason about
  (salon working hours, tolerances, durations) is domain config and lives in `Models/`
  (e.g. `Models/WorkHours.swift`), otherwise the view model ends up importing the
  view layer.
  A generic UICommons component (e.g. `SwipeToDelete<Content>`) must keep its constants enum at
  **file scope**, not nested inside the struct — Swift forbids static stored properties in types
  nested within generic types, and moving them "tidily" inside breaks the build.
- Screen-covering popups are presented by the feature that owns them, via `.fullScreenCover` +
  `.presentationBackground(.clear)` — **not** by hoisting state into `MasterRootView`
  so a shared `ZStack` can draw them above the tab bar. Presentation modifiers
  render outside the view hierarchy, so the tab bar stops being a reason to leak feature types into
  the router. To keep a custom fade instead of the system slide-up, wrap the *state mutation* in a
  `Transaction` with `disablesAnimations = true` and animate inside the popup; never put
  `.transaction { }` on the modifier, which disables animations for the whole subtree.
  A tap on the backdrop does nothing (Y-62, user decision): `PopupContainer`'s backdrop is a plain
  shape, so a popup closes only through its own Cancel / Close / Done button, and every step of a
  popup must offer one.
  A screen with several popups holds **one** optional enum (`SchedulePopup` in `ScheduleView`,
  M-36.0: a case per popup carrying its view model, `id` from that view model) and one
  `fullScreenCover` with a `switch`, not a `@State` and a cover per popup. The cover's `onDismiss`
  then runs for every popup, so anything it does must check its own pending state first.
  A confirmation after a popup's action is a **toast**, `.toast(_:)` (`Assets/UICommons/View+Toast.swift`,
  Y-54): a `ToastMessage` (text + `.success`/`.failure`, whose style also picks the haptic) shown
  at the top of the screen for 2 s, touches passing through. The popup only reports what happened
  (`AddedNotice` in Розклад, built by the view model that did the write, never by the view); the
  screen parks it in a pending state and shows the toast from `onDismiss`, so it appears over the
  screen once the popup is gone. A failed write shows a failure toast — never a success one.
- **The routers are a system `TabView`** (`Tab(_:systemImage:value:)` over `MasterTab`),
  which renders Liquid Glass on iOS 26 and the standard bar on 18 from the same code, with no
  `#available`. It owns the bottom safe area, including inside a screen's own `NavigationStack`, so
  screens take no clearance parameter. The inset stops scroll content *at* the bar's top edge, not
  above it, so every scrolling tab screen ends its content with its own bottom padding from its
  metrics file (`contentBottomPadding`/`listBottomPadding`, 24pt) — without it the last row sits
  flush against the glass (found on a device: the old client Account screen's "Видалити акаунт"). Two consequences of
  the system bar: **tabs keep their state across switches**, so a flow that hands off to another tab
  must reset its own navigation path first (the client booking flow, removed in M-30, cleared its
  `path` in `finishBooking()` before switching to "Мої записи"); and **a tab's `.task`s run
  only while it is on screen** — they don't start for a tab never opened and are cancelled when the
  user switches away — so a subscription that feeds a tab badge starts in the router, not in the
  tab's screen (the Requests badge did this until the tab was removed in M-30). The selected-tab colour is `.tint(Color.ink)` on the `TabView`,
  with each tab's content re-tinted `.tint(Color.accentColor)` so it doesn't leak into carets and
  pickers (see "Accent and tab bar" in `code-style.md`).
- **A pushed screen shows the system navigation bar; only a tab's root hides it** (Y-42). Hiding
  the bar with `.toolbar(.hidden, for: .navigationBar)` also disables the edge swipe back — iOS
  turns the interactive pop gesture off together with the bar — which is why Клієнтська картка,
  Мої послуги, Мої плани and Профіль had none while they drew their own `ScreenHeader` (deleted in
  Y-42). A pushed screen uses `.navigationBarTitleDisplayMode(.inline)`, `.toolbarRole(.editor)`
  (a chevron-only back button: the roots have no title, so iOS would print "Back") and puts its
  actions in `ToolbarItem(placement: .topBarTrailing)` as a plain `Button(_:systemImage:action:)`
  — iOS 26 draws it as glass, a `RoundIconButton` there would add a second surface. A title is a
  `.principal` `Text` in `.elmsSans`, not `.navigationTitle`, which only takes the system font;
  no `UINavigationBar.appearance()`. On iOS 18 the back button is a flat accent chevron — accepted
  (user, Y-42) for the swipe and less code. The rejected alternative, a `UINavigationController`
  extension that re-enables the gesture with the bar hidden, is a hack over system behaviour.
- **Nested `NavigationLink`s don't work.** Wrapping a whole card in a link and then putting a link
  inside it is unpredictable in SwiftUI — the inner one may never receive taps, or both fire. If a
  card needs more than one destination, don't wrap the card: give each control its own link
  (the client `ServiceOfferCard`, removed in M-30, did this — each hour chip pushed that slot, the
  round chevron pushed the whole offer). Accept that the card body then stops being tappable, and give any icon-only control
  an `accessibilityLabel`, since it is otherwise silent to VoiceOver.
  The same holds for **any control inside any other** — a `Menu` or `Button` inside a
  `NavigationLink` row: put them side by side in an `HStack` and let one `.cardSurface` cover both
  (`ClientRow`: the link wraps avatar and name, the contact `Menu` sits beside it).
- **A `Menu` label cannot be a `Button`.** `Menu` is itself the button; a `Button` inside its
  label fights it for the tap. When a menu must look like one of our buttons, draw the button's
  *look* without the `Button`: `RoundIconLabel` is `RoundIconButton`'s look, extracted in M-32.2b
  so the row's contact menu and every round button share one drawing. `CapsuleButton`'s look was
  not extracted (it is tangled with loading/disabled states and three roles); the client card's
  "Зв'язатися" menu label is drawn privately as a `.cardSurface` row (M-32.5, user decision: it
  matches the list rows instead of the primary capsule) — extract it when a second one appears.
  `BookingActionLabel` (M-34.2) follows the same rule: one row look, used as a `Button` label for
  three actions and as the `ClientContactMenu` label for "Написати".
- **A row inside `SwipeToDelete` is tapped with `.onTapGesture`, not a `Button`** (found on a
  device in M-34.2). A `Button` fires on release whenever the finger is still over it, however
  far it moved — and a swiped row moves with the finger, so every swipe also "tapped" the row and
  opened its popup. A tap gesture fails as soon as the finger moves (`ScheduleSlotRow`,
  `SchedulePlanRow`, Мої послуги's `ServiceRow`). Older rows also carry
  `.accessibilityAddTraits(.isButton)`; new code adds no VoiceOver traits or hints (user, M-37.5).
- **Reordering moves our own views, never the system drag** (Y-60, rejected on the simulator).
  `List` + `.onMove` and `.onDrag` + `DropDelegate` move a system *snapshot*: a grey rectangle
  around the card, clipped shadows, a flash when the real row returns, and on iOS 18 `.onDrag`
  has no "drag ended" event, so a drop outside a target left the row transparent. Instead
  "Мої послуги" (`ServiceReorderList`) drags a row by its handle ☰ with
  `DragGesture(minimumDistance: 0)` — a dedicated area, so it starts on touch and never fights the
  scroll — and the service chips (`ChoiceChips` with a `ChoiceChipsReorder`) drag after a 0.3 s
  long press, drawing a floating copy over the grid and an empty slot in it. The geometry lives in
  pure value types (`RowDrag`, `ChipDrag`, `AutoScroll`), checked with `swiftc` scripts. Rules
  found on the way:
  - **Measure every row**: a plain `VStack`, not `LazyVStack` — a lazy stack leaves off-screen
    rows unmeasured, and the target jumped to the end.
  - **Track the finger in a space that does not move with it** (the stack's or the viewport's),
    never the handle's own: the handle rides with the row and the row shook.
  - **End a drag both ways**: `.onEnded` for the normal release and a `@GestureState` reset
    (`onChange`) for a cancelled gesture, which never calls `onEnded`; `land()` runs once. With
    only the `@GestureState`, a tap shorter than a frame toggled it twice in one frame and the
    `onChange` was skipped.
  - **A long press lifts on `.second`, not `.first(true)`**: in `LongPressGesture.sequenced`,
    `.first(true)` means "touch is down", so every tap lifted the chip.
  - **The tap goes before the move gesture**: of two gestures on one view the first attached gets
    the touch; with the long press first, `.onTapGesture` never fired.
  - **While landing, ignore every other touch** (`isLanding`, owner check), or a second handle or
    chip grabs the item still animating into place.
  - **Inside a `GlassEffectContainer`, `.opacity(0)` hides the text, not the glass** — the empty
    slot draws the label `.hidden()` without its surface.
  - **Reorder the array only after the landing animation has fully finished**
    (`completionCriteria: .removed`, then a `disablesAnimations` transaction), and keep the last
    dragged row's `zIndex(1)` until the next drag — `zIndex` cannot animate, and its shadow
    flashed under the neighbour.
  - A Firestore snapshot that arrives mid-drag is deferred until the drop
    (`MyServicesViewModel.beginReorder()` / `finishReorder(from:to:)`).
  `ServiceReorderList` draws `SwipeToDelete` + `ServiceRow` itself (a gesture-carrying handle
  cannot be handed to a caller's row closure without `AnyView`); it moves to `UICommons` and
  becomes generic when "Мої плани" gets the same drag.
- **A row's swipe is a UIKit pan that begins only on a horizontal velocity** (Y-56, found on the
  simulator). `SwipeToDelete` once used `.simultaneousGesture(DragGesture(minimumDistance: 12))`:
  a SwiftUI drag claims the touch after 12pt in *any* direction — a direction `guard` in
  `onChanged` only stops the offset — so a vertical drag that started on a row never scrolled the
  list. Its private `HorizontalPan` (`UIGestureRecognizerRepresentable`) answers `false` from
  `gestureRecognizerShouldBegin` when the vertical velocity wins, the recognizer fails, and the
  `ScrollView` takes the touch. `List` + `.swipeActions` was rejected: it restyles both lists and
  makes the trash a system one.
- **A screen-wide swipe is `.gesture` on the screen, and its list scrolls only when it overflows**
  (M-39, found on the simulator). Розклад's `.weekSwipe` sits on the root stack with `.gesture`,
  not `.simultaneousGesture`: a descendant's gesture wins, so a row's `SwipeToDelete` pan keeps
  the swipe to itself (rechecked in Y-56, when that pan became UIKit). A `ScrollView` inside
  still takes most slightly diagonal drags first; the day list carries `.scrollBounceBehavior(.basedOnSize)`, so a day whose rows fit never starts a
  pan and the swipe always lands. Don't remove the `ScrollView` instead — a full day does not fit.
- **A scroll position that depends on a measured size is set after the measurement, by command**
  (found on the simulator, M-36.1 fix). `RescheduleDayScroller` centres a day with side margins
  computed from its width; an initial id given to `scrollPosition(id:)` before
  `onGeometryChange` reported the width was applied with zero margins and clamped, and the bound
  state then disagreed with the screen. Hold a `ScrollPosition`, call `scrollTo(id:anchor:)` the
  first time the width is known, and scroll on a tap with `scrollTo` too — assigning a bound id
  that already equals the state is no change and scrolls nothing. Read the centred item back with
  `viewID(type:)`.
- **Haptics fire imperatively on the tap, not through `.sensoryFeedback`** (found on a device in
  M-35.2). The modifier prepares a feedback generator when its view *appears*, and the first one
  per launch connects to the system haptics service on the main thread — the "Надіслати графік"
  popup stalled visibly on its first open. `SendScheduleTextStep` calls
  `UINotificationFeedbackGenerator().notificationOccurred(.success)` inside the button action
  instead; the one-time cost moved to the first tap and was not noticeable there.
- **A screen can push another feature's screen; it does so by id, after its popup is gone.**
  Розклад has its own `NavigationStack` (M-34.2) and pushes Клієнтки's `ClientCardView` with
  `navigationDestination(item:)` over a plain `String` id — not `ClientRoute`, which stays private
  to Клієнтки's stack. The push comes from "Картка клієнтки" inside a `fullScreenCover`, and
  navigating while a cover is still dismissing can be dropped, so the tap only stores
  `pendingCardClientId` and the cover's `onDismiss` moves it into `openCardClientId`.
- **Input masking uses `.onChange`, never `Binding(get:set:)`.** The obvious way to cap or reformat
  what a `TextField` accepts — a computed binding whose `set` filters the incoming string — **does
  not work**: when the filtered result equals the value the property already held, nothing
  observable changed, so the field keeps the text the user typed and the rejected character stays on
  screen. Bind straight to the view model property and normalize in `.onChange`, where the corrected
  value genuinely differs from the typed one and the field updates (the client `ProfileFormPopup`,
  removed in M-30, masked the phone this way; M-32's client form is the next one). The consequence is that the view model stores the **display** text and derives
  the clean value from it, not the reverse. Don't reach for a `didSet` on the property either:
  property observers under `@Observable` are a macro-expansion question not worth answering when
  the state can be computed instead (e.g. `showsPhoneError = hasSubmitted && isPhoneValid == false`).
  The same goes for **splitting one value across several controls** (hour and minute wheels for a
  time): don't derive the parts with `Binding(get:set:)`. Model the value as a small struct whose
  parts are stored properties and bind each control by key path — `TimeWheel` binds
  `$time.hour`/`$time.minute` on `ClockTime`. A rule tying the parts together (the old closing
  rule "hour 22 → minute `00`", dropped in M-33.1) is a `didSet` on that plain struct, which is
  fine: the `@Observable` caution above is about observers on view model properties, not on a
  value type stored in one.
- **A `Task {}` created inside a `View`'s helper method does not inherit `MainActor`.** `Task`
  captures isolation *statically*, from the enclosing declaration — and helper methods on a `View`
  struct are nonisolated (only `body` carries the protocol's `@MainActor`). So anything
  **synchronous** called after an `await` — a `dismiss()` closure, an `onSuccess()` callback —
  runs on the generic executor and mutates `@State` off the main thread. Nothing diagnoses this:
  the callee is nonisolated too, so even Swift 6 stays quiet. Write `Task { @MainActor in ... }`
  at these sites (`ServiceFormPopup`, `ClientFormPopup`, `DeleteAccountPopup` all do). Don't
  annotate the *method* instead — that cascades up through every caller (`actions(dismiss:)` and
  friends) and then into closure-conversion questions. A `Task {}` whose only post-`await` work is
  another `await` needs nothing: the async call hops to its own actor by itself.
  `Service`/`Slot` use `@DocumentID var id: String?` (Firestore assigns it, don't encode it
  yourself). `UserProfile.id` is `uid`, since that collection is keyed by the Firebase Auth uid
  rather than an auto-generated document ID.
- `YOi/YOi/Services/Repositories/` — protocols only (`AuthRepository`, `ServiceRepository`,
  `ClientRepository`, `SlotRepository`, `EventTemplateRepository`,
  `EventRepository`, `UserDataRepository`). These files must **not** import Firebase — that's the whole point: ViewModels
  depend on these contracts, not on Firestore/Auth directly, so a fake implementation can stand in
  for SwiftUI previews or tests without touching the network.
- `YOi/YOi/Services/Firestore/` — concrete implementations (`FirebaseAuthRepository`,
  `FirestoreServiceRepository`, `FirestoreClientRepository`,
  `FirestoreSlotRepository`, `FirestoreEventTemplateRepository`, `FirestoreEventRepository`,
  `FirestoreUserDataRepository`).
  `Firestore.firestore()`/`Auth.auth()`
  are singletons managed by the Firebase SDK itself; that's fine and expected — what we avoid is
  wrapping *our own* repository classes in `.shared` singletons. ViewModels take a repository
  protocol as an init parameter, defaulting to the real Firestore-backed implementation.
  Every master's data lives under her own `users/{uid}/`; the Firestore repositories reach it
  through `Firestore.userCollection(_:)` (`Firestore+UserCollection.swift`), never a hard-coded
  top-level `collection(...)`, so protocols and view models never see the uid.
- **App-wide settings get a top-level feature folder**, like `Auth/` and
  `Root/`: `Appearance/` holds `AppAppearance` (System / Light / Dark, stored in
  `@AppStorage("appearance")` and applied by `RootView`) and `AppearancePicker`, the rows shown in
  the Profile screen (`Master/Profile/`). It has no view model — the picker only reads and writes
  `@AppStorage`. `LargeTitleHeader` takes an optional trailing view: Статистика puts the round
  person button there, which opens Profile.
- One `PBXFileSystemSynchronizedRootGroup`, `YOi/YOi/`, feeds the `YOi` target — app source and
  build resources alike (the fonts sit in `YOi/YOi/Assets/Font/`). It is auto-picked-up like the
  `GoogleService-Info.plist` case (see `firebase.md`); dropping a file into the tree is enough, no
  manual "Add Files" step.
