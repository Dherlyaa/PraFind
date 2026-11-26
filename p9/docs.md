# Dokumentasi Refactoring Pertemuan ke-9 — Pradita Find Mobile

## 1. Ringkasan Tujuan
Pertemuan ke-9 berfokus pada peningkatan kualitas kode, keterbacaan, pemisahan tanggung jawab (*separation of concerns*), penghilangan duplikasi logika, serta kelulusan pengujian dan analisis statis pada aplikasi **`pradita_find_mobile`** (Flutter, Riverpod, `http`, `local_auth`, `geolocator`, `image_picker`).

Seluruh perubahan dilakukan secara bertahap dengan alur: **pengujian awal → refactoring → pengujian ulang → commit Git**.

---

## 2. Ringkasan Perubahan Utama

| Komponen / Berkas | Peran & Perubahan Utama |
| :--- | :--- |
| `lib/features/reports/domain/report_validator.dart` & `test/report_validator_test.dart` | Memisahkan aturan validasi input laporan (`validateTitle`, `validateLocation`, `validateDescription`) ke lapisan domain murni agar mudah diuji unit. |
| `lib/core/utils/snackbar_helper.dart` | Menyediakan utilitas `showAppSnackBar(context, message)` untuk menghilangkan duplikasi pemanggilan `ScaffoldMessenger`. |
| `lib/features/reports/presentation/pages/create_report_page.dart` | Memecah tampilan dan alur form menjadi helper fokus (`_fetchDevicePosition`, `_buildFormInputs`, `_buildLocationField`, `_buildFormActions`, `_buildImagePreview`, `_buildSubmitButton`), memakai `showAppSnackBar`, serta menjaga keamanan `BuildContext` dengan pengecekan `mounted`. |
| `lib/features/reports/data/report_repository.dart` & `test/features/reports/presentation/report_features_test.dart` | Menghubungkan `fetchReports` ke `http.Client` (pengecekan status HTTP `200`, *decode* JSON ke `ReportModel`, dan pemfilteran `query`), serta mengekstrak helper `_reportsUri`, `_filterByQuery`, `_findReportIndexById`, dan `_simulateNetworkDelay`. |
| `lib/features/auth/presentation/pages/login_page.dart` | Mengganti pemanggilan `SnackBar` berulang dengan `showAppSnackBar`, menyatukan alur sukses login (`_onLoginSuccess`), dan mengekstrak `_performBiometricAuth` serta `_buildLoginButton`. |
| `lib/main.dart` & `test/widget_test.dart` | Menyelaraskan *root widget* aplikasi (`PraditaFindApp` dengan `ProviderScope` dan halaman awal `LoginPage`) serta memperbarui *widget test* utama. |
| Pembersihan berkas & analisis statis | Menghapus berkas nyasar `lib/features/data/report_repository.dart`, memperbaiki *import* relatif pada tes ke *package import*, dan memastikan `flutter analyze` bersih (`No issues found!`). |

---

## 3. Detail Implementasi per Bagian

### A. Validasi Domain (`ReportValidator`)
Aturan validasi kolom pada form pembuatan laporan dipindahkan keluar dari widget UI ke kelas domain khusus (`ReportValidator`), dilengkapi pengujian unit di `test/report_validator_test.dart` sehingga aturan validasi dapat diverifikasi tanpa merender widget.

### B. Helper Notifikasi Terpusat (`showAppSnackBar`)
Pemanggilan `ScaffoldMessenger.of(context).showSnackBar(...)` yang sebelumnya tersebar di beberapa halaman disatukan ke `lib/core/utils/snackbar_helper.dart` melalui fungsi `showAppSnackBar`.

### C. Dekomposisi `CreateReportPage`
Komponen halaman pembuatan laporan dipecah agar masing-masing bagian memiliki tanggung jawab tunggal:
- **Pengambilan lokasi GPS:** `_getCurrentLocation()` dan `_fetchDevicePosition()` menangani status layanan GPS dan status izin (`denied`, `deniedForever`).
- **Komponen UI:** `_buildFormInputs()`, `_buildLocationField()`, `_buildFormActions()`, `_buildImagePreview()`, dan `_buildSubmitButton()` mendukung tata letak responsif (*wide screen* vs *narrow screen*) dan status `isSubmitting`.
- **Keamanan konteks asinkron:** pengecekan `if (!mounted) return;` ditempatkan sebelum mengakses `context` setelah operasi `await`.

### D. Integrasi HTTP & Helper di `ReportRepository`
- `fetchReports({String query = ''})` melakukan permintaan `GET` melalui `http.Client` ke `$baseUrl/reports`:
  - Melempar `Exception` jika *status code* bukan `200`.
  - Melakukan `jsonDecode` dan memetakan elemen JSON ke `ReportModel.fromJson(...)` (memicu `FormatException` jika JSON tidak valid atau struktur data tidak sesuai).
  - Menyaring hasil berdasarkan `query` melalui `_filterByQuery`.
- Operasi *mock* CRUD (`submitReport`, `updateReport`, `deleteReport`) menggunakan helper `_findReportIndexById` dan `_simulateNetworkDelay` untuk menghindari pengulangan kode.

### E. Perapian `LoginPage` & Widget Root
- `LoginPage` memanfaatkan `showAppSnackBar` untuk seluruh pesan status/kesalahan (*web bypass*, sukses autentikasi, pembatalan/gagal, `PlatformException`, dan error umum).
- `PraditaFindApp` di `lib/main.dart` diuji pada `test/widget_test.dart` untuk memastikan judul aplikasi dan tombol login biometrik tampil sesuai ekspektasi.

---

## 4. Perintah Verifikasi
Jalankan perintah berikut untuk memeriksa analisis statis, pengujian, dan status repositori Git:

```bash
flutter analyze
flutter test
git status
git log -n 6 --oneline