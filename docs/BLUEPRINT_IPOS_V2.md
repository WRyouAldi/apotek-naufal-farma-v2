# BLUEPRINT — iPOS APOTEK NAUFAL FARMA V2
Status: BASELINE LOCKED — 2026-10-17
Repository: https://github.com/WRyouAldi/apotek-naufal-farma-v2

## 1. Tujuan
Menyelesaikan aplikasi POS apotek yang dapat dipakai untuk transaksi nyata setelah lolos uji operasional. Build APK yang sukses saja bukan bukti aplikasi siap digunakan.

## 2. Aturan desain dan perubahan
- Pertahankan desain lama Pearl Crystal Liquid Glass dan struktur navigasi V2.
- Tidak membuat repository atau aplikasi baru.
- Pertahankan database produk yang ada, termasuk kode produk, harga jual, harga beli, stok, supplier, dan lokasi/rak.
- Tidak perlu fitur scan barcode produk. QR hanya digunakan untuk menampilkan QRIS statis resmi merchant agar pelanggan memindainya untuk membayar.
- Perubahan fungsi dilakukan bertahap dengan uji regresi.
- Jangan mengganti atau menghapus data produk saat migrasi transaksi.
- Jangan pernah menyimpan kredensial atau secret pembayaran di aplikasi klien.
- QRIS statis harus menggunakan gambar resmi merchant; status bayar manual sampai integrasi API resmi tersedia.

## 3. Arsitektur sumber data
- SQLite native adalah sumber utama produk, transaksi penjualan, detail transaksi, dan stok di APK.
- localStorage hanya menjadi arsip/migrasi kompatibilitas, bukan sumber transaksi utama saat berjalan di APK.
- Riwayat dan laporan membaca data transaksi yang sama dengan proses kasir.
- Migrasi transaksi lama tidak mengubah stok historis.
- Data transaksi baru disimpan dalam tabel sales dan sale_items.

## 4. Alur transaksi (wajib atomik)
1. Kasir mencari produk berdasarkan nama atau kode produk; tidak ada pemindaian barcode produk.
2. Produk ditambahkan ke keranjang dengan harga dan jumlah.
3. Aplikasi menghitung total dari detail keranjang.
4. Validasi metode pembayaran, nominal, dan konfirmasi pembayaran non-tunai.
5. SQLite memulai transaksi database.
6. Validasi ulang invoice, produk, harga terbaru, dan stok terkini.
7. Simpan sales dan semua sale_items.
8. Kurangi stok pada products dan stock dalam transaksi database yang sama; setiap pembaruan harus terverifikasi.
9. Commit database. Jika satu langkah gagal, rollback seluruh perubahan.
10. Hanya setelah hasil tersimpan/terkonfirmasi, kosongkan keranjang dan muat ulang riwayat serta stok.

## 5. Pencegahan transaksi ganda
- Invoice harus unik.
- Retry dengan invoice dan detail yang sama boleh mengembalikan hasil idempotent tanpa mengurangi stok dua kali.
- Invoice sama dengan isi berbeda harus ditolak.
- UI harus mencegah klik bayar berulang selama permintaan berlangsung dan memulihkan status dengan aman jika terjadi timeout.

## 6. Pembatalan/void
- Tidak menghapus transaksi yang sudah dibayar secara permanen.
- Void wajib mencatat alasan, waktu, dan status.
- Pengembalian stok dilakukan dalam satu transaksi database dan hanya satu kali.
- Laporan omzet bersih mengecualikan transaksi VOIDED; laporan audit tetap dapat menampilkan transaksi void.
- Transaksi legacy yang diimpor tidak mengubah stok ketika dimigrasikan.

## 7. Modul
- Beranda: ringkasan dan akses cepat.
- Cek Harga/Produk: pencarian berdasarkan nama/kode, harga, stok, informasi produk.
- Kasir: keranjang, jumlah, total, metode pembayaran, nominal tunai/kembalian, konfirmasi non-tunai.
- Persediaan: data stok yang konsisten; perubahan stok tercatat.
- Riwayat Penjualan: invoice, tanggal, item, total, metode, status, pencarian/filter.
- Laporan: tanggal yang konsisten, jumlah transaksi, omzet bersih, total item, detail barang, void terpisah.
- Ekspor: CSV/Excel dan PDF A4.
- Printer: struk thermal Bluetooth.
- Backup/restore: transaksi dan produk dipisahkan jelas serta validasi sebelum restore.
- Sinkronisasi: konflik dan hasil sinkronisasi harus terlihat jelas; tidak boleh menimpa data tanpa konfirmasi.

## 8. Pengujian wajib
### Transaksi
- Tunai pas, tunai lebih, tunai kurang.
- QRIS/non-tunai belum dikonfirmasi dan sudah dikonfirmasi.
- Keranjang kosong, qty nol/negatif, harga berubah, total dimanipulasi.
- Stok cukup, stok tepat habis, stok tidak cukup.
- Klik bayar ganda, retry invoice sama, invoice sama dengan detail berbeda.
- Kegagalan penyimpanan di tengah transaksi harus rollback sales, sale_items, dan stok.
### Data
- Produk dengan kode/nama duplikat atau kosong.
- Migrasi transaksi lama berulang tidak menggandakan invoice dan tidak mengubah stok.
- Void berhasil, void berulang, alasan kosong, detail hilang, rollback void.
- Laporan tanggal hari ini, tanggal tanpa transaksi, pergantian bulan/tahun, dan transaksi void.
### Regresi
- Pencarian produk, scanner, import CSV, edit/hapus produk.
- Sinkronisasi, backup/restore, PDF A4, Excel, printer thermal.
- UI mobile dan navigasi lama.
### Build
- Validator statis.
- Kompilasi APK.
- Artefak APK tersedia.
- Pengujian di perangkat nyata sebelum status “siap operasional”.

## 9. Kriteria selesai
- Build sukses dan APK tersedia.
- Seluruh pengujian P0 lulus.
- Tidak ada transaksi atau pengurangan stok ganda.
- Stok tidak negatif dan kedua representasi stok konsisten.
- Riwayat dan laporan cocok dengan tabel sales.
- Laporan tidak menampilkan kode sumber.
- PDF dan struk dapat dicetak.
- Desain lama dan fitur yang sudah ada tidak regresi.

## 10. Status saat baseline dibuat
Sudah terlihat di repository: tabel SQLite sales/sale_items, bridge commitSale/salesHistory/voidSale/migrasi legacy, serta workflow build yang pernah sukses pada commit yang diperiksa. Ini belum membuktikan pengujian operasional penuh.
Prioritas berikutnya: audit P0 pada alur kasir, stok, void, riwayat/laporan; tambah pemeriksaan regresi yang bisa diotomasi; lalu uji APK di perangkat.
