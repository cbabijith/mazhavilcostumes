# Mazhavil Costumes — Implementation Plan

> **Created:** 2026-05-02 | **Total Phases:** 5 | **Total Estimate:** ~16 hrs

---

## Table of Contents

1. [Phase Overview](#phase-overview)
2. [RBAC Access Matrix](#rbac-access-matrix)
3. [Phase 1: Foundation](#phase-1-foundation)
4. [Phase 2: Order Module](#phase-2-order-module)
5. [Phase 3: Dashboard Redesign](#phase-3-dashboard-redesign)
6. [Phase 4: Product Enhancements](#phase-4-product-enhancements)
7. [Phase 5: Reports Module](#phase-5-reports-module)
8. [Confirmed Decisions](#confirmed-decisions)

---

## Phase Overview

| Phase | Scope | Est. Time | Depends On |
|-------|-------|-----------|------------|
| **Phase 1** | Foundation — DB migration, RBAC, Sidebar email fix, Logout confirm, Staff discount toggles | ~3 hrs | None |
| **Phase 2** | Order Module — Remove security deposit, Product & Order discounts, Cancel with refund check | ~4 hrs | Phase 1 |
| **Phase 3** | Dashboard — Operational cards (all roles) + Admin-only revenue (by order status) | ~2.5 hrs | Phase 1 |
| **Phase 4** | Product — Purchase price field, Enhanced product detail stats | ~1.5 hrs | Phase 1 |
| **Phase 5** | Reports — 11 reports (R1–R11), Excel/PDF export, Customer enquiry log | ~5 hrs | Phases 1–4 |

---

## RBAC Access Matrix

### Screen-Level Access

| Screen / Module | Admin | Manager | Staff |
|----------------|-------|---------|-------|
| Dashboard (Revenue + Ops) | ✅ Full | ❌ Ops Only | ❌ Ops Only |
| Dashboard (Ops Only) | ✅ | ✅ | ✅ |
| Orders | ✅ Full | ✅ Full | ✅ Full |
| Calendar | ✅ | ✅ | ✅ |
| Products | ✅ Full CRUD | ✅ Full CRUD | ✅ Full CRUD |
| Categories | ✅ Full CRUD | ✅ Full CRUD | ✅ Full CRUD |
| Customers | ✅ Full CRUD | ✅ Full CRUD | ✅ Full CRUD |
| Banners | ✅ Full CRUD | ✅ Full CRUD | ✅ Full CRUD |
| Staff | ✅ Full CRUD | ✅ Full CRUD | ❌ Hidden |
| Branches | ✅ Full CRUD | ❌ Hidden | ❌ Hidden |
| Settings | ✅ Full access | ❌ Hidden | ❌ Hidden |
| Switch Branches | ✅ | ❌ | ❌ |

### Feature-Level Permissions (Orders)

| Feature | Admin | Manager | Staff |
|---------|-------|---------|-------|
| Create/Edit/View orders | ✅ | ✅ | ✅ |
| Cancel order (with mandatory reason) | ✅ | ✅ | ✅ |
| Start rental | ✅ | ✅ | ✅ |
| Process return | ✅ | ✅ | ✅ |
| Collect payment | ✅ | ✅ | ✅ |
| Product-level discount | ✅ Always | 🔒 `can_give_product_discount` | 🔒 `can_give_product_discount` |
| Order-level discount | ✅ Always | 🔒 `can_give_order_discount` | 🔒 `can_give_order_discount` |
| Edit item rent amount | ✅ Always | 🔒 `can_give_product_discount` | 🔒 `can_give_product_discount` |
| Delete order | ✅ | ❌ | ❌ |
| Adjust (late fee, damage) | ✅ | ✅ | ✅ |

> **Note:** `can_give_product_discount` and `can_give_order_discount` are per-staff toggles in the staff table, managed by admin/manager via the Staff edit form.

---

## Phase 1: Foundation

**Goal:** Set up the database schema, fix RBAC, fix sidebar bugs, add staff discount toggles.

### Step 1A: Database Migration (`006_foundation.sql`)

```sql
-- Staff: discount permission toggles
ALTER TABLE staff ADD COLUMN IF NOT EXISTS can_give_product_discount BOOLEAN DEFAULT false;
ALTER TABLE staff ADD COLUMN IF NOT EXISTS can_give_order_discount BOOLEAN DEFAULT false;

-- Order Items: per-item discount
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS discount DECIMAL(10, 2) DEFAULT 0;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS discount_type VARCHAR(10) DEFAULT 'flat'
    CHECK (discount_type IN ('flat', 'percent'));

-- Orders: order-level discount type + cancellation tracking
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount_type VARCHAR(10) DEFAULT 'flat'
    CHECK (discount_type IN ('flat', 'percent'));
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancelled_by UUID REFERENCES staff(id) ON DELETE SET NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;

-- Orders: DROP security deposit columns
ALTER TABLE orders DROP COLUMN IF EXISTS security_deposit;
ALTER TABLE orders DROP COLUMN IF EXISTS deposit_collected;
ALTER TABLE orders DROP COLUMN IF EXISTS deposit_collected_at;
ALTER TABLE orders DROP COLUMN IF EXISTS deposit_payment_method;
ALTER TABLE orders DROP COLUMN IF EXISTS deposit_returned;
ALTER TABLE orders DROP COLUMN IF EXISTS deposit_returned_at;

-- Products: DROP security_deposit, ADD purchase_price
ALTER TABLE products DROP COLUMN IF EXISTS security_deposit;
ALTER TABLE products ADD COLUMN IF NOT EXISTS purchase_price DECIMAL(10, 2) DEFAULT 0;
```

### Step 1B: RBAC Update

**File:** `apps/admin/lib/permissions.ts`

Update `rolePermissions`:
- **Staff:** `['dashboard', 'orders', 'products', 'categories', 'customers', 'banners']`
- **Manager:** Staff permissions + `'staff'`
- **Admin:** Everything (unchanged)

### Step 1C: Quick Fixes

**Sidebar Email (Sidebar.tsx):**
- Currently shows hardcoded `role@mazhavilcostumes.com`
- Fix: Read `user.email` from `appStore`

**Logout Confirmation (Sidebar.tsx):**
- Add confirmation modal before `supabase.auth.signOut()`
- "Are you sure you want to log out?"

### Step 1D: Staff Form — Discount Toggles

**File:** `apps/admin/components/admin/StaffForm.tsx`

Add "Discount Permissions" section with two toggles:
- **Product Discount** — "Allow editing rent price and applying item-level discounts"
- **Order Discount** — "Allow applying overall order discounts on the total amount"

Only visible when role is `manager` or `staff` (admin always has full access).

### Step 1E: Auth & Store Updates

- **`lib/auth.ts`** — Fetch `can_give_product_discount`, `can_give_order_discount` from staff table
- **`stores/appStore.ts`** — Add discount fields to `User` interface
- **`domain/types/branch.ts`** — Add discount fields to `Staff` interface
- **`domain/types/order.ts`** — Remove deposit fields, add cancellation fields, add item discount fields
- **`hooks/useDiscountPermission.ts`** — New hooks: `useProductDiscountPermission()`, `useOrderDiscountPermission()`

### Files Modified in Phase 1

| File | Change |
|------|--------|
| `database/migrations/006_foundation.sql` | **New** — schema changes |
| `lib/permissions.ts` | Update staff/manager permission arrays |
| `lib/auth.ts` | Fetch discount permissions from staff |
| `domain/types/branch.ts` | Add discount fields to Staff |
| `domain/types/order.ts` | Remove deposit, add cancel + discount fields |
| `stores/appStore.ts` | Add discount fields to User type |
| `components/admin/Sidebar.tsx` | Fix email, add logout confirm |
| `components/admin/StaffForm.tsx` | Add discount permission toggles |
| `hooks/useDiscountPermission.ts` | **New** — permission hooks |
| `hooks/index.ts` | Export new hooks |
| `app/api/auth/me/route.ts` | Return discount permissions |
| `app/api/staff/*` | Whitelist new fields |

---

## Phase 2: Order Module

**Goal:** Remove security deposit, implement dual-level discount system, implement cancel with refund check.

### Step 2A: Remove Security Deposit from UI

| File | Changes |
|------|---------|
| `OrderForm.tsx` | Remove deposit toggle, amount input, payment method (lines ~902-954). Remove `depositCollected`, `depositAmount`, `depositPaymentMethod` state variables. Remove deposit from `handleCheckout` payload. Remove deposit validation. |
| `OrderDetailsView.tsx` | Remove "Security Deposit" row in receipt card. Remove deposit editing. Remove "Refund Security Deposit" button. Remove deposit refund logic. |
| `orderService.ts` | Remove deposit from auto-complete logic. Remove `markDepositReturned` method. |
| `orderRepository.ts` | Remove deposit-related queries |
| API routes | Remove deposit endpoints (`app/api/orders/[id]/deposit/`) |

### Step 2B: Product-Level Discount

**In OrderForm.tsx cart items:**
- Make `price_per_day` an editable input (only if `useProductDiscountPermission()`)
- Add per-item discount field with flat/% toggle
- Update totals calculation:

```
Item Total = (price_per_day * quantity) - item_discount
```

### Step 2C: Order-Level Discount

**In OrderForm.tsx below totals:**
- Add order discount section (only if `useOrderDiscountPermission()`)
- Flat ₹ or % toggle
- Totals display:

```
Subtotal                    ₹2,500
GST (18%)                     ₹450
──────────────────────────────────
Gross Total                 ₹2,950
Order Discount              -₹200
──────────────────────────────────
Grand Total                 ₹2,750
Advance Paid               -₹1,000
──────────────────────────────────
Balance Due                 ₹1,750
```

### Step 2D: Cancel with Reason + Refund Check

**Cancel Flow:**
1. User clicks "Cancel Order"
2. System checks if `amount_paid > 0`
3. If yes → warning: "This order has ₹X already paid. You can cancel and refund, or refund and cancel."
4. Mandatory reason textarea
5. On confirm: store `cancellation_reason`, `cancelled_by`, `cancelled_at`
6. Create refund payment record if applicable
7. Track in order status history

**Cancel Modal Design:**
```
┌─────────────────────────────────────────┐
│  Cancel Order #A1B2C3                   │
│                                         │
│  ⚠️ ₹1,500 has been paid for this      │
│  order. A refund record will be created │
│  upon cancellation.                     │
│                                         │
│  Reason for cancellation: *             │
│  [________________________________]     │
│  [________________________________]     │
│                                         │
│  □ Process refund of ₹1,500            │
│    Payment mode: [Cash ▾]              │
│                                         │
│        [Go Back]   [Cancel Order]       │
└─────────────────────────────────────────┘
```

### Files Modified in Phase 2

| File | Change |
|------|--------|
| `components/admin/OrderForm.tsx` | Remove deposit, add discounts, editable rent |
| `components/admin/OrderDetailsView.tsx` | Remove deposit UI, update cancel modal, show discounts |
| `services/orderService.ts` | Remove deposit logic, add discount validation, cancel with reason |
| `repository/orderRepository.ts` | Save item-level discounts, cancel data |
| `app/api/orders/[id]/route.ts` | Handle cancel reason, discount fields |
| `app/api/orders/[id]/deposit/route.ts` | **Delete** this route |
| `hooks/useOrders.ts` | Update types |

---

## Phase 3: Dashboard Redesign

**Goal:** Operational dashboard for all roles + Admin-only revenue section with status breakdown.

### Step 3A: Operational Dashboard (All Roles)

Six cards in 3×2 grid, each showing `X Invoices (Y Products)`:

| Card | Query Logic |
|------|------------|
| **Today's Booking** | `created_at::date = today AND status != 'cancelled'` |
| **Today's Delivery** | `start_date = today AND status IN ('scheduled','confirmed')` |
| **Today's Return** | `end_date = today AND status IN ('ongoing','in_use','late_return')` |
| **Prepare Delivery** | `start_date BETWEEN today AND today+7 AND status IN ('scheduled','confirmed')` |
| **Pending Delivery** | `start_date < today AND status IN ('scheduled','confirmed')` |
| **Pending Return** | `end_date <= today AND status IN ('ongoing','in_use','late_return')` |

Each card is **clickable** → navigates to `/dashboard/orders` with appropriate filter.

### Step 3B: Admin Revenue Section (Admin Only)

**Revenue by Order Status:**
- **Completed Revenue:** Total `amount_paid` from completed orders
- **Ongoing Revenue:** Total `amount_paid` from ongoing/in_use orders
- **Scheduled Revenue:** Total `advance_amount` from scheduled orders

Also includes (existing):
- Revenue Pacing, Category Revenue, Booking Velocity, Dead Stock
- **New:** Cancellation stats (count + refund total)
- **Remove:** "Asset Exposure" card (deposit-related)

### Step 3C: New Service Method

```typescript
// dashboardService.ts
interface OperationalMetrics {
  todaysBooking: { invoiceCount: number; productCount: number };
  todaysDelivery: { invoiceCount: number; productCount: number };
  todaysReturn: { invoiceCount: number; productCount: number };
  prepareDelivery: { invoiceCount: number; productCount: number; days: number };
  pendingDelivery: { invoiceCount: number; productCount: number; daysSince: number };
  pendingReturn: { invoiceCount: number; productCount: number; daysSince: number };
}

interface RevenueByStatus {
  completed: number;
  ongoing: number;
  scheduled: number;
  cancelled: { count: number; refundTotal: number };
}
```

### Files Modified in Phase 3

| File | Change |
|------|--------|
| `services/dashboardService.ts` | Add `getOperationalMetrics()`, `getRevenueByStatus()`, remove deposits |
| `app/dashboard/page.tsx` | Complete redesign — ops cards + conditional revenue |
| `app/api/dashboard/route.ts` | New or updated API for operational metrics |

---

## Phase 4: Product Enhancements

**Goal:** Add purchase price field, enhance product detail page with comprehensive stats.

### Step 4A: Purchase Price Field

- Add `purchase_price` input to `ProductForm.tsx`
- Display in product detail page
- Used for ROI calculation in Phase 5 reports

### Step 4B: Enhanced Product Detail Stats

Add to existing product detail page (`products/[id]/page.tsx`):

| Stat | Calculation |
|------|-------------|
| Monthly revenue table (last 6 months) | Aggregate `order_items.subtotal` by month |
| Usage rate (%) | `total_rental_days / days_since_creation × 100` |
| Average rental duration | Mean of `(end_date - start_date)` across orders |
| Cancelled orders count | Orders with this product that were cancelled |
| ROI | `total_revenue / purchase_price × 100` (if purchase_price > 0) |

### Files Modified in Phase 4

| File | Change |
|------|--------|
| `components/admin/ProductForm.tsx` | Add purchase_price input |
| `app/dashboard/products/[id]/page.tsx` | Enhanced stats + monthly revenue table |
| `app/api/products/[id]/orders/route.ts` | Return monthly breakdown + new stats |
| `domain/types/product.ts` | Add `purchase_price` to interfaces |

---

## Phase 5: Reports Module

**Goal:** Build 11 reports, all exportable as Excel (.xlsx) and PDF.

### New Page: `/dashboard/reports`

Report selector with sub-pages for each report type.

### Reports List

| ID | Report Name | Category | Filters | Data Source |
|----|------------|----------|---------|-------------|
| R1 | Day-wise Booking | Booking | Date (default: tomorrow) | Orders by `start_date` |
| R2 | Due/Overdue Report | Due | As of today, sorted most overdue first | Orders where `end_date ≤ today` + active status |
| R3 | Revenue Report | Sale | Status (Completed/Ongoing/Scheduled), Period (Day/Week/Month/Year/Custom) | Orders `amount_paid` + `advance_amount` |
| R4 | Top Costumes | Sale | Rank by: Rental Count / Revenue | `order_items` aggregated by product |
| R5 | Top Customers | Sale | Period filter | Customers ranked by total spend |
| R6 | Item Rental Frequency | Sale | Reverse by count, printable | Products ranked by rental count |
| R7 | ROI / Profit per Costume | Sale | All products with `purchase_price > 0` | `total_revenue / purchase_price` |
| R8 | Dead Stock / No-Sale | Sale | Period (Month/Year/Custom) | Products with 0 rentals in period |
| R9 | Sales by Staff | Sale | Month/Year | Staff ranked by revenue from their created orders |
| R10 | Inventory + Revenue | Inventory | None | Per-product: stock levels + lifetime revenue |
| R11 | Customer Enquiry Log | Reminder | Month/Year | Manual entries from staff |

### R3 — Revenue Report Detail

Before showing results, filter by status:
- ☐ Completed orders
- ☐ Ongoing orders
- ☐ Scheduled orders

Results show each status **separately** in the report.

### R4 — Top Costumes Detail

Two ranking modes (toggle):
- **By Rental Count** — Most rented first
- **By Revenue** — Highest earning first

### R7 — ROI Report Detail

Uses `purchase_price` field (added in Phase 4):
```
ROI = ((Total Revenue - Purchase Price) / Purchase Price) × 100
```

### R11 — Customer Enquiry Log

**New DB table:** `customer_enquiries`
```sql
CREATE TABLE customer_enquiries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_query VARCHAR(255) NOT NULL,  -- What the customer asked for
  customer_name VARCHAR(255),
  customer_phone VARCHAR(20),
  notes TEXT,
  logged_by UUID REFERENCES staff(id),
  branch_id UUID REFERENCES branches(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**UI:** Simple form on the reports page:
- "What did the customer ask for?" (text input)
- Customer name/phone (optional)
- Notes (optional)
- Submit → saved to `customer_enquiries`

**Report View:** Monthly/yearly aggregation showing what products are in demand but unavailable.

### Export Format

All reports support:
- **Excel (.xlsx)** — using a library like `xlsx` or `exceljs`
- **PDF** — using `jspdf` + `jspdf-autotable` or server-side rendering

### Files Created in Phase 5

| File | Purpose |
|------|---------|
| `database/migrations/007_reports.sql` | Customer enquiries table |
| `app/dashboard/reports/page.tsx` | Reports landing page |
| `app/dashboard/reports/[type]/page.tsx` | Individual report pages |
| `services/reportService.ts` | Report data queries |
| `repository/reportRepository.ts` | Raw DB queries for reports |
| `lib/exportUtils.ts` | Excel/PDF export helpers |
| `app/api/reports/[type]/route.ts` | Report data API endpoints |
| `components/admin/ReportFilters.tsx` | Shared filter components |
| `components/admin/ReportTable.tsx` | Shared table with export buttons |

---

## Confirmed Decisions

| # | Decision | Status |
|---|----------|--------|
| 1 | Staff sees: Dashboard, Orders, Calendar, Products, Categories, Customers, Banners | ✅ Confirmed |
| 2 | Manager = Staff + Staff module | ✅ Confirmed |
| 3 | Admin = Everything | ✅ Confirmed |
| 4 | Separate product discount and order discount toggles | ✅ Confirmed |
| 5 | Security deposit removed from BOTH UI and DB | ✅ Confirmed |
| 6 | Staff has full Customer module access | ✅ Confirmed |
| 7 | ALL roles can cancel with mandatory reason | ✅ Confirmed |
| 8 | Cancel checks for refund, warns, tracks | ✅ Confirmed |
| 9 | Staff can collect payments | ✅ Confirmed |
| 10 | Discounts support flat (₹) and percentage (%) | ✅ Confirmed |
| 11 | Sidebar shows actual user email | ✅ Confirmed |
| 12 | Logout confirmation dialog | ✅ Confirmed |
| 13 | Revenue breakdown by: Completed / Ongoing / Scheduled | ✅ Confirmed |
| 14 | Product `purchase_price` field for ROI | ✅ Confirmed |
| 15 | R11 = Manual enquiry log | ✅ Confirmed |
| 16 | All reports exportable as Excel + PDF | ✅ Confirmed |
| 17 | R3 has status filter before results | ✅ Confirmed |
| 18 | R4 has dual ranking (count + revenue) | ✅ Confirmed |
| 19 | Drop deposit columns immediately (clean slate) | ✅ Confirmed |
| 20 | Product detail shows stats table (no chart library) | ✅ Confirmed |
