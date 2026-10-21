# A1 — Consolidated Requirements Baseline
## Apotek D'She Farma — Clean Flutter Rebuild

**Status:** BASELINE CONSOLIDATED — pending owner review of brand asset and any unresolved business rules  
**Date:** 2026-10-21  
**Target branch:** `flutter-clean-rebuild`  
**Purpose:** One implementation contract for the clean Flutter rebuild. This document supersedes conflicting implementation instructions in older plans, but does not delete historical documents or business requirements that remain compatible.

---

## 1. Source-of-truth hierarchy

When documents disagree, apply this order:

1. **Latest explicit owner instruction** in the conversation/repository issue.
2. **This consolidated baseline** for the clean rebuild.
3. `docs/FLUTTER_UI_UX_DESIGN_LOCK_DSHE_FARMA.md` for detailed visual tokens and screen acceptance.
4. `docs/FLUTTER-MIGRATION-PLAN.md` for migration risks and data-validation requirements.
5. `docs/BLUEPRINT_IPOS_V2.md` and `docs/BLUEPRINT_IPOS_APOTEK_NAUFAL_FARMA_V2.md` for business rules, data integrity, and operational features, except where contradicted by newer explicit instructions.
6. `docs/DESIGN_SYSTEM_LOCK.md`, older P2.x reports, and historical migration notes are reference/history only where they conflict with the newer Flutter-specific lock.

Do not silently choose between conflicting rules. Record the conflict and apply the explicit decisions below.

## 2. Explicit decisions

- Product: **Apotek D'she Farma**.
- Platform/runtime: native Flutter Android; **no WebView runtime or fallback**.
- Rebuild: create a clean presentation architecture; do not carry forward old screen/widget layouts as the design foundation.
- Visual system: **Pearl Crystal Light** and **Charcoal Silver Dark**, monochrome silver glassmorphism, restrained blur, high readability, consistent geometry.
- Initial destination: **Cek Harga**.
- Primary navigation order: **Kasir / Cek Harga / Lainnya**.
- Cek Harga is read-only: search/scan must never mutate the cashier cart.
- **QRIS UI/payment-provider feature is excluded** by the latest owner instruction. Do not show QRIS screen, QRIS payment method, static QR, or imply payment-provider integration. Historical QRIS documentation remains archived but is not implementation scope.
- Unknown/unverified stock must be explicitly represented as unknown; never infer available or zero stock from missing data.
- Existing product/business data must not be deleted/reset until backup, migration, and reconciliation have been verified.
- A successful compile is not proof of visual acceptance or operational readiness.
- The existing generated/drawn monogram is provisional. Do not label a brand mark final until the owner-approved asset is identified/approved.

## 3. Visual design contract

### 3.1 Pearl Crystal Light tokens
- Background `#F1F3F6`
- Surface `#FFFFFF`
- Secondary surface `#E8EDF2`
- Border `#D6DCE3`
- Secondary text `#5C6570`
- Primary text `#20252B`
- Restrained decorative accent `#7D9CA5`

### 3.2 Charcoal Silver Dark tokens
- Background `#111317`
- Surface `#20242A`
- Raised surface `#2A3038`
- Border `#454D57`
- Secondary text `#B9C1CB`
- Primary text `#F1F3F6`
- Silver accent `#AAB5C2`

### 3.3 Surface and layout rules
- Use rounded cards (approximately 20–26 logical px), controls (14–20 px), and capsule navigation.
- Blur must be clipped to its surface, restrained, and never impair text/scanning or scroll performance.
- No excessive borders, repeated shine/glow, saturated unrelated accents, or stacked expensive blur layers.
- Light and dark themes must share layout hierarchy and geometry.
- Respect safe areas, keyboard insets, text scaling, reduced-motion preference, and narrow Android widths.
- Brand name must remain legible. Header/Hero must not consume space needed for core tasks.
- Navigation must not cover content; scrolling must reach the final item.
- No visual requirement is accepted solely from token/source inspection; inspect screenshots on emulator/device.

## 4. Navigation and screen requirements

### 4.1 Global shell
- Initial page: Cek Harga.
- Destinations, in order: Kasir, Cek Harga, Lainnya.
- Floating capsule navigation on phones; adaptive rail/layout on wider screens.
- Correct active state, readable labels, safe-area handling, no clipping/overlap.

### 4.2 Cek Harga
- Search by product name, product code, and barcode.
- Exact barcode lookup before fuzzy text search.
- Show product name, code/barcode where present, formatted selling price, and stock certainty.
- Include loading, empty, no-result, data-error, camera-permission-denied, and scanner-failure states.
- Scanning is optional to the user and must fail gracefully if camera access is unavailable.
- Must not add/edit/remove cart lines or otherwise change cashier state.

### 4.3 Kasir
- Search/type and barcode scanning are discoverable.
- Typing presents suggestions; selecting a result adds it only inside the cashier workflow.
- Quantity selection before/during cart entry follows a consistent, testable interaction.
- Separate cart lines, quantity, subtotal, total, payment amount/method, and change.
- Block empty-cart checkout, invalid/non-positive quantities, insufficient payment, and stock that is insufficient or unknown under the approved stock policy.
- Prevent repeated submit/double charge; recover safely from timeout or persistence error.
- Show success only after durable transaction commit.
- Preserve stock validation and atomic persistence.

### 4.4 Lainnya / operations
- Feature inventory must cover product/inventory management, transaction history, reports, import/export, cloud sync, backup/restore, settings, and printing.
- Implement each only against a defined data contract and acceptance test.
- Where a feature is not migrated/available, show an honest unavailable/incomplete state; never a fake success.
- No QRIS UI or payment-provider feature.

## 5. Data and business invariants

- Native Android database is the authoritative source for products, transactions, transaction details, and stock used by POS operations.
- Define canonical product and transaction models plus repository/service boundaries; widgets must not issue ad-hoc SQL.
- Preserve product code, barcode, name, selling price, purchase cost, stock, stock-known state, category/brand/unit, minimum stock, rack/location, supplier, and notes when present in source data.
- Missing stock remains unknown, not automatically available or confirmed zero.
- Product catalog seed/import must be idempotent; repeated app launches/imports must not duplicate records.
- Validate CSV schema, required columns, row counts, duplicates, prices, stock certainty, and malformed rows before writing.
- Import/sync writes must be transactional or have an explicit rollback/recovery plan; do not delete absent records without confirmation.
- Sales, sale items, and stock decrement must commit in one database transaction.
- Validate current product, price, quantity, and stock immediately before commit.
- Failure at any stage rolls back all transaction-related writes.
- Invoice uniqueness and idempotency prevent duplicate sales/stock decrement on retry.
- Prevent negative stock; if products and normalized stock tables coexist, verify consistency or define one canonical stock ledger.
- Transaction history and reports must read the same authoritative transaction source.
- Historical migration must be idempotent and must not change historical stock.
- Backups/restores require validation and reconciliation before replacing live data.
- Never store payment secrets in the app. QRIS/payment-provider integration is out of scope.

## 6. Migration scope and preservation policy

The rebuild must not copy the old screen/layout/widget implementation as its foundation. Legacy source may be inspected only to recover:
- data field mappings and product catalog source,
- business rules and operational feature inventory,
- report/receipt formats,
- import/export/sync behavior,
- validated assets and test cases.

Before using a legacy service or asset, verify its behavior, ownership, data format, and compatibility. Do not assume it is correct merely because it exists. Do not delete old branches, historical files, database sources, or catalog backups during rebuild.

Expected product count of 4,348 is a reconciliation target from historical documentation, not a verified current import result. Confirm actual source count and record-level reconciliation before declaring catalog migration complete.

## 7. Branding requirements

- Display name: **Apotek D'she Farma**.
- One approved brand asset must be used consistently for in-app logo, splash, and launcher icon where technically applicable.
- Theme-aware logo treatment must remain legible in both themes and at small sizes.
- Existing custom-painted monogram is provisional until owner approval.
- Do not invent or substitute a generic pharmacy icon as the final mark.

## 8. Architecture requirements

Use modular feature-first architecture. Suggested target:

```text
lib/
  app/             # app setup, routing, state composition
  core/
    theme/         # tokens, light/dark themes, typography
    components/    # reusable surfaces, controls, status, navigation
    utilities/
  features/
    price_check/
    cashier/
    inventory/
    transactions/
    reports/
    import_export/
    synchronization/
    settings/
  data/
    models/
    repositories/
    database/
    services/
  main.dart
```

This is a target architecture, not a claim that files already exist. Keep widgets presentation-only, data access in repositories/services, and business rules in testable domain/use-case code. Avoid one giant `main.dart`, duplicated theme values, and hidden global cart coupling.

## 9. Required tests and release gates

### Automated
- `flutter analyze` with no errors; resolve relevant warnings before release.
- `flutter test` for models, repositories, database migration/seed, search, cart isolation, checkout invariants, and widgets in both themes.
- Catalog tests for row count, field preservation, duplicates, empty/long names, special characters, zero prices, missing barcodes, and unknown stock.
- Transaction tests: empty cart, invalid quantity, exact/over/under payment, insufficient/unknown stock, duplicate invoice, double submit, write failure/rollback, restart persistence, and stock consistency.
- Responsive/widget tests at narrow phone dimensions and enlarged text scale.
- Clean Android debug and release builds; artifact SHA must match the commit under test.

### Manual emulator/physical device
- Inspect Pearl Crystal Light and Charcoal Silver Dark screenshots.
- Check branding, header, Hero/dashboard hierarchy where specified, search, cards, active navigation, keyboard, safe areas, scroll end, scanner permission/failure, offline search, app restart, checkout, history, and reports.
- Test a narrow phone and a larger screen.
- Verify no WebView runtime, no QRIS UI, and no hidden cart mutation from Cek Harga.
- Record actual pass/fail evidence; never infer a device pass from CI.

### Release rule
Do not declare production-ready until the required tests pass, catalog and transaction data are reconciled, the release artifact matches the latest intended commit, and Android device/emulator acceptance is recorded. Release signing must use an owner-controlled keystore/secrets; do not claim a production-signed artifact without evidence.

## 10. Open items that require explicit confirmation/evidence

1. **Final logo:** locate the owner-approved D'she Farma logo asset or obtain approval for the candidate; do not finalize the monogram by assumption.
2. **Stock policy:** define whether checkout is blocked whenever stock is unknown or whether an explicitly authorized override exists. Until confirmed, fail safe and block checkout for unknown stock.
3. **Source catalog:** identify the authoritative source, confirm record count, and reconcile all product fields including purchase cost and stock-known state.
4. **Existing database/history:** identify actual data source(s), backup procedure, migration scope, and reconciliation evidence before importing.
5. **Payment methods:** confirm permitted non-QRIS methods and manual confirmation rules; never imply provider confirmation automatically.
6. **Printer/device support:** confirm target thermal printer connectivity and required receipt width before selecting plugin/hardware assumptions.
7. **Cloud sync contract:** confirm authoritative source, conflict policy, authentication, and whether sync is one-way or bidirectional before production implementation.

## 11. Acceptance checklist (must be tracked, not assumed)

- [ ] Requirement conflicts resolved and this baseline accepted.
- [ ] Feature inventory and data-source map completed.
- [ ] Approved brand asset identified.
- [ ] Clean Flutter architecture created independently of old UI.
- [ ] Both themes and shared components implemented.
- [ ] Cek Harga acceptance tests pass.
- [ ] Cashier/checkout invariant tests pass.
- [ ] Catalog migration reconciled.
- [ ] Inventory/history/report/import/export/sync/backup/printing scope verified.
- [ ] Automated checks pass on the intended commit.
- [ ] Android visual and functional review recorded.
- [ ] Release artifact matches the intended commit and signing status is explicit.

**This document is a requirements baseline, not evidence that implementation or tests have completed.**
