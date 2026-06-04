# Mobile App Features Roadmap

This document catalogs the current implementation status of features in `apps/mobile` compared to the admin dashboard (`apps/admin`), outlining the development objectives for the **Product**, **Order**, and **Calendar** modules.

---

## 1. Feature Status Matrix

| Module | Status | Core UI | Business Logic | Alignment with Admin |
|---|---|---|---|---|
| **Auth** | ✅ Complete | Login & Splash Views | Next.js API Auth | Aligned |
| **Dashboard** | ✅ Complete | Metric Cards, Lists | Operational Stats Service | Aligned |
| **Products** | 🔄 In Development | List, Detail Views | Partially Linked | Needs inventory & Branch checks |
| **Orders** | 🔄 In Development | Basic Lists | Simple Create/Edit | Needs reservation & availability validation |
| **Calendar** | ⏳ Planned | Stub screen | None | Needs calendar grid & booking validation |
| **Customers** | ✅ Complete | Profile/KYC Lists | CRUD integrations | Aligned |
| **Branches** | ✅ Complete | Store details/list | Branch locations CRUD | Aligned |
| **Payments** | ⏳ Planned | Empty | None | Needs cash/UPI/bank ledger |
| **Staff** | ⏳ Planned | Empty | None | Needs role/RBAC permissions |
| **Reports** | ⏳ Planned | Empty | None | Needs revenue & GST reporting views |

---

## 2. Module Development Targets

### A. Product Module
- **Goal**: Align mobile product catalog and creation/edit forms with Next.js rules.
- **Key Fields**:
  - `price_per_day` (costume rental pricing).
  - `security_deposit`.
  - Inventory tracking: `total_quantity`, `available_quantity`, `reserved_quantity`, `maintenance_quantity`.
  - Condition details: `condition`, `sanitization_status`.
- **Tasks**:
  1. Refactor `ProductFormView` to support inventory statuses and branch checks.
  2. Implement proper image upload capability to Cloudflare R2 via `UploadRepository`.

### B. Order Module
- **Goal**: Track orders, handle status flow, and validate stock prior to saving.
- **State Flow**: `Pending` $\rightarrow$ `Confirmed` $\rightarrow$ `Active` (rented out) $\rightarrow$ `Returned` / `Late` $\rightarrow$ `Cancelled`.
- **Validation**:
  - Availability date checks to prevent double booking.
  - Branch availability verification.
- **Tasks**:
  1. Sync Order Models and status changes with the admin API endpoints.
  2. Implement availability checks in the booking form.

### C. Calendar Module
- **Goal**: Render rental booking schedules and statuses visually on a grid/calendar.
- **Tasks**:
  1. Build a clean, swipeable month/week grid view (`CalendarView`).
  2. Implement visual indicators for dates showing rented out, reserved, and available costumes.
  3. Allow quick detail views of bookings directly from calendar cells.
