from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
checks = []

def check(name, ok, detail):
    checks.append((name, bool(ok), detail))

arch = (ROOT / "tools/page_architecture_v5.js").read_text(encoding="utf-8")
pdf = (ROOT / "tools/patch_pdf_a4.py").read_text(encoding="utf-8")
main = (ROOT / "app/src/main/java/com/naufalfarma/apotek/MainActivity.kt").read_text(encoding="utf-8")
report = (ROOT / "tools/report_ui_v2.js").read_text(encoding="utf-8")
tx = (ROOT / "tools/transaction_print_v1.js").read_text(encoding="utf-8")
checkout = (ROOT / "app/src/main/assets/index.html").read_text(encoding="utf-8")
check("Pearl Crystal Liquid Glass theme is locked", "--nf-pearl:#f4f5f7" in (ROOT / "tools/ui_theme_v2.css").read_text(encoding="utf-8") and "--nf-green:#188b70" in (ROOT / "tools/ui_theme_v2.css").read_text(encoding="utf-8") and "DESIGN LOCK" in (ROOT / "tools/ui_theme_v2.css").read_text(encoding="utf-8"), "primary theme palette and lock declaration must remain in place")
check("Independent read-only Cek Harga", "Independent read-only price lookup" in arch and "nfPriceQuery" in arch and "nfPriceResults" in arch, "separate query and results are present")
check("Mobile POS active page is visible", ".nf-page.nf-active,.nf-page.active" in (ROOT / "tools/ui_theme_v2.css").read_text(encoding="utf-8") and "el.classList.toggle('nf-active',key===page)" in arch, "navigation class and CSS visibility selector must match")
check("Mobile POS opens on Dashboard with persistent Home navigation", "window.nfGo('home')" in arch and 'data-page="home"' in arch and "data-page=\"transaction\"" in arch, "launch route exposes the Dashboard Hero and Home remains reachable from every page")
check("Kasir retains existing cart", "nodes.cart" in arch and "nodes.results" in arch and "nfTransaction" in arch, "existing cashier search/results/cart remain connected")
check("POS barcode scanner is available across search features", "nfPriceScanBarcode" in arch and "nfCrudScanBarcode" in arch and "nfOutScanBarcode" in arch and "nfScanBarcode" in arch and "window.onNativeBarcodeScanned=function(code)" in arch, "scanner actions and destination-aware barcode routing exist for cashier, price lookup, item list, and stock-out")
check("Native product field mapping", '"price"' in main and '"stok"' in main and "p.price" in arch and "p.stok" in arch, "price/stok keys returned by ProductDb are supported")
check("A4 PDF uses native pagination", "PrintManager" in pdf and "createPrintDocumentAdapter" in pdf and "ISO_A4" in pdf, "native Android print pipeline configured")
check("PDF tables fit and wrap", "table-layout:fixed" in pdf and "overflow-wrap:anywhere" in pdf and "display:table-header-group" in pdf, "fixed table layout, wrapping and repeated headers configured")
key = "naufal_farma_transactions"
check("Report and receipt share transaction key", key in report and key in tx, "both modules use the same local transaction history")
check("Native reports read SQLite as the source of truth", "window.Android.salesHistory" in report and "window.Android.salesHistory" in tx, "reports and receipts must read native SQLite, not stale localStorage copies")
check("APK build uses canonical web UI baseline", "web_source=Path('docs/index.html')" in (ROOT / "tools/prepare_apk_v3.py").read_text(encoding="utf-8"), "latest web UI is synced before native build transformations")
check("APK source strips injected modules before reinjection", "'csvImportV2','githubCloudSyncV1'" in (ROOT / "tools/prepare_apk_v3.py").read_text(encoding="utf-8"), "CSV/cloud modules must not be duplicated during build")
check("Report totals have item fallback", "function total(t)" in report and "reduce((a,i)=>a+sub(i),0)" in report, "totals can be calculated from line items")
check("Native report reads SQLite history", "window.Android.salesHistory" in checkout and "function loadHistory()" in checkout, "Android reports use native SQLite sales as the primary source")
check("Voided sales excluded from net reports", 'String(tx.status||"LUNAS").toUpperCase()!=="VOIDED"' in checkout, "voided sales remain auditable but do not inflate daily net sales")
check("Report export template does not close parent script", "standalonePaymentHubStyle" not in checkout[checkout.find("const xls="):checkout.find("const blob=new Blob([xls]")] and "const blob=new Blob([xls]" in checkout, "Excel export template remains a single well-formed JavaScript string")
check("Report KPI excludes voided sales", 'dateOf(t)===e.value&&String(t?.status||"LUNAS").toUpperCase()!=="VOIDED"' in report, "daily report transaction count, sold quantity and omzet exclude voided sales")
check("POS rejects cash underpayment", 'if(cash<total){alert("Pembayaran Tunai kurang "' in checkout and "Transaksi belum disimpan." in checkout, "cash checkout must stop before persisting an underpaid sale")
check("QRIS requires manual DANA verification", 'id="paymentVerified"' in checkout and "notifikasi/riwayat transaksi di aplikasi DANA Bisnis" in checkout and "if(!verified)" in checkout, "non-cash payment requires explicit cashier confirmation after checking merchant payment status")
check("POS records invoice and payment method", 'paymentMethod:method' in checkout and 'invoice:"ANF-"' in checkout and 'status:"LUNAS"' in checkout, "transaction includes invoice, payment method and paid status")
check("POS customer field", 'id="customerName"' in checkout and "customer," in checkout, "optional customer is saved with the transaction")
check("Android POS persists sales in SQLite", "fun commitSale(tx: JSONObject)" in main and "CREATE TABLE IF NOT EXISTS sales" in main and "CREATE TABLE IF NOT EXISTS sale_items" in main, "native sales header and line items are stored in SQLite")
check("Native sale decrements stock atomically", "beginTransaction()" in main and "setTransactionSuccessful()" in main and "products SET stok=stok-?" in main and "stock SET quantity=quantity-?" in main, "sale and both stock representations are updated in a SQLite transaction")
check("Native sale deletion is guarded", "Transaksi POS tersimpan di SQLite dan tidak boleh dihapus langsung" in checkout and "typeof window.Android.salesHistory" in checkout, "native transaction history cannot be silently deleted through localStorage")
check("Android restore does not claim false success", "Restore transaksi langsung ke database POS Android belum tersedia" in checkout, "native restore is explicitly blocked until it can restore to SQLite safely")
check("Backup preserves legacy localStorage archive", "legacyLocalStorageTransactions" in checkout and "belum diimpor ke SQLite" in checkout, "legacy records are retained separately in backup")
check("SQLite history wildcard returns all sales", 'if (date == "*")' in main and "SELECT transaction_json FROM sales ORDER BY id DESC" in main, "history wildcard no longer filters for a literal asterisk")
check("Legacy history migration is idempotent", "fun importLegacyTransactions(rows: JSONArray)" in main and "SELECT id FROM sales WHERE invoice=?" in main and "migrateLegacyTransactionsToSQLite" in checkout, "legacy records are imported with invoice deduplication")
check("Legacy migration does not alter stock", "Historical imports deliberately do not change stock." in main, "legacy sales are imported as history only")
check("App seed refresh preserves live inventory", "preserveExistingStock = existingId != null" in main and 'SELECT stok FROM products WHERE id=?' in main and 'SELECT quantity FROM stock WHERE product_id=? AND office=\'default\' LIMIT 1' in main, "updating the bundled product seed must not reset quantities already changed by sales")
check("Duplicate invoice payload is validated", "Nomor invoice sudah dipakai untuk transaksi berbeda" in main, "same invoice with a different payload is rejected")
check("Voided invoice cannot be replayed as paid", 'same && stored.optString("status", "LUNAS") == "LUNAS"' in main, "idempotent retries only acknowledge still-paid transactions")
check("POS cancellation has audit reason", "fun voidSale(invoiceValue: String, reasonValue: String)" in main and "voidReason" in main and "voidedAt" in main, "void requires a reason and persists timestamp/reason in transaction history")
check("POS cancellation restores stock atomically", "UPDATE products SET stok=stok+?" in main and "UPDATE stock SET quantity=quantity+?" in main and "status='LUNAS'" in main, "void restores both stock representations and only marks paid sales void inside one SQLite transaction")
check("History exposes audited void action", "function voidTransaction(invoice)" in checkout and "window.Android.voidSale" in checkout and "data-invoice=" in checkout, "native history calls SQLite void API with invoice and cashier reason")
check("Dedicated POS checkout workspace", 'id="posWorkspaceV1"' in checkout and ("modal.id='posCheckoutModal'" in checkout or 'id="posCheckoutModal"' in checkout) and ("open.id='posCheckoutOpen'" in checkout or "id='posCheckoutOpen'" in checkout or 'id="posCheckoutOpen"' in checkout), "checkout is presented in a dedicated payment sheet instead of only inline fields")
check("QRIS merchant identity and asset safety", 'ID1026613777956' in checkout and 'id="pembayaranMandiri"' in checkout and "QRIS statis resmi" in checkout, "standalone QRIS menu keeps merchant identity and does not treat placeholder as a scannable asset")
check("P1 Dark Pearl covers dynamic modules", "dsheP1AllPages" in checkout and "#barangKeluarSection" in checkout and ".nf-crud-card" in checkout and "#nfCloudCard" in checkout and ".nf-glass-nav" in checkout, "Barang Keluar, Daftar Item, Cloud Sync and navigation share the P1 theme override")
check("P1 preserves scannable QRIS white canvas", "QRIS scanning surface must stay white" in checkout and ".payment-qris-frame img" in checkout and "background:#fff!important" in checkout, "QRIS image/canvas remains white and unfiltered in dark mode")
check("P1 dark theme keeps light theme untouched", "Light mode remains unchanged" in checkout and 'html[data-dshe-theme="dark"] .nf-crud-box' in checkout, "global module overrides are scoped to Dark Pearl/system dark rather than recoloring light mode")
seed = ROOT / "app/src/main/assets/products_seed.json"
if seed.exists():
    try:
        rows = json.loads(seed.read_text(encoding="utf-8"))
        costs = sum(1 for row in rows if int(row.get("cost", 0) or 0) > 0)
        check("Product seed count", len(rows) == 4348, f"expected 4348, got {len(rows)}")
        check("Purchase prices retained", costs >= 4000, f"expected >=4000, got {costs}")
    except Exception as exc:
        check("Product seed parses", False, str(exc))
else:
    check("Product seed exists", False, "run prepare_apk_v3.py before validation")

for name, ok, detail in checks:
    print(f"{'PASS' if ok else 'FAIL'}: {name} — {detail}")
passed = sum(ok for _, ok, _ in checks)
print(f"Static regression checks: {passed}/{len(checks)} passed")
if passed != len(checks):
    sys.exit(1)
