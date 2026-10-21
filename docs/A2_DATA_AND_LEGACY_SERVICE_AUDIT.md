# A2 — Audit Data, Database, and Legacy Services
## Apotek D'She Farma — Flutter Clean Rebuild

**Branch:** `flutter-clean-rebuild`  
**Audit date:** 2026-10-21  
**Scope:** Read-only source audit of the catalog asset, Flutter product/transaction models, SQLite implementation, cloud CSV sync, current tests, and historical migration/blueprint documents. This is an audit report, not a claim that runtime/device tests have passed.

## 1. Executive result

**A2 status: audit findings recorded; migration is NOT yet approved for live operation.**

The repository contains a valid-looking static product catalog with 4,348 rows and a working outline for native SQLite persistence. However, the data currently available in `assets/products.json` is a **price catalog**, not a verified inventory ledger. Core safeguards exist (transactional seed, transactional checkout, unknown-stock flag), but several integrity and feature gaps must be resolved before production use.

## 2. Source catalog verification

Inspected `assets/products.json` on this branch and parsed it as JSON.

| Check | Result |
|---|---|
| Row count | **4,348** |
| Fields present | `code`, `barcode`, `name`, `price` |
| Empty product codes | 0 |
| Empty product names | 0 |
| Negative/non-numeric prices | 0 |
| Zero prices | 0 |
| Duplicate normalized product codes | 0 |
| Duplicate non-empty barcodes | 0 |
| Blank barcodes | **4,323 / 4,348** |
| Stock / purchase cost / category / supplier fields in asset | Not present |

This confirms the JSON asset has 4,348 records and no duplicate codes under trim + case-insensitive comparison. It does **not** prove parity with the current cloud CSV or any historic local database. Only 25 rows have a non-blank barcode, so barcode scan coverage from this asset alone is limited.

## 3. Data model and SQLite findings

Files inspected: `lib/models.dart`, `lib/pos_database.dart`.

### Existing foundation worth preserving
- Native SQLite is used; no WebView runtime is required by these services.
- Product model can represent price, stock certainty, category, brand, unit, purchase cost, minimum stock, rack, supplier, and notes.
- Database has product name/code/barcode indexes.
- Product seed is guarded by an empty-table check and writes inside a SQLite transaction.
- Seeded JSON products are correctly assigned `stock_known = 0`; the code does not infer inventory from the missing stock field.
- Checkout groups stock decrement, transaction header, and transaction items inside one database transaction. A failed stock update throws and should roll back the sale.

### Risks / gaps requiring fixes or explicit acceptance
1. **Schema identity and uniqueness:** product code and barcode are indexed but not declared unique. The seed uses `ConflictAlgorithm.ignore`, which does not prevent logical duplicates when no matching unique constraint exists. Current JSON has unique codes, but import/sync must validate uniqueness too.
2. **Product edit loses stock certainty:** the current UI's basic product editor builds a new `Product` without carrying `stockKnown` and the extended metadata fields. Its defaults can make an unknown stock appear known when saved, and can replace cost/category/supplier/rack/notes with defaults. Do not use this editor for production inventory until fixed.
3. **Checkout validates stock, but stale price/quantity are not reloaded:** checkout uses the price and subtotal on the cart model, while its SQL update only checks stock. Re-read canonical product price and stock in the transaction before writing, validate each quantity is positive, and calculate totals from database values.
4. **Duplicate cart lines:** if the same product appears in more than one line, each line is processed sequentially. This can work for stock checks but needs explicit aggregation/validation and tests to prevent inconsistent totals or accidental double submit.
5. **No idempotency/double-submit guard is visible at the database boundary:** add a checkout operation guard or unique operation/invoice identifier before considering checkout complete.
6. **Schema migrations need tests:** the database version is 3 and has incremental ALTER statements. No migration tests were found in the inspected test files.
7. **History is incomplete:** current model/query returns only the last 100 transaction headers. Transaction-item details, invoice/receipt representation, reports, export and historical migration have not been verified as implemented.

## 4. Cloud catalog sync audit

File inspected: `lib/cloud_catalog_sync.dart`.

### Existing safeguards
- HTTP status, empty response, expected header, required code/name/price columns, malformed rows, and a minimum 1,000 valid-row guard are checked before database writes.
- Parsed records are applied in a SQLite transaction.
- Records absent from the CSV are not deleted.
- Missing/negative stock is represented as unknown rather than confirmed zero inventory.

### Risks / gaps
1. **Source authority is not confirmed.** The code reads a public CSV from the legacy repository. The owner must confirm that this is the canonical current catalog before production sync is enabled.
2. **Sync can overwrite local product edits.** Existing rows matched by product code are updated with imported values, including stock certainty and fields that may be absent in the source. Define source-of-truth and field-level conflict rules first.
3. **No reconciliation report:** the current summary counts read/inserted/updated/skipped/negative-stock rows but does not report duplicate source codes, ambiguous matches, field-level changes, or before/after reconciliation.
4. **No duplicate-code rejection:** the source is parsed row by row; duplicate codes may cause repeated updates to one database record in a single sync.
5. **Number parsing needs locale tests:** `_number` strips dots and commas indiscriminately. This is compatible with simple Indonesian thousands-formatted values such as `13.000`, but decimal formats and unexpected input must be covered by tests before relying on it for all exports.
6. **CSV parser needs edge-case tests:** quoted delimiters/newlines, inconsistent row widths, malformed quotes, CRLF and BOM behavior are not covered by tests currently inspected.
7. **Network/offline behavior is unverified on device.** A timeout is configured, but this source audit is not proof of runtime reliability.

## 5. Legacy documentation reconciliation

Historical blueprints contain QRIS requirements and some conflicting barcode behavior. These are historical references only. The newer owner-specific baseline takes precedence:
- Flutter native UI only; no WebView fallback.
- QRIS and provider-payment UI are excluded.
- Cek Harga remains read-only and must not mutate the cashier cart.
- Unknown stock must not be represented as zero or as available.
- Preserve legacy source files/data until backup and reconciliation are evidenced.

The old blueprint's instructions about static QRIS must **not** be reimplemented.

## 6. Test evidence audit

Inspected `test/models_test.dart`, `test/visual_system_test.dart`, and `docs/P2.3.1-blackbox-test-report.md`.

- Current model tests cover subtotal arithmetic and basic Product map conversion only.
- Visual tests lock several theme tokens and contrast checks, but they do not validate every screen or interactive flow.
- The historic black-box report explicitly marks several runtime cases NOT RUN.
- No results from a fresh `flutter analyze`, `flutter test`, clean release build, or physical-device session are asserted by this report.

**A passing source inspection is not a passing build or runtime test.**

## 7. Required remediation backlog (ordered)

### A2-R1 — Protect product identity and import integrity (P0)
- Normalize and validate product codes before import/sync.
- Detect duplicate source codes and duplicate barcodes; show a preview/report and do not silently merge ambiguous rows.
- Add appropriate database uniqueness constraints only after existing data has been checked and a migration plan exists.
- Test repeat seed/sync and conflict behavior.

### A2-R2 — Preserve inventory certainty and metadata (P0)
- Fix product editor so it round-trips every supported field and preserves `stockKnown`.
- Separate “stock value = 0” from “stock unknown” in the UI and data operations.
- Do not enable checkout when stock is unknown until an explicit owner-approved override policy exists.

### A2-R3 — Harden checkout transaction (P0)
- Reload products and authoritative prices inside the database transaction.
- Validate positive integer quantities, recompute line subtotals/total from canonical values, and recheck known stock.
- Aggregate duplicate product lines or reject duplicates deterministically.
- Add double-submit/idempotency protection and rollback tests.

### A2-R4 — Establish catalog sync contract (P1)
- Confirm authoritative source and allowed fields to overwrite.
- Add duplicate detection, field-level reconciliation, and a preview/confirmation step.
- Test malformed CSV, locale-formatted prices, truncated downloads, no-op sync, partial invalid rows and repeated sync.

### A2-R5 — Verify database and operational history (P1)
- Add schema migration tests from every supported version.
- Add transaction-item detail queries, durable invoice/receipt identity, and history/report consistency tests.
- Define backup/restore and historical transaction migration before touching any existing live database.

### A2-R6 — Evidence-based validation (P1)
- Run analyzer/tests/build on the exact branch commit and record commit SHA + run result.
- Execute emulator/device tests for search, barcode permission/error, offline use, unknown stock, valid/invalid checkout, rollback, restart persistence and theme/layout.
- Keep QRIS and WebView absent from the implementation.

## 8. Data preservation rules for the next phase

- Never overwrite or delete an existing database during rebuild.
- Do not treat the 4,348-row JSON as the complete inventory ledger.
- Do not silently convert unknown stock into verified stock.
- Do not sync against the legacy CSV as an authoritative source until confirmed.
- Take and verify a backup before any real-data migration.
- Keep any imported catalog migration idempotent and produce a row-level reconciliation summary.

## 9. A2 acceptance

A2 establishes the audit baseline and priority remediation list. A2 is **not** a production-readiness sign-off. The next phase should implement the P0 data integrity safeguards before expanding features or styling.

### Evidence reviewed
- `assets/products.json`
- `lib/models.dart`
- `lib/pos_database.dart`
- `lib/cloud_catalog_sync.dart`
- `test/models_test.dart`
- `test/visual_system_test.dart`
- `docs/FLUTTER-MIGRATION-PLAN.md`
- `docs/BLUEPRINT_IPOS_V2.md`
- `docs/BLUEPRINT_IPOS_APOTEK_NAUFAL_FARMA_V2.md`
- `docs/P2.3.1-blackbox-test-report.md`
- `docs/A1_CONSOLIDATED_REQUIREMENTS_BASELINE.md`
