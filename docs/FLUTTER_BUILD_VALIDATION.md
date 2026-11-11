# Flutter APK Build Validation

This branch uses `.github/workflows/flutter.yml` to validate and package the native Flutter Android app.

## Required gates

1. Resolve Flutter dependencies (`flutter pub get`).
2. Analyze Dart source (`flutter analyze`).
3. Run automated tests (`flutter test`).
4. Build the debug Android APK (`flutter build apk --debug`).
5. Upload `build/app/outputs/flutter-apk/app-debug.apk` as the `dshe-farma-pos-debug-apk` workflow artifact.

A build is considered current only when the workflow run's commit SHA matches the latest commit on `p2.3.2-flutter-migration` and the workflow completes successfully. An artifact from an older SHA must not be presented as the latest build.

## Product constraints

- Native Flutter implementation; no WebView runtime fallback.
- QRIS remains removed.
- Keep the Pearl Crystal light / Charcoal Silver dark visual direction and follow `FLUTTER_UI_UX_DESIGN_LOCK_DSHE_FARMA.md`.
- Cek Harga must not automatically add items to the cashier cart.

## Visual verification

CI analysis, tests, and APK compilation do not replace manual device checks. Confirm layout, contrast, navigation, logo/branding, and cashier/check-price interactions on a real or emulated Android device before marking visual acceptance complete.
