# PROJECT CONTRACT
## Mazhavil Dance Costumes - Rental Management System

**Contract Reference**: MC-2026-001  
**Date**: June 15, 2026  
**Prepared For**: Mahavadevan Sir, Supportta Solutions  
**Project Name**: Mazhavil Dance Costumes Rental Management System  
**Version**: 1.0

---

## TABLE OF CONTENTS

1. [Executive Summary](#1-executive-summary)
2. [Project Overview](#2-project-overview)
3. [Technical Architecture](#3-technical-architecture)
4. [Technology Stack](#4-technology-stack)
5. [System Features](#5-system-features)
6. [Database Architecture](#6-database-architecture)
7. [API Architecture](#7-api-architecture)
8. [Security Model](#8-security-model)
9. [Mobile Application](#9-mobile-application)
10. [Deployment Architecture](#10-deployment-architecture)
11. [Project Deliverables](#11-project-deliverables)
12. [Maintenance & Support](#12-maintenance--support)
13. [Project Timeline](#13-project-timeline)
14. [Terms & Conditions](#14-terms--conditions)
15. [Acceptance Criteria](#15-acceptance-criteria)

---

## 1. EXECUTIVE SUMMARY

Mazhavil Dance Costumes is a comprehensive costume rental management system designed for single-shop, multi-branch operations. The system provides end-to-end management of costume inventory, customer relationships, rental orders, cleaning workflows, and business analytics through a modern web-based admin dashboard, customer-facing storefront, and staff mobile application.

### Key Highlights
- **Modern Monorepo Architecture**: Built with pnpm workspaces and Turborepo for efficient development
- **Multi-Platform**: Web (Admin + Storefront) + Mobile (Flutter) applications
- **Scalable Database**: Supabase PostgreSQL with Row-Level Security (RLS)
- **Cloud Storage**: Cloudflare R2 for optimized image management
- **Role-Based Access Control**: granular permissions for super_admin, admin, manager, and staff roles
- **Real-Time Operations**: Live inventory tracking, order management, and cleaning workflows

---

## 2. PROJECT OVERVIEW

### 2.1 Business Context
Mazhavil Dance Costumes operates as a single retail business with multiple physical branches. The system manages:
- High-value costume inventory across multiple locations
- Customer relationships and KYC verification
- Rental order lifecycle from booking to return
- Cleaning and maintenance workflows
- Damage assessment and charge calculations
- Business analytics and reporting

### 2.2 System Components

#### A. Admin Dashboard (Port 3001)
- **Purpose**: Internal management system for staff and administrators
- **Users**: super_admin, admin, manager, staff
- **Key Modules**: Categories, Products, Orders, Customers, Cleaning, Reports, Settings

#### B. Storefront (Port 3002)
- **Purpose**: Customer-facing rental interface
- **Users**: End customers
- **Key Features**: Product browsing, category filtering, WhatsApp booking requests

#### C. Mobile Application (Flutter)
- **Purpose**: Staff companion app for on-the-go operations
- **Users**: Staff members
- **Architecture**: Thin client communicating with Next.js API

### 2.3 Monorepo Structure
```
mazhavilcostumes/
├── apps/
│   ├── admin/          # Next.js 16 Admin Dashboard
│   ├── storefront/     # Next.js 16 Customer Storefront
│   └── mobile/         # Flutter Mobile App
├── packages/
│   ├── shared-api/     # Shared API functions
│   ├── shared-types/   # TypeScript type definitions
│   ├── shared-ui/      # Reusable UI components
│   └── shared-utils/   # Utility functions
├── database/           # SQL schemas and migrations
└── docs/              # Documentation
```

---

## 3. TECHNICAL ARCHITECTURE

### 3.1 Next.js Architecture (Admin & Storefront)

Both web applications follow a strict **5-Layer Architecture** pattern:

```
Domain → Repository → Service → Hooks → Components/Pages
```

#### Layer Responsibilities

| Layer | Location | Purpose | Constraints |
|-------|-----------|---------|-------------|
| **Domain** | `domain/` | Zod validation schemas, TypeScript interfaces, type-guards, enums | Pure functions and static definitions. No imports from other layers |
| **Repository** | `repository/` | Direct database transactions (Supabase CRUD). Extends BaseRepository | No business logic. Returns RepositoryResult<T> pattern |
| **Service** | `services/` | Business validation, slug conflict resolution, parent-level checks, delete safety evaluations | Orchestrates multiple repositories. Returns formatted error codes |
| **Hooks** | `hooks/` | TanStack Query wrappers for fetching, caching, and mutations | Displays UI notifications via Zustand store |
| **Components** | `components/` | React pages and UI widgets | Must not query Supabase or Repositories directly. Always uses Hooks |

#### Singleton Pattern
All Repositories and Services export both class structure and singleton instance:
```typescript
export class ProductService { ... }
export const productService = new ProductService();
```

#### Barrel Exports
Every layer has an `index.ts` that re-exports everything. Import from barrel:
```typescript
import { Product } from '@/domain';
import { productService } from '@/services';
import { useProducts } from '@/hooks';
```

### 3.2 Flutter Mobile Architecture (Thin Client)

The mobile app functions as a strict UI client:

```
View (Widget) → Provider (Riverpod) → Repository (Dio) → Next.js API
```

#### Key Rules
1. **Riverpod State Management**: All UI interactions trigger Riverpod state controllers
2. **Repository Pattern**: Repositories wrap Dio network client, handle error states, map JSON payloads
3. **No Direct Database Access**: Mobile client communicates strictly with Next.js endpoints
4. **Responsive Layouts**: All widgets must support multi-device layouts (320px to tablets)

### 3.3 Module Folder Structure (Flutter)

Every feature module follows this structure:
```
features/<module_name>/
├── models/           # Data classes (fromJson/toJson)
├── repositories/     # HTTP calls via Dio to Next.js API
├── providers/        # Riverpod providers (state management)
└── views/            # UI widgets and screens
```

---

## 4. TECHNOLOGY STACK

### 4.1 Web Applications (Admin & Storefront)

#### Core Framework
- **Next.js**: 16.2.4 (App Router)
- **React**: 19.2.4
- **TypeScript**: 5.7.3 (strict mode)
- **Node.js**: >=20.9.0
- **Package Manager**: pnpm 9.15.4

#### Build Tools
- **Turborepo**: 2.3.3 (Monorepo orchestration)
- **Tailwind CSS**: 4 (Styling)
- **PostCSS**: CSS processing

#### Database & Backend
- **Supabase**: 2.105.4 (PostgreSQL + Auth + RLS)
- **@supabase/supabase-js**: 2.48.0
- **@supabase/ssr**: 0.5.2

#### State Management
- **TanStack Query**: 5.99.2 (Server state)
- **Zustand**: 5.0.12 (Client UI state)
- **React Hook Form**: 7.73.1 (Form state)
- **Zod**: 4.3.6 (Validation)

#### UI Components
- **shadcn/ui**: Component library (new-york style)
- **Radix UI**: Headless components
- **Lucide React**: 0.471.0 (Icons)
- **class-variance-authority**: 0.7.1
- **tailwind-merge**: 2.6.0

#### File Upload & Storage
- **@aws-sdk/client-s3**: 3.1035.0 (Cloudflare R2 compatibility)
- **Cloudflare R2**: Image storage and CDN

#### PDF & Barcode Generation
- **@react-pdf/renderer**: 4.5.1 (Invoice generation)
- **jsPDF**: 2.5.2
- **jsPDF-AutoTable**: 3.8.4
- **JsBarcode**: 3.12.3
- **@zxing/browser**: 0.2.0 (Barcode scanning)
- **@zxing/library**: 0.23.0

#### Date & Time
- **date-fns**: 4.1.0
- **react-day-picker**: 9.14.0

#### Drag & Drop
- **@dnd-kit/core**: 6.3.1
- **@dnd-kit/sortable**: 10.0.0
- **@dnd-kit/utilities**: 3.2.2

#### Charts & Analytics
- **Recharts**: 3.8.1

#### Image Processing
- **heic-convert**: 2.1.0 (HEIC to JPEG conversion)
- **html2canvas**: 1.4.1

#### Utilities
- **xlsx**: 0.18.5 (Excel export)
- **uuid**: 14.0.0

### 4.2 Mobile Application (Flutter)

#### Core Framework
- **Flutter SDK**: ^3.11.4
- **Dart**: ^3.11.4

#### State Management
- **flutter_riverpod**: 3.3.1
- **riverpod_annotation**: 4.0.2
- **riverpod_generator**: 4.0.3 (Code generation)

#### Networking
- **dio**: 5.9.2 (HTTP client)

#### Storage & Security
- **flutter_secure_storage**: 10.0.0
- **path_provider**: 2.1.5

#### UI Components
- **cupertino_icons**: 1.0.8
- **flutter_svg**: 2.2.4
- **auto_size_text**: 3.0.0 (Responsive text)
- **shimmer**: 3.0.0 (Loading skeletons)

#### Image Handling
- **image_picker**: 1.1.2
- **cached_network_image**: 3.4.1

#### Supabase Integration
- **supabase_flutter**: 2.8.4

#### Barcode Scanning
- **mobile_scanner**: 7.2.0

#### Utilities
- **intl**: 0.20.2 (Internationalization)
- **equatable**: 2.0.8 (Value equality)
- **url_launcher**: 6.3.1

#### Development Tools
- **build_runner**: 2.14.0
- **flutter_lints**: 6.0.0

### 4.3 Shared Packages

#### shared-types
- **Purpose**: TypeScript type definitions shared across apps
- **Dependencies**: TypeScript 5.7.3

#### shared-api
- **Purpose**: Shared Supabase queries, mutations, and API clients
- **Dependencies**: @supabase/supabase-js, shared-types, shared-utils

#### shared-ui
- **Purpose**: Reusable shadcn/ui components
- **Dependencies**: React 18/19, class-variance-authority, lucide-react, shared-utils

#### shared-utils
- **Purpose**: Common utility functions (cn, formatting, etc.)
- **Dependencies**: clsx, tailwind-merge

### 4.4 Development Tools

#### Linting & Formatting
- **ESLint**: 9
- **Prettier**: 3.4.2
- **TypeScript**: 5.7.3

#### Package Management
- **pnpm**: 9.15.4
- **Turborepo**: 2.3.3

---

## 5. SYSTEM FEATURES

### 5.1 Category Hierarchy System

#### 3-Level Hierarchy Structure
```
Main Category (parent_id = null)
├── Sub Category (parent_id = main.id)
│   ├── Variant (parent_id = sub.id) - Cannot have children
│   └── Variant (parent_id = sub.id)
└── Sub Category (parent_id = main.id)
    └── Variant (parent_id = sub.id)
```

#### Key Features
- **Auto-Generating Slugs**: Converts names to unique, lowercase, hyphenated slugs with collision resolution
- **GST & Tax Configuration**: Set GST percentages at category level, inherited by child products
- **Cleaning Buffer Configuration**: `has_buffer` flag dictates mandatory 1-day cleaning buffer between bookings
- **Cascade & Delete Safety**: Deletions blocked if category has child nodes or associated products
- **Collapsible Tree View**: Interactive expand/collapse navigation in admin dashboard
- **Category Detail Pages**: Deep drill-down with breadcrumbs and child management
- **Smart Child Creation**: Pre-filled parent selection via query parameters

### 5.2 Product & Inventory Management

#### Advanced Costume Attributes
- Size, color, material, weight
- Gemstones information
- Metal purity (e.g., 18K, 22K)
- Purchase cost tracking
- SKU and barcode generation

#### Rental Pricing Model
- Configurable `price_per_day` rental rates
- Security deposit amounts
- GST calculation based on category settings

#### Branch-Level Inventory Allocation
- `total_quantity`: Total physical inventory at branch
- `available_quantity`: Currently available for rent
- `low_stock_threshold`: Alert threshold per branch
- Multi-branch inventory tracking

#### Image Management
- **Client-Side Compression**: Canvas-based compression scales images up to 20MB down to <100KB WebP
- **Parallel Uploading**: Uses Promise.all for simultaneous uploads to Cloudflare R2
- **Direct CDN Serving**: Bypasses Next.js image proxying to avoid Vercel gateway timeouts
- **Optimistic Deletion**: Images deleted asynchronously from R2 after product deletion

#### Performance Features
- Instant save with background sync
- Server-side pagination
- Debounced search
- Optimistic UI updates

### 5.3 Rental Order Lifecycle

#### Order Status Flow
```
pending → confirmed → scheduled → delivered → in_use/ongoing → returned → completed/cancelled/flagged
```

#### Detailed Statuses
- **pending**: Initial booking request
- **confirmed**: Booking confirmed
- **scheduled**: Pickup scheduled
- **delivered**: Items delivered to customer
- **in_use/ongoing**: Customer currently using items
- **returned**: Items returned to store
- **completed**: Order fully completed
- **cancelled**: Order cancelled
- **flagged**: Order flagged for review

#### Rental Scheduling
- Explicit start and end dates
- Event date tracking
- Pickup and return time scheduling
- Delivery method (pickup/delivery)
- Delivery and pickup addresses

#### Stock Conflict Detection
- Real-time validation of inventory availability
- Checks total physical inventory minus active reservations
- Flags conflicts in `conflict_details` JSON field
- Prevents overbooking

#### Payment & Deposit Tracking
- **Payment Types**: advance, partial, full, late_fee, damage
- **Payment Modes**: cash, upi, card, bank_transfer
- **Advance Collection**: Track advance amount, collection status, method, and timestamp
- **Payment Status**: pending, partial, paid

#### Automatic Late Flagging
- Database triggers automatically set `is_late` flag
- Triggers when `end_date` is in past AND status is ongoing/in_use/delivered

### 5.4 Cleaning, Maintenance & Damage Control

#### Cleaning Records Management
- **Status Flow**: scheduled → pending → in_progress → completed
- **Priority Levels**: normal, urgent
- **Priority Urgent Cleaning**: Automatically flags as urgent if product is reserved for upcoming order
- **Priority Order Linking**: Links to `priority_order_id` for tracking
- **Expected Return Date**: Cleaning can begin after order's end date

#### Damage Assessment Flow
- **Condition Rating**: Excellent, Good, Fair, Damaged
- **Damage Decisions**: no_damage, minor, major, replace
- **Damage Charges**: Calculated per item and added to order totals
- **Unit-Level Tracking**: Tracks damaged units for quantity > 1
- **Assessment Notes**: Detailed documentation of damage

### 5.5 Customer Management

#### Comprehensive Profiles
- Contact details (name, email, phone, alt_phone)
- Physical address
- GSTIN (GST identification number)
- Profile photo URL

#### Identity Verification (KYC)
- **ID Types**: Aadhaar, Passport, Driving License, PAN, Other
- **ID Number**: Document number tracking
- **ID Documents**: JSON array of document URLs (front/back)
- **Photo Upload**: High-resolution profile photos

#### Customer Features
- Real-time search and pagination
- Optimistic UI deletions
- Unified form for create/edit
- Order history tracking

### 5.6 Marketing & Banners

#### Store Campaigns
- **Banner Types**: hero, promo, announcement
- **Configurable CTA**: Redirects to products, categories, or custom URLs
- **Accessibility Settings**: Alt text for images
- **Mobile Optimization**: Separate mobile image URLs
- **Campaign Scheduling**: Start and end dates
- **Priority System**: Higher priority = more important
- **Position Control**: Display order management

### 5.7 Storefront Web App (Customer-Facing)

#### Design
- **Luxury Minimalist UI**: Premium ivory, gold, and charcoal palette
- **Mobile-First**: Bottom mobile navigation with app-like experience
- **Responsive Design**: Optimized for all screen sizes

#### Features
- **Collection Page Filtering**: Filter by category, sub-category, size, availability
- **Product Browsing**: View products with images and details
- **WhatsApp Booking**: Pre-filled rental requests sent to store's WhatsApp

### 5.8 Admin Dashboard Features

#### Dashboard Analytics
- Today's bookings count
- Today's delivery total/done
- Today's return total/done
- Prepare deliveries (next 5 days)
- Pending deliveries
- Pending returns
- Revenue due
- Priority cleaning records

#### Order Management
- Order creation with customer selection
- Product selection with availability checking
- Stock conflict detection and resolution
- Payment tracking and recording
- Status updates with history
- Invoice generation (PDF)
- Barcode scanning for quick lookup

#### Product Management
- CRUD operations for products
- Category assignment (3-level hierarchy)
- Branch assignment
- Image upload with compression
- Inventory tracking
- Low stock alerts
- Featured product management

#### Customer Management
- Customer profiles with KYC
- ID document uploads
- Order history
- Search and filter
- Contact management

#### Cleaning Management
- Cleaning record creation
- Status tracking
- Priority management
- Urgent cleaning alerts
- Branch-based tracking

#### Reports
- Revenue reports
- Inventory reports
- Order reports
- Dead stock analysis (90+ days no rental)
- Custom date range reports

#### Settings
- Store configuration
- Branch management
- Staff management
- Role-based access control
- System settings

### 5.9 Staff Management

#### Roles & Permissions
- **super_admin**: Full system access
- **admin**: Full access except system-level operations
- **manager**: Branch management, order management, reporting
- **staff**: Read-only products/categories, order creation, cleaning updates

#### Staff Features
- Staff profile management
- Branch assignment
- Role assignment
- Activity tracking
- Authentication via Supabase

### 5.10 Branch Management

#### Multi-Branch Operations
- Branch creation and management
- Branch-specific inventory
- Branch assignment for products
- Branch assignment for staff
- Branch-specific order management
- Main branch designation

### 5.11 Invoice Generation

#### PDF Invoices
- Professional invoice layout
- Company branding
- Order details
- Itemized billing
- GST breakdown
- Payment status
- Barcode integration
- Auto-generated via @react-pdf/renderer

### 5.12 Barcode System

#### Barcode Features
- Product barcode generation
- Barcode scanning via @zxing
- Mobile app barcode scanning
- Quick product lookup
- Inventory tracking

---

## 6. DATABASE ARCHITECTURE

### 6.1 Database Platform
- **Provider**: Supabase
- **Database**: PostgreSQL
- **Security**: Row-Level Security (RLS)
- **Backup**: Automated by Supabase

### 6.2 Core Tables

#### audit_logs
Tracks all system changes for compliance and debugging.
- Columns: id, user_id, entity_type, entity_id, action, old_values, new_values, ip_address, user_agent, created_at

#### banners
Marketing banner management.
- Columns: id, store_id, title, subtitle, description, call_to_action, web_image_url, mobile_image_url, redirect_type, redirect_target_id, redirect_url, banner_type, position, is_active, priority, start_date, end_date, alt_text, audit fields

#### branches
Physical branch/store locations.
- Columns: id, store_id, name, address, phone, is_main, is_active, audit fields

#### categories
3-level category hierarchy.
- Columns: id, name, slug, description, image_url, parent_id, store_id, is_global, is_active, sort_order, gst_percentage, has_buffer, audit fields, deleted_at

#### cleaning_records
Cleaning workflow tracking.
- Columns: id, product_id, order_id, branch_id, quantity, status, priority, priority_order_id, started_at, completed_at, notes, expected_return_date, store_id, timestamps

#### customer_enquiries
Customer inquiry tracking.
- Columns: id, product_query, customer_name, customer_phone, notes, logged_by, branch_id, store_id, created_at

#### customers
Customer profiles and KYC.
- Columns: id, name, email, phone, alt_phone, address, gstin, photo_url, id_type, id_number, id_documents, audit fields, timestamps

#### damage_assessments
Damage evaluation and charges.
- Columns: id, order_id, order_item_id, product_id, branch_id, unit_index, decision, notes, assessed_by, assessed_at, timestamps

#### order_items
Individual items within an order.
- Columns: id, order_id, product_id, quantity, price_per_day, subtotal, condition_rating, damage_description, damage_charges, is_returned, returned_at, returned_quantity, discount, discount_type, gst_percentage, base_amount, gst_amount, damaged_quantity, timestamps

#### order_reservations
Inventory reservations for orders.
- Columns: id, order_id, product_id, branch_id, quantity, reserved_from, reserved_to, timestamps

#### order_status_history
Order status change tracking.
- Columns: id, order_id, status, notes, changed_by, created_at

#### orders
Main order management.
- Columns: id, store_id, branch_id, customer_id, pickup_branch_id, status, start_date, end_date, event_date, pickup_time, return_time, subtotal, gst_amount, gst_percentage, total_amount, amount_paid, payment_status, advance_amount, advance_collected, advance_payment_method, advance_collected_at, late_fee, discount, damage_charges_total, delivery_method, delivery_address, pickup_address, notes, audit fields, discount_type, cancellation_reason, cancelled_by, cancelled_at, has_priority_cleaning, has_stock_conflict, conflict_details, is_late, timestamps

#### payments
Payment transaction tracking.
- Columns: id, order_id, payment_type, amount, payment_mode, transaction_id, payment_date, notes, created_by, timestamps

#### product_inventory
Branch-specific inventory tracking.
- Columns: id, product_id, branch_id, quantity, available_quantity, low_stock_threshold, timestamps

#### products
Product catalog and inventory.
- Columns: id, store_id, category_id, subcategory_id, subvariant_id, branch_id, name, slug, description, sku, barcode, price_per_day, quantity, available_quantity, images, sizes, colors, material, weight, gemstones, metal_purity, is_active, is_featured, track_inventory, low_stock_threshold, total_rentals, total_revenue, avg_rating, reviews_count, last_rented_at, audit fields, purchase_price, deleted_at, timestamps

#### settings
System configuration.
- Columns: id, store_id, key, value, updated_by, updated_at

#### staff
Staff user management.
- Columns: id, store_id, branch_id, user_id, name, email, phone, role, is_active, audit fields, timestamps

#### stores
Store/company information.
- Columns: id, name, slug, email, phone, address, logo_url, subscription_status, is_active, gstin, timestamps

### 6.3 Database Functions (RPCs)

#### calculate_late_flag
Trigger function that automatically sets `is_late` flag based on:
- `end_date` is in the past
- Status is one of: ongoing, in_use, delivered

#### get_dead_stock
Returns products that haven't been rented in 90+ days.

#### get_operational_dashboard_metrics
Returns operational metrics for dashboard:
- Today's bookings
- Today's delivery total/done
- Today's return total/done
- Prepare deliveries (next 5 days)
- Pending deliveries
- Pending returns
- Revenue due
- Priority cleaning records

#### get_user_branch_id
Returns the branch ID of the authenticated staff member.

#### get_user_role
Returns the role of the authenticated staff member.

#### is_admin
Returns TRUE if authenticated user is super_admin or admin.

#### is_manager_or_admin
Returns TRUE if authenticated user is super_admin, admin, or manager.

#### is_super_admin
Returns TRUE if authenticated user is super_admin.

### 6.4 Database Triggers

#### update_branch_inventory_updated_at
Automatically updates `updated_at` timestamp on branch_inventory changes.

#### update_updated_at_column
Automatically updates `updated_at` timestamp on table changes.

#### trigger_update_late_flag
Automatically calculates and sets `is_late` flag on orders table when `end_date` or `status` changes.

### 6.5 Row-Level Security (RLS)

#### RLS Policies
- Policies applied to isolate reads and mutations
- Role-based access control:
  - `super_admin`, `admin`, `manager`: Full write access to categories, products, inventory, orders, settings
  - `staff`: Read-only access to products/categories, write access for orders and cleaning records

#### Audit Fields
All tables preserve audit fields:
- `created_by`: User who created the record
- `updated_by`: User who last updated the record
- `created_at_branch_id`: Branch where record was created
- `updated_at_branch_id`: Branch where record was last updated
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

---

## 7. API ARCHITECTURE

### 7.1 API Structure

All APIs are REST endpoints in Next.js App Router under `app/api/`.

#### API Modules
- `/api/auth` - Authentication endpoints
- `/api/banners` - Banner management
- `/api/branch-inventory` - Branch inventory operations
- `/api/branches` - Branch management
- `/api/calendar` - Calendar operations
- `/api/categories` - Category CRUD
- `/api/cleaning` - Cleaning record management
- `/api/cron` - Scheduled tasks
- `/api/customers` - Customer management
- `/api/dashboard` - Dashboard metrics
- `/api/enquiries` - Customer enquiries
- `/api/gallery` - Gallery management
- `/api/orders` - Order management
- `/api/payments` - Payment processing
- `/api/products` - Product management
- `/api/reports` - Report generation
- `/api/settings` - System settings
- `/api/staff` - Staff management
- `/api/upload` - File uploads

### 7.2 API Authentication

#### Authentication Method
- Supabase Auth integration
- JWT token validation
- Session management
- Role-based access control via `apiGuard()`

#### Permission Checks
All API routes must:
1. Authenticate user
2. Check permissions based on role
3. Call service layer
4. Return standardized response

### 7.3 API Response Format

#### Success Response
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

#### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error description"
  }
}
```

### 7.4 Key API Endpoints

#### Category API
- `GET /api/categories` - List all categories
- `POST /api/categories` - Create new category
- `GET /api/categories/:id` - Fetch single category
- `PATCH /api/categories/:id` - Update category
- `DELETE /api/categories/:id` - Delete category
- `GET /api/categories/:id/can-delete` - Pre-delete safety check
- `GET /api/categories/:id/children` - Get direct children
- `POST /api/categories/upload` - Upload category image

#### Product API
- `GET /api/products` - List products with pagination
- `POST /api/products` - Create product
- `GET /api/products/:id` - Fetch single product
- `PATCH /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product
- `POST /api/products/upload` - Upload product images

#### Order API
- `GET /api/orders` - List orders
- `POST /api/orders` - Create order
- `GET /api/orders/:id` - Fetch single order
- `PATCH /api/orders/:id` - Update order
- `DELETE /api/orders/:id` - Delete order
- `POST /api/orders/:id/status` - Update order status
- `GET /api/orders/:id/invoice` - Generate invoice PDF

#### Customer API
- `GET /api/customers` - List customers
- `POST /api/customers` - Create customer
- `GET /api/customers/:id` - Fetch single customer
- `PATCH /api/customers/:id` - Update customer
- `DELETE /api/customers/:id` - Delete customer

#### Cleaning API
- `GET /api/cleaning` - List cleaning records
- `POST /api/cleaning` - Create cleaning record
- `PATCH /api/cleaning/:id` - Update cleaning record
- `GET /api/cleaning/priority` - Get priority cleaning records

#### Payment API
- `GET /api/payments` - List payments
- `POST /api/payments` - Record payment
- `GET /api/payments/:id` - Fetch single payment

#### Upload API
- `POST /api/upload` - Upload file to Cloudflare R2
- Supports multipart/form-data
- Client-side compression before upload

### 7.5 API Security

#### Security Measures
- No hardcoded secrets
- Environment variable validation
- Field whitelisting on PATCH endpoints
- Input validation via Zod schemas
- SQL injection prevention via Supabase
- XSS prevention via React
- CSRF protection via Next.js

#### Rate Limiting
- Implemented via Next.js middleware
- Configurable per endpoint
- Prevents API abuse

---

## 8. SECURITY MODEL

### 8.1 Authentication

#### Supabase Auth
- Email/password authentication
- JWT token-based sessions
- Session refresh tokens
- Password reset functionality
- Multi-factor authentication (optional)

#### Staff Authentication
- Staff accounts linked to Supabase users
- Role assignment in staff table
- Branch-based access control
- Session timeout configuration

### 8.2 Authorization

#### Role-Based Access Control (RBAC)

##### super_admin
- Full system access
- User management
- System configuration
- All CRUD operations
- Access to all branches

##### admin
- Full access except system-level operations
- Cannot manage super_admin users
- Cannot modify system settings
- Access to all branches

##### manager
- Branch management
- Order management
- Product management
- Customer management
- Reporting and analytics
- Limited to assigned branch

##### staff
- Read-only access to products and categories
- Create and update orders
- Update cleaning records
- View assigned branch data
- Cannot delete products or categories

### 8.3 Row-Level Security (RLS)

#### RLS Policies
- Database-level security
- Policies applied to all tables
- Role-based table access
- Branch-level data isolation

#### Audit Trail
- All changes logged to audit_logs table
- Tracks user, action, entity, and timestamps
- IP address and user agent tracking
- Old and new values stored

### 8.4 Data Protection

#### Sensitive Data
- Passwords hashed by Supabase
- ID documents stored in secure R2 bucket
- Customer phone numbers masked in UI
- GSTIN and financial data protected

#### Encryption
- TLS/SSL for all communications
- Supabase encryption at rest
- R2 bucket encryption
- Secure token storage

### 8.5 Input Validation

#### Server-Side Validation
- Zod schemas for all inputs
- Type checking
- Length validation
- Format validation (email, phone, GSTIN)
- Business rule validation

#### Client-Side Validation
- React Hook Form validation
- Real-time feedback
- User-friendly error messages
- Prevents invalid submissions

### 8.6 API Security

#### Endpoint Security
- Authentication required for all protected endpoints
- Role-based permission checks
- Field whitelisting on updates
- Mass assignment prevention

#### CORS Configuration
- Configured for specific domains
- Prevents cross-origin attacks
- Development vs production settings

### 8.7 File Upload Security

#### Image Upload
- File type validation (images only)
- File size limits (max 20MB)
- Client-side compression
- Virus scanning (optional)
- Secure R2 bucket with CORS

#### Document Upload
- ID document validation
- File type restrictions
- Size limits
- Secure storage

---

## 9. MOBILE APPLICATION

### 9.1 Flutter App Architecture

#### Thin Client Pattern
The mobile app is a thin client that:
- Communicates exclusively with Next.js API
- No direct Supabase access
- All business logic on server
- State managed via Riverpod

#### Feature Modules

##### Auth Module
- Login screen
- Session management
- Token storage (flutter_secure_storage)
- Logout functionality

##### Branches Module
- Branch listing
- Branch selection
- Branch details

##### Categories Module
- Category browsing
- Category tree view
- Category filtering

##### Products Module
- Product listing
- Product search
- Product details
- Barcode scanning
- Image viewing

##### Orders Module
- Order creation
- Order listing
- Order details
- Order status updates
- Payment recording

##### Customers Module
- Customer listing
- Customer search
- Customer details
- Customer creation

##### Dashboard Module
- Operational metrics
- Today's summary
- Pending tasks
- Priority alerts

##### Calendar Module
- Calendar view
- Order scheduling
- Delivery/return tracking

### 9.2 Mobile UI/UX

#### Design Principles
- Material Design 3
- Responsive layouts (320px to tablets)
- Auto-sizing text
- Shimmer loading states
- Smooth animations

#### Responsive Rules
- No hardcoded widths
- Use Expanded, Flexible, LayoutBuilder
- AutoSizeText for text scaling
- SingleChildScrollView for scrollable content
- Support landscape mode

#### Navigation
- Bottom navigation bar
- App-like experience
- Smooth transitions
- Back button handling

### 9.3 Mobile Features

#### Barcode Scanning
- mobile_scanner integration
- Quick product lookup
- Order scanning
- Inventory verification

#### Image Handling
- Image picker integration
- Camera support
- Gallery selection
- Cached network images
- Optimized loading

#### Offline Support
- Cached data (optional)
- Offline queue (optional)
- Sync on reconnect (optional)

#### Push Notifications
- Order reminders
- Cleaning alerts
- Delivery notifications (optional)

### 9.4 Mobile Security

#### Secure Storage
- flutter_secure_storage for tokens
- Encrypted local storage
- Biometric authentication (optional)

#### Network Security
- HTTPS only
- Certificate pinning (optional)
- API token management
- Session timeout

---

## 10. DEPLOYMENT ARCHITECTURE

### 10.1 Web Deployment

#### Hosting Platform
- **Recommended**: Vercel (for Next.js apps)
- **Alternative**: AWS, DigitalOcean, or any Node.js hosting

#### Environment Variables
Required environment variables:
```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Cloudflare R2
R2_ENDPOINT=https://your-account.r2.cloudflarestorage.com
R2_ACCESS_KEY_ID=your_access_key
R2_SECRET_ACCESS_KEY=your_secret_key
R2_BUCKET_NAME=your_bucket_name
R2_PUBLIC_URL=https://your-pub-id.r2.dev
R2_ACCOUNT_ID=your_account_id
```

#### Build Process
```bash
# Install dependencies
pnpm install

# Build all apps
pnpm build

# Build specific app
pnpm --filter admin build
pnpm --filter storefront build
```

#### Deployment Steps
1. Configure environment variables in hosting platform
2. Set up Supabase project with required tables
3. Configure Cloudflare R2 bucket with CORS
4. Run database migrations
5. Deploy Next.js apps to Vercel
6. Configure custom domains
7. Set up SSL certificates
8. Configure CDN for images

### 10.2 Mobile Deployment

#### Build Process
```bash
# Build for Android
flutter build apk --release
flutter build appbundle --release

# Build for iOS
flutter build ios --release
```

#### App Stores
- **Google Play Store**: Android distribution
- **Apple App Store**: iOS distribution
- **TestFlight**: iOS beta testing
- **Internal Distribution**: Enterprise distribution

#### Signing
- Android: Keystore management
- iOS: Apple Developer account
- Code signing configuration
- Provisioning profiles

### 10.3 Database Deployment

#### Supabase Setup
1. Create Supabase project
2. Run database migrations
3. Configure RLS policies
4. Set up database functions
5. Configure triggers
6. Enable Row-Level Security
7. Set up backup schedules

#### Migration Management
- SQL migration files in `database/migrations/`
- Version-controlled schema changes
- Rollback procedures
- Testing in staging environment

### 10.4 Cloudflare R2 Setup

#### Bucket Configuration
1. Create R2 bucket
2. Configure CORS policy
3. Set up public access
4. Configure CDN
5. Set up lifecycle rules
6. Enable encryption

#### Image Optimization
- Client-side WebP compression
- Parallel uploads
- CDN serving
- Cache headers

### 10.5 Monitoring & Logging

#### Application Monitoring
- Vercel Analytics (for Next.js)
- Error tracking (Sentry optional)
- Performance monitoring
- Uptime monitoring

#### Database Monitoring
- Supabase dashboard
- Query performance
- Storage usage
- Backup verification

#### Logging
- Application logs
- API request logs
- Error logs
- Audit logs (database)

---

## 11. PROJECT DELIVERABLES

### 11.1 Source Code

#### Complete Source Code Repository
- Monorepo structure with all apps
- Admin dashboard (Next.js)
- Storefront (Next.js)
- Mobile app (Flutter)
- Shared packages
- Database schemas and migrations
- Documentation

#### Code Quality
- TypeScript strict mode
- ESLint configuration
- Prettier formatting
- Code comments and documentation
- Git version control

### 11.2 Documentation

#### Technical Documentation
- Architecture documentation (ARCHITECTURE.md)
- Feature documentation (FEATURES.md)
- Database schema documentation (SCHEMA.md)
- API documentation
- Agent guidelines (AGENTS.md)

#### User Documentation
- Admin dashboard user guide
- Mobile app user guide
- Setup and deployment guide
- Troubleshooting guide

#### Developer Documentation
- Development setup guide
- Coding standards
- Architecture patterns
- Testing guidelines
- Contribution guidelines

### 11.3 Configuration Files

#### Environment Configuration
- Environment variable templates
- Configuration examples
- Deployment scripts

#### Build Configuration
- Next.js configuration
- Flutter configuration
- Turborepo configuration
- Tailwind CSS configuration

### 11.4 Database

#### Database Schema
- Complete SQL schema
- Migration files
- Database functions (RPCs)
- Triggers
- RLS policies

#### Seed Data (Optional)
- Sample categories
- Sample products
- Sample customers
- Sample orders

### 11.5 Assets

#### Branding Assets
- Logo files (SVG, PNG)
- Brand colors
- Typography

#### UI Assets
- shadcn/ui components
- Custom components
- Icons (Lucide)

### 11.6 Testing

#### Automated Tests
- API test scripts (PowerShell)
- Category management tests (30 test cases)
- Integration tests (optional)
- Unit tests (optional)

#### Test Coverage
- API endpoint testing
- Business logic testing
- Validation testing
- Error handling testing

### 11.7 Deployment Artifacts

#### Web Applications
- Production builds
- Deployment configurations
- CI/CD pipelines (optional)

#### Mobile Application
- APK files (Android)
- App bundle (Android)
- IPA files (iOS)
- Store submission assets

---

## 12. MAINTENANCE & SUPPORT

### 12.1 Post-Launch Support

#### Initial Support Period
- **Duration**: 3 months post-launch
- **Scope**: Bug fixes, critical issues, deployment assistance
- **Response Time**: 24-48 hours for critical issues

#### Extended Support
- **Optional**: Extended support contracts available
- **Scope**: Feature enhancements, optimizations, training
- **Terms**: Negotiated separately

### 12.2 Maintenance Tasks

#### Regular Maintenance
- Dependency updates
- Security patches
- Performance optimization
- Database maintenance
- Backup verification

#### Monitoring
- Application uptime
- Error tracking
- Performance metrics
- Storage usage
- API response times

#### Updates
- Feature enhancements
- UI improvements
- Bug fixes
- Security updates

### 12.3 Training

#### Admin Training
- Dashboard usage
- Order management
- Product management
- Customer management
- Reporting

#### Staff Training
- Mobile app usage
- Order creation
- Barcode scanning
- Cleaning workflows

#### Technical Training
- Architecture overview
- Code structure
- Development setup
- Deployment process

### 12.4 Documentation Updates

#### Keep Updated
- API documentation
- User guides
- Troubleshooting guides
- Release notes

### 12.5 Backup & Recovery

#### Database Backups
- Automated daily backups
- Point-in-time recovery
- Backup verification
- Disaster recovery plan

#### Code Backups
- Git version control
- Remote repository (GitHub/GitLab)
- Branch management
- Release tagging

---

## 13. PROJECT TIMELINE

### 13.1 Development Phases

#### Phase 1: Foundation (Week 1-2)
- Project setup and configuration
- Database schema design
- Authentication system
- Base repository and service layers

#### Phase 2: Core Features (Week 3-6)
- Category management
- Product management
- Customer management
- Order management
- Inventory tracking

#### Phase 3: Advanced Features (Week 7-10)
- Cleaning management
- Damage assessment
- Payment tracking
- Invoice generation
- Barcode system

#### Phase 4: Mobile App (Week 11-14)
- Flutter app setup
- Core features implementation
- API integration
- Testing and optimization

#### Phase 5: Storefront (Week 15-16)
- Customer-facing UI
- Product browsing
- WhatsApp integration
- Responsive design

#### Phase 6: Testing & QA (Week 17-18)
- Integration testing
- User acceptance testing
- Performance testing
- Security testing
- Bug fixes

#### Phase 7: Deployment (Week 19-20)
- Production deployment
- Database migration
- Mobile app store submission
- Final testing
- Launch

### 13.2 Milestones

#### Milestone 1: Core System Complete
- Category, product, customer, order management
- Admin dashboard functional
- Database schema complete

#### Milestone 2: Advanced Features Complete
- Cleaning, damage, payment, invoice modules
- Barcode system functional
- Reporting complete

#### Milestone 3: Mobile App Complete
- Flutter app functional
- All features implemented
- API integration complete

#### Milestone 4: Storefront Complete
- Customer UI complete
- WhatsApp integration
- Responsive design

#### Milestone 5: Testing Complete
- All tests passed
- Bugs resolved
- Performance optimized

#### Milestone 6: Launch
- Production deployment
- Mobile app live
- Documentation complete

### 13.3 Timeline Flexibility

The timeline is estimated and may vary based on:
- Feature complexity
- Client feedback
- Testing requirements
- Third-party integrations
- Resource availability

---

## 14. TERMS & CONDITIONS

### 14.1 Project Scope

#### In Scope
- Complete development of Mazhavil Dance Costumes system
- Admin dashboard (Next.js)
- Customer storefront (Next.js)
- Mobile app (Flutter)
- Database design and implementation
- API development
- Documentation
- Initial deployment
- Post-launch support (3 months)

#### Out of Scope
- Hardware procurement
- Third-party service subscriptions (Supabase, Cloudflare R2, hosting)
- Ongoing operational costs
- Marketing materials
- Content creation (product images, descriptions)
- Legal compliance (beyond technical implementation)
- Extended support beyond 3 months

### 14.2 Intellectual Property

#### Ownership
- All source code and deliverables become property of Mazhavil Dance Costumes
- Supportta Solutions retains no rights to the code
- Custom code is proprietary to client

#### Third-Party Components
- Open-source libraries remain under their respective licenses
- Client is responsible for compliance with third-party licenses
- No proprietary third-party code included

### 14.3 Confidentiality

#### Confidential Information
- All project information is confidential
- Source code, documentation, and designs are confidential
- Business processes and data are confidential
- Agreement extends beyond project completion

#### Non-Disclosure
- Supportta Solutions will not disclose project information
- Will not use project for portfolio without permission
- Will not share code with other clients

### 14.4 Payment Terms

#### Payment Schedule
- **Milestone 1**: 20% - Project initiation
- **Milestone 2**: 20% - Core features complete
- **Milestone 3**: 20% - Advanced features complete
- **Milestone 4**: 20% - Mobile app complete
- **Milestone 5**: 10% - Testing complete
- **Milestone 6**: 10% - Launch and delivery

#### Payment Method
- Bank transfer or UPI
- Invoice provided for each payment
- Payment due within 7 days of invoice

### 14.5 Change Requests

#### Minor Changes
- Included within scope
- No additional cost
- Implemented within timeline

#### Major Changes
- Require change request
- Additional cost estimate
- Timeline adjustment
- Client approval required

### 14.6 Warranty

#### Bug Fixes
- 3-month warranty period
- Free bug fixes for defects
- Response time: 24-48 hours
- Excludes user errors or third-party issues

#### Performance
- System meets specified requirements
- Acceptable performance under normal load
- Optimized for specified user count

### 14.7 Limitations of Liability

#### Maximum Liability
- Limited to total project cost
- No liability for consequential damages
- No liability for data loss
- No liability for third-party service failures

#### Force Majeure
- Not liable for delays due to circumstances beyond control
- Includes natural disasters, pandemics, etc.

### 14.8 Termination

#### By Client
- Can terminate with written notice
- Payment for work completed
- Delivery of completed work

#### By Supportta Solutions
- Can terminate for non-payment
- Can terminate for material breach
- Notice period: 30 days

### 14.9 Acceptance

#### Acceptance Criteria
- System meets all functional requirements
- All tests pass
- Documentation complete
- Deployment successful
- Client sign-off required

#### UAT Period
- 2-week user acceptance testing
- Client testing and feedback
- Bug fixes during UAT
- Final approval required

### 14.10 Governing Law

#### Jurisdiction
- Governed by laws of India
- Disputes resolved in Indian courts
- Arbitration clause optional

---

## 15. ACCEPTANCE CRITERIA

### 15.1 Functional Requirements

#### Category Management
- [ ] Create, read, update, delete categories
- [ ] 3-level hierarchy working
- [ ] Slug auto-generation
- [ ] GST configuration
- [ ] Cleaning buffer configuration
- [ ] Delete safety checks
- [ ] Collapsible tree view
- [ ] Category detail pages

#### Product Management
- [ ] Create, read, update, delete products
- [ ] Image upload with compression
- [ ] Branch inventory tracking
- [ ] Low stock alerts
- [ ] Barcode generation
- [ ] Search and filter
- [ ] Pagination working

#### Order Management
- [ ] Create orders with customer selection
- [ ] Product selection with availability check
- [ ] Stock conflict detection
- [ ] Payment tracking
- [ ] Status updates
- [ ] Invoice generation (PDF)
- [ ] Order history
- [ ] Late order flagging

#### Customer Management
- [ ] Create, read, update, delete customers
- [ ] KYC document upload
- [ ] Profile photo upload
- [ ] Search and filter
- [ ] Order history

#### Cleaning Management
- [ ] Create cleaning records
- [ ] Status tracking
- [ ] Priority management
- [ ] Urgent cleaning alerts

#### Damage Assessment
- [ ] Record damage assessments
- [ ] Condition rating
- [ ] Damage charges calculation
- [ ] Assessment notes

#### Payment Management
- [ ] Record payments
- [ ] Multiple payment types
- [ ] Payment mode tracking
- [ ] Payment history

#### Staff Management
- [ ] Create staff accounts
- [ ] Role assignment
- [ ] Branch assignment
- [ ] Activity tracking

#### Branch Management
- [ ] Create branches
- [ ] Branch configuration
- [ ] Branch-specific inventory

#### Dashboard
- [ ] Operational metrics
- [ ] Today's summary
- [ ] Pending tasks
- [ ] Priority alerts

#### Reports
- [ ] Revenue reports
- [ ] Inventory reports
- [ ] Order reports
- [ ] Dead stock analysis

### 15.2 Technical Requirements

#### Performance
- [ ] Page load time < 3 seconds
- [ ] API response time < 500ms
- [ ] Image upload < 10 seconds
- [ ] Mobile app startup < 3 seconds

#### Security
- [ ] Authentication working
- [ ] RBAC implemented
- [ ] RLS policies active
- [ ] Input validation
- [ ] SQL injection prevention
- [ ] XSS prevention

#### Code Quality
- [ ] TypeScript strict mode
- [ ] No linting errors
- [ ] Code formatted with Prettier
- [ ] Documentation complete
- [ ] Comments in code

#### Testing
- [ ] All API tests passing
- [ ] Integration tests passing
- [ ] User acceptance testing complete
- [ ] No critical bugs

### 15.3 Deployment Requirements

#### Web Applications
- [ ] Admin dashboard deployed
- [ ] Storefront deployed
- [ ] Custom domains configured
- [ ] SSL certificates active
- [ ] Environment variables configured

#### Mobile Application
- [ ] Android APK built
- [ ] iOS IPA built
- [ ] App store submission ready
- [ ] TestFlight setup (optional)

#### Database
- [ ] Supabase project configured
- [ ] Migrations executed
- [ ] RLS policies active
- [ ] Functions and triggers working
- [ ] Backups configured

#### Storage
- [ ] Cloudflare R2 bucket configured
- [ ] CORS policy set
- [ ] CDN serving active
- [ ] Image upload working

### 15.4 Documentation Requirements

#### Technical Documentation
- [ ] Architecture documentation
- [ ] Feature documentation
- [ ] Database schema documentation
- [ ] API documentation
- [ ] Agent guidelines

#### User Documentation
- [ ] Admin user guide
- [ ] Mobile app user guide
- [ ] Setup guide
- [ ] Troubleshooting guide

#### Developer Documentation
- [ ] Development setup guide
- [ ] Coding standards
- [ ] Architecture patterns
- [ ] Testing guidelines

### 15.5 Sign-Off

#### Client Acceptance
- [ ] System tested by client
- [ ] All requirements met
- [ ] Documentation reviewed
- [ ] Training completed
- [ ] Final sign-off obtained

---

## SIGNATURES

### Client (Mazhavil Dance Costumes)
_________________________
Name: 
Title: 
Date: 

### Vendor (Supportta Solutions)
_________________________
Name: Mahavadevan Sir
Title: 
Date: 

---

## APPENDICES

### Appendix A: Environment Variables Template
```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Cloudflare R2
R2_ENDPOINT=
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_BUCKET_NAME=
R2_PUBLIC_URL=
R2_ACCOUNT_ID=
```

### Appendix B: Technology Stack Summary
- **Web**: Next.js 16, React 19, TypeScript, Tailwind CSS, Supabase
- **Mobile**: Flutter, Dart, Riverpod, Dio
- **Database**: Supabase PostgreSQL
- **Storage**: Cloudflare R2
- **Build**: Turborepo, pnpm

### Appendix C: Contact Information
**Project Contact**: [To be provided]
**Technical Contact**: [To be provided]
**Support Contact**: [To be provided]

---

**Document Version**: 1.0  
**Last Updated**: June 15, 2026  
**Next Review**: Upon project completion
