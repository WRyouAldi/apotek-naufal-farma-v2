# BLUEPRINT IMPLEMENTASI — iPOS APOTEK NAUFAL FARMA V2
Versi: 1.0 | Status: Aktif dikerjakan
Repository: WRyouAldi/apotek-naufal-farma-v2

## 1. Tujuan
Mengubah V2 yang sudah ada menjadi POS apotek yang konsisten untuk operasional, bukan sekadar tampilan atau APK yang bisa dibuka. Pertahankan desain lama Pearl Crystal Liquid Glass, database produk, navigasi, dan fitur yang sudah ada.

## 2. Aturan yang tidak boleh dilanggar
- Jangan membuat repository/aplikasi baru.
- Jangan mengganti tema Pearl Crystal Liquid Glass dengan tema baru.
- Jangan menghapus atau mereset 4.348 data produk dan harga beli.
- Jangan menyatakan siap sebelum build dan pengujian fungsional berhasil.
- SQLite menjadi sumber utama transaksi pada APK Android.
- Web/browser mode boleh tetap memakai localStorage sebagai fallback, tetapi jangan menulis transaksi native ke dua sumber data yang dapat berbeda.
- QRIS statis tidak boleh dianggap terverifikasi otomatis; konfirmasi manual tetap diperlukan.

## 3. Arsitektur transaksi
Alur: Cari/scan produk -> keranjang -> validasi harga dan stok -> pembayaran -> satu transaksi SQLite atomik -> kurangi stok -> riwayat -> laporan -> struk/PDF.

Tabel utama:
- products: master produk dan stok yang ditampilkan aplikasi.
- stock: saldo stok ter-normalisasi per lokasi.
- sales: header transaksi, invoice unik, waktu, pelanggan, metode pembayaran, total, tunai, kembalian, status.
- sale_items: detail item, kuantitas, harga, subtotal.
- db_meta: metadata seed/migrasi.

## 4. Invarian transaksi (wajib)
1. Invoice unik dan idempotensi: retry tidak boleh membuat penjualan kedua atau mengurangi stok dua kali.
2. Validasi seluruh item, produk, harga, kuantitas, stok, metode dan nominal pembayaran sebelum commit.
3. Penjualan, detail item, dan pengurangan stok berada dalam satu SQLite transaction.
4. Jika satu validasi atau penulisan gagal, rollback semua perubahan.
5. Kedua representasi stok (products.stok dan stock.quantity) tidak boleh berbeda; operasi harus memverifikasi setiap baris yang diubah.
6. Setelah commit native berhasil, UI tidak boleh menandai transaksi gagal hanya karena cache/penyimpanan lokal tambahan gagal.
7. Pembayaran non-tunai hanya dicatat lunas setelah konfirmasi kasir yang eksplisit; QRIS statis tidak memberikan callback otomatis.

## 5. Satu sumber data
- APK Android: SQLite menjadi sumber transaksi, riwayat, dan laporan.
- Browser non-Android: localStorage fallback.
- Riwayat dan laporan native membaca transaksi SQLite yang sama.
- Format tanggal filter laporan adalah yyyy-MM-dd; sold_date disimpan dalam format ISO yyyy-MM-dd, bukan string tanggal lokal.
- Data lama di localStorage perlu jalur migrasi satu kali yang idempoten; jangan menghapus data lama tanpa verifikasi hasil migrasi.

## 6. Modul dan kriteria penerimaan
### P0 — Transaksi dan stok
- Pembayaran tunai kurang ditolak.
- Stok kurang ditolak.
- Penjualan berhasil tersimpan tepat satu kali.
- Invoice duplikat tidak mengurangi stok ulang.
- Kegagalan penulisan membatalkan seluruh perubahan.
- products.stok dan stock.quantity konsisten.

### P1 — Riwayat dan laporan
- Riwayat membaca SQLite di APK.
- Filter tanggal menggunakan tanggal ISO lokal yang konsisten.
- Omzet = jumlah total transaksi sukses pada tanggal tersebut.
- Qty dan subtotal dihitung dari sale_items; total tidak terduplikasi akibat item yang sama.
- Ekspor Excel dan PDF menggunakan hasil filter yang sama.

### P2 — Operasional
- Pencarian dan barcode menambah produk yang benar ke keranjang.
- Struk thermal menampilkan invoice, waktu, item, total, metode pembayaran, tunai/kembalian bila relevan.
- PDF A4 tetap berfungsi.
- UI responsif dan tema lama tetap terjaga.

## 7. Rencana pengujian minimum
1. Tunai pas, tunai lebih, tunai kurang.
2. QRIS belum dikonfirmasi dan QRIS terkonfirmasi manual.
3. Stok cukup, stok tepat habis, stok kurang.
4. Invoice duplikat dan tombol bayar ditekan berulang.
5. Kegagalan insert detail/stock harus rollback seluruh transaksi.
6. Tutup dan buka ulang aplikasi; transaksi tetap tersedia.
7. Filter hari ini dan tanggal lain.
8. Cocokkan jumlah transaksi, omzet, qty, dan detail antara kasir, riwayat, laporan, Excel/PDF.
9. Regresi database produk, import CSV, barcode, backup/restore, PDF dan thermal.
10. Build APK bersih dan verifikasi artefak.

## 8. Status awal yang telah ditemukan
- SQLite products, sales, sale_items tersedia di kode.
- commitSale sudah dipanggil dari kasir native.
- Riwayat/laporan masih membaca localStorage; ini harus disatukan.
- Implementasi stok perlu memeriksa hasil kedua update stok dan konsistensi rollback.
- Build workflow terakhir pernah hijau, tetapi itu bukan bukti semua alur POS telah lolos uji perangkat.

## 9. Definition of Done
POS baru dinyatakan siap setelah:
- build APK sukses pada commit terbaru;
- semua pemeriksaan statis dan sintaks lulus;
- pengujian fungsional P0/P1 lulus;
- tidak ada transaksi/stock mismatch;
- laporan cocok dengan transaksi SQLite;
- fitur lama dan tema lama lolos regresi.
