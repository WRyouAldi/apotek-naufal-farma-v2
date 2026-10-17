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
check("Independent read-only Cek Harga", "Independent read-only price lookup" in arch and "nfPriceQuery" in arch and "nfPriceResults" in arch, "separate query and results are present")
check("Kasir retains existing cart", "nodes.cart" in arch and "nodes.results" in arch and "nfTransaction" in arch, "existing cashier search/results/cart remain connected")
check("Barcode routed by active page", "Route scanner results according" in arch and "getElementById('nfPrice')?.classList.contains('nf-active')" in arch and "legacyBarcodeHandler(code)" in arch, "Cek Harga remains read-only and Kasir preserves legacy handler")
check("Native product field mapping", '"price"' in main and '"stok"' in main and "p.price" in arch and "p.stok" in arch, "price/stok keys returned by ProductDb are supported")
check("A4 PDF uses native pagination", "PrintManager" in pdf and "createPrintDocumentAdapter" in pdf and "ISO_A4" in pdf, "native Android print pipeline configured")
check("PDF tables fit and wrap", "table-layout:fixed" in pdf and "overflow-wrap:anywhere" in pdf and "display:table-header-group" in pdf, "fixed table layout, wrapping and repeated headers configured")
key = "naufal_farma_transactions"
check("Report and receipt share transaction key", key in report and key in tx, "both modules use the same local transaction history")
check("Report totals have item fallback", "function total(t)" in report and "reduce((a,i)=>a+sub(i),0)" in report, "totals can be calculated from line items")
checkout = (ROOT / "app/src/main/assets/index.html").read_text(encoding="utf-8")
check("POS rejects cash underpayment", 'if(cash<total){alert("Pembayaran Tunai kurang "' in checkout and "Transaksi belum disimpan." in checkout, "cash checkout must stop before persisting an underpaid sale")
check("QRIS requires manual DANA verification", 'id="paymentVerified"' in checkout and "notifikasi/riwayat transaksi di aplikasi DANA Bisnis" in checkout and "if(!verified)" in checkout, "non-cash payment requires explicit cashier confirmation after checking merchant payment status")
check("POS records invoice and payment method", 'paymentMethod:method' in checkout and 'invoice:"ANF-"' in checkout and 'status:"LUNAS"' in checkout, "transaction includes invoice, payment method and paid status")
check("POS customer field", 'id="customerName"' in checkout and "customer," in checkout, "optional customer is saved with the transaction")
check("Dedicated POS checkout workspace", 'id="posWorkspaceV1"' in checkout and 'id="posCheckoutModal"' in checkout and ("open.id='posCheckoutOpen'" in checkout or "id='posCheckoutOpen'" in checkout or 'id="posCheckoutOpen"' in checkout), "checkout is presented in a dedicated payment sheet instead of only inline fields")
check("QRIS merchant identity and asset safety", 'ID1026613777956' in checkout and 'QRIS resmi merchant belum tersedia' in checkout, "merchant identity is shown and missing QR image is not replaced with a fake code")
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
