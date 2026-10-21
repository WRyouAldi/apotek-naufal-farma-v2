# A3 — Flutter Foundation and Data Integrity
## Apotek D'She Farma — implementation log

**Branch:** `flutter-clean-rebuild`  
**Started:** 2026-10-21  
**Status:** implementation in progress; CI run pending. This document records source changes, not a release-readiness claim.

## A3.1 Implemented in this pass

### Product persistence safeguards — `lib/pos_database.dart`
- Product name and code are required on save.
- Negative selling price, purchase cost, stock and minimum stock are rejected.
- Product code comparison is normalized for case and surrounding whitespace when checking collisions.
- Non-empty barcode collisions are rejected.
- Editing a product that no longer exists fails explicitly rather than silently reporting success.

### Checkout integrity — `lib/pos_database.dart`
- Empty cart, missing product ID, non-positive quantity, negative payment, and missing payment method are rejected.
- Repeated cart lines are combined by persisted product ID before stock validation and transaction-item writes.
- Product name, price and stock certainty are re-read from SQLite inside the checkout transaction.
- Unknown stock is explicitly blocked; a price catalog alone cannot authorize a sale.
- Line subtotals and total are recalculated from database prices, not stale cart prices.
- Stock decrements, transaction header and transaction items remain inside one SQLite transaction; any thrown validation/write error rolls back the transaction.
- Conditional stock updates are retained to detect insufficient or changed stock.

### Product editor — `lib/main.dart`
- Edit flow now carries forward the existing `stockKnown` value and supported metadata fields instead of allowing model defaults to silently change them.
- Product editor now exposes category, brand, unit, purchase cost, minimum stock, rack, supplier and notes fields.
- Added an explicit **“Stok sudah diverifikasi”** checkbox; stock stays unknown unless staff deliberately confirms physical stock. This prevents a default zero from being mistaken for a verified count.
- Save errors are shown to the operator instead of leaving failures silent.

### Model tests — `test/models_test.dart`
- Added stock-unknown conversion coverage.
- Added round-trip coverage for supported product metadata.
- Added a duplicate-cart-line arithmetic case.

### CI trigger
- Updated `.github/workflows/flutter.yml` so pushes to `flutter-clean-rebuild` run the existing analyzer, tests, and release APK build workflow.

### Additional safeguards added after initial A3 pass

- Cloud CSV sync now rejects duplicate normalized product codes and duplicate non-empty barcodes before opening a database write transaction. The error identifies the conflicting value and states that local data was not changed.
- Product management list now renders stock as **“Stok belum diketahui”** when `stockKnown` is false instead of displaying an ambiguous zero.

## A3.2 Validation status

- [x] Changes committed to `flutter-clean-rebuild`.
- [x] Changed source files re-fetched from GitHub and key safeguards verified in source.
- [x] `flutter analyze` passed on an earlier A3 commit in GitHub Actions; rerun is required for the latest commit.
- [x] `flutter test` passed on an earlier A3 commit in GitHub Actions; rerun is required for the latest commit.
- [ ] Release APK build — the earlier run was still in progress when checked; verify the run for the latest commit.
- [ ] Database-level integration tests for checkout rollback, stock races, product identity conflicts and migration paths — not yet implemented.
- [ ] Physical Android testing — not performed by this source change.

## A3.3 Remaining risks before A3 can be called complete

1. The current product schema still has no unique database constraints on normalized product code or barcode. Save-time checks improve safety but are not a substitute for a migration-safe uniqueness design and import validation.
2. Checkout has no durable idempotency key/invoice identifier yet; repeated user submissions should be covered by an explicit operation guard and tests.
3. Database integration tests and migration tests are still required.
4. The product editor preserves extended metadata but does not yet provide fields to edit all of it.
5. Cloud sync still needs a confirmed authoritative source and conflict/preview contract.
6. The source catalog has 4,348 rows but contains no stock ledger; products seeded from it remain stock-unknown and checkout stays blocked until verified stock data is available.
7. Build/test status must be read from the run associated with the exact latest commit; a queued run is not a pass.

## A3 acceptance gate

A3 remains **in progress** until CI passes for the latest intended commit, database integration tests cover the P0 invariants, and the application is tested on an Android emulator or physical device. QRIS remains excluded; Flutter remains the sole runtime target.


## A3.4 Next implementation slice — product data entry

- [x] Expose supported product metadata in the product editor.
- [x] Require a product code in the form before attempting a save.
- [x] Validate non-negative integer price, purchase cost, stock and minimum stock in the form and database layer.
- [x] Make stock certainty an explicit operator action; existing unknown stock remains unknown until the checkbox is deliberately selected.
- [x] Show success/failure feedback for product saves.
- [ ] Verify the editor changes with latest-commit CI and Android runtime testing.
