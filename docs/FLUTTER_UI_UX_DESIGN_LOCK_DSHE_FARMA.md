# FLUTTER UI/UX DESIGN LOCK — APOTEK D'SHE FARMA

**Status:** `DESIGN_LOCKED`  
**Platform:** Flutter Android, mobile-first  
**Reference:** Project owner's screenshot showing a monochrome silver glassmorphism interface  
**Scope:** Visual system, reusable components, navigation, motion, accessibility, and acceptance criteria

---

## 1. Purpose

This document locks the intended visual direction for the Flutter version of **Apotek D'She Farma**. Future UI work must follow this specification rather than introducing unrelated visual styles.

The reference image is a visual-language reference, not a request to copy another application's content or branding. Adapt its material treatment and layout principles to pharmacy/POS workflows.

## 2. Design principles

1. **Monochrome Silver Glassmorphism** — charcoal, silver, pearl, and neutral gray form the core palette.
2. **Frosted glass with restraint** — translucent surfaces and background blur create depth without reducing readability.
3. **Mobile-first ergonomics** — frequent cashier actions must be reachable and legible on a phone.
4. **Information hierarchy** — price, product name, stock state, transaction total, and primary actions must be immediately scannable.
5. **Consistency** — light and dark themes share component geometry and hierarchy.
6. **Function before decoration** — blur, gradients, and animation must not interfere with scanning, typing, checkout, or accessibility.
7. **No false completion claims** — a visual change is not finished until it is built and checked on an Android device/emulator.

## 3. Theme system

### 3.1 Light theme — Pearl Crystal

| Token | Suggested value | Usage |
|---|---|---|
| `pearlBackground` | `#F1F3F6` | Main page background |
| `pearlSurface` | `#FFFFFF` | Main cards and sheets |
| `pearlSurfaceTint` | `#E8EDF2` | Secondary surfaces |
| `silverBorder` | `#D6DCE3` | Fine card outlines |
| `silverText` | `#5C6570` | Secondary text |
| `pearlText` | `#20252B` | Primary text |
| `pearlAccent` | `#7D9CA5` | Restrained focus/selection accent |

### 3.2 Dark theme — Charcoal Silver

| Token | Suggested value | Usage |
|---|---|---|
| `charcoalBackground` | `#111317` | Main page background |
| `charcoalSurface` | `#20242A` | Main cards |
| `charcoalSurfaceRaised` | `#2A3038` | Raised cards/sheets |
| `charcoalBorder` | `#454D57` | Fine borders |
| `silverText` | `#B9C1CB` | Secondary text |
| `charcoalText` | `#F1F3F6` | Primary text |
| `silverAccent` | `#AAB5C2` | Focus/selection accent |

These are starting tokens, not a requirement to use every color in every component. Keep the UI predominantly neutral and use accents sparingly.

## 4. Material and surfaces

- Use rounded cards with translucent fills, subtle borders, and restrained shadows.
- Apply `BackdropFilter` only where it improves visual depth; clip blur to the panel's rounded shape.
- Keep blur radii moderate; never blur text or product information.
- Provide a solid or near-solid fallback for low-performance devices and reduced-transparency settings.
- Avoid stacking expensive blur layers over scrolling lists.
- Cards: approximately 20–26 logical pixels radius.
- Search fields and primary controls: approximately 14–20 logical pixels radius.
- Floating navigation: capsule/large radius.
- Use thin, low-contrast borders and restrained shadows. Avoid neon glow, saturated gradients, and excessive shine.

## 5. Navigation

Primary mobile destinations remain:

1. **Kasir**
2. **QRIS**
3. **Cek Harga**
4. **Lainnya**

Requirements:
- Use a floating capsule-style bottom navigation inspired by the reference.
- Clearly distinguish the active destination with a compact selected state.
- Keep icons consistent in stroke/weight and labels readable on narrow devices.
- Respect Android system bars and safe areas; avoid oversized navigation or excessive bottom padding.
- On wider screens, adapt to a navigation rail/layout without changing destination order.
- **Initial destination:** Cek Harga, unless a product requirement explicitly changes it.

## 6. Brand identity and logo

- App name: **Apotek D'She Farma**.
- Do not use a generic stock pharmacy icon as the final brand mark.
- Treat the logo as a distinct brand asset/component that remains legible at small sizes.
- Logo color treatment must adapt to Pearl Crystal and Charcoal Silver themes.
- A placeholder or hand-drawn logo is not automatically the approved final logo; the owner must approve the final mark before release.
- Keep launcher icon, app-bar logo, splash branding, and in-app brand marks visually consistent.
- Do not alter the brand name or introduce unrelated symbols without approval.

## 7. Screen-specific guidance

### 7.1 Cek Harga — primary landing screen

Users must be able to check a product's price without adding it to a cart.

- Prominent search supporting product name, item code, and barcode.
- Clear search/clear actions and useful empty/loading/error states.
- Results show product name, code/barcode when available, and formatted selling price.
- Stock display distinguishes known/available, known low/empty, and unknown/unverified stock.
- Camera barcode scanning includes permission-denied and camera-failure states.
- Searching or scanning here must **not** automatically add a product to the cashier cart.
- Avoid dense paragraphs and unnecessary dashboard decoration.

### 7.2 Kasir

- Make product entry by typing/searching and barcode scanning easy to discover.
- Show suggestions when typing; selecting a result adds a product only within the cashier workflow.
- Support quantity selection before or during cart entry according to the approved flow.
- Clearly separate cart lines, quantity controls, subtotal, total, payment, and change.
- Prevent checkout if payment is insufficient or stock is insufficient/unknown under the approved stock policy.
- Provide feedback without relying on color alone.
- Do not remove existing POS capabilities as part of a visual redesign.

### 7.3 QRIS

- Keep QRIS accessible from primary navigation.
- Display the approved QRIS asset and payment instructions when configured.
- Do not imply payment succeeded merely because a QR image is displayed.
- Distinguish static QR display from verified payment confirmation. Verified success requires a supported provider integration or confirmed operator workflow.
- Do not invent transaction notifications or API credentials.

### 7.4 Lainnya

Provide a consistent entry point for inventory/product management, transaction history, reports, import/export, cloud catalog synchronization, and settings. Only show a workflow as available when implemented and communicate its state accurately.

## 8. Typography and content

- Use a clear hierarchy: screen title, section title, primary value, supporting metadata.
- Product names and prices must be easy to scan.
- Use Indonesian labels and familiar Rupiah formatting (for example, `Rp 12.000`).
- Avoid excessive all-caps labels, letter spacing, and decorative typography.
- Do not truncate critical prices, quantities, stock status, or payment results.
- Ellipsis is for secondary text only, with a way to inspect the full value when needed.

## 9. Motion and interaction

Use short, purposeful transitions: subtle navigation fade/slide, restrained card appearance, clear button press states, visible loading, and success/error feedback with text and icon.

- Motion must not delay checkout or barcode handling.
- Avoid looping decorative animations and large spring effects in cashier workflows.
- Respect reduced-motion/accessibility settings where practical.
- Interactive controls need appropriate pressed, disabled, loading, success, and error states.
- Frequent actions should have touch targets around 48×48 logical pixels or larger.

## 10. Accessibility and responsiveness

- Maintain readable contrast in both themes.
- Do not communicate stock/payment status using color alone.
- Support system text scaling without overflow.
- Respect safe areas, keyboard insets, and camera permission flows.
- Test narrow Android devices, common phone sizes, and wider screens.
- Avoid horizontal overflow, clipped navigation labels, and keyboard-obscured checkout controls.
- Blur must not reduce text contrast.

## 11. Performance

- Use blur selectively, especially in long scrolling lists.
- Avoid rebuilding expensive decorative layers on every keystroke.
- Debounce live search where appropriate.
- Keep barcode scanning responsive and use efficient list rendering for large catalogs.
- Do not run cloud sync on every keystroke or block the UI during synchronization.
- Always show sync progress and a meaningful completion/failure message.

## 12. Data integrity and POS safety

- Product search in Cek Harga must never create a cart line.
- Unknown stock must not be displayed as confirmed zero stock.
- Negative or invalid source stock must be marked unverified rather than silently represented as verified stock.
- Failed cloud fetch/validation must not partially overwrite the local catalog.
- Import must be transactional and must not delete local products merely because they are absent from the remote file.
- Payment success must not be inferred from QR display alone.
- Transaction/stock updates must remain atomic.
- Keep legacy `docs/index.html` unchanged as fallback until Flutter feature parity and device checks are accepted.

## 13. Flutter implementation guidance

- Centralize theme tokens and `ThemeData` for Pearl Crystal and Charcoal Silver.
- Build reusable widgets for glass cards, search fields, product result cards, status chips, and floating navigation.
- Avoid hard-coded theme-specific colors scattered across screens; prefer theme-aware semantic colors.
- Keep business logic and database operations out of UI widgets where possible.
- Keep the final logo as a separate asset or approved vector/widget.
- Database schema changes require explicit versioned migrations and migration tests.
- New dependencies require a clear reason and CI validation.

## 14. Acceptance checklist

### Visual
- [ ] Matches the monochrome silver glassmorphism direction of the supplied reference.
- [ ] Pearl Crystal light theme is consistent.
- [ ] Charcoal Silver dark theme is consistent.
- [ ] No stray white panels or unrelated saturated-green elements in dark mode.
- [ ] Blur is restrained and text remains readable.
- [ ] Bottom navigation is a compact floating capsule and respects safe areas.
- [ ] Brand marks are consistent and legible.

### Functional
- [ ] Cek Harga supports name/code/barcode search.
- [ ] Cek Harga never auto-adds items to the cart.
- [ ] Scanner handles permission denial and camera errors.
- [ ] Cashier validates payment and stock correctly.
- [ ] QRIS display does not falsely claim payment success.
- [ ] Cloud sync shows progress/results and preserves local data on failure.
- [ ] Existing legacy functions are not silently removed.

### Verification
- [ ] `flutter analyze` passes.
- [ ] `flutter test` passes.
- [ ] Android debug APK builds successfully.
- [ ] Database upgrades from supported schema versions are tested.
- [ ] Light and dark themes are inspected on Android emulator/device.
- [ ] Narrow-screen, keyboard, and system-bar behavior is checked.
- [ ] Remaining limitations are documented before release.

## 15. Change-control rule

This document is the visual source of truth. Do not change the theme direction, navigation order, brand name, or core interaction rules without an explicit owner request.

Implementation may refine spacing, contrast, and responsiveness **within** this design system. If an existing component conflicts with this reference, update the component to meet this document rather than weakening the design lock.

---

**End of design lock.**
