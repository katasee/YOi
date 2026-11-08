# Data layer

- `Slot.date`/`time` are plain `String`
  (`yyyy-MM-dd`/`HH:mm`) but must never be produced by an inline `DateFormatter` — always go
  through `YOi/YOi/Utilities/DateFormat.swift`.
  That file splits into three kinds: **storage** formatters (`DateFormat.date`/`DateFormat.time`) pin
  `en_US_POSIX` locale so the string written to Firestore can't be corrupted by device
  locale/calendar; **display** formatters (`DateFormat.dayNumber`/`weekdayLetter`/`monthYear`) use
  `Locale.current` so on-screen dates follow the app's language — the app is multilingual via the
  String Catalog, so display formatters must never hardcode a locale; **message** formatters
  (`DateFormat.messageDay`/`messageTime`, `d.MM`/`H:mm`, M-35.2) pin `en_US_POSIX` like storage
  ones, because the "Надіслати графік" text is the master's own fixed format (`1.10-9:00/11:00`)
  and must not follow the device locale either — but it is never stored, hence its own name. All
  three keep the salon's fixed `TimeZone`. `firestore.rules` regex-validates the storage format server-side
  (`hasValidSlotFormat(_:)`) as defense in depth. Times shown on screen must go through
  `DateFormat.displayTime(_:)` rather than printing the stored `HH:mm` string (`SlotItem.timeText`
  does) — it uses `setLocalizedDateFormatFromTemplate("jmm")`, so an English device gets
  "9:00 AM". Use the `"jmm"` template, not `"j"`: the latter silently drops minutes.
  **Any display formatter that combines more than one field must go through
  `templateFormatter(_:)`, never a fixed `dateFormat` string.** A fixed pattern pins the *order* of
  the fields and lets the locale change only the words: `"d MMMM"` gives the correct "12 серпня" in
  Ukrainian and the wrong "12 August" in English, where the convention is "August 12". The template
  (`"dMMMM"`) states which fields are wanted and lets the locale order them. The one deliberate
  exception is `monthYear`, which keeps the fixed `"LLLL y"`: `LLLL` is the *standalone* month form
  ("Серпень 2026"), while a template would produce the genitive "серпня 2026" — wrong for a bare
  month header. Don't "fix" that one.
- **A phone number goes through `YOi/YOi/Utilities/PhoneFormat.swift`, never a raw string.**
  Same storage/display split as `DateFormat`: Firestore holds one canonical form
  (`+48` + exactly 9 digits, e.g. `+48600123456`), the screen shows `+48 600 123 456`, and the edit
  field holds the spaced text while `phoneDigits` derives the digits from it. `display(_:)` returns
  anything it cannot parse **verbatim** rather than mangling it, which is what keeps values written
  before the format existed (or by hand in the Console) readable. The app is Poland-only by
  deliberate choice; widening it means turning the static `+48` prefix into a picker, not changing
  the stored form. `firestore.rules` does **not** regex-validate this, unlike `hasValidSlotFormat(_:)` —
  a malformed phone breaks nothing server-side.
- Firestore's Codable convenience methods — `setData(from:)`, `addDocument(from:)` — have **no
  `async` overload** in this SDK version, only `throws` with an optional completion closure.
  Writing `try await someRef.setData(from: model)` compiles but silently resolves to the sync
  overload (Swift warns "No 'async' operations occur..."), so the write becomes fire-and-forget —
  errors never surface. Always encode manually with `Firestore.Encoder().encode(_:)` and call the
  raw dictionary method instead (`setData(_:)` / `addDocument(data:)`), which Swift auto-bridges
  from the underlying ObjC `completion: (NSError?) -> Void` overload into a real `async throws`.
  The compiler warning **"No 'async' operations occur within 'await' expression"** is the tell —
  treat it as a real, actionable bug report, not noise. That's different from the stale SourceKit
  "No such module"/"Cannot find type" errors that show up after almost every file write and clear
  themselves once indexing catches up (verify those against an actual `xcodebuild` run, not at
  face value) — the async-operations warning is a genuine compiler diagnostic about the code as
  written and won't go away on its own.
- **The deliberate fire-and-forget writes are `FirestoreClientRepository`'s `add`, `update` and
  `delete`, `FirestoreServiceRepository`'s `add`, `FirestoreSlotRepository`'s `add`, `book`, `addBooked`, `clearBooking` and `delete`,
  `FirestoreEventTemplateRepository`'s `add`, `update` and `delete`, and
  `FirestoreEventRepository`'s `add`, `update` and `delete`, and
  `FirestoreMonthlySummaryRepository`'s `add`** (user decisions: `add` in
  M-32.4, `update`/`delete` in M-32.5, slots in M-33.2, booking in M-34.1, `addBooked` in Y-53, templates in M-37.2,
  plans in M-37.4 and their `update` in M-37.6, the month archive in M-38.1, a service's `add` in Y-58,
  where the protocol itself declares them plain `throws`). Awaiting a write waits
  for the *server* acknowledgement, so offline the client popups spun forever with Cancel disabled,
  although the change was already in the local cache and on screen. They now pass
  `completion: nil`: the write lands locally at once and Firestore syncs it later. The cost is that a
  server rejection goes unseen — acceptable because `hasValidClientFormat()` checks what
  `ClientFormViewModel` already enforces, and a delete validates nothing. Encoding and
  "not signed in" errors still throw. `update` and `delete` are declared `throws` without `async`
  (a sync method satisfies the protocol's `async throws`): calling a completion-handler API inside
  an `async` function raises "consider using asynchronous alternative function". Every other
  write still awaits; don't copy this without the same reasoning (a service's `update` and
  `delete` still spin offline in "Мої послуги", not yet changed).
  `ClientRepository.add` and `ServiceRepository.add` return the new document id: `addDocument`
  builds the reference — and its auto id — on the device before anything is sent, so a client or
  service created from the booking popup can be picked at once, offline too. Booking writes are `setData(merge: true)` on the slot document;
  a cleared field is `FieldValue.delete()`, never `null`. "Заповнити місяць" merges only `date` and
  `time`, which is what keeps a booking alive when a filled month covers it — don't turn either
  write into a plain `setData`, it would replace the whole document. A new booked window
  (`addBooked`, Y-53 quick add) is one merged write of the booking fields together with `date`
  and `time` — never `add` then `book`: `book` alone creates a document without them, which the
  bounded `slots` query never reads. A plan's `update` (M-37.6)
  is `updateData` with all six fields: a plan deleted while its popup was open fails the write
  instead of being recreated, which both `setData` forms would do. `templateId` is optional (a
  one-off plan has none, Y-58), and `Firestore.Encoder` omits a `nil`, so `update` writes
  `FieldValue.delete()` for it — otherwise a plan changed to one-off would keep its old id.
- Realtime data uses **async/await + `AsyncStream`** (`observeServices()`), not
  Combine. Each Firestore `addSnapshotListener` callback yields the full current array for that
  query; `continuation.onTermination` removes the listener. Listener errors are currently swallowed
  (`{ snapshot, _ in ... }`) — if that needs to surface to the UI, switch to `AsyncThrowingStream`
  rather than bolting an error side-channel onto `AsyncStream`. `observeClients()` already has:
  a swallowed error yields `[]`, and an empty client base after a failed listener reads as lost
  data. It builds the stream with `makeStream(of:bufferingPolicy: .bufferingNewest(1))` — every
  snapshot is the full list, so only the latest one matters — and `FakeClientRepository` keeps its
  state in a `Mutex` so `onTermination` can drop a finished continuation without a data race.
  `observeClient(id:)` (M-32.5) listens to one document and yields `nil` when it does not exist
  (`try? snapshot.data(as:)`). Every throwing stream goes through
  `AsyncThrowingStream.listening(_:read:)` (`Services/Firestore/AsyncThrowingStream+Listener.swift`,
  moved out of `FirestoreClientRepository` in M-33.2 when `slots` became the second user): the
  caller says what to listen to and how to read a snapshot, the helper owns the stream, the error
  and `onTermination`. The fakes keep their own observer dictionary (`observe(_:)` in
  `FakeClientRepository`). `observeServices` stays as it is (`observeBlocks` went with `Block` in
  M-38).
- **A listener reads its whole result again** whenever it re-attaches more than ~30 minutes after
  the last one, and a tab's `.task` re-attaches on every return to the tab. So a collection that
  only grows (`slots`, and `events` since M-37.4) is queried with a lower bound
  (`Slot.historyStart(now:)`, 3 months, on `date`), not
  read whole; reads are billed per document across all masters. The same bound limits how far back
  Розклад's "Перейти до дати" calendar pages (`Slot.historyStartDate(now:)`, the `Date` that
  `historyStart` formats), so it never offers months whose windows were not read. The client
  card's bookings (M-34.3) reuse the same bounded query and filter by `clientId`; a full
  per-client history would need its own `clientId ==` query, read whole on every card open.
- **A new field added to a model whose collection already has documents must be optional.** Swift's
  synthesized `init(from:)` does **not** fall back to a property's default value — a missing key
  throws `keyNotFound`, so `var isActive = true` would break decoding for every pre-existing
  document and render the whole list empty. Declare `var isActive: Bool?` and hide the optional
  behind a computed accessor (`var isOffered: Bool { isActive ?? true }`) that the rest of the code
  reads instead. Write the field explicitly on create so only legacy documents rely on the fallback.
  Optional `var`s also keep the memberwise initializer source-compatible (they default to `nil`),
  so existing call sites don't need touching.
- **Money is `Int`, never `Double`.** `Service.price` is whole PLN; `ServiceFormat` renders it with
  `.fractionLength(0)` and the input field uses `.numberPad`. `Double` accumulates rounding error
  once values get summed (the Stats screen does exactly that), and `.numberPad` has no decimal-
  separator key at all, which removes the whole class of locale-parsing bugs — no `FormatStyle`,
  no `.locale(.current)`, just `Int(text)`. If groszy are ever needed, switch to minor units
  (`Int` groszy), not back to floating point. Changing a stored numeric field's type is a data
  migration: a Firestore double decodes into `Int` only when it is whole (`800.0` yes, `450.5` no),
  and one bad document fails the whole query.
- In `firestore.rules`, **`write` means create + update + delete**, and on a delete
  `request.resource` is `null`. Any rule that validates incoming fields must therefore be attached
  to `create, update` with `delete` allowed separately — `allow write: if isOwner(uid) &&
  hasValidServiceFormat()` silently breaks deletion. `services`, `clients`, `slots`,
  `eventTemplates` and `events` are all split this way. `monthlyStats` (M-38.1) has `create` and
  `delete` but no `update`: a finished month's summary is written once and never rewritten.
- **A write that freezes data reads from the server, not the cache.** The `monthlyStats` archive
  reads ids and slots with `getDocuments(source: .server)`: a listener's first snapshot comes from
  the local cache, which is empty after a fresh install, and a summary written from it would be a
  permanent zero. Offline the read throws and the archive waits for the next launch.
- **A slot is a window, booked or not** (`Models/Slot/`: `date`, `time`, `clientId?` + the
  service snapshot `serviceId?`/`serviceName?`/`servicePrice?` since M-34.1 — no end time, no
  status). It replaced the old `Block` (`available → pending → confirmed`, an end time), which
  M-38 deleted together with `blocks` once Статистика was recomputed from slots. With no end time
  there is no duration, so nothing in the app counts hours. `firestore.rules` is deployed manually
  via Firebase Console — no CLI/CI hookup.
- **Independent cabinets, no roles** (since M-30). Every account is a master; sign-up creates
  `users/{uid}` (`name`, `email`), and all her data lives under it: `users/{uid}/services`,
  `users/{uid}/slots`, and every later collection. The Firestore repositories resolve the path with
  `Firestore.userCollection(_:)` from the signed-in user. `firestore.rules` has one gate,
  `isVerifiedOwner(uid)` (owner and `request.auth.token.email_verified`), on the user document and
  everything below it — no `get()` lookups, no role field (old documents may still carry `role`;
  `UserProfile` ignores it). The one exception is `create` of `users/{uid}`, which only needs the
  owner: sign-up writes it before the email is verified. Because the rules read the claim from the
  ID token, the token is force-refreshed right after verification — in `VerifyEmailViewModel.check()`
  on the usual path, or in `RootViewModel.refresh()` when it first sees the flag flip at launch.
  A signed-in user with no `users/{uid}` document gets one recreated by `RootViewModel` (name = the
  email's local part) instead of being signed out, so a half-finished sign-up or account deletion
  never locks the email out.
- **Every collection under `users/{uid}/` is listed in `FirestoreUserDataRepository.collections`.**
  Account deletion wipes only what is listed, so a collection added without it silently survives
  "Видалити акаунт" — an App Store 5.1.1(v) problem with no visible failure. Add the name in the
  same PR that adds the collection.
