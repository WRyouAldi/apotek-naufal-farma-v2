from pathlib import Path
import re

p = Path('app/src/main/java/com/naufalfarma/apotek/MainActivity.kt')
s = p.read_text(encoding='utf-8')

html_start = s.index('                val html = """', s.index('fun savePdf(title: String, bodyHtml: String)'))
html_end = s.index('                """.trimIndent()', html_start) + len('                """.trimIndent()')

new_html = '''                val html = """
                    <!doctype html><html><head><meta charset='utf-8'>
                    <meta name='viewport' content='width=794, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
                    <style>
                    *{box-sizing:border-box}
                    html,body{margin:0;padding:0;background:#fff;width:794px;min-width:794px;max-width:794px}
                    body{font-family:Arial,sans-serif;color:#111;font-size:9pt;padding:34px;width:794px;max-width:794px;overflow:visible}
                    #pdfRoot{width:726px;max-width:726px;margin:0 auto;overflow:visible}
                    h1{text-align:center;font-size:17pt;line-height:1.15;margin:0 0 4px;max-width:726px}
                    h2{text-align:center;font-size:11pt;line-height:1.2;margin:0 0 10px;max-width:726px}
                    p{margin:4px 0 10px;max-width:726px}
                    table{width:726px!important;max-width:726px!important;border-collapse:collapse;table-layout:fixed}
                    thead{display:table-header-group}
                    tr{break-inside:avoid;page-break-inside:avoid}
                    th,td{border:1px solid #888;padding:5px 6px;vertical-align:top;overflow-wrap:anywhere;word-break:break-word;white-space:normal}
                    th{background:#eee}
                    img,svg,canvas,iframe,pre{max-width:726px!important}
                    .r{text-align:right;white-space:nowrap}
                    .total{margin:12px 0 0 auto;width:300px;max-width:726px}
                    .total th,.total td{font-weight:700}
                    </style></head><body><div id='pdfRoot'>$bodyHtml</div></body></html>
                """.trimIndent()'''

s = s[:html_start] + new_html + s[html_end:]

# Ensure the hidden WebView's physical width corresponds to an A4 CSS viewport.
layout_old = '(window.decorView as? ViewGroup)?.addView(pdfWebView, ViewGroup.LayoutParams(595, ViewGroup.LayoutParams.WRAP_CONTENT))'
layout_new = '''val cssPageWidth = 794
                val webViewPixelWidth = (cssPageWidth * resources.displayMetrics.density).toInt()
                (window.decorView as? ViewGroup)?.addView(
                    pdfWebView,
                    ViewGroup.LayoutParams(webViewPixelWidth, ViewGroup.LayoutParams.WRAP_CONTENT)
                )'''
if layout_old in s:
    s = s.replace(layout_old, layout_new)
elif 'val webViewPixelWidth = (cssPageWidth * resources.displayMetrics.density).toInt()' not in s:
    raise SystemExit('Could not locate WebView width setup; aborting PDF patch')


start = s.index('        private fun savePdfFromWebView(view: WebView, title: String) {')
end = s.index('        private fun toast(message: String)', start)

new_func = '''        private fun savePdfFromWebView(view: WebView, title: String) {
            // Delegate pagination and PDF generation to Android's native print pipeline.
            // PrintDocumentAdapter callbacks have package-private constructors, so the
            // supported public entry point is PrintManager.print().
            val safeTitle = title.replace(Regex("[^A-Za-z0-9._-]"), "_")
            val filename = if (safeTitle.lowercase().endsWith(".pdf")) safeTitle else "$safeTitle.pdf"
            try {
                val attrs = android.print.PrintAttributes.Builder()
                    .setMediaSize(android.print.PrintAttributes.MediaSize.ISO_A4)
                    .setResolution(android.print.PrintAttributes.Resolution("naufal_pdf", "PDF", 300, 300))
                    .setMinMargins(android.print.PrintAttributes.Margins.NO_MARGINS)
                    .build()
                val printManager = getSystemService(android.content.Context.PRINT_SERVICE) as android.print.PrintManager
                printManager.print(filename, view.createPrintDocumentAdapter(filename), attrs)
                toast("Pilih 'Save as PDF' pada dialog cetak untuk menyimpan laporan A4.")
            } catch (e: Exception) {
                toast("Gagal membuka pencetakan PDF: ${e.message}")
            } finally {
                // Keep the WebView alive while Android's print adapter consumes it.
                view.postDelayed({
                    (view.parent as? ViewGroup)?.removeView(view)
                    view.destroy()
                }, 60000)
            }
        }
'''

s = s[:start] + new_func + s[end:]
p.write_text(s, encoding='utf-8')
print('A4 PDF patch applied')
