# Blueprint UI — Dark Pearl Charcoal Silver

**Proyek:** Apotek D'she Farma POS Mobile  
**Status:** Blueprint implementasi dan verifikasi

## Tujuan
Menyempurnakan tema Dark Pearl agar premium, konsisten, mudah dibaca, dan nyaman digunakan pada ponsel. Arah visual yang disepakati adalah **Charcoal Silver**, tanpa mengganti identitas atau alur POS.

## Prinsip desain
- Gunakan beberapa tingkat charcoal, bukan hitam pekat untuk semua permukaan.
- Silver menjadi aksen border, ikon, pemisah, dan indikator aktif.
- Teks utama terang; teks sekunder tetap terbaca.
- Utamakan angka penting, status, ikon berlabel, dan kelompok tindakan daripada paragraf panjang.
- Mobile-first: target sentuh nyaman dan layout tidak bertumpuk.
- Blur/gradien harus ringan dan tidak mengurangi keterbacaan atau performa.

## Token visual awal
| Token | Nilai | Pemakaian |
|---|---|---|
| Charcoal card | `#292D33` | Kartu utama |
| Charcoal secondary | `#24272C` | Kartu sekunder |
| Silver edge | `#535963` | Border/pemisah |
| Primary text | `#F2F4F7` | Judul dan angka utama |
| Muted text | `#C1C7D0` | Keterangan |

Nilai perlu divalidasi dengan pemeriksaan kontras di setiap komponen.

## Komponen yang harus konsisten
1. Header/brand Apotek D'she Farma.
2. Kartu statistik dan ringkasan.
3. Quick actions dan navigasi.
4. Form input, pencarian, dropdown, dan scanner barcode.
5. Daftar hasil pencarian dan item transaksi.
6. Dialog, notifikasi, loading, empty state, dan error.
7. Keranjang, subtotal, pembayaran, dan status transaksi.
8. Kanvas QRIS: pertahankan latar QR yang sesuai agar tetap dapat dipindai.

## Interaksi dan animasi
- Transisi singkat, tidak menghambat input.
- Feedback tombol dan loading yang jelas.
- Perubahan qty/keranjang diperbarui langsung.
- Hindari blur berat di area padat informasi.

## Kriteria penerimaan
- Tema konsisten setelah aplikasi dibuka ulang.
- Tidak ada kartu putih lama yang tidak disengaja.
- Teks, ikon, border, dan status terbaca.
- QR tetap dapat dipindai.
- Alur POS utama tetap berfungsi di layar ponsel.
- APK yang diuji berasal dari commit terbaru; perubahan source saja bukan bukti APK telah diperbarui.

## Status
Perubahan CSS dan pemeriksaan embedding source telah dikomit. Build APK dan hasil visual di perangkat masih harus diverifikasi dari hasil aktual GitHub Actions dan pengujian instalasi.
