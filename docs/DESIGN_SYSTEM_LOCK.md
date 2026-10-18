# Apotek Naufal Farma V2 — Design System Lock

**Status: LOCKED — PRIMARY THEME**

The sole primary visual theme is **Pearl Crystal Liquid Glass**. Do not replace it with a different theme, redesign the visual foundation, or create a separate app/repository.

## Locked visual foundation
- Pearl White: `#F4F5F7`
- Mint Green: `#188B70`
- Deep Green: `#126A57`
- Charcoal Ink: `#202632`
- Crystal-white glass surfaces, subtle silver borders, restrained blur, soft shadows, and rounded components.
- Motion remains short, purposeful, and respects `prefers-reduced-motion`.

## Allowed improvements
- Fix layout defects, overflow, alignment, spacing, and mobile responsiveness.
- Improve visual hierarchy, accessibility, focus states, touch targets, and navigation transitions.
- Polish hero, cards, search, cashier/cart/checkout, QRIS, stock-out, reports, and history **within the existing theme**.

## Protected behavior and data
Do not regress the existing product database (4,348 products), sale/purchase prices, barcode search/scanning, cashier and transaction persistence, stock consistency, QRIS separation and verification, reports, A4 PDF, thermal printing, or synchronization.

## Release gate
A successful build is required before calling a change build-ready. Visual behavior and operational flows must still be verified on an Android device; a build passing alone does not prove device-level correctness.

## Change policy
Only change the theme foundation if the user explicitly asks to unlock/revise this decision. Otherwise, every future UI/UX pass must preserve this theme.
