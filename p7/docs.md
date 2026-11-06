# Laporan Pertemuan 7: MVP Lengkap, Advanced Features & Integrasi API

**Nama Aplikasi:** Pradita Find (Campus Lost and Found)

**Mata Kuliah:** Pemrograman Mobile / Full-stack

## 1. Deskripsi Singkat

Pada Pertemuan ke-7 ini, aplikasi **Pradita Find** telah berhasil mencapai tahap *Minimum Viable Product* (MVP). Seluruh alur utama aplikasi mulai dari layar autentikasi, melihat daftar laporan (Read), hingga membuat laporan baru (Create) telah terhubung dengan baik. Aplikasi kini tidak lagi menggunakan data statis lokal, melainkan sudah terintegrasi dengan layanan *mock backend* berbasis *cloud* untuk menyimulasikan pertukaran data HTTP secara nyata.

Aplikasi juga telah mengimplementasikan validasi form, manajemen *state* terpusat menggunakan Riverpod, dan penanganan status UI (Loading, Empty, Error, Success).

## 2. Implementasi 3 Advanced Features

Untuk melengkapi fungsionalitas dan memberikan *User Experience* (UX) yang optimal, aplikasi ini mengintegrasikan 3 fitur lanjutan (kamera, lokasi, dan sensor biometrik):

### A. Autentikasi Biometrik (Sensor)

* **Package:** `local_auth`
* **Cara Kerja:** Aplikasi menggunakan layar `LoginPage` sebagai gerbang utama. Pengguna diwajibkan melakukan pemindaian sidik jari (*Fingerprint*) atau wajah (*Face ID*) sebelum dapat masuk ke halaman utama daftar laporan.
* **Manfaat bagi Pengguna:** Memberikan lapisan keamanan ekstra untuk memastikan hanya civitas kampus (pemilik perangkat) yang dapat melihat atau membuat laporan. Ini sangat berguna untuk mencegah spam laporan atau penyalahgunaan akun.
* **Penanganan (*Handling*):**
  * Mengecek ketersediaan *hardware* sensor pada perangkat.
  * Penanganan *error* jika pengguna membatalkan proses *scan*.
  * Menyediakan opsi alternatif (PIN/Pola) jika biometrik gagal dibaca.

### B. Input Gambar Kamera & Galeri (Kamera)

* **Package:** `image_picker`
* **Cara Kerja:** Pada form pembuatan laporan (`CreateReportPage`), pengguna diberikan opsi untuk mengambil foto barang secara langsung melalui Kamera atau mengunggahnya dari Galeri perangkat.
* **Manfaat bagi Pengguna:** Memberikan bukti visual yang konkret dan akurat mengenai kondisi atau bentuk barang yang hilang/ditemukan. Hal ini secara drastis mempercepat proses identifikasi barang oleh pihak kampus atau pemilik asli.
* **Penanganan (*Handling*):**
  * Validasi izin akses kamera dan galeri (`AndroidManifest.xml` & `Info.plist`).
  * Penanganan jika pengguna membuka kamera namun kembali (batal) tanpa mengambil foto (tidak menyebabkan *crash*).
  * Pratinjau gambar otomatis di UI (*Image Preview*).

### C. Auto-Deteksi Lokasi GPS (Lokasi)

* **Package:** `geolocator` & `geocoding` (serta pemanfaatan GPS emulator)
* **Cara Kerja:** Terdapat tombol deteksi lokasi otomatis pada form pembuatan laporan. Saat ditekan, aplikasi membaca titik koordinat pengguna saat ini (Latitude/Longitude) untuk mengisi *text field* lokasi secara otomatis.
* **Manfaat bagi Pengguna:** Menghemat waktu pengetikan dan memberikan presisi lokasi kejadian yang jauh lebih akurat dibandingkan input manual, sehingga memudahkan pencarian titik hilang/ditemukannya barang di area kampus.
* **Penanganan (*Handling*):**
  * Menampilkan indikator *Loading* berputar saat sedang mencari sinyal GPS.
  * Penanganan *error* berlapis: Peringatan jika GPS perangkat mati, permintaan izin lokasi dinamis, serta notifikasi *error* jika pengguna menolak izin.

## 3. Penanganan State & UI/UX (Kelengkapan MVP)

Sesuai instruksi, aplikasi Pradita Find telah menangani skenario batas (*edge cases*):

1. **Loading:** Indikator visual (`CircularProgressIndicator`) digunakan saat aplikasi menarik data dari internet, mengambil koordinat GPS, menunggu verifikasi biometrik, dan *submit* form.
2. **Error Handling & Validasi:** Terdapat validasi *form* agar input wajib tidak kosong, serta penanganan via `ScaffoldMessenger (Snackbar)` jika terjadi kegagalan jaringan atau penolakan izin *hardware*.
3. **Empty State:** Jika *endpoint* API merespons dengan daftar kosong (belum ada data di MockAPI), aplikasi akan merender UI informatif yang menyatakan belum ada laporan dibuat.
4. **Navigasi:** Transisi perpindahan halaman dikelola secara terstruktur, seperti penggunaan `Navigator.pushReplacement` setelah *login* agar pengguna tidak bisa menekan tombol *Back* ke halaman *Login* lagi.

## 4. Integrasi HTTP Network & Mock Backend (MockAPI.io)

Sebagai arsitektur penyimpan data, aplikasi mengimplementasikan koneksi HTTP menggunakan *RESTful API*.

* **Layanan:** MockAPI.io
* **Package:** `http`
* **Cara Kerja:** Modul `ReportRepository` melakukan *request* HTTP (GET, POST, PUT, DELETE) ke *endpoint* API yang di-host di layanan *cloud* MockAPI (`https://[id].mockapi.io/api/v1/reports`). Aplikasi mengirimkan *payload* berformat JSON saat membuat laporan baru (termasuk koordinat GPS), dan melakukan *parsing* respons JSON saat memuat halaman beranda.
* **Manfaat bagi Pengembangan MVP:**
  * Membuktikan bahwa kode integrasi jaringan (API Client) berfungsi sempurna layaknya berkomunikasi dengan *server* sungguhan.
  * Memungkinkan aplikasi untuk didemokan secara *real-time*; data yang dibuat di *form* akan langsung tersimpan di *server cloud* dan muncul pada daftar laporan, tanpa terhambat oleh proses pembuatan *custom backend* (Node.js/PHP) maupun kendala jaringan *localhost* pada emulator.
  * Menyimulasikan latensi *server* (network delay) yang nyata untuk menguji keandalan manajemen *State* aplikasi (Riverpod).