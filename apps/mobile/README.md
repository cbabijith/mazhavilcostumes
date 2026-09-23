# Mazhavil Costumes Mobile App

This directory contains the Flutter mobile application for **Mazhavil Costumes**, acting as the mobile version of the admin dashboard.

## Overview
The mobile app mirrors the functionality of the web admin portal, allowing store managers, administrators, and staff to manage products, categories, stores, branches, customers, and orders right from their mobile devices. 

It consumes the exact same Next.js API (`https://mazhavilcostumes-admin.vercel.app/api`) built for the web admin portal, meaning business logic is centralized and synchronized in real-time.

---

## Architecture & Technology Stack

The app uses a **Feature-First Architecture**. Instead of grouping by technical type (e.g., all models in one folder, all views in another), files are grouped by the feature they belong to (e.g., `features/products/`).

### Core Technologies
*   **Framework**: Flutter (Dart)
*   **State Management**: Riverpod (`flutter_riverpod`, `riverpod_annotation`)
*   **Networking / HTTP**: Dio (`dio`)
*   **Performance Optimization**: `cached_network_image`, `shimmer`
*   **Environment Config**: `flutter_dotenv` (loading `.env` files)
*   **Local Storage**: `flutter_secure_storage` (for auth tokens)

---

## Implemented Features

### Invoice GSTIN and settlement refresh (PR #89)

- Admins can open **Drawer → Invoice Settings** to edit the business GSTIN printed on deposit and final bills. Input is trimmed, uppercased and format-validated; saving an empty value removes the GSTIN. Loading failures cannot overwrite a saved value, and failed saves retain the draft for retry.
- The settings viewmodel calls `SettingsRepository`, which uses the authenticated shared API: `GET /api/settings?key=gst_number` and `PATCH /api/settings` with `{ "key": "gst_number", "value": "..." }`. Manager/staff accounts cannot access the editor, and the server enforces write permissions.
- Successful order creation, updates, deletions, returns and payment changes refresh cached order lists, details, payments, dashboard metrics and reports. This prevents a completed return from leaving stale Pending/Revenue Due cards on mobile.
- The shared admin backend performs the payment reconciliation, dashboard RPC fix and invoice PDF rendering. These Flutter changes require the corresponding backend deployment; no live database migration is executed by the app.

Offline verification:

```sh
flutter analyze --no-pub
flutter test --no-pub test/widget/invoice_settings_test.dart test/unit/pr89_mobile_contract_test.dart test/unit/order_return_viewmodel_test.dart test/unit/order_return_repository_test.dart test/widget/order_return_flow_test.dart
```

### Order return settlement

- The Order Items section matches the website reference: **Mark All Good**, **Good / Damaged / Not Returned**, **Discount**, and one return action. The settlement preview appears when a discount or fee is present and updates while typing; it stays hidden when there are no adjustments. Extra late-fee and return-notes inputs and the separate Good-condition save button are omitted. Damage details appear only when Damaged is selected.
- The financial receipt uses the same draft total and balance as the preview. During a new return discount it shows the combined Order Discount, the discount saved at the start of this return (Initial Discount), and Return Settlement Disc. Clearing the input restores saved amounts. Typing does not save the order or change payments.
- **Not Returned** shows a pending-unit warning and **Save Partial Return (N Pending)**. The existing API receives cumulative `returned_quantity` values, preserving units already received. **Good / Damaged** marks the remaining units returned. Unmarked items must be explicitly checked before submission.
- Discount and inspection drafts survive refreshes and are submitted on confirmation. Previously saved inspections are restored; explicit `returned_quantity` takes precedence over the API's older `is_returned` flag for pending items.
- Previews, confirmation, and the payment limit share `OrderReturnViewModel`. They start from the saved order total, replace damage charges, preserve existing late fees, and deduct only the newly entered return discount.
- The Flutter preview does not subtract an existing discount again: a saved ₹150 total previews as ₹150 without a new discount, or ₹80 with a new ₹70 return discount.
- Return controls follow the API's accepted statuses: ongoing, in use, and partial.
- Mobile uses the existing `late_fee` field on `PATCH /api/orders/:id/return`, sending the saved late fee unchanged because the API replaces that value. No API update is required for these Flutter changes.
- Scope limitation: the unchanged API can still deduct an existing order discount again when saving an inspection or completing a return. The Flutter-only changes do not correct that server calculation or repair historical totals. The tests below verify Flutter behavior and request compatibility, not server-side persistence.

Offline regression checks (no live order writes):

```sh
flutter analyze --no-pub
flutter test --no-pub test/unit/order_return_viewmodel_test.dart test/unit/order_return_repository_test.dart test/widget/order_return_flow_test.dart
```

### 1. Unified Dashboard
*   **Greeting Banner**: Dynamic greeting tailored to the logged-in user.
*   **Quick Actions & Summary**: Direct access to creating orders, adding products, and viewing high-level stats (Total Sales, Pending Orders, Customers).
*   **Recent Orders**: A snapshot of the latest order status natively embedded in the dashboard.

### 2. Product Management Module
*   **Infinite Scroll & Pagination**: The product list integrates `page` and `limit` to lazily load catalog items, eliminating lag for large datasets.
*   **Instant Fire-and-Forget Saving**: Editing or creating products pops the UI instantly. The Riverpod repository handles heavy image uploads and API submission in the background, updating the state upon success.
*   **Smart Quantity Stepper**: Uses deeply optimized custom `TextEditingController` steppers to modify quantities instantly without triggering expensive widget tree rebuilds.
*   **Barcode Auto-Generation**: One-tap 8-digit numeric barcode generation for new inventory items.
*   **Camera & Gallery Integration**: Uses `image_picker` to allow rapid image assignment to products.
*   **Cascading Categories**: Selecting a main category instantly fetches related sub-categories and variants.

### 3. Native Image Loading
*   Uses `Image.network` natively combined with a `loadingBuilder`.
*   Displays a beautiful `Shimmer` skeleton effect while images download to give a premium, polished user experience.

### 4. Role-Based Access Control (RBAC)
The app restricts UI based on the user's role:
*   **Super Admin**: Has access to all stores, settings, branches, and staff management.
*   **Store Manager**: Can manage inventory, edit product fields, and manage stock.
*   **Staff / Agent**: Restricted to read-only views for products. Staff can browse the catalog and assist customers, but cannot edit fields or add new inventory.

---

## Custom Premium Theme

The application strictly adheres to a luxurious, 4-color custom theme sourced from ColorHunt:

*   **`0xFFF8F8F8` (Off-White)**: The primary Scaffold Background, giving a clean and minimalist base.
*   **`0xFFFAEBCD` (Blanched Almond)**: The Surface color for cards, search bars, and avatar backgrounds.
*   **`0xFFF7C873` (Golden)**: The Accent color. Used for price tags, floating action buttons (FABs), and high-visibility badges.
*   **`0xFF434343` (Charcoal)**: The Primary Active color. Used for app bars, primary text, main buttons, and dominant gradients, replacing all default Material colors.

All theme configurations are strictly controlled in `lib/core/theme.dart`.

---

## Directory Structure

```text
lib/
├── core/                       # Shared code applicable across all features
│   ├── api_client.dart         # Singleton Dio client with base URL & interceptors
│   ├── main_layout.dart        # Scaffold containing the Drawer and main body switching
│   └── theme.dart              # Global UI theme (Charcoal/Golden aesthetic)
├── exceptions/                 # Custom Exception classes
├── features/                   # Feature modules
│   ├── auth/                   # Authentication feature (Login, Splash, Tokens)
│   ├── dashboard/              # Home view with greeting and summary metrics
│   ├── products/               # Products Management (List, Add, Edit, Detail)
│   ├── categories/             # Category Management
│   └── orders/                 # Order viewing
├── utils/                      # Helper utilities (formatting, validators)
└── main.dart                   # Application entry point
```

---

## Next Steps / Roadmap
*   Finalize Calendar & Date-picker module for tracking exact rental dates.
*   Implement Order Creation flow (adding products to a cart and assigning a customer).
