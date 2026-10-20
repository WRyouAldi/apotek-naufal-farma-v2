# Flutter Migration Plan — Apotek D'She Farma

## Goal
Replace the legacy WebView POS gradually, without losing existing pharmacy operations or silently inventing data. The legacy app at `docs/index.html` remains the behavioral reference until Flutter passes parity tests.

## Current audit (2026-10-20)
- Legacy HTML/JS is approximately 1 MB and embeds a catalog of 4,348 products.
- Legacy implementation contains workflows for product search, QRIS, imports, reports, printing, sync, stock, and other operational actions.
- Flutter branch has a new shell, SQLite product/transaction tables, scanner screen, price-check screen, basic product editing, checkout and transaction history.
- Flutter is not feature-parity yet. The catalog file now carries name/code/barcode/price only; stock was not present in that source, so stock is explicitly marked unknown. Do not infer stock from a zero value.
- QRIS provider confirmation, migration of transaction history, purchase-cost/profit fields, full reporting/export/printing, and legacy sync have not been verified as migrated.
- CI/build must pass and a real Android device check is required before live use.

## Migration strategy: strangler, not big-bang replacement
1. Keep the current WebView app as the production fallback while Flutter is developed in its own branch.
2. Freeze a feature inventory and define acceptance tests for each legacy workflow.
3. Migrate read-only Price Check first, because it has a small blast radius and is the user's immediate priority.
4. Introduce a repository/data layer so widgets do not query SQLite directly. Use a single canonical product model and explicit `stockKnown` state.
5. Migrate inventory management and CSV import/export with validation, preview, duplicate handling, rollback, and a reconciliation report.
6. Migrate cashier and checkout only after product prices and stock are reconciled. Enforce stock decrement and transaction persistence in one database transaction.
7. Migrate QRIS only with verified merchant configuration and an authoritative confirmation flow; otherwise clearly label it manual and never auto-confirm.
8. Migrate reports, receipt printing, backup/restore and sync after transaction schema parity is established.
9. Release side-by-side to a test device, compare results against WebView, and switch the default only after all release gates pass.

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
