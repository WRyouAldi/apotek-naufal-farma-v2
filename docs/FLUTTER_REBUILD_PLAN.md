# Rebuild Plan — Apotek D'She Farma Flutter

**Source of truth:** `docs/FLUTTER_UI_UX_DESIGN_LOCK_DSHE_FARMA.md`  
**Approach:** rebuild the presentation layer cleanly instead of layering more patches onto the legacy UI. Preserve data/business services unless a separate migration is required.

## Locked decisions
- Native Flutter Android; no WebView runtime.
- Pearl Crystal Light and Charcoal Silver Dark.
- Monochrome silver glassmorphism with restrained blur and consistent semantic colors.
- Initial destination: Cek Harga.
- Bottom navigation: Kasir, Cek Harga, Lainnya.
- Cek Harga searches by name/code/barcode and never adds items to the cashier cart.
- QRIS/provider-specific QR payment UI remains removed.
- Unknown stock stays visibly unverified; preserve cashier stock validation.
- App-bar logo, splash icon, and Android launcher icon must share one approved brand asset. Current drawn monogram is provisional until owner approval.

## Rebuild sequence
1. **Foundation:** centralize theme tokens, typography, spacing, responsive breakpoints, glass surfaces, buttons, fields, status chips, and navigation.
2. **Branding:** create a dedicated brand asset and configure Android launcher/splash consistently; do not call a provisional monogram final.
3. **Cek Harga:** make this the landing screen; compact search, scan states, readable prices, verified/unknown stock. No cart coupling.
4. **Kasir:** compact product suggestions, scanner, cart/quantity, totals, and payment validation using existing database services.
5. **Lainnya:** inventory, transaction history, reports, import/export, cloud sync, and settings with honest availability states.
6. **Responsive polish:** keyboard/safe-area handling, text scaling, narrow phones, larger screens, motion, accessibility.
7. **Verification:** run `flutter analyze`, all `flutter test`, build debug APK, verify artifact commit SHA, and inspect both themes on Android emulator/device.

## Acceptance gates
- No legacy screen layout remains reachable after its replacement is accepted.
- No unrelated saturated-green accents or QRIS UI.
- Cek Harga is the initial destination and never mutates the cart.
- Search, scanner, stock checks, checkout, and transaction persistence continue to work.
- CI success alone is not visual acceptance; device/emulator review is required.
- Never distribute an APK from an older commit as the latest build.

This is a work order, not evidence the rebuild or device validation has completed. Mark steps complete only with code and test/build evidence.
