from pathlib import Path
import re

p = Path('app/src/main/java/com/naufalfarma/apotek/MainActivity.kt')
s = p.read_text(encoding='utf-8')

html_start = s.index('                val html = """', s.index('fun savePdf(title: String, bodyHtml: String)'))
html_end = s.index('                """.trimIndent()', html_start) + len('                """.trimIndent()')

new_html = '''                val html = """
                    <!doctype html><html><head><meta charset='utf-8'>
                    <meta name='viewport' content='width=595, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>
                    <style>
                    *{box-sizing:border-box}
                    html,body{margin:0;padding:0;background:#fff;width:595px;min-width:595px;max-width:595px}
                    body{font-family:Arial,sans-serif;color:#111;font-size:9pt;padding:34px;width:595px;max-width:595px;overflow:visible}
                    #pdfRoot{width:527px;max-width:527px;margin:0 auto;overflow:visible}
                    h1{text-align:center;font-size:17pt;line-height:1.15;margin:0 0 4px;max-width:527px}
                    h2{text-align:center;font-size:11pt;line-height:1.2;margin:0 0 10px;max-width:527px}
                    p{margin:4px 0 10px;max-width:527px}
                    table{width:527px!important;max-width:527px!important;border-collapse:collapse;table-layout:fixed}
                    thead{display:table-header-group}
                    tr{break-inside:avoid;page-break-inside:avoid}
                    th,td{border:1px solid #888;padding:5px 6px;vertical-align:top;overflow-wrap:anywhere;word-break:break-word;white-space:normal}
                    th{background:#eee}
                    img,svg,canvas,iframe,pre{max-width:527px!important}
                    .r{text-align:right;white-space:nowrap}
                    .total{margin:12px 0 0 auto;width:300px;max-width:527px}
                    .total th,.total td{font-weight:700}
                    </style></head><body><div id='pdfRoot'>$bodyHtml</div></body></html>
                """.trimIndent()'''

s = s[:html_start] + new_html + s[html_end:]

start = s.index('        private fun savePdfFromWebView(view: WebView, title: String) {')
end = s.index('        private fun toast(message: String)', start)

new_func = '''        private fun savePdfFromWebView(view: WebView, title: String) {
            // Use Android's WebView print adapter for real document pagination.
            // Drawing a tall WebView onto repeated PdfDocument canvases clips content
            // on some Android WebView versions, which caused the reported cut-off PDF.
            val safeTitle = title.replace(Regex("[^A-Za-z0-9._-]"), "_")
            val filename = if (safeTitle.lowercase().endsWith(".pdf")) safeTitle else "$safeTitle.pdf"
            var outputUri: Uri? = null
            var descriptor: android.os.ParcelFileDescriptor? = null
            try {
                val values = ContentValues().apply {
                    put(MediaStore.Downloads.DISPLAY_NAME, filename)
                    put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
                    put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                    put(MediaStore.Downloads.IS_PENDING, 1)
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    outputUri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                        ?: throw IllegalStateException("Gagal membuat file PDF")
                    descriptor = contentResolver.openFileDescriptor(outputUri, "w")
                        ?: throw IllegalStateException("Gagal membuka file PDF")
                } else {
                    val dir = getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
                        ?: throw IllegalStateException("Folder Download tidak tersedia")
                    dir.mkdirs()
                    descriptor = android.os.ParcelFileDescriptor.open(
                        File(dir, filename),
                        android.os.ParcelFileDescriptor.MODE_CREATE or
                            android.os.ParcelFileDescriptor.MODE_TRUNCATE or
                            android.os.ParcelFileDescriptor.MODE_WRITE_ONLY
                    )
                }

                val adapter = view.createPrintDocumentAdapter(filename)
                val attrs = android.print.PrintAttributes.Builder()
                    .setMediaSize(android.print.PrintAttributes.MediaSize.ISO_A4)
                    .setResolution(android.print.PrintAttributes.Resolution("naufal_pdf", "PDF", 300, 300))
                    .setMinMargins(android.print.PrintAttributes.Margins.NO_MARGINS)
                    .build()
                val targetDescriptor = descriptor
                    ?: throw IllegalStateException("File PDF tidak siap")

                adapter.onLayout(
                    null, attrs, android.os.CancellationSignal(),
                    object : android.print.PrintDocumentAdapter.LayoutResultCallback() {
                        override fun onLayoutFinished(
                            info: android.print.PrintDocumentInfo,
                            changed: Boolean
                        ) {
                            adapter.onWrite(
                                arrayOf(android.print.PageRange.ALL_PAGES),
                                targetDescriptor,
                                android.os.CancellationSignal(),
                                object : android.print.PrintDocumentAdapter.WriteResultCallback() {
                                    override fun onWriteFinished(pages: Array<android.print.PageRange>) {
                                        try {
                                            targetDescriptor.close()
                                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && outputUri != null) {
                                                val done = ContentValues().apply {
                                                    put(MediaStore.Downloads.IS_PENDING, 0)
                                                }
                                                contentResolver.update(outputUri!!, done, null, null)
                                            }
                                            toast("PDF A4 tersimpan di Download/$filename")
                                        } catch (e: Exception) {
                                            toast("PDF dibuat, tetapi finalisasi gagal: ${e.message}")
                                        } finally {
                                            (view.parent as? ViewGroup)?.removeView(view)
                                            view.destroy()
                                        }
                                    }

                                    override fun onWriteFailed(error: CharSequence?) {
                                        try { targetDescriptor.close() } catch (_: Exception) {}
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && outputUri != null) {
                                            try { contentResolver.delete(outputUri!!, null, null) } catch (_: Exception) {}
                                        }
                                        toast("Gagal menulis PDF: ${error ?: "kesalahan tidak diketahui"}")
                                        (view.parent as? ViewGroup)?.removeView(view)
                                        view.destroy()
                                    }
                                }
                            )
                        }

                        override fun onLayoutFailed(error: CharSequence?) {
                            try { targetDescriptor.close() } catch (_: Exception) {}
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && outputUri != null) {
                                try { contentResolver.delete(outputUri!!, null, null) } catch (_: Exception) {}
                            }
                            toast("Gagal menata halaman PDF: ${error ?: "kesalahan tidak diketahui"}")
                            (view.parent as? ViewGroup)?.removeView(view)
                            view.destroy()
                        }
                    },
                    null
                )
            } catch (e: Exception) {
                try { descriptor?.close() } catch (_: Exception) {}
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && outputUri != null) {
                    try { contentResolver.delete(outputUri!!, null, null) } catch (_: Exception) {}
                }
                toast("Gagal menyimpan PDF: ${e.message}")
                (view.parent as? ViewGroup)?.removeView(view)
                view.destroy()
            }
        }
'''

s = s[:start] + new_func + s[end:]
p.write_text(s, encoding='utf-8')
print('A4 PDF patch applied')
