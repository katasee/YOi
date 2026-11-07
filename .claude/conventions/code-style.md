# Code style

Any function/initializer call with 3 or more arguments gets one argument per line, not packed onto
one line:

```swift
throw NSError(
    domain: "Auth",
    code: 401,
    userInfo: [NSLocalizedDescriptionKey: "Not signed in"]
)
```

Same for declaring a function with 3+ parameters. Under 3 arguments, keep it on one line.

**A trailing closure does not count toward that total — only the arguments inside the parentheses
do.** So `VStack(alignment: .leading, spacing: 8) { ... }` is a two-argument call and stays on one
line, even though `VStack.init` genuinely takes three parameters and the closure is the third
(`content:`). Counting it would split every stack, `Button(action:)` and `ForEach` in the app,
which is not what the rest of the code does — the whole of `Auth/`, `Master/Schedule/` and
`Assets/UICommons/` writes these on one line, and the handful of split ones that had accumulated in
`Client/Booking/` (removed in M-30) were normalized back to match.

One agreed exception: **literal fixture arrays inside `#if DEBUG` preview data may stay packed**
(`ServicesPreviewData.swift`, `SchedulePreviewData.swift`). A column of `Service(...)` / `Slot(...)`
calls reads as a table, which is the point of the file, and none of it ships. The exception is for
fixture *literals* only — production code and preview *views* follow the normal rule.

**`#if DEBUG` around a `#Preview` is a feature-folder convention, not an app-wide one.** Feature
views wrap their previews because those previews reference `*PreviewData` fixtures, which are
themselves `#if DEBUG` — without the wrapper the file wouldn't compile for release. A component in
`Assets/UICommons/` builds its preview from literals and fakes nothing, so it needs no wrapper, and
none of the components there has one. Match the folder you're writing in.

**Surfaces are modifiers, not fills.** The page (`Background`) and a card (`Card`) are both white
in the light theme, so a bare `.background(Color.card, …)` is invisible. Use one of two
modifiers from `Assets/UICommons/`: `.cardSurface(padding:cornerRadius:)` for cards and boxes —
popup summaries included (contour + two soft shadows; pass `padding: 0` when the card pads itself
asymmetrically) — and `.raisedSurface(shape)` for small raised controls (unselected chips, round
buttons, fields; filled with `Raised`). In dark the shadows (tinted with `Shadow`, black there)
vanish on the near-black page, so depth comes from tone (`Card` `#1F1A1F` and `Raised` `#2C252C`
on `Background` `#0B080B`) plus a top rim and a soft top-down sheen tinted with `Highlight` —
clear in light, white in dark, so the light theme is untouched. Both modifiers draw it; don't add
`colorScheme` branches to get depth. **Nothing a user reads as an object is flat**: a flat outlined box
(`.insetSurface`) existed in M-27 and was removed after a device pass, because a summary plate that
does not lift reads as a hole in the popup. The deliberately flat exceptions are markers, not
objects: the dashed free window (`FreeSlotRow`), the "today" outline in `WeekDayStrip`, and the
conflict warning line (`ConflictNoticeView`, M-37.7: a tinted note, not a card).
A raised control that can be *selected* swaps its surface for a `PrimaryFill` fill with
`.brandShadow()` (the selected day in `WeekDayStrip`); write that as an explicit `if`/`else` in
`.background`, not as a fill stacked over a raised one — for a plain chip or field that is
`.selectableSurface(isSelected:in:)` (`Assets/UICommons/`, M-37.3), which holds exactly that
`if`/`else` (on iOS 26 it is glass instead — see "Liquid Glass on our own views"). `Hairline` is for dividers and outlines
only — never a fill (the client avatar, removed in M-30, shaded with a `Raised` → `Shadow` gradient instead) — and
`Stroke` is for the dashed outline of a free window (`FreeSlotRow`). Shadows sit on the surface's background shape,
never on the whole content — `.shadow` on a view with children shadows each child. A horizontal `ScrollView` of raised chips
clips their shadows; the client booking chip row (removed in M-30) used `.scrollClipDisabled()` (scrolled chips may then paint into
the screen gutters — accepted).

**Liquid Glass on our own views** (first used in M-36.1's reschedule lens,
`RescheduleDayScroller`). `.glassEffect` exists only on iOS 26 and the deployment target is 18.1,
so it goes under `if #available(iOS 26, *)` with a token fallback in the `else` (the lens: a
`Raised` pill with a `Hairline` outline). Three things learned on the simulator: glass laid *over*
text refracts and blurs it — put it behind the content; over a flat card there is nothing to
refract, so glass reads only by its rim and highlight; and an opaque `.tint` hides the glass
entirely (the "black" lens was just a black pill). Keep it untinted unless a device pass says
otherwise.
Since Y-42 every control we draw is glass on iOS 26, at its drawing site, with today's surface in
the `else`: `RoundIconLabel`, `CapsuleButton`, `.selectableSurface`, the selected day in
`WeekDayCell`/`MonthDayCell`, the auth submit button, the client card's
"Зв'язатися" and `ClientAvatar`. Unfilled roles are `.regular`; filled ones keep their colour as
`Glass.primary` / `Glass.destructive` (`Glass+Roles.swift`: `.regular` tinted with `PrimaryFill` /
`DestructiveFill`) — one place to change, never an inline `.tint` — and the "opaque tint" rule
above still bites: in the light theme `PrimaryFill` is near-black, which glass cannot lighten, so
the black buttons read as plain black and only the dark theme's wine shows the glass. The user
tried 85% opacity and a graphite `#2A2A2E` tint and kept the plain black. Four more rules, all
found on a device:
- **Glass goes on the view that is touched, not in `.background { }`.** `.interactive()` reacts only
  on the view that receives the touch, so a tappable surface puts `.glassEffect` on its label; a
  glass button also drops `PressableButtonStyle` for `.plain`, because interactive glass is the
  press feedback and the scale + 0.75 opacity on top doubled it and washed the glass out. Markers
  (a selected day) are not interactive and may keep glass in a `.background`.
- **Glass in a `.background` must not sit inside a `GlassEffectContainer`.** The container draws
  all its glass in one layer above the content, so a tinted `Color.clear` glass background covered
  the week strip's numbers. Inside a container, glass goes on the view that carries the content —
  the chips do (`.selectableSurface` applies it to the chip itself), and their grids are wrapped
  in `.glassEffectGroup()` (`View+GlassEffectGroup.swift`, a no-op on 18).
- **A moving selection stays on `matchedGeometryEffect`.** `glassEffectID` in a container was tried
  for a tab-bar-like morph of the selected day and the Fill-month lens and gave a jump instead of a
  slide; it was reverted. A real morph is its own task, checked on a device after each step.
- **Glass never sits on glass.** Glass cannot refract glass: the Fill-month lens on a glass track
  all but vanished on an iOS 26 device (clearer glass than 27's), so the track stays
  `.raisedSurface` and only the lens is glass.
- **Content stays flat.** Cards, rows, input fields and popups keep `.cardSurface`/
  `.raisedSurface`: glass is the control layer, and text on glass reads worse.

User-facing strings never sit as bare literals in a View — they go in
`YOi/YOi/Localizable.xcstrings` (String Catalog) under a `feature.kind.name` key
(e.g. `auth.field.email`, `auth.action.signUp`) and get pulled in via `String(localized: "key")`.
Exception: the "YOi" wordmark/brand name — it's not translated, leave it as a literal. Add the
key to the catalog in the same change that introduces the string; don't leave it dangling for a
later pass.

Text never uses the system font — always go through `Font.elmsSans(_:_:)`
(`YOi/YOi/Assets/UICommons/Extension+ElmsSans.swift`), e.g. `.font(.elmsSans(.bold, 32))`, never
`.font(.system(...))`, `.font(.title)`, `.bold()`, or similar. Pick the closest weight from
`ElmsSans` (`regular`/`medium`/`semiBold`/`bold`, in `YOi/YOi/Assets/UICommons/ElmsSansWeight.swift`;
the mockup's weight 600 is `.semiBold`, 700 is `.bold`)
instead of layering SwiftUI's own `.fontWeight()` on top. The four `.ttf` files sit in
`YOi/YOi/Assets/Font/` and are registered by hand in `Info.plist` under
`UIAppFonts` — adding a new weight means dropping the `.ttf` in that folder *and* adding its
filename to `UIAppFonts`, or `Font.custom` silently falls back to the system font with no warning
or crash.

The one exception is **tab bar labels**: they are drawn by the system `TabView`, which renders them in
the system font; don't try to force ElmsSans onto them through `UITabBarAppearance`.

**Colour scheme and roles.** The app has a light and a dark theme ("Темне вино", the canvas page
"Темний + темне вино"); every colorset carries both appearances. The user picks System / Light /
Dark on the Profile screen (`AppearancePicker` in `Appearance/`); the choice is `AppAppearance` in `@AppStorage("appearance")`,
applied once with `.preferredColorScheme` on `RootView`. There is no light lock any more — don't
reintroduce `INFOPLIST_KEY_UIUserInterfaceStyle`, and don't branch on `colorScheme` in views: a
colour that differs between themes is a colorset, not an `if`.

Each token has **one role**, because one colour cannot serve two roles in both themes (that is
what broke when `Ink` was text *and* fill *and* shadow):

| Token | Role | Light / dark |
|---|---|---|
| `Ink` | text and glyphs only | `#0A0A0B` / `#FFFFFF` |
| `PrimaryFill` / `OnPrimary` | primary button and every selected fill / text on it | `#0A0A0B` / `#6B3442`; white |
| `Raised` | `.raisedSurface` fill | `#FFFFFF` / `#2C252C` |
| `Destructive` / `DestructiveFill` | destructive text / destructive fill | `#C42F2F`; `#FF6961` / `#D93A3A` |
| `Shadow` | every shadow | `#0A0A0B` / `#000000` |
| `Backdrop` | popup backdrop | ink 22% / black 55% |
| `Highlight` | surface rim and sheen | clear / white |
| `HeaderFill` | `BookingHeader` block — unused since M-30 removed it | `#0A0A0B` / `#1F1A1F` (card tone) |
| `Warning` / `WarningSoft` | a window too close before a plan (M-37.7): glyph, text and outline / the flat fill under the warning line | `#9A5200` / `#FFB340`; `#FFF4E0` / `#33261A` |
| `DestructiveSoft` | the flat fill under a red conflict line (text on it is `Destructive`) | `#FDECEC` / `#3A1F22` |
| `StatusConfirmed` | positive / success: the Stats up-trend and the success toast's check (Y-54); the name predates that role | `#0B7A1A` / `#4CD964` |

Never name a colorset after an existing SwiftUI `Color` member — the generated symbol collides
(`Primary` would be `Color.primary`, hence `PrimaryFill`).

**Accent and tab bar.** `AccentColor` is `#0A0A0B` / `#D7ADB5`; it drives carets, alert buttons,
pickers and the `RoundIconButton` glyph. The selected **tab** is deliberately *not* the accent:
the `TabView` is `.tint(Color.ink)` (black / white, user decision after a device pass — wine
`#6B3442` on the dark glass bar was ~1.7:1), and each tab's content is re-tinted
`.tint(Color.accentColor)` so the tab tint does not leak into carets and pickers. That pair of
`.tint`s is the one sanctioned exception to "no global tint in code"; a local `.tint` on a spinner
or a button (`ListStatusOverlay`, `CapsuleButton`) is fine as before.

**The wine marks are a separate token, not the accent.** `Wine` (`#7D2E3E` / `#D7ADB5`) and
`WineSoft` (`#F6E9EC` / `#2C252C`, the tile under it) are applied *by name* in small doses: the auth
swap link, `IconBadge` (wine glyph on a flat `WineSoft` tile), the expected-revenue amount,
today's number in `WeekDayStrip`. In dark the wine *fill* `#6B3442` is `PrimaryFill`, not `Wine`.
Wine marks; it never replaces ink.
