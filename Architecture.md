# Pradita Find — Application Architecture

## 1. Prototype

Prototype digunakan untuk merancang tampilan dan alur penggunaan aplikasi sebelum implementasi.

Prototype utama Pradita Find terdiri dari:

### Login & Registrasi

Halaman autentikasi mahasiswa sebelum membuat atau mengelola laporan:

* Masuk dengan email & password
* Pendaftaran akun mahasiswa baru

### Dashboard

Menampilkan ringkasan informasi barang:

* Jumlah barang hilang
* Jumlah barang ditemukan
* Laporan aktif
* Laporan terbaru

### Daftar Barang

Menampilkan seluruh laporan barang dalam bentuk card atau list.

Pengguna dapat:

* Mencari barang
* Memfilter barang
* Memilih barang untuk melihat detail

### Buat Laporan

Form untuk membuat laporan barang hilang atau ditemukan.

Input utama:

* Jenis laporan
* Nama barang
* Kategori
* Deskripsi
* Lokasi
* Tanggal
* Foto
* Nama pelapor
* Email pelapor

### Detail Barang

Menampilkan informasi lengkap dari sebuah laporan.

Informasi yang ditampilkan:

* Foto barang
* Nama barang
* Jenis laporan
* Kategori
* Deskripsi
* Lokasi
* Tanggal
* Status
* Informasi pelapor

### Kelola Laporan

Digunakan untuk mengubah atau menghapus laporan yang telah dibuat.

Pengguna dapat:

* Edit laporan
* Hapus laporan
* Mengubah status laporan menjadi selesai

Prototype dapat dibuat terlebih dahulu menggunakan Figma atau langsung diimplementasikan sebagai mock UI React.

---

## 2. Struktur Proyek

Pradita Find menggunakan struktur proyek yang memisahkan halaman, komponen reusable, model data, service/API, dan routing.

Struktur utama:

```text
pradita-find/
├── apps/
│   ├── web/
│   │   └── src/
│   │       ├── main.tsx
│   │       ├── App.tsx
│   │       ├── routes/
│   │       │   └── AppRoutes.tsx
│   │       ├── pages/
│   │       │   ├── LoginPage.tsx          
│   │       │   ├── RegisterPage.tsx       
│   │       │   ├── DashboardPage.tsx
│   │       │   ├── ReportsPage.tsx
│   │       │   ├── CreateReportPage.tsx
│   │       │   ├── ReportDetailPage.tsx
│   │       │   └── EditReportPage.tsx
│   │       ├── components/
│   │       │   ├── ReportCard.tsx
│   │       │   ├── ReportForm.tsx
│   │       │   ├── SearchBar.tsx
│   │       │   ├── FilterPanel.tsx
│   │       │   ├── StatusBadge.tsx
│   │       │   └── ConfirmationDialog.tsx
│   │       ├── services/
│   │       │   ├── authService.ts         
│   │       │   ├── reportService.ts
│   │       │   ├── categoryService.ts
│   │       │   ├── locationService.ts
│   │       │   └── dashboardService.ts
│   │       └── hooks/
│   │           └── useReports.ts
│   │
│   ├── api/
│   │   └── src/
│   │       ├── app.ts
│   │       ├── server.ts
│   │       ├── routes/
│   │       │   ├── authRoutes.ts
│   │       │   ├── reportRoutes.ts
│   │       │   ├── categoryRoutes.ts
│   │       │   ├── locationRoutes.ts
│   │       │   └── dashboardRoutes.ts
│   │       ├── controllers/
│   │       │   ├── AuthController.ts
│   │       │   ├── ReportController.ts
│   │       │   ├── CategoryController.ts
│   │       │   ├── LocationController.ts
│   │       │   └── DashboardController.ts
│   │       ├── services/
│   │       │   ├── AuthService.ts
│   │       │   ├── ReportService.ts
│   │       │   ├── CategoryService.ts
│   │       │   ├── LocationService.ts
│   │       │   └── DashboardService.ts
│   │       ├── models/
│   │       │   ├── UserModel.ts
│   │       │   ├── ReportModel.ts
│   │       │   ├── CategoryModel.ts
│   │       │   └── LocationModel.ts
│   │       └── config/
│   │           └── database.ts
│   │
│   └── packages/
│       └── shared/
│           └── src/
│               ├── models/        
│               ├── enums/
│               └── dto/
│
├── docker-compose.yml
├── .env.example
└── package.json

```

---

## 3. Routing

Routing digunakan untuk mengatur perpindahan halaman pada aplikasi React.

Route utama:

```text
/login                  → Halaman Login
/register               → Halaman Registrasi
/                       → Dashboard
/reports                → Daftar Barang
/reports/create         → Buat Laporan
/reports/:Id            → Detail Barang
/reports/:Id/edit       → Edit Laporan

```

Alur navigasi utama:

```text
Login / Register
   │
   └── Dashboard
          │
          ├── Daftar Barang
          │      ├── Detail Barang
          │      │      └── Edit Laporan
          │      │
          │      └── Buat Laporan
          │
          └── Buat Laporan

```

Routing dikelola menggunakan React Router.

---

## 4. Reusable Component

Reusable component digunakan untuk menghindari pembuatan elemen UI yang sama berulang kali.

### ReportCard

Menampilkan ringkasan laporan:

* Foto
* Nama barang
* Jenis laporan
* Lokasi
* Tanggal
* Status

### ReportForm

Digunakan pada:

* Buat Laporan
* Edit Laporan

### SearchBar

Digunakan untuk mencari barang berdasarkan kata kunci.

### FilterPanel

Digunakan untuk memfilter berdasarkan:

* Jenis laporan
* Kategori
* Lokasi
* Status

### StatusBadge

Menampilkan status laporan dengan tampilan yang berbeda.

Status:

```text
ACTIVE
RESOLVED

```

### ConfirmationDialog

Digunakan sebelum:

* Menghapus laporan
* Mengubah status laporan

### LoadingState

Digunakan ketika aplikasi sedang mengambil data dari API.

### EmptyState

Ditampilkan ketika tidak terdapat laporan yang sesuai dengan pencarian atau filter.

---

## 5. Model Data

Model data mendefinisikan bentuk data yang digunakan oleh aplikasi.

### User

```text
User
├── Id
├── Name
├── Email
├── Password (Hashed)
├── Role (Student/Admin)
└── CreatedAt

```

### Report

```text
Report
├── Id
├── UserId
├── Type
├── ItemName
├── CategoryId
├── Description
├── LocationId
├── Date
├── ImageUrl
├── ReporterName
├── ReporterEmail
├── Status
├── CreatedAt
└── UpdatedAt

```

### Category

```text
Category
├── Id
├── Name
└── CreatedAt

```

### Location

```text
Location
├── Id
├── Name
└── CreatedAt

```

### ReportType

```text
LOST
FOUND

```

### ReportStatus

```text
ACTIVE
RESOLVED

```

Model dan enum yang digunakan oleh frontend dan backend disimpan pada package `shared`.

---

## 6. Service / API

Service digunakan sebagai penghubung antara frontend dengan backend.

Struktur komunikasi:

```text
React Page
    ↓
Component / Hook
    ↓
Service
    ↓
REST API
    ↓
Express Backend
    ↓
Service
    ↓
Mongoose Model
    ↓
MongoDB

```

### Auth Service

Menangani:

```text
login()
register()
logout()

```

### Report Service

Menangani:

```text
getReports()
getReportById()
createReport()
updateReport()
deleteReport()
updateReportStatus()

```

### Category Service

Menangani:

```text
getCategories()
createCategory()
updateCategory()
deleteCategory()

```

### Location Service

Menangani:

```text
getLocations()
createLocation()
updateLocation()
deleteLocation()

```

### Dashboard Service

Menangani pengambilan data ringkasan dashboard.

---

## 7. Backend Structure

Backend menggunakan Node.js, TypeScript, dan Express.

Struktur backend:

```text
api/
└── src/
    ├── config/
    │   └── database.ts
    ├── routes/
    │   ├── authRoutes.ts
    │   ├── reportRoutes.ts
    │   ├── categoryRoutes.ts
    │   ├── locationRoutes.ts
    │   └── dashboardRoutes.ts
    ├── controllers/
    │   ├── AuthController.ts
    │   ├── ReportController.ts
    │   ├── CategoryController.ts
    │   ├── LocationController.ts
    │   └── DashboardController.ts
    ├── services/
    │   ├── AuthService.ts
    │   ├── ReportService.ts
    │   ├── CategoryService.ts
    │   ├── LocationService.ts
    │   └── DashboardService.ts
    ├── models/
    │   ├── UserModel.ts
    │   ├── ReportModel.ts
    │   ├── CategoryModel.ts
    │   └── LocationModel.ts
    ├── app.ts
    └── server.ts

```

Pembagian tanggung jawab:

**Route**
Mengatur endpoint API.

**Controller**
Menerima request dan mengembalikan response.

**Service**
Menangani business logic.

**Model**
Berkomunikasi dengan MongoDB melalui Mongoose.

---

## 8. Database

Database yang digunakan adalah **MongoDB**.

Collection utama:

* `users`
* `reports`
* `categories`
* `locations`

Relasi sederhana:

```text
User
   │
   └── Report

Category
   │
   └── Report

Location
   │
   └── Report

```

`Report` menyimpan `UserId`, `CategoryId`, dan `LocationId` untuk menghubungkan laporan dengan pembuat laporan, kategori, dan lokasi.

---

## 9. Alur Utama Aplikasi

### Autentikasi Pengguna

```text
Pengguna
   ↓
Halaman Login / Register
   ↓
Auth Service
   ↓
REST API (/api/auth)
   ↓
Backend Service
   ↓
Dashboard (Setalah Login Berhasil)

```

### Melihat Barang

```text
Pengguna
   ↓
Daftar Barang
   ↓
Search / Filter
   ↓
Pilih Barang
   ↓
Detail Barang

```

### Membuat Laporan

```text
Pengguna
   ↓
Buat Laporan
   ↓
Isi Form
   ↓
Frontend Service
   ↓
REST API
   ↓
Backend Service
   ↓
MongoDB
   ↓
Laporan berhasil dibuat

```

### Menyelesaikan Laporan

```text
Detail Barang
   ↓
Tandai Selesai
   ↓
Confirmation Dialog
   ↓
REST API
   ↓
Update Status
   ↓
RESOLVED

```

---

## 10. Arsitektur Keseluruhan

Arsitektur Pradita Find menggunakan pendekatan client-server sederhana.

```text
┌──────────────────────────────┐
│         React Web            │
│        TypeScript            │
│                              │
│ Pages                        │
│ Components                   │
│ Hooks                        │
│ Services                     │
└──────────────┬───────────────┘
               │
               │ REST API
               ↓
┌──────────────────────────────┐
│       Node.js + Express      │
│         TypeScript           │
│                              │
│ Routes                       │
│ Controllers                  │
│ Services                     │
│ Mongoose Models              │
└──────────────┬───────────────┘
               │
               │
               ↓
┌──────────────────────────────┐
│           MongoDB            │
│                              │
│ users                        │
│ reports                      │
│ categories                   │
│ locations                    │
└──────────────────────────────┘

```

---

## 11. Teknologi

```text
Frontend  : React + TypeScript + Vite + Tailwind CSS
Backend   : Node.js + TypeScript + Express
Database  : MongoDB
ODM       : Mongoose
API       : REST API
Container : Docker Compose

```

Arsitektur ini dipilih agar aplikasi memiliki pemisahan yang jelas antara **UI, routing, reusable component, service/API, backend logic, dan database**, sehingga lebih mudah dikembangkan dan dipelihara.