# Build dan Testing — Android APK

## Tujuan
Memastikan APK dibangun dari source terbaru dan perubahan UI benar-benar hadir di aplikasi.

## Alur build
Workflow repository berada di `.github/workflows/build-apk.yml`.
1. Buka tab **Actions** di repository.
2. Pilih workflow build APK.
3. Periksa run terbaru dan commit SHA yang digunakan.
4. Pastikan seluruh langkah build dan validasi sukses.
5. Unduh artifact APK dari run tersebut.
6. Instal artifact itu pada perangkat Android dan verifikasi.

## Pemeriksaan sebelum build
- Perubahan UI tersedia di `docs/index.html`.
- Skrip persiapan menyalin file tersebut ke `app/src/main/assets/index.html`.
- Pemeriksaan embedding Charcoal Silver lolos.
- Validasi proyek dan pemeriksaan data yang dikonfigurasi workflow lolos.

## Pengujian setelah instalasi
- Catat commit SHA dan nomor run.
- Periksa halaman utama dan layar utama POS.
- Aktifkan Dark Pearl Charcoal Silver.
- Periksa kartu, statistik, tombol, form, teks, dialog, dan navigasi.
- Tutup dan buka ulang aplikasi untuk memeriksa persistensi tema.
- Uji pencarian produk, qty, keranjang, scanner, dan alur pembayaran yang tersedia.
- Pastikan QRIS tetap terbaca dan tidak menampilkan sukses tanpa verifikasi.

## Jika perubahan tidak terlihat
1. Pastikan APK berasal dari run setelah commit UI terbaru.
2. Cocokkan SHA run dengan commit yang memuat perubahan.
3. Instal artifact terbaru; hapus versi lama bila diperlukan.
4. Uji ulang dan catat screenshot/langkah reproduksi.
5. Jika masih gagal, periksa selector CSS, atribut tema, inline style, dan log runtime/build.

## Status
| Pemeriksaan | Status |
|---|---|
| CSS Charcoal Silver dikomit ke source | Sudah |
| Pemeriksaan embedding source ditambahkan | Sudah |
| Build APK terbaru terverifikasi sukses | Belum dikonfirmasi |
| APK terbaru diuji pada perangkat nyata | Belum dikonfirmasi |

Jangan tandai build atau pengujian lulus tanpa hasil aktual dari GitHub Actions dan perangkat.
