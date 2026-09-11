# PraFind(Pradita Find)

Aplikasi ini dibuat untuk membantu mahasiswa Pradita dalam melaporkan, mencari, dan menemukan informasi barang hilang atau barang yang ditemukan di lingkungan kampus.

Saat ini, informasi mengenai barang hilang seperti **KTM, kunci motor, charger, jaket, tumbler, dompet, dan barang pribadi lainnya** sering dibagikan melalui Instagram Story atau grup WhatsApp. Cara tersebut memiliki beberapa masalah, seperti informasi yang cepat tertimbun oleh postingan baru, sulit dicari kembali, dan tidak adanya tempat terpusat untuk menyimpan informasi barang hilang maupun barang temuan.

Aplikasi ini menyediakan platform terpusat sehingga mahasiswa dapat melihat dan mencari informasi barang hilang/temuan dengan lebih mudah.

## 1. Deskripsi Masalah

Mahasiswa yang kehilangan barang di lingkungan kampus biasanya menyebarkan informasi melalui Instagram Story, grup WhatsApp, atau meminta bantuan teman.

Metode tersebut belum optimal karena:

* Informasi barang hilang mudah tertimpa oleh pesan atau postingan baru.
* Mahasiswa harus mencari informasi secara manual melalui banyak chat atau Story.
* Tidak tersedia sistem pencarian barang berdasarkan kategori, lokasi, atau waktu.
* Informasi barang temuan dan barang hilang tersebar di berbagai platform.
* Tidak ada database terpusat yang dapat digunakan mahasiswa untuk mencari informasi barang.

### Masalah Utama

**Belum adanya platform terpusat bagi mahasiswa Pradita untuk melaporkan, mencari, dan menemukan informasi barang hilang atau barang temuan di lingkungan kampus.**

Aplikasi yang dikembangkan akan menjadi tempat khusus untuk menyimpan informasi tersebut sehingga lebih mudah ditemukan dan tidak cepat hilang dari timeline komunikasi mahasiswa.

---

## 2. Profil Target Pengguna

### Target Utama

**Mahasiswa Pradita**

Mahasiswa dapat menggunakan aplikasi untuk:

* Melaporkan barang yang hilang.
* Melaporkan barang yang ditemukan.
* Mencari barang yang sedang dicari atau telah ditemukan.
* Melihat detail barang berdasarkan kategori, lokasi, dan waktu.
* Menghubungi pemilik atau penemu barang melalui informasi kontak yang tersedia.

### Target Pengguna Tambahan

**Admin aplikasi**

Admin bertugas membantu menjaga kualitas informasi yang ada di dalam sistem, seperti mengelola laporan yang tidak sesuai atau menghapus informasi yang tidak relevan.

---

## 3. Manfaat Aplikasi

Aplikasi memberikan beberapa manfaat utama bagi mahasiswa Pradita, yaitu:

### Bagi mahasiswa yang kehilangan barang

* Lebih mudah melaporkan barang yang hilang.
* Dapat mencari apakah barang tersebut sudah ditemukan mahasiswa lain.
* Informasi kehilangan tersimpan dalam satu platform.
* Tidak perlu mengandalkan Story Instagram atau grup WhatsApp saja.

### Bagi mahasiswa yang menemukan barang

* Lebih mudah memberitahukan bahwa suatu barang telah ditemukan.
* Barang temuan dapat dilihat oleh mahasiswa yang sedang mencari barang tersebut.
* Informasi barang tidak cepat tertimbun seperti pada chat atau Story.

### Bagi lingkungan kampus

* Informasi barang hilang dan barang temuan menjadi lebih terorganisir.
* Mengurangi penyebaran informasi yang sama di banyak grup.
* Mempermudah proses mempertemukan pemilik dengan barang yang ditemukan.

---

## 4. Daftar Fitur Inti

Fitur inti dipilih dengan mempertimbangkan bahwa aplikasi harus **realistis untuk diselesaikan dalam 12 pertemuan**.

### 4.1 Registrasi dan Login

Pengguna dapat membuat akun dan masuk ke aplikasi.

Data pengguna minimal:

* Nama
* Email mahasiswa
* Password

Tujuan fitur ini adalah agar setiap laporan barang memiliki identitas pengguna yang jelas.

---

### 4.2 Membuat Laporan Barang

Pengguna dapat membuat laporan mengenai barang yang:

* **Hilang**
* **Ditemukan**

Informasi laporan minimal:

* Nama barang
* Kategori barang
* Deskripsi barang
* Lokasi kehilangan/penemuan
* Tanggal kehilangan/penemuan
* Foto barang
* Status laporan

Contoh:

> **KTM ditemukan**
> Lokasi: Gedung A lantai 2
> Tanggal: 10 September 2026
> Deskripsi: KTM dengan nama pemilik tertentu.

---

### 4.3 Daftar Barang

Aplikasi menampilkan seluruh laporan barang dalam bentuk daftar atau card.

Pengguna dapat melihat:

* Foto barang
* Nama barang
* Jenis laporan (Hilang/Ditemukan)
* Lokasi
* Tanggal laporan
* Status

---

### 4.4 Pencarian Barang

Pengguna dapat mencari barang berdasarkan kata kunci.

Contoh:

* `KTM`
* `charger`
* `kunci`
* `jaket`

Fitur ini menjadi salah satu fitur utama karena mengatasi masalah pencarian informasi yang sulit dilakukan melalui Instagram Story atau grup WhatsApp.

---

### 4.5 Filter Barang

Pengguna dapat memfilter laporan berdasarkan:

* Jenis laporan: Hilang / Ditemukan
* Kategori barang
* Lokasi
* Status

Contoh:

> Pengguna memilih **Ditemukan + Kunci + Gedung B**

Sistem akan menampilkan laporan yang sesuai.

---

### 4.6 Detail Laporan

Pengguna dapat membuka sebuah laporan untuk melihat informasi lengkap.

Detail dapat berisi:

* Foto
* Nama barang
* Deskripsi
* Kategori
* Lokasi
* Tanggal
* Status
* Informasi pelapor

---

### 4.7 Kontak Pelapor

Pengguna yang menemukan barang yang kemungkinan miliknya dapat menghubungi pelapor.

Pada versi awal, kontak dapat berupa:

* Email
* Informasi kontak yang disediakan pengguna

Tujuannya adalah mempermudah proses konfirmasi dan pengambilan barang.

---

### 4.8 Mengubah Status Laporan

Pemilik laporan dapat mengubah status barang.

Contoh status:

* **Aktif**
* **Sudah ditemukan**
* **Sudah dikembalikan**

Contoh:

> Mahasiswa kehilangan KTM → membuat laporan → KTM ditemukan → status diubah menjadi **Sudah ditemukan**.

Dengan demikian, pengguna lain tidak perlu menindaklanjuti laporan yang sudah selesai.

---

### 4.9 Mengelola Laporan Milik Sendiri

Pengguna dapat melihat dan mengelola laporan yang telah dibuat.

Operasi yang tersedia:

* Melihat laporan
* Mengedit laporan
* Menghapus laporan
* Mengubah status laporan

---

### 4.10 Dashboard Sederhana

Dashboard menampilkan ringkasan informasi seperti:

* Jumlah barang hilang
* Jumlah barang ditemukan
* Laporan terbaru
* Laporan yang masih aktif

Dashboard bertujuan memberikan gambaran singkat mengenai kondisi barang hilang/temuan di kampus.

---

## 5. Fitur yang Tidak Dikerjakan

Agar proyek dapat selesai secara realistis dalam **12 pertemuan**, beberapa fitur kompleks tidak menjadi bagian dari versi awal aplikasi.

### Tidak termasuk dalam scope:

* Notifikasi push real-time.
* Integrasi otomatis dengan Instagram.
* Integrasi otomatis dengan WhatsApp.
* Chat real-time antar pengguna.
* Sistem GPS/lokasi real-time.
* Peta interaktif lokasi barang.
* Sistem AI untuk mengenali barang dari foto.
* Face recognition.
* Sistem verifikasi identitas mahasiswa dengan sistem akademik kampus.
* Integrasi SSO kampus.
* Sistem reward atau gamifikasi.
* Sistem penitipan barang secara resmi oleh pihak kampus.
* Aplikasi mobile native Android/iOS.
* Multi-campus atau penggunaan untuk universitas lain.

Fitur-fitur tersebut dapat menjadi pengembangan pada versi berikutnya apabila versi awal aplikasi telah berjalan dengan baik.

---

## 6. Teknologi yang Digunakan

### Frontend

* **TypeScript**
* **React**

Frontend digunakan untuk membangun antarmuka pengguna seperti:

* Halaman login
* Dashboard
* Daftar barang
* Form laporan
* Detail laporan
* Pencarian dan filter

### Backend

* **TypeScript**
* **Node.js**

Backend digunakan untuk:

* Menangani API
* Autentikasi pengguna
* CRUD laporan barang
* Pencarian dan filtering
* Pengelolaan status laporan

### Database

* **MongoDB**

MongoDB digunakan untuk menyimpan data:

* Pengguna
* Laporan barang
* Kategori barang
* Status laporan

---

## 7. Kriteria Aplikasi Dinyatakan Berhasil

Aplikasi dinyatakan berhasil apabila minimal memenuhi kriteria berikut:

### Fungsional

1. Pengguna dapat melakukan registrasi dan login.
2. Pengguna dapat membuat laporan barang hilang.
3. Pengguna dapat membuat laporan barang ditemukan.
4. Pengguna dapat melihat daftar laporan barang.
5. Pengguna dapat mencari barang berdasarkan kata kunci.
6. Pengguna dapat menggunakan filter laporan.
7. Pengguna dapat melihat detail laporan.
8. Pengguna dapat mengedit dan menghapus laporan miliknya.
9. Pengguna dapat mengubah status laporan.
10. Pengguna dapat memperoleh informasi kontak pelapor.

### Data

* Data laporan berhasil disimpan di MongoDB.
* Data yang ditampilkan pada frontend berasal dari backend/API.
* Perubahan data tersimpan dan dapat ditampilkan kembali dengan benar.

### Usability

* Pengguna dapat memahami cara membuat laporan tanpa memerlukan bantuan teknis.
* Pengguna dapat menemukan barang tertentu melalui fitur pencarian dan filter.
* Informasi barang ditampilkan secara jelas dan terstruktur.

### Teknis

* Frontend React berhasil berkomunikasi dengan backend Node.js melalui API.
* Backend dapat melakukan operasi CRUD terhadap MongoDB.
* Autentikasi pengguna berjalan dengan baik.
* Tidak terdapat error kritis pada alur utama aplikasi.

### Keberhasilan Utama

**Aplikasi dianggap berhasil apabila mahasiswa Pradita dapat melaporkan barang hilang/temuan dan menemukan informasi barang yang relevan dengan lebih cepat dan terstruktur dibandingkan menggunakan Story Instagram atau grup WhatsApp.**

---

## 8. Batasan MVP

Versi pertama aplikasi atau **MVP (Minimum Viable Product)** berfokus pada satu kebutuhan utama:

> **Memusatkan informasi barang hilang dan barang ditemukan mahasiswa Pradita agar mudah dilaporkan, dicari, dan dikelola.**

Prioritas pengembangan adalah memastikan alur berikut berjalan dengan baik:

**Login → Membuat Laporan → Laporan Tersimpan → Pencarian/Filter → Melihat Detail → Menghubungi Pelapor → Mengubah Status**

Fitur di luar alur tersebut dapat dikembangkan pada tahap berikutnya.

---

## 9. Gambaran Sederhana Alur Penggunaan

### Skenario Barang Hilang

Mahasiswa kehilangan charger di kampus.

1. Mahasiswa login.
2. Memilih **Buat Laporan**.
3. Memilih jenis laporan **Hilang**.
4. Mengisi nama, kategori, lokasi, tanggal, deskripsi, dan foto.
5. Laporan disimpan.
6. Mahasiswa lain yang menemukan charger tersebut dapat membuat laporan **Ditemukan**.
7. Pemilik mencari charger melalui fitur pencarian.
8. Pemilik melihat detail laporan dan menghubungi penemu.
9. Setelah barang kembali, status laporan diubah menjadi **Sudah dikembalikan**.

### Skenario Barang Ditemukan

Mahasiswa menemukan KTM di area kampus.

1. Mahasiswa login.
2. Memilih **Buat Laporan**.
3. Memilih jenis laporan **Ditemukan**.
4. Mengisi informasi barang dan lokasi penemuan.
5. Laporan ditampilkan pada daftar barang.
6. Pemilik KTM mencari berdasarkan kata kunci atau kategori.
7. Pemilik menghubungi penemu untuk melakukan konfirmasi dan pengambilan barang.

---

## 10. Tujuan Akhir Proyek

Proyek ini bertujuan menghasilkan sebuah aplikasi web sederhana yang menjadi **pusat informasi barang hilang dan barang ditemukan bagi mahasiswa Pradita**.

Dengan adanya aplikasi ini, informasi yang sebelumnya tersebar di Instagram Story dan grup WhatsApp dapat disimpan dalam satu sistem yang lebih:

**terstruktur, mudah dicari, mudah diperbarui, dan tidak cepat tertimbun.**
