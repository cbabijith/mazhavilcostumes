# Mazhavil Costumes - Feature Catalog

This document details the functional capabilities and features of the **Mazhavil Costumes** monorepo workspace.

---

## 1. Core Platform Capabilities
* **Single-Shop, Multi-Branch Operations**: A dedicated costume rental system designed for a single storefront business with multiple physical warehouse/shop branches.
* **Unified Workspace Admin & Storefront**: Next.js-powered systems sharing domain models, schemas, and configurations.
* **Database RLS & RBAC**: Row-Level Security in Supabase with explicit roles (`super_admin`, `admin`, `manager`, `staff`) governing actions across branches.

---

## 2. Category Hierarchy System
* **3-Level Hierarchy**:
  * **Level 1 (Main Category)**: parent_id is null.
  * **Level 2 (Sub-Category)**: parent_id points to Level 1.
  * **Level 3 (Variant / Leaf)**: parent_id points to Level 2. Cannot have child nodes.
* **Auto-Generating Slugs**: Automatically converts names to unique, lowercase, hyphenated slugs with collision resolution.
* **GST & Tax Configuration**: Set GST percentages at the category level, which are inherited by child products.
* **Cleaning Buffer Configuration**: `has_buffer` flag dictates whether products in the category require a mandatory 1-day cleaning buffer between bookings or can be rented back-to-back.
* **Cascade & Delete Safety**: Deletions are blocked if a category has child nodes or is associated with active products.

---

## 3. Product & Inventory Management
* **Advanced Costume Attributes**: Track specific metadata including size, color, material, weight, gemstones, metal purity, and purchase cost.
* **Rental Pricing Model**: Configurable `price_per_day` rental rates and security deposit amounts.
* **Branch-Level Inventory Allocation**: Track `total_quantity`, `available_quantity`, and `low_stock_threshold` on a branch-by-branch basis.
* **Optimistic Deletion & Image Cleanup**: Products are immediately removed from client views upon deletion, while their images are deleted from Cloudflare R2 asynchronously.
* **Performance-Optimized Client-Side Image Uploader**:
  * Canvas-based client-side image compression: Scales images up to 20MB down to <100KB WebP files.
  * Parallel uploading: Uses `Promise.all` to upload files in parallel to Cloudflare R2.
  * Direct CDN serving: Bypasses Next.js image proxying to avoid Vercel gateway timeouts.

---

## 4. Rental Order Lifecycle & Stock Conflicts
* **Rental Scheduling**: Book rentals with explicit start, end, event dates, and pickup/return times.
* **Detailed Order Statuses**: Transition orders across states: `pending` ➔ `confirmed` ➔ `scheduled` ➔ `delivered` ➔ `in_use`/`ongoing` ➔ `returned` ➔ `completed`/`cancelled`/`flagged`.
* **Stock Conflict Detection**: Real-time validation checking if total physical inventory (minus active reservations) is sufficient for new bookings, flagging conflicts in `conflict_details`.
* **Payment & Deposit Tracking**:
  * Record multiple payment types: `advance`, `partial`, `full`, `late_fee`, `damage`.
  * Track payment modes: `cash`, `upi`, `card`, `bank_transfer`.
  * Manage advance payment collection status and methods.
* **Automatic Late Flagging**: Orders with status `ongoing` / `in_use` past their `end_date` are automatically flagged as late via database triggers.

---

## 5. Cleaning, Maintenance & Damage Control
* **Cleaning Records Management**: Track returned items through cleaning states: `scheduled` ➔ `pending` ➔ `in_progress` ➔ `completed`.
* **Priority Urgent Cleaning**: Automatically flags cleaning records as urgent if the product is reserved for another upcoming order, linking the record to the `priority_order_id`.
* **Damage Assessment Flow**:
  * Assess condition of returned items (Excellent, Good, Fair, Damaged).
  * Record damage decisions (`no_damage`, `minor`, `major`, `replace`).
  * Calculate damage charges per item and update order totals.

---

## 6. Marketing & Banners
* **Store Campaigns**: Manage `hero`, `promo`, and `announcement` banners.
* **Configurable Call-To-Action (CTA)**: Support redirects to specific products, categories, or custom URLs.
* **Accessibility Settings**: Support unique alt text and mobile-specific image optimization.

---

## 7. Storefront Web App (Customer-Facing)
* **Luxury Minimalist UI**: Designed with a premium ivory, gold, and charcoal palette.
* **Bottom Mobile Navigation**: Mobile-first layouts featuring custom app-like navigation tabs.
* **Collection Page Filtering**: Customers browse products filtered by category, sub-category, size, and availability.
* **WhatsApp Booking Request**: Customers can send pre-filled rental requests directly to the store's WhatsApp number.

---

## 8. Flutter Mobile Client (Staff-Facing Thin Client)
* **Thin Client Architecture**: All business validation, database mutations, and RLS checks are performed on the server.
* **Real-time Synchronization**: Views pull from the Next.js API endpoints.
* **Responsive Layouts**: Consistent grid layouts and scaled typography on any device via clamped responsive coefficients.
