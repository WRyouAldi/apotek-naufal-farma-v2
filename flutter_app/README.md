# Flutter migration foundation

This directory is an **incremental Flutter migration**, not yet a replacement for the production POS.

## Current status
- Material 3 foundation using the Pearl Crystal Light / Dark Pearl Charcoal Silver palettes.
- Persistent four-destination navigation and responsive dashboard shell.
- Explicit notice that production data and transaction logic are not connected.
- Widget tests and a CI workflow that analyzes, tests, and builds a debug APK.

## Critical migration rule
Do not switch the production APK to this Flutter app until feature parity and black-box tests pass. The current Android app contains a Kotlin native bridge and a large HTML/JavaScript POS, including the 4,348-product seed and existing transaction/storage functions. This Flutter shell intentionally does not simulate those operations.

## Next integration milestones
1. Define repository interfaces for products, inventory, sales, and transaction history.
2. Migrate the product database and persistence with data migration/backup checks.
3. Implement cashier search/autocomplete, barcode scanning, quantity, cart, totals, and payment persistence.
4. Migrate inventory/stock-out, item management, stock opname, sync, reports, and print.
5. Verify QRIS merchant identity and payment result handling before enabling real payment use.
6. Run unit/widget/integration tests and compare persisted records with the current app before switching the launcher.

## Run locally
From this directory:
```sh
flutter pub get
flutter analyze
flutter test
flutter run
```
