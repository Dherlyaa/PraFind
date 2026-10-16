# Laporan Tugas Pertemuan 5: Local Data & Persistence
**Project:** Pradita Find (Flutter Web/PWA)  

---

## 1. Ringkasan Implementasi
Pada tugas pertemuan ke-5 ini, saya telah mengimplementasikan **Local Data & Persistence** untuk menyimpan data aplikasi secara lokal di perangkat/browser pengguna. Teknologi yang digunakan adalah package `shared_preferences` (yang di-compile menjadi *localStorage* pada platform Web/PWA) dengan metode penyimpanan data berformat *JSON String*.

## 2. Posisi Code (Implementasi Vertikal: FE => Local Storage)
Untuk memudahkan *reviewer* dalam memeriksa kode, implementasi fitur ini dibagi secara vertikal ke dalam beberapa *layer* arsitektur berikut:

1. **Data Model (Entity):** `lib/features/reports/domain/report_model.dart`
2. **Local Storage Repository:** `lib/features/reports/data/report_repository.dart`
3. **State Management (Logic):** `lib/features/reports/presentation/providers/report_list_provider.dart`
4. **User Interface (UI):** `lib/features/reports/presentation/pages/report_list_page.dart`

## 3. Data Model
Model data yang disimpan adalah `ReportModel`. Model ini telah dilengkapi dengan metode konversi:
* `fromJson()`: Untuk *parsing* data (Read) dari *Local Storage* ke dalam bentuk *Object*.
* `toJson()`: Untuk mengubah *Object* menjadi format *Map* sebelum di-*encode* menjadi *JSON string* (Create/Update).
* Penambahan field `status` dengan *default value* `'ACTIVE'` untuk mendemonstrasikan proses Update (berubah menjadi `'RESOLVED'`).

## 4. Implementasi CRUD (Create, Read, Update, Delete)
Fungsi CRUD diimplementasikan penuh pada file `report_repository.dart`:
* **Create (`submitReport`)**: Mengambil data *list* lokal saat ini, menambahkan *Object* laporan baru, mengonversinya kembali menjadi *JSON string*, lalu menyimpannya ke *storage*.
* **Read (`fetchReports`)**: Membaca *JSON string* dari `shared_preferences`, men-decode data, dan mem-parsingnya kembali menjadi *List of ReportModel*.
* **Update (`updateReport`)**: Mencari data berdasarkan `id`, memperbarui atributnya (contoh: mengubah status laporan menjadi Selesai/Dicoret), lalu menyimpan ulang *list* tersebut ke *storage*.
* **Delete (`deleteReport`)**: Menghapus data spesifik dari *list* berdasarkan `id` menggunakan metode `removeWhere()`, kemudian menyimpan perubahan ke *storage*.

## 5. Persistence Test
Aplikasi telah diuji coba untuk memastikan data tetap tersedia *(persistent)*:
1. Menambahkan beberapa data laporan barang baru.
2. Melakukan *Hard Refresh* pada browser dan menutup tab aplikasi sepenuhnya.
3. Saat aplikasi dibuka kembali, data secara otomatis di-muat (*initial loading*) dari *Local Storage* dan dirender di layar utama tanpa ada yang hilang.

## 6. Dokumentasi Demo
*(Lampirkan link video Google Drive/YouTube demo singkat yang menunjukkan proses CRUD dan layar saat di-refresh di sini)*
* **Link Video Demo:** https://drive.google.com/file/d/1VeeGNMpBJO_mz0NRcijNXeK5763-K7-F/view?usp=sharing

---