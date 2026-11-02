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

- The Order Items section provides **Mark All Good**, **Good / Damaged / Not Returned**, **Returning Now**, **Discount**, an optional **Extra Late Fee**, and one return action. Multi-unit outstanding lines have minus/plus buttons and editable quantities, initially set to all outstanding units. Single-unit lines use the condition choices alone. Damage quantity is limited to units returning now. Previously returned lines show a saved label and cannot be edited or returned twice.
- The settlement preview appears when a discount or fee is present. A separate **Payment Due / Collect Payment** panel appears whenever a balance remains, including orders without adjustments. It uses the same live balance as the collection dialog. Extra Late Fee adds only the newly entered amount to any saved fee; the app does not automatically calculate daily late charges. Return-notes inputs and the separate Good-condition save button are omitted.
- The financial receipt uses the same draft total and balance as the preview. During a new return discount it shows the combined Order Discount, the discount saved at the start of this return (Initial Discount), and Return Settlement Disc. Clearing the input restores saved amounts. Typing does not save the order or change payments.
- **Not Returned** or a reduced count on an inspected line shows **Save Partial Return (N Pending)**. Unmarked lines do not cause a false partial-return warning, but must be inspected before submission. A zero-count Good/Damaged line is blocked; a submission must return at least one unit. Confirmation shows unit counts. Only lines returning units are sent to the API, with cumulative `returned_quantity` (previously received + returning now). Other lines retain their saved assessment and rent.
- Discount, extra late-fee, inspection and quantity drafts survive refreshes. A successful return clears newly entered discount and fee values so a later partial-return visit does not apply them twice. A changed received quantity resets the line for the next visit. Physical returns use `returned_quantity`; the legacy `is_returned` flag alone cannot prove every unit is back.
- Previews, the financial receipt, confirmation, and the payment limit share `OrderReturnViewModel`. They start from the saved order total, replace damage charges, preserve existing late fees, add only the newly entered late fee, and deduct only the newly entered return discount. Negative, non-numeric, NaN and infinite adjustments block return submission and payment collection.
- Entering an extra fee before the return is overdue shows an on-time warning. The due date remains on time for its entire local calendar day; the next day is overdue. Saved fees alone do not trigger this warning.
- The Flutter preview does not subtract an existing discount again: a saved ₹150 total previews as ₹150 without a new discount, or ₹80 with a new ₹70 return discount.
- Return controls follow the current web statuses: ongoing, in use, partial and flagged. Flagged returns and omission of pending/already-returned rows require the matching current web backend; the older admin service in this checkout is not the reference implementation.
- Mobile uses `PATCH /api/orders/:id/return` through the existing repository and shared Dio client. Because the API replaces `late_fee`, mobile sends the saved fee plus the newly entered fee as one absolute amount; it does not send `additional_late_fee`. No database operations run from Flutter.
- Return settlement on the matching admin API preserves saved discounts and order-level damage charges while replacing item damage assessments and the absolute late fee. Deploy the matching admin changes with the mobile update. The offline tests use local fixtures and do not modify live orders or repair historical totals.

Offline regression checks (no live order writes):

```sh
flutter analyze --no-pub
flutter test --no-pub test/unit/order_return_viewmodel_test.dart test/unit/order_return_repository_test.dart test/widget/order_return_flow_test.dart
```

### Financial adjustments

- **Adjust** in Order Details opens a shared sheet with four types: **Discount**, **Late Fee**, **Damage Fee**, and **Extra Charge**. Amounts must be finite positive currency values. Reasons are optional, and late fees show the same on-time warning as the return form.
- Applying an adjustment first loads the latest order with `GET /api/orders/:id`, then sends an absolute `PATCH /api/orders/:id`. Discounts reduce the total and add to saved discount; fees and extra charges increase the total. Late and damage fees add to their saved fields. Extra charges are included in the total and labelled notes rather than a separate fee column.
- Notes retain earlier order notes and append the type, amount and optional reason, for example `Late Fee: ₹25.00 — Returned late`. Adjustments change charges or discounts; they do not collect money, change `amount_paid`, or create payment-ledger entries. Payment collection remains a separate action.
- Saving refreshes the order and financial receipt. Pending return discount, late-fee and inspection drafts remain independent and continue to preview on top of the refreshed saved amounts. Cancelling changes nothing; failed saves retain the sheet draft for retry. A subsequent return preserves saved adjustments and applies only new return inputs.
- The model, viewmodel and sheet live in `lib/features/orders/models/order_adjustment.dart`, `viewmodels/order_adjustment_viewmodel.dart`, and `widgets/order_adjustment_sheet.dart`. Offline unit/sheet tests are `test/unit/order_adjustment_viewmodel_test.dart` and `test/widget/order_adjustment_sheet_test.dart`; `test/widget/order_return_flow_test.dart` also exercises the actual Order Details integration and subsequent return.

```sh
flutter analyze --no-pub
flutter test --no-pub test/unit/order_adjustment_viewmodel_test.dart test/widget/order_adjustment_sheet_test.dart test/unit/order_return_viewmodel_test.dart test/unit/order_return_repository_test.dart test/widget/order_return_flow_test.dart
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

### Loading performance (October 21, 2026)

Session restoration starts immediately on the splash screen and restores identity before dashboard loading. Branch-scoped providers await initial branch resolution. Dashboard startup no longer preloads the customer directory.

Product and Order searches debounce for 300 ms, cancel replaced requests, and ignore obsolete results and pagination responses. Opening an unfiltered Orders tab reuses its request; clearing filters preserves the selected branch. Product totals reuse the category-count response; older APIs without `meta.total` show an unknown total instead of an inaccurate zero. Thumbnails decode at their display size and device pixel density.

Analytics shares requests by branch/range/category period/ROI limit and retains unused completed results for up to 30 seconds after completion. Active reports refresh through explicit refresh or mutation invalidation. Refresh and order mutations invalidate both the request cache and visible metrics. Diagnostic request timings can be enabled with `--dart-define=PERFORMANCE_LOGS=true`; normal release API logging is disabled.

Regression checks: `flutter test test/unit/loading_performance_test.dart` and `flutter analyze --no-pub`. To exercise an un-deployed admin build on Android over USB, run the admin production server on port 3001, use `adb reverse tcp:3001 tcp:3001`, and build with `--dart-define=API_BASE_URL=http://127.0.0.1:3001/api`. Restore a build without that override before disconnecting the device.

### Fast repeat startup (November 2, 2026)

The connected phone previously waited for branches (~3.1 s), then the operational dashboard (~2.8 s). The branch switcher now requests `GET /api/branches?simple=true`, avoiding the staff-count query; branch management still requests full details. Two encrypted startup snapshots let returning users see their branch and saved overview while both live requests refresh in parallel. The overview explicitly shows “Saved overview · Updating…” or a refresh-failure message. First use, expired snapshots and a changed account/branch still require a live response.

Snapshots are isolated by API URL, account, store, role, assigned branch/staff and selected branch, expire after 24 hours, and operational data cannot cross midnight in India. Logout and successful mutations invalidate snapshots immediately; queued writes and obsolete responses cannot repopulate invalidated data. Authorization failures surface as errors. This display cache never replaces server stock, booking or payment checks. Authentication logs no longer print session responses or token fragments.

Visited tabs now retain widgets, search and scroll state, with inactive animations disabled; unseen tabs remain unmounted. Startup no longer initializes the upload SDK; the existing upload repository initializes it once when first needed and retries initialization after failure.

Build with `flutter build apk --release --no-pub --target-platform android-arm64` for deployment. Add `--dart-define=PERFORMANCE_LOGS=true` for safe request timings and first-frame/saved-overview/fresh-overview timing markers. Markers measure from Dart entry to the rendered frame, excluding Android process/engine startup. Normal releases disable these diagnostics. Use the production API when verifying the user's existing signed-in session.

Checks: `flutter analyze --no-pub` and `flutter test --no-pub test/unit/startup_snapshot_cache_test.dart test/unit/loading_performance_test.dart test/unit/pr89_mobile_contract_test.dart test/widget/retained_tab_view_test.dart`.

### Saved Orders, Calendar and Products (November 2, 2026)

Returning users can now open the unfiltered first Orders/Products page and the last Calendar month from encrypted storage while a live refresh runs. Each view labels saved data and offers retry if refreshing fails. Empty saved results work too. Account, API, role, branch and calendar-range changes never reuse another scope's snapshot; Calendar snapshots also expire at midnight in India. Search/filter results do not overwrite the default list snapshot, and pagination waits for fresh page one before appending live rows. Successful writes and logout clear the display snapshots. Order/product details and stock/payment checks continue to fetch authoritative server data.

Stream providers register dependencies and cancellation before subscribing, so rapid searches and branch/month changes cancel obsolete requests. Calendar builds day lists without repeatedly copying prior bookings. List cards use the API's `item_count`; Product snapshot decoding preserves category names and image URLs. The diagnostic build logs saved/fresh frame markers for each main tab plus API `Server-Timing` when available.

The Calendar client requests `summary=true`. Existing APIs can ignore this flag; deploying the companion admin changes enables the smaller payload. Saved-data loading works independently of that deployment. Additional checks: `flutter test --no-pub test/unit/saved_screens_test.dart` (saved-before-network behavior, scope isolation, refresh failure, pagination and a 1,500-booking calendar).

#### v2 release verification on Nothing AIN065

Installed `Mazhavil-Fast-2026-11-02-v2-release.apk` at 14:02 without clearing data, using the existing installation's certificate. Android package flags confirmed a non-debuggable release. The same APK is in the phone's Downloads folder. SHA-256: `3a9cde2ee91623e0f4240af11ca8d75ffeb4d47ec659c1f1053774c49194f690`.

On the controlled cold-start pass, Android reported initial activity display at 588 ms. The saved Home overview rendered 253 ms after Dart entry. Separate on-device tap markers followed by saved-frame markers measured Orders at 83 ms, Calendar at 92 ms and Products at 102 ms. The markers precede the ADB tap command, so these include its dispatch overhead. Screenshots captured 338–388 ms after the tap commands confirmed populated content and the saved-data label before network completion.

All background responses succeeded: Orders 1,593 ms, Calendar 2,269 ms, Products 2,323 ms and operational dashboard 2,876 ms. Returning through all four tabs issued zero additional API requests; populated screenshots completed 382–486 ms after each tap (includes screenshot overhead, not a frame-time benchmark). Fresh Orders/Calendar screenshots confirmed the saved-data label disappeared. No Flutter runtime/layout exceptions or crashes were found in the captured test logs. Original screen timeout was restored.

These device measurements use the existing production API; they do **not** measure the undeployed admin optimizations. Earlier in the same run live refreshes took 2.8–4.3 seconds, so network/server variability remains. A first visit without a valid snapshot still needs a live response. The 27 Flutter regression checks and 57 admin offline checks passed; Flutter analysis had no errors/warnings (56 existing info lints), TypeScript and the admin production build passed, and the Android release build succeeded. Audit evidence is under ignored `.dart_tool/performance_audit/nov02-v2-*` files.

#### Earlier connected-device baseline

Verified on the unlocked Nothing AIN065 against the production API. The phone had subsequently been reinstalled with a debuggable APK; the verified release APK was restored using the existing installation's signing certificate, without clearing its authenticated session. Android package flags confirmed that the tested build was not debuggable.

Two cold launches rendered the saved overview at 607 ms and 233 ms from Dart entry; Android reported initial activity display at 760 ms and 569 ms respectively. These are different timing scopes. In the second launch, a screenshot completed 1,501 ms after issuing the launch command and already showed populated cards with the saved-data refresh label. The live overview then replaced the snapshot; its rendered-frame markers were 3,411 ms and 3,493 ms from Dart entry.

Returning through Home, Orders, Calendar and Products issued zero additional API requests. Each populated tab was visible in its first screenshot, completed 326–394 ms after issuing the tap (includes ADB/screenshot overhead, so these are upper bounds rather than frame-time measurements). A separate Products return check retained the scrolled list. No crashes or layout exceptions were found in the captured test logs.

Fresh production requests remain a bottleneck: in the first pass Products took 3,616 ms, Orders 4,616 ms, Calendar 3,441 ms, Analytics 4,474 ms, and category counts 4,431 ms. A subsequent Orders request took 2,552 ms. Cached startup and tab reuse avoid these waits for already loaded data; the measurements do not establish instant first-time data loading. Diagnostic logs/screenshots are under the ignored `.dart_tool/performance_audit/nov02-*` paths. The phone's original screen timeout was restored after testing.
