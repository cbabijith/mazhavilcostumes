# Price Override Validation Fix (Order Creation / Editing)

This document records the changes made to the order form's price override behavior. This fix is documented here so it can be easily ported to other branches/projects.

## The Problem

In the order creation/edit form (`OrderForm.tsx`), editing the `price_per_day` of an item in the cart would immediately trigger an error toast ("Price cannot be lower than ₹X.XX") and reset the value to its minimum/original price if the value dropped below the original price _temporarily_ during typing (e.g., when deleting characters to type a higher value like `150` starting from `120`). This made editing the price frustrating or impossible.

## The Solution

1. **Flexible Typing & Keystrokes:** The numeric input allows any input (including empty strings `""` or temporary lower values) while typing, calculating cart totals on the fly.
2. **Finish Typing Validation (`onBlur`):** Once the user finishes typing (clicks/taps outside the input field, firing the `onBlur` event), the application validates the price. If it is lower than the minimum price (or left empty), a toast error is displayed and the price resets back to the original minimum.
3. **Form Submission Check (`handleCheckout`):** As a final safeguard, if the user bypasses `onBlur` or submits directly, the checkout function validates all cart item prices and blocks submission if any override is lower than the item's original daily rate.

---

## Code Diff

### File: `apps/admin/components/admin/OrderForm.tsx`

```diff
@@ -536,6 +536,15 @@
       return;
     }

+    // Validate price overrides (prices cannot be lower than original)
+    for (const item of cartItems) {
+      const minPrice = item.original_price_per_day ?? 0;
+      if (item.price_per_day < minPrice) {
+        showError("Price Override", `Price for "${item.product.name}" cannot be lower than the original price of ${formatCurrency(minPrice)}.`);
+        return;
+      }
+    }
+
     const basePayload = {
       notes: notes || undefined,
       delivery_address: deliveryAddress || undefined,
@@ -1036,20 +1036,22 @@
                               <span className="text-[10px] text-slate-400 font-medium">₹</span>
                               <input
                                 type="number"
-                                value={item.price_per_day}
-                                min={item.original_price_per_day}
+                                value={item.price_per_day === 0 ? "" : item.price_per_day}
+                                min={0}
                                 step="1"
                                 onChange={(e) => {
-                                  const val = parseFloat(e.target.value);
+                                  const val = e.target.value === "" ? 0 : parseFloat(e.target.value);
                                   if (isNaN(val)) return;
-                                  const minPrice = item.original_price_per_day ?? 0;
-                                  if (val < minPrice) {
-                                    showError("Price Override", `Price cannot be lower than ${formatCurrency(minPrice)}.`);
-                                    setCartItems(prev => prev.map(p =>
-                                      p.product.id === item.product.id ? { ...p, price_per_day: minPrice } : p
-                                    ));
-                                    return;
-                                  }
                                   setCartItems(prev => prev.map(p =>
                                     p.product.id === item.product.id ? { ...p, price_per_day: val } : p
                                   ));
                                 }}
+                                onBlur={(e) => {
+                                  const val = e.target.value === "" ? 0 : parseFloat(e.target.value);
+                                  const minPrice = item.original_price_per_day ?? 0;
+                                  if (isNaN(val) || val < minPrice) {
+                                    showError("Price Override", `Price cannot be lower than ${formatCurrency(minPrice)}.`);
+                                    setCartItems(prev => prev.map(p =>
+                                      p.product.id === item.product.id ? { ...p, price_per_day: minPrice } : p
+                                    ));
+                                  }
+                                }}
                                 onWheel={(e) => (e.target as HTMLInputElement).blur()}
                                 className="w-20 h-6 text-xs text-right font-semibold border border-slate-200 rounded px-1.5 outline-none focus:border-slate-900 bg-white"
                               />
```

---

# Staff Audit Tracking (Order Creation / Price Updates)

This section records the changes made to capture and display the staff members responsible for creating orders and updating prices/orders.

## 1. Domain Types

Added `created_by` and `updated_by` UUID fields to the `Order` interface, and added `creator` and `updater` (staff details) relationship fields to the `OrderWithRelations` interface.

### File: `apps/admin/domain/types/order.ts`

```typescript
export interface Order {
  // ...
  created_by?: string | null;
  updated_by?: string | null;
  readonly created_at: string;
  readonly updated_at?: string;
}

export interface OrderWithRelations extends Order {
  // ...
  creator?: {
    id: string;
    name: string;
    email: string;
  } | null;
  updater?: {
    id: string;
    name: string;
    email: string;
  } | null;
}
```

## 2. Repository Layer

Updated `OrderRepository` to fetch `creator` and `updater` relationships in `findById`, and automatically attach `updated_by` (obtained from the request's user context) on `update`.

### File: `apps/admin/repository/orderRepository.ts`

```typescript
// Inside findById
const { data, error } = await this.client
  .from(this.tableName)
  .select(
    `
    *,
    customer:customer_id(*),
    branch:branch_id(id, name),
    items:order_items(*, product:product_id(*, category:category_id(*))),
    creator:created_by(id, name, email),
    updater:updated_by(id, name, email)
  `
  )
  .eq('id', id)
  .single();

// Inside update
const response = await this.client
  .from(this.tableName)
  .update({
    ...orderData,
    ...this.getUpdateAuditFields(),
  })
  .eq('id', id)
  .select()
  .single();
```

## 3. UI/Components Display

Updated order details view and order editing form headers to dynamically display the staff members who created or last updated the order details.

### File: `apps/admin/components/admin/OrderDetailsView.tsx`

```tsx
<p className="text-sm text-slate-500">
  Created on {format(new Date(order.created_at), 'dd MMM, yyyy • h:mm a')} by{' '}
  <span className="font-semibold">{order.creator?.name || 'Admin'}</span>
</p>;
{
  order.updated_at && order.updater && (
    <p className="text-xs text-slate-400 mt-1">
      Last updated on {format(new Date(order.updated_at), 'dd MMM, yyyy • h:mm a')} by{' '}
      <span className="font-semibold">{order.updater.name}</span>
    </p>
  );
}
```

### File: `apps/admin/components/admin/OrderForm.tsx`

```tsx
{
  isEditing ? (
    <div className="space-y-0.5 mt-1 text-xs text-slate-500">
      <p>
        Created on{' '}
        {initialData.created_at
          ? format(new Date(initialData.created_at), 'dd MMM, yyyy • h:mm a')
          : ''}{' '}
        by <span className="font-semibold">{initialData.creator?.name || 'Admin'}</span>
      </p>
      {initialData.updated_at && initialData.updater && (
        <p>
          Last updated on {format(new Date(initialData.updated_at), 'dd MMM, yyyy • h:mm a')} by{' '}
          <span className="font-semibold">{initialData.updater.name}</span>
        </p>
      )}
    </div>
  ) : (
    <p className="text-sm text-slate-500">Search customer, add items, and confirm</p>
  );
}
```
