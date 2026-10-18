# Analisis UI/UX — Apotek D'she Farma POS Mobile

## Fokus
Membuat POS lebih cepat dipahami dan dioperasikan di ponsel sambil mempertahankan Pearl Crystal / Dark Pearl Charcoal Silver.

## 1. Hierarki visual
**Risiko:** terlalu banyak teks dan kartu dengan bobot visual sama membuat halaman terasa datar.  
**Perbaikan:** tampilkan informasi terpenting lebih dahulu; kelompokkan tindakan dan bedakan judul, angka, serta keterangan.

## 2. Konsistensi Dark Pearl
**Risiko:** kartu terang lama atau teks redup membuat tema terlihat tidak konsisten.  
**Perbaikan:** gunakan token charcoal/silver yang sama, periksa komponen dinamis dan inline style, lalu uji seluruh layar pada APK terbaru.

## 3. Input produk
Alur yang diharapkan:
1. Pengguna memilih **Ketik** atau **Scan barcode**.
2. Pada mode Ketik, kolom pencarian aktif dan hasil muncul saat pengguna mengetik.
3. Pengguna memilih produk yang sesuai.
4. Pengguna menentukan kuantitas sebelum menambahkan produk.
5. Keranjang dan total diperbarui langsung.
6. Kuantitas dapat diubah atau item dihapus tanpa mengulang proses.

Daftar barang tidak harus ditampilkan penuh sebelum pencarian dimulai. Sediakan state loading, hasil kosong, dan error.

## 4. Scanner barcode
- Tampilkan status izin kamera dan panduan jika izin belum diberikan.
- Beri feedback saat barcode terdeteksi.
- Sediakan input manual sebagai fallback.
- Cegah scan berulang menambahkan item tanpa sengaja.
- Uji barcode tidak dikenal dan produk tanpa barcode.

## 5. Keranjang dan pembayaran
- Item, subtotal, dan total harus mudah ditemukan.
- Sediakan ringkasan sebelum transaksi diselesaikan.
- Bedakan status menunggu, berhasil, gagal, dan dibatalkan.
- Tampilkan sukses hanya setelah proses benar-benar terverifikasi.

## 6. QRIS
QRIS yang tampil tidak membuktikan pembayaran diterima. Notifikasi otomatis memerlukan integrasi resmi penyedia/acquirer dan verifikasi transaksi. UI harus mengikuti status yang benar dari sistem.

## Checklist pengujian
- [ ] Ganti Pearl Crystal ↔ Dark Pearl dan periksa semua komponen.
- [ ] Tutup/buka aplikasi dan periksa persistensi tema.
- [ ] Cari produk, pilih hasil, ubah qty, lalu tambahkan ke keranjang.
- [ ] Uji barcode valid/tidak dikenal dan input manual.
- [ ] Uji keranjang kosong, qty tidak valid, stok kurang, dan item duplikat.
- [ ] Uji dialog, keyboard, loading, empty state, dan error.
- [ ] Uji QRIS tanpa menyatakan sukses sebelum verifikasi.
- [ ] Uji APK hasil build terbaru, bukan hanya source.

## Status
Dokumen ini merupakan analisis dan rencana pengujian. Checklist belum dianggap lulus sebelum pengujian aktual dicatat.

## Analisis tambahan — Dark Pearl v3
Perbaikan source terbaru menambah cakupan untuk:
- Token charcoal berlapis untuk latar, kartu, permukaan terangkat, dan input.
- Input, select, textarea, placeholder, serta focus state yang lebih terbaca.
- Mode **Ikuti sistem HP** ketika OS menggunakan dark mode.
- Kartu transaksi dan panel cloud yang sebelumnya berpotensi mempertahankan warna terang dari inline style.
- Pengecualian untuk QRIS agar area kode tetap memiliki latar putih untuk pemindaian.

### Risiko yang masih harus diuji
- Beberapa komponen legacy mungkin menggunakan inline style atau nama kelas yang tidak tercakup.
- Warna status sukses/peringatan/error harus tetap punya makna dan kontras.
- Hasil visual perlu diperiksa pada APK terbaru di perangkat nyata; perubahan CSS saja belum membuktikan semuanya tampil benar.

