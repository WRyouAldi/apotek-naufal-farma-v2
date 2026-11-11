# Flutter Migration Plan — Apotek D'She Farma

## Goal
Build Apotek D'She Farma as a Flutter-first native Android POS. WebView is not the target architecture and must not constrain Flutter implementation. Existing legacy assets/data may be consulted only as migration sources where needed; do not preserve WebView as a required runtime fallback.

## Current audit (2026-10-20)
- Legacy HTML/JS is approximately 1 MB and embeds a catalog of 4,348 products.
- Legacy implementation contains workflows for product search, QRIS, imports, reports, printing, sync, stock, and other operational actions.
- Flutter branch has a new shell, SQLite product/transaction tables, scanner screen, price-check screen, basic product editing, checkout and transaction history.
- Flutter is not feature-parity yet. The catalog file now carries name/code/barcode/price only; stock was not present in that source, so stock is explicitly marked unknown. Do not infer stock from a zero value.
- QRIS provider confirmation, migration of transaction history, purchase-cost/profit fields, full reporting/export/printing, and legacy sync have not been verified as migrated.
- CI/build must pass and a real Android device check is required before live use.

## Flutter-first implementation strategy
1. Flutter is the sole target UI/runtime. Do not build new features in WebView or keep a WebView fallback as a requirement.
2. Use the old code/data only as a reference for field mappings and required business behavior; do not copy its UI architecture.
3. Keep a feature inventory and acceptance tests for each pharmacy workflow.
4. Prioritize read-only Price Check with exact barcode lookup, robust search, stock certainty and accessible error states.
5. Introduce repository/data services so widgets do not issue ad-hoc SQL; use a canonical product model and explicit `stockKnown` state.
6. Implement inventory and CSV import/export with validation, preview, duplicate handling, rollback and reconciliation reports.
7. Implement cashier/checkout only with verified prices/stock, atomic transaction persistence and clear failure recovery.
8. QRIS is intentionally excluded by owner instruction. Do not reintroduce it without explicit approval.
9. Implement reports, thermal receipt printing, backup/restore and cloud sync as Flutter/native workflows after their data contracts are defined.
10. Release only after automated tests, data reconciliation and physical Android checks pass. The acceptance gate is quality verification, not a WebView fallback.

## Price Check acceptance criteria
- Search by product name, code and barcode.
- Exact barcode lookup precedes fuzzy text search.
- Empty, loading, no-result, database-error and camera-permission states are visible and recoverable.
- Display the source price exactly; format Rupiah only for display.
- Do not add a product to cart from the Price Check page.
- Display stock as unknown when the source has no stock value.
- Cold start imports/opens the catalog successfully; repeated launches do not duplicate records.
- Test representative names, duplicate codes, empty barcodes, special characters, long names and zero prices.
- Confirm the app works offline after first install.

## Release gates
- `flutter analyze` passes with no errors.
- `flutter test` passes, including database/catalog and widget tests.
- Android debug and release APK builds succeed from a clean checkout.
- Install and test on a physical Android device: camera permission, scanner, keyboard, narrow screen, dark/light theme, lifecycle/restart, offline search.
- Reconcile product count (expected 4,348 source records), names/codes/prices, duplicates, and imported row count.
- No live sale until stock, transaction persistence, receipt/report and payment flows are tested against known cases.

## Known limitations / explicit non-goals
- A product price catalog is not a stock ledger. Unknown stock must never be shown as zero stock or available.
- A static QRIS image is not proof of payment.
- A successful compile alone does not establish operational readiness.
- Never delete or replace the legacy app/database during migration until backups and reconciliation are confirmed.


## Cloud catalog sync implementation (2026-10-20)
- Flutter now has a manual **Lainnya → Sinkronisasi database cloud** action.
- Source is the legacy public CSV endpoint: `https://raw.githubusercontent.com/WRyouAldi/apotek-naufal-farma/main/cloud/xReport2.csv`.
- Import validates HTTP status, non-empty response, expected headers, required columns, valid rows, and a minimum 1,000 valid products before opening a write transaction.
- CSV is applied transactionally by product code; records absent from the CSV are not deleted. Failed downloads/validation leave the local database unchanged.
- Negative or missing source stock is stored as zero with `stock_known=0` so it is not represented as verified inventory. The count of negative source rows is surfaced to the operator.
- This is **one-way cloud-to-device catalog sync**. It does not yet upload local changes, synchronize transactions across devices, or automatically run in the background. The schema currently maps code/barcode/name/selling price/stock; cost, category, unit, minimum stock, rack, supplier and notes still need schema/UI migration.
- CI must validate this commit before treating the new sync flow as build-verified. Real-device network and offline tests remain required.


## Visual design execution log (2026-10-21)

### Design lock
- `docs/FLUTTER_UI_UX_DESIGN_LOCK_DSHE_FARMA.md` is the visual source of truth.
- Reference direction: monochrome silver glassmorphism, Pearl Crystal light theme, Charcoal Silver dark theme, floating capsule navigation.
- Legacy `docs/index.html` remains unchanged as a migration reference only; it is not a runtime fallback.

### P1 — visual foundation (implementation in progress)
- Aligned Flutter primary accent tokens to the design lock (`#7D9CA5` Pearl Crystal and `#AAB5C2` Charcoal Silver); set cards to avoid Material surface-tint drift.
- Reduced dependence on saturated green in the home hero and logo treatment.
- Validation status: source updated; CI and Android rendering verification still required.

### P2 — core components (implementation in progress)
- Checkout now rejects unverified/unknown stock atomically at the database boundary; cashier selection also blocks unknown or depleted stock and quantity beyond known stock.
- Reworked mobile bottom navigation into a floating, rounded, blurred capsule with safe-area spacing.
- Glass panel and theme tokens remain shared foundations.
- Validation status: source updated; CI and device comparison still required.

### P3 — screen-wide consistency
- Not yet accepted. Cek Harga, Kasir, Lainnya, sheets/dialogs, empty/error/loading states and logo placements require a systematic light/dark review.

### P4 — motion, responsiveness and final verification
- Not yet accepted. Requires reduced-motion review, keyboard/safe-area checks, narrow-screen checks, scanner lifecycle checks, automated tests, clean Android builds and device/emulator screenshot comparison.

### Honest release gate
No phase is marked 100% complete until its acceptance checks pass. A code commit alone is not proof of a successful build or visual match. Do not use the Flutter branch for live sales until database/stock/payment and device checks pass.


## Flutter-first decision (2026-10-21)

Owner decision: **maximize Flutter's native capabilities and ignore WebView as the target implementation**.

### Implementation priorities
- Native-feeling UI built from reusable Flutter widgets; no WebView shell.
- Central theme tokens for Pearl Crystal (light) and Charcoal Silver (dark).
- Reusable glass surfaces and floating capsule navigation with safe-area handling.
- Product/transaction repository boundary between widgets and SQLite.
- Fast catalog lookup with indexed code/barcode/name search and large-list rendering.
- Camera barcode scanner with explicit permission, lifecycle, and error handling.
- SQLite migrations, atomic checkout, data import validation, and reconciliation.
- Native Android integrations for thermal printing, files, backup/restore, and device-specific features where needed.
- QRIS remains removed from navigation and feature screens.

### Definition of done
A feature is complete only when its UI, business logic, persistence, error states, tests, and Android verification all pass. CI success is necessary but not sufficient for visual or operational acceptance. Do not describe P1–P4 as 100% until every checklist item has evidence.
