# Pradita Find — Architecture

Build a simple full-stack web application named **Pradita Find**.

## Tech Stack

* Frontend: React + TypeScript + Vite + Tailwind CSS
* Backend: Node.js + TypeScript + Express
* Database: MongoDB
* ODM: Mongoose
* API style: REST API
* Package manager: npm
* Use Docker Compose for MongoDB
* Use `.env.example` for environment configuration

## Code Rules

* Do not add comments unless truly necessary.
* Use PascalCase for all classes, types, interfaces, enums, React components, database models, API DTOs, and JSON property names.
* Local variables may use camelCase.
* Keep code lines below 150 characters where practical.
* Keep the implementation simple and consistent.
* Use a clean folder structure.
* Do not add authentication in the first version.

## Main Entities

### 1. Report

Represents a lost or found item report.

Fields:

* Id
* Type
* ItemName
* CategoryId
* Description
* LocationId
* Date
* ImageUrl
* ReporterName
* ReporterEmail
* Status
* CreatedAt
* UpdatedAt

`Type`:

* `LOST`
* `FOUND`

`Status`:

* `ACTIVE`
* `RESOLVED`

### 2. Category

Fields:

* Id
* Name
* CreatedAt

### 3. Location

Fields:

* Id
* Name
* CreatedAt

## Database Rules

* `Report.Type` must be `LOST` or `FOUND`.
* `Report.Status` must be `ACTIVE` or `RESOLVED`.
* `Report.CategoryId` must reference an existing Category.
* `Report.LocationId` must reference an existing Location.
* Resolved reports must remain stored in MongoDB.
* Deleting a report must remove only the selected report.
* Use timestamps for report creation and updates.
* Add indexes for fields frequently used in search and filtering.
* Seed initial categories, campus locations, and example reports.

## Backend Architecture

Use a simple layered structure:

```text
Route
  ↓
Controller
  ↓
Service
  ↓
Model
  ↓
MongoDB
```

### Routes

Define REST routes separately from business logic.

### Controllers

Controllers handle:

* Request parameters
* Request body
* Query parameters
* Response status
* Response data

Controllers should not contain complex business logic.

### Services

Services handle:

* Report creation and update
* Search and filtering
* Status changes
* Category management
* Location management
* Dashboard aggregation

### Models

Mongoose schemas and models are stored in the backend and are not shared with the frontend.

## Backend Features

### Report API

Support:

* Create report
* List reports
* Get report detail
* Update report
* Delete report
* Update report status

### Search and Filter

`GET /api/reports` supports:

* `search`
* `type`
* `category`
* `location`
* `status`
* `date`

Search should support matching against relevant report information such as:

* ItemName
* Description
* Category

Example:

```text
GET /api/reports?search=charger&type=FOUND&status=ACTIVE
```

### Dashboard API

Return aggregated information:

* TotalReports
* LostReports
* FoundReports
* ActiveReports
* ResolvedReports
* RecentReports

The dashboard data must be calculated from MongoDB.

## Required API Routes

### Reports

```text
GET    /api/reports
POST   /api/reports
GET    /api/reports/:Id
PUT    /api/reports/:Id
DELETE /api/reports/:Id
PATCH  /api/reports/:Id/status
```

### Categories

```text
GET    /api/categories
POST   /api/categories
PUT    /api/categories/:Id
DELETE /api/categories/:Id
```

### Locations

```text
GET    /api/locations
POST   /api/locations
PUT    /api/locations/:Id
DELETE /api/locations/:Id
```

### Dashboard

```text
GET    /api/dashboard
```

## Frontend Architecture

Use a simple page/component/service structure.

### Pages

```text
Dashboard
Reports
CreateReport
ReportDetail
EditReport
Categories
Locations
```

### Components

Reusable components should include:

* ReportCard
* ReportTable
* SearchBar
* FilterPanel
* ReportForm
* StatusBadge
* ConfirmationDialog
* LoadingState
* EmptyState

### Services

Create frontend API services for:

```text
ReportService
CategoryService
LocationService
DashboardService
```

Frontend services are responsible for communicating with the REST API.

## UI Data Flow

```text
React Component
      ↓
Frontend Service
      ↓
REST API
      ↓
Controller
      ↓
Service
      ↓
Mongoose Model
      ↓
MongoDB
```

For example:

```text
ReportPage
   ↓
ReportService.getReports()
   ↓
GET /api/reports
   ↓
ReportController
   ↓
ReportService
   ↓
ReportModel
   ↓
MongoDB
```

## Shared Package

Use a TypeScript monorepo with npm workspaces.

```text
pradita-find/
  apps/
    web/
    api/
  packages/
    shared/
```

Create:

```text
@pradita-find/shared
```

Use the shared package for:

* Shared models
* Enums
* API response types
* Request DTOs
* Shared constants

Example:

```text
packages/shared/src/
  models/
    Report.ts
    Category.ts
    Location.ts
  enums/
    ReportType.ts
    ReportStatus.ts
  dto/
    ReportResponse.ts
    DashboardResponse.ts
  index.ts
```

`apps/web` and `apps/api` must import shared types from `@pradita-find/shared`.

Do not duplicate shared TypeScript definitions between frontend and backend.

## Project Structure

```text
pradita-find/
  apps/
    web/
      src/
        components/
        pages/
        services/
        hooks/
        layouts/
        App.tsx
        main.tsx

    api/
      src/
        controllers/
        services/
        routes/
        models/
        dto/
        config/
        utils/
        app.ts
        server.ts

  packages/
    shared/
      src/
        models/
        enums/
        dto/
        index.ts

  docker-compose.yml
  .env.example
  package.json
```

## Environment Configuration

`.env.example` should contain:

```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/pradita_find
```

The frontend should use an environment variable for the backend API URL.

Example:

```env
VITE_API_URL=http://localhost:5000/api
```

## Docker

Use Docker Compose only for MongoDB in the first version.

Example services:

```text
docker-compose.yml
  └── mongodb
```

The backend and frontend may run locally during development.

## API Response Rules

Use a consistent JSON response structure.

Success:

```json
{
  "Success": true,
  "Data": {}
}
```

Error:

```json
{
  "Success": false,
  "Message": "Laporan tidak ditemukan"
}
```

For list endpoints:

```json
{
  "Success": true,
  "Data": [],
  "Total": 0
}
```

## Model Mapping

Mongoose models are database-specific.

The backend should map Mongoose documents into shared API models before returning responses.

The frontend must never import:

* Mongoose types
* MongoDB-specific document types
* Backend-only models

## Development Requirements

Provide npm scripts for:

* Installing dependencies
* Running frontend
* Running backend
* Running both applications
* Building all packages
* Running MongoDB with Docker
* Seeding database

The entire monorepo should compile successfully with a single build command.
