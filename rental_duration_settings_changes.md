# Dynamic Rental Duration Settings — Web Changes

This document outlines the modifications made to transition the web admin application from a hardcoded 3-day base rental duration to a dynamic setting configurable via the dashboard.

---

## 🛠️ Summary of Changed Files

### 1. Domain & Schema Layer

*   **[`apps/admin/domain/types/settings.ts`](file:///d:/personal/mazhavilcostumes/apps/admin/domain/types/settings.ts)**
    *   Added `DEFAULT_RENTAL_DURATION = 'default_rental_duration'` to the `SettingKey` enum so it is recognized as a valid settings configuration key.
*   **[`apps/admin/domain/schemas/settings.schema.ts`](file:///d:/personal/mazhavilcostumes/apps/admin/domain/schemas/settings.schema.ts)**
    *   Added `'default_rental_duration'` to the `SettingKeyEnum` Zod validator to allow validation when querying or updating settings via API.

### 2. React Hooks Layer

*   **[`apps/admin/hooks/useSettings.ts`](file:///d:/personal/mazhavilcostumes/apps/admin/hooks/useSettings.ts)**
    *   Added `defaultRentalDuration` to the query key factory.
    *   Implemented the `useDefaultRentalDuration()` hook, which fetches the configured default rental duration from the backend API.
*   **[`apps/admin/hooks/index.ts`](file:///d:/personal/mazhavilcostumes/apps/admin/hooks/index.ts)**
    *   Exported `useDefaultRentalDuration` from the central hooks entry point.

### 3. Repository Layer (Pricing Calculation)

*   **[`apps/admin/repository/orderRepository.ts`](file:///d:/personal/mazhavilcostumes/apps/admin/repository/orderRepository.ts)**
    *   **In `create`**: Resolved `storeId` early, fetched the `default_rental_duration` setting for that store, and adjusted the `pricingMultiplier` using:
        ```typescript
        const defaultDuration = durationSetting?.value ? parseInt(durationSetting.value, 10) : 3;
        const effectiveDefaultDuration = isNaN(defaultDuration) || defaultDuration < 1 ? 3 : defaultDuration;
        const pricingMultiplier = Math.max(1, rentalDays - (effectiveDefaultDuration - 1));
        ```
        This replaces the hardcoded `rentalDays - 2` calculation. Removed the redundant duplicate `storeId` resolution block later in the method.
    *   **In `update`**: Fetched the `store_id` for the updated order and queried the `default_rental_duration` setting from the database to dynamically compute the `pricingMultiplier`.

### 4. Admin UI Components

*   **[`apps/admin/app/dashboard/settings/page.tsx`](file:///d:/personal/mazhavilcostumes/apps/admin/app/dashboard/settings/page.tsx)**
    *   Fetched the default rental duration using `useDefaultRentalDuration()`.
    *   Managed state with the `defaultRentalDuration` local variable.
    *   Added a beautiful **Rental Settings** card containing a numeric input field for configuring the default rental days.
    *   Implemented validation on save to ensure the configured days are a valid integer $\ge 1$.
*   **[`apps/admin/components/admin/OrderForm.tsx`](file:///d:/personal/mazhavilcostumes/apps/admin/components/admin/OrderForm.tsx)**
    *   Fetched and parsed the `default_rental_duration` setting.
    *   Updated the client-side price calculation logic so the pricing multiplier is computed dynamically:
        ```typescript
        const pricingMultiplier = useMemo(
          () => Math.max(1, rentalDays - (defaultRentalDuration - 1)),
          [rentalDays, defaultRentalDuration]
        );
        ```
    *   Modified the item price breakdown label so that it dynamically displays the exact number of free base days (e.g. `(X days − Y free)`) instead of hardcoding `− 2 free`.
    *   Added a `useEffect` and `hasInitializedDateRef` to automatically set the default return date based on `defaultRentalDuration` when the page finishes loading.
    *   Updated the pickup date's `onChange` event to update the return date using the dynamic rental duration offset `defaultRentalDuration - 1` rather than a hardcoded `2` days offset.
    *   Extended the quick date action buttons to allow adding up to `+5` extra days.

### 5. Security Deposit Refund Restricting

*   **[`apps/admin/components/admin/OrderDetailsView.tsx`](file:///d:/personal/mazhavilcostumes/apps/admin/components/admin/OrderDetailsView.tsx)**
    *   Defined an `isProductReturned` flag checking if the order status is `returned`, `completed`, or `cancelled`.
    *   Disabled the **Refund Security Deposit** button when `isProductReturned` is false.
    *   Added a warning message below the disabled button stating: `"⚠️ Security deposit can be returned once the product is returned."`

### 6. Database Migration & Seeding

*   **[`database/migrations/044_seed_default_rental_duration.sql`](file:///d:/personal/mazhavilcostumes/database/migrations/044_seed_default_rental_duration.sql)**
    *   Added a safe migration script to insert the `default_rental_duration` key with a default value of `'3'` for all existing stores to prevent empty configurations.

---

## 🚀 Post-Work Build Status
*   **Verification**: Successfully ran `pnpm --filter admin build`. The Next.js/TypeScript check compiled with **0 errors and 0 warnings**.
