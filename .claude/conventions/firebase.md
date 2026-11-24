# Firebase SDK

The Firebase iOS SDK is a normal remote Swift package dependency
(`https://github.com/firebase/firebase-ios-sdk`, "Up to Next Major Version"), providing the
`FirebaseAuth`, `FirebaseFirestore` and `FirebaseAppCheck` products to the `YOi` target. Requires
Xcode 16.3+ (Swift tools version 6.1); the project now builds on Xcode 16.4. (Earlier this was a
local Swift package reference pointing at a machine-specific `~/Developer/firebase-ios-sdk` checkout, needed because
Firebase >= 12.15.0 requires Swift tools 6.1 and the project was still on Xcode 16.1 — that
workaround is gone now that Xcode is updated.)

`GoogleService-Info.plist` is gitignored (regenerate from Firebase Console per environment) but
must exist on disk in `YOi/YOi/` for the app to run — Xcode's synchronized-folder project
format (`PBXFileSystemSynchronizedRootGroup`) means any file dropped into that directory tree is
picked up automatically, no manual "Add Files" step needed.

## App Check

`YOiApp.init()` installs `AppCheckFactory` (private, in `YOiApp.swift`) **before**
`FirebaseApp.configure()` — App Check is created during `configure()` with whatever factory is set
then, and a late one is ignored without an error. Firestore and Auth attach the token themselves.

- **Simulator: the debug provider** (`#if targetEnvironment(simulator)`, not `DEBUG`, so a device
  Debug build attests like the App Store one). It prints `Firebase App Check debug token: …` on
  launch; register it in Console → App Check → Apps → ⋮ → Manage debug tokens. A token is per
  install — a new simulator or a reinstall prints a new one. **Never commit a debug token**: the
  scheme `YOi.xcscheme` is shared, so it cannot go into the scheme's environment either.
- **Device: App Attest**, which needs `YOi/YOi.entitlements`
  (`com.apple.developer.devicecheck.appattest-environment` = `production`, both configurations).
  Without the entitlement the provider is created but iOS refuses the attestation.
- **Enforcement is a Console switch** (App Check → APIs), off since Y-77. Once on, a build without
  App Check — every build before Y-77 — gets every Firestore and Auth request rejected.
