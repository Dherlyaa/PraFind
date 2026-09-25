# Architecture — PraFind (Pradita Find)

Build a simple full-stack web application named **Pradita Find**.

## Purpose

Help Pradita students report, search, and manage information about lost and found items within the campus environment.

Currently, information about lost items such as **KTM, kunci motor, charger, jaket, tumbler, dompet, dan barang pribadi lainnya** is commonly shared through Instagram Stories or WhatsApp groups. This information is easily buried by newer posts or messages and is difficult to search again.

The application provides a centralized platform where students can:

* Report lost items.
* Report found items.
* Search and filter lost and found item reports.
* View detailed information about an item.
* Contact the person who reported the item.
* Update the status of their own report.

The first version focuses on a simple and realistic Lost & Found system that can be completed within **12 meetings**.

## Use this stack

* Frontend: React + TypeScript + Vite + Tailwind CSS
* Backend: Node.js + TypeScript + Express
* Database: MongoDB
* ORM / ODM: Mongoose
* API style: REST API
* Image storage: Local server storage for the first version
* Use Docker Compose for MongoDB
* Use `.env.example` for database URL and server configuration

## Code rules

* Do not add comments unless truly necessary.
* Use PascalCase for all classes, types, interfaces, enums, React components, database models, API DTOs, and JSON property names.
* Local variables may use camelCase.
* Keep code lines below 150 characters where practical.
* Use a clean and simple folder structure.
* Do not add complex authentication or authorization in the first version.
* Assume the application is used by Pradita students within the campus environment.
* Do not implement real-time chat in the first version.
* Do not implement automatic integration with Instagram or WhatsApp.

## Main entities

### 1. User

Represents a student who creates reports.

Fields:

* Id
* Name
* StudentNumber
* Email
* Password
* CreatedAt
* UpdatedAt

The `StudentNumber` is used to identify the student within the application.

---

### 2. Category

Represents the category of a lost or found item.

Fields:

* Id
* Name
* Description
* CreatedAt

Example categories:

* KTM / Kartu Identitas
* Kunci
* Elektronik
* Pakaian
* Dompet
* Tas
* Alat Tulis
* Botol / Tumbler
* Lainnya

---

### 3. ItemReport

Represents a lost or found item report.

Fields:

* Id
* UserId
* CategoryId
* Type
* Name
* Description
* Location
* EventDate
* ImageUrl
* Status
* CreatedAt
* UpdatedAt

`Type` values:

* `LOST`
* `FOUND`

`Status` values:

* `ACTIVE`
* `RESOLVED`

Examples:

* A student reports a lost KTM → `Type = LOST`
* A student reports a found charger → `Type = FOUND`
* The item has been returned → `Status = RESOLVED`

---

### 4. Contact

Represents contact information displayed for an item report.

Fields:

* Id
* ItemReportId
* Email
* PhoneNumber
* CreatedAt

The first version may primarily use the user's email from the `User` entity. A separate `Contact` entity can be used when additional contact information is required.

## Database rules

* Every `ItemReport` must belong to one `User`.
* Every `ItemReport` must belong to one `Category`.
* `Type` must be either `LOST` or `FOUND`.
* `Status` must be either `ACTIVE` or `RESOLVED`.
* Users can only edit or delete their own reports.
* Resolved reports must remain stored in the database.
* Do not permanently delete reports automatically when their status becomes `RESOLVED`.
* Search must work on item name and description.
* Filtering must support item type, category, location, and status.
* `CreatedAt` and `UpdatedAt` must be stored for every report.
* Use Mongoose schemas and indexes for commonly searched fields.
* Create a seed script containing example users, categories, and item reports.

## Backend features

### 1. CRUD User

Provide basic user management for the first version.

Operations:

* Create user.
* List users.
* Get user detail.
* Update user.
* Delete user.

User data should include:

* Name
* StudentNumber
* Email

Password handling should be kept simple for the first version. Authentication is not required in this initial architecture.

---

### 2. CRUD Category

Operations:

* Create category.
* List categories.
* Get category detail.
* Update category.
* Delete category.

Categories should be reusable by multiple item reports.

---

### 3. CRUD Item Report

Users can create and manage lost and found item reports.

Create report fields:

* Type
* Name
* CategoryId
* Description
* Location
* EventDate
* ImageUrl

Operations:

* Create report.
* List reports.
* Get report detail.
* Update report.
* Delete report.

The backend must validate:

* Required item name.
* Valid report type.
* Valid category.
* Location.
* Event date.
* Valid status.

---

### 4. Item Search and Filter

Provide an endpoint to search and filter reports.

Search requirements:

* Search by item name.
* Search by item description.

Filter requirements:

* Type: LOST / FOUND
* Category
* Location
* Status

Example:

```text
GET /api/reports?search=charger&type=FOUND&category=Elektronik
```

The response must return reports matching all provided filters.

---

### 5. Update Item Report Status

Users can update the status of their own reports.

Supported statuses:

* `ACTIVE`
* `RESOLVED`

Example:

```text
LOST + ACTIVE
```

means the student is still looking for the item.

```text
LOST + RESOLVED
```

means the item has already been found or returned.

```text
FOUND + ACTIVE
```

means the item has been found but has not yet been returned to its owner.

```text
FOUND + RESOLVED
```

means the item has been successfully returned or the report is no longer active.

---

### 6. Report Ownership

Every report must store its `UserId`.

The API must support retrieving reports created by a particular user.

This is required so that a student can manage their own reports.

Operations:

* View my reports.
* Edit my report.
* Delete my report.
* Update my report status.

For the first version, ownership can be validated using the `UserId` sent by the frontend. Full authentication and authorization are outside the initial scope.

---

### 7. Contact Reporter

Provide a simple way for a student to obtain contact information from the person who created a report.

The report detail response should include:

* Reporter name.
* Reporter email.
* Optional phone number.

The first version does not require an internal messaging system.

---

### 8. Dashboard API

Return a summary of Lost & Found activity.

The dashboard should provide:

* TotalReports
* TotalLostReports
* TotalFoundReports
* ActiveReports
* ResolvedReports
* LatestReports

Return item statistics grouped by category when practical.

Example:

```text
TotalReports: 120
TotalLostReports: 75
TotalFoundReports: 45
ActiveReports: 50
ResolvedReports: 70
```

The dashboard must read information from MongoDB.

No external platform should be required to display dashboard data.

---

## Frontend pages

### 1. Home / Dashboard

Display a summary of Lost & Found activity.

Elements:

* Total laporan.
* Barang hilang.
* Barang ditemukan.
* Laporan aktif.
* Laporan selesai.
* Daftar laporan terbaru.
* Search bar.
* Filter button.

The dashboard must not automatically send notifications or access Instagram/WhatsApp.

---

### 2. Daftar Barang

Show all active item reports.

Each item card should display:

* Foto barang.
* Nama barang.
* Jenis laporan.
* Kategori.
* Lokasi.
* Tanggal.
* Status.

Users can:

* Search items.
* Filter items.
* Open item details.

---

### 3. Detail Barang

Show complete information about a selected report.

Display:

* Foto barang.
* Nama barang.
* Jenis laporan.
* Kategori.
* Deskripsi.
* Lokasi.
* Tanggal kehilangan/penemuan.
* Status.
* Nama pelapor.
* Email pelapor.
* Nomor kontak jika tersedia.

Provide a button:

`Hubungi Pelapor`

The first version may open the user's email application instead of implementing internal chat.

---

### 4. Buat Laporan

Provide a form for creating a Lost & Found report.

Fields:

* Jenis laporan
* Nama barang
* Kategori
* Deskripsi
* Lokasi
* Tanggal kehilangan/penemuan
* Foto barang

Types:

* `Barang Hilang`
* `Barang Ditemukan`

Submit button:

`Buat Laporan`

---

### 5. Laporan Saya

Show reports created by the current user.

For every report display:

* Nama barang.
* Jenis laporan.
* Lokasi.
* Tanggal.
* Status.

Available actions:

* Edit.
* Delete.
* Ubah status.
* Lihat detail.

---

### 6. Edit Laporan

Allow users to update their own reports.

Editable fields:

* Nama barang.
* Kategori.
* Deskripsi.
* Lokasi.
* EventDate.
* Foto.
* Status.

The frontend must show a confirmation dialog before deleting a report.

---

### 7. Category Management

For the first version, category management may be provided as a simple admin-style page or seeded statically.

Operations:

* List categories.
* Add category.
* Edit category.
* Delete category.

This feature should remain simple and does not require a separate admin authentication system.

---

## UI requirements

* Use Indonesian language for all labels, buttons, messages, placeholders, and validation.
* Create a clean and responsive student-oriented web application.
* Use simple cards, tables, badges, forms, confirmation dialogs, search fields, filters, and empty states.
* Make the main action `Buat Laporan` easy to find.
* Show clear distinction between:

  * Barang Hilang
  * Barang Ditemukan
* Use status badge colors:

  * Aktif: green
  * Selesai: gray
* Use type badge colors:

  * Hilang: red
  * Ditemukan: blue
* Show loading states when fetching data.
* Show success and error messages after create, update, delete, and status update operations.
* Do not add charts in the first version.
* Do not overcomplicate the interface with advanced animations.

## Required API routes

### User

* `GET /api/users`
* `POST /api/users`
* `GET /api/users/:Id`
* `PUT /api/users/:Id`
* `DELETE /api/users/:Id`

### Category

* `GET /api/categories`
* `POST /api/categories`
* `GET /api/categories/:Id`
* `PUT /api/categories/:Id`
* `DELETE /api/categories/:Id`

### Item Reports

* `GET /api/reports`
* `POST /api/reports`
* `GET /api/reports/:Id`
* `PUT /api/reports/:Id`
* `DELETE /api/reports/:Id`
* `PATCH /api/reports/:Id/status`

### User Reports

* `GET /api/users/:Id/reports`

### Dashboard

* `GET /api/dashboard`

### Contact

* `GET /api/reports/:Id/contact`

## Query parameters for reports

The main report endpoint must support query parameters.

Example:

```text
GET /api/reports?search=KTM
```

```text
GET /api/reports?type=LOST
```

```text
GET /api/reports?type=FOUND&category=Elektronik
```

```text
GET /api/reports?location=Gedung%20A&status=ACTIVE
```

Supported parameters:

* `search`
* `type`
* `category`
* `location`
* `status`
* `page`
* `limit`

The backend should support pagination to prevent large amounts of data from being returned at once.

## Deliverables

* Complete frontend and backend source code.
* Mongoose schemas and database models.
* MongoDB seed data.
* Docker Compose file for MongoDB.
* `.env.example`.
* REST API implementation.
* Search and filtering implementation.
* Lost and Found report CRUD.
* Report status management.
* User report management.
* Dashboard summary.
* README with:

  * Project description.
  * Installation instructions.
  * Environment variables.
  * Docker usage.
  * MongoDB setup.
  * Seed instructions.
  * Frontend startup.
  * Backend startup.
  * API overview.
* Ensure the application builds successfully and all basic CRUD, search, filter, and report status features work.

# Project structure

Use a TypeScript monorepo with npm workspaces.

Structure:

```text
pradita-lost-and-found/
  apps/
    web/
    api/
  packages/
    shared/
```

## Frontend

```text
apps/web/
  src/
    components/
    pages/
    layouts/
    hooks/
    services/
    utils/
    App.tsx
    main.tsx
```

## Backend

```text
apps/api/
  src/
    controllers/
    services/
    routes/
    models/
    middleware/
    utils/
    config/
    app.ts
    server.ts
```

## Shared package

Create:

```text
packages/shared/
```

Package name:

```text
@pradita-lost-and-found/shared
```

Store all shared domain models, enums, API response types, and shared constants here.

Both `apps/web` and `apps/api` must import shared types from this package.

Do not duplicate domain model definitions between frontend and backend.

## Example shared files

```text
packages/shared/src/
  models/
    User.ts
    Category.ts
    ItemReport.ts
    Contact.ts
  enums/
    ReportType.ts
    ReportStatus.ts
  dto/
    ItemReportResponse.ts
    DashboardResponse.ts
    CreateItemReportRequest.ts
    UpdateItemReportRequest.ts
  constants/
    ItemCategories.ts
  index.ts
```

## Shared model rules

Define shared TypeScript interfaces or types only once in `packages/shared`.

Example:

```text
User
Category
ItemReport
Contact
ReportType
ReportStatus
DashboardResponse
```

must be imported by both frontend and backend from:

```text
@pradita-lost-and-found/shared
```

Mongoose models remain in the backend because they are database-specific.

The backend maps Mongoose documents to shared API models before returning responses.

The frontend must not import Mongoose or backend database models.

Configure:

* TypeScript workspace dependencies.
* npm workspace scripts.
* TypeScript build configuration.
* Development scripts.
* Shared package build.
* Frontend and backend environment configuration.

All packages must compile successfully.

# Architecture flow

The main application flow is:

```text
React + TypeScript
       |
       | REST API
       v
Node.js + Express
       |
       | Mongoose
       v
MongoDB
```

For the Lost & Found workflow:

```text
Mahasiswa
   |
   v
Buat Laporan
   |
   v
React Frontend
   |
   v
REST API
   |
   v
MongoDB
   |
   v
Daftar Barang
   |
   +----> Search / Filter
   |
   +----> Detail Barang
   |
   +----> Hubungi Pelapor
   |
   +----> Ubah Status
```

# Main application workflow

## Lost item workflow

```text
Mahasiswa kehilangan barang
        |
        v
Buat laporan "Barang Hilang"
        |
        v
Sistem menyimpan laporan
        |
        v
Laporan muncul pada daftar
        |
        v
Mahasiswa lain menemukan barang
        |
        v
Membuat laporan "Barang Ditemukan"
        |
        v
Pemilik mencari barang
        |
        v
Melihat detail laporan
        |
        v
Menghubungi pelapor
        |
        v
Barang dikembalikan
        |
        v
Status laporan menjadi "Selesai"
```

## Found item workflow

```text
Mahasiswa menemukan barang
        |
        v
Buat laporan "Barang Ditemukan"
        |
        v
Laporan tersimpan
        |
        v
Pemilik barang melakukan pencarian
        |
        v
Pemilik melihat detail
        |
        v
Pemilik menghubungi penemu
        |
        v
Barang dikembalikan
        |
        v
Status menjadi "Selesai"
```

# Scope boundaries

The first version must focus on the core problem: **centralizing and making Lost & Found information searchable for Pradita students**.

Do not implement:

* Real-time chat.
* Push notifications.
* Instagram API integration.
* WhatsApp API integration.
* Instagram Story publishing.
* WhatsApp group integration.
* AI image recognition.
* Face recognition.
* GPS tracking.
* Interactive map.
* Campus academic system integration.
* SSO integration.
* Native Android application.
* Native iOS application.
* Complex admin role and permission system.
* Payment system.
* Reward or gamification system.

These features may be considered future improvements after the core application is stable.

# Success criteria

The application is considered successful when:

1. A student can create a Lost report.
2. A student can create a Found report.
3. Reports are stored successfully in MongoDB.
4. Students can view available reports.
5. Students can search for an item using keywords.
6. Students can filter reports by type, category, location, and status.
7. Students can open a report and see complete details.
8. Students can obtain the reporter's contact information.
9. Students can edit and delete their own reports.
10. Students can update the status of their own reports.
11. Dashboard summary data is displayed correctly.
12. The application can be run locally using the provided setup instructions.
13. Frontend and backend build successfully.
14. The core Lost & Found workflow can be completed without relying on Instagram or WhatsApp.

The primary success indicator is:

> **A Pradita student can report, search, and follow up on a lost or found item through one centralized application without having to search through Instagram Stories or WhatsApp groups.**

