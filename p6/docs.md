# Laporan Tugas Pertemuan 6: Integrasi API dan Vertical Slice
**Project:** Pradita Find (Flutter Web/Mobile)  

---

## 1. Deskripsi Implementasi (Vertical Slice)
Pada tugas ini, saya memilih fitur inti aplikasi yaitu **Daftar Barang Hilang/Temuan**. Sistem penyimpanan yang sebelumnya menggunakan local storage telah di- *upgrade* dan dihubungkan secara *vertical slice* ke Backend/API menggunakan *package* `http`. 

Alur integrasi (UI ➔ Provider ➔ Repository ➔ API ➔ Model) telah diterapkan secara penuh untuk proses *Loading* data (GET) maupun penyimpanan data ke Backend (POST/PUT/DELETE).

## 2. Manajemen State UI (5 Kondisi)
Sistem UI telah diatur untuk responsif terhadap respons API melalui arsitektur Riverpod, mencakup kondisi berikut:
1. **Loading:** Menampilkan `CircularProgressIndicator` saat memanggil *endpoint* API.
2. **Success:** Menampilkan daftar laporan barang menggunakan `ListView` ketika API mengembalikan status HTTP 200 dengan data JSON yang valid.
3. **Empty:** Menampilkan pesan "Data dari server kosong" jika API mengembalikan respons array kosong `[]`.
4. **Error:** Menampilkan ikon merah dan pesan *Exception* jika terjadi gagal koneksi, *server down*, atau *timeout*.
5. **Retry:** Terdapat tombol **"Coba Lagi (Retry)"** pada layar *Error* yang memanggil ulang fungsi *fetch API* tanpa harus me-restart aplikasi.

## 3. Skenario Unit Test (6 Kriteria Wajib)
Untuk menjamin keandalan *parsing* data dan *request* API, telah dibuat dan dieksekusi **6 Unit Test** menggunakan `MockClient` (tanpa menyentuh *server* sungguhan). Seluruh tes berstatus **PASSED**.

1. **Model Valid:** Memastikan `ReportModel.fromJson` sukses mem- *parsing* JSON dengan format benar.
2. **Model Invalid:** Memastikan model melempar `FormatException` jika JSON kehilangan *key* wajib (*id* atau *title*).
3. **API Sukses:** Memastikan repository mengembalikan `List<ReportModel>` jika HTTP bernilai 200.
4. **Data Kosong:** Memastikan repository mengembalikan *list* kosong jika respons API berupa JSON array kosong `[]`.
5. **HTTP Gagal:** Memastikan repository melempar `Exception` jika *status code* API bukan 200 (misal: 404 atau 500).
6. **JSON Rusak:** Memastikan sistem menangkap *error* `FormatException` jika respons API berisi format *string* JSON yang cacat/rusak.

---

## 4. Catatan Khusus untuk Reviewer

*   **Apakah sudah ada koneksi ke API?** 
    **Sudah.** Koneksi API diimplementasikan pada file `lib/features/reports/data/report_repository.dart`. *Class* `ReportRepository` telah menggunakan `http.Client` untuk melakukan operasi GET (Fetch data), POST (Submit data), PUT (Update status), dan DELETE (Hapus data) ke *base URL* API.
*   **Apakah sudah ada Unit test?** 
    **Sudah.** Pengujian terdapat pada file `test/features/reports/presentation/report_features_test.dart` yang berisi 6 *test cases* (termasuk mock HTTP Client untuk menyimulasikan *response* API rusak, kosong, sukses, dan *error*).

---
**Lampiran:** 
*   *Link Video Demo UI (Menampilkan Loading, Error, Retry, dan Success):* 
https://drive.google.com/file/d/1N71QpSofwEv5wgXoiX9B84IEa7FrGd0z/view?usp=sharing