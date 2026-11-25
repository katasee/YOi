# YOi

A free iPhone calendar for any master who works by appointment — nails, hair, barbers, brows,
massage, trainers, tutors. Clients write to her in Instagram; she books them in YOi in a few taps,
sends her free windows as a ready message, and sees her month's income.

[App Store](https://apps.apple.com/app/id6830248587) · [Website](https://yoi-app.github.io/)

## Features

- **Schedule by day** — bookings, free windows and personal plans on one screen.
- **Fill the month** — pick working days and hours; free windows for the whole month appear at once.
- **Send schedule** — free windows turned into a ready message (`3.11-9:00/11:00/14:00`), with her
  own header and sign-off, in Ukrainian, Polish or English.
- **Clients** — name, Instagram, phone, booking history; message or call in one tap.
- **Services** — her own price list in her own order; the booking price fills itself.
- **Personal plans** — gym, doctor, day off, one-off or weekly; overlaps are flagged.
- **Statistics** — revenue, expected revenue, visits, occupancy, comparison with last month.
- Light and dark theme; currency PLN / UAH / USD / EUR; onboarding tour.

Clients never use the app: every account is an independent cabinet that only its owner can read.

## Tech stack

- SwiftUI, iOS 18.1+ (Liquid Glass on iOS 26), Swift Observation (`@Observable`).
- Firebase: Auth (email + password), Cloud Firestore (offline cache, realtime listeners),
  App Check (App Attest).
- MVVM + Repository: view models depend on repository protocols, Firestore implementations sit
  behind them. No third-party dependencies besides the Firebase SDK.

## Project layout

```
YOi/YOi/
├── Auth/, Root/            sign-in, sign-up, launch and routing
├── Master/                 the app's tabs and screens, one folder per feature
├── Models/                 domain types (Slot, Service, Client, …)
├── Services/
│   ├── Repositories/       protocols only, no Firebase import
│   └── Firestore/          Firebase implementations
├── Utilities/              DateFormat, PhoneFormat
└── Assets/UICommons/       shared components
firestore.rules             security rules (deployed by hand in Firebase Console)
docs/plan.md                status and the ordered next steps
```

## Building

1. Xcode 16.3 or newer.
2. Create a Firebase project with an iOS app (bundle id of your own), enable Email/Password auth and
   Firestore, and put its `GoogleService-Info.plist` into `YOi/YOi/` — it is gitignored.
3. Publish `firestore.rules` in Console → Firestore → Rules.
4. Build:

   ```bash
   cd YOi && xcodebuild -scheme YOi -destination 'generic/platform=iOS Simulator' build
   ```

On the simulator App Check uses the debug provider: the first launch prints
`Firebase App Check debug token: …`; register it in Console → App Check → Manage debug tokens.

## Documentation

- [`docs/plan.md`](docs/plan.md) — what is done, why, and what comes next.
- [`docs/superpowers/specs/2026-07-15-yoi-mvp-design.md`](docs/superpowers/specs/2026-07-15-yoi-mvp-design.md) — product spec.
- [`CLAUDE.md`](CLAUDE.md) and [`.claude/conventions/`](.claude/conventions/) — architecture,
  data layer and code style conventions.

## Support

yoi.app.support@gmail.com
