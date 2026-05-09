# Analysis of Order Module, Buffer Operations, and Cleaning Workflow

This document provides a comprehensive analysis of how Mazhavil Costumes manages product availability, rental buffers, and the cleaning lifecycle, especially when multiple orders are placed close to each other.

---

## 1. The Core Concept: 1-Day Cleaning Buffer

In a costume rental business, an item isn't ready for the next customer the moment it is returned. It requires cleaning, inspection, and preparation.

- **Standard Buffer**: The system automatically adds **1 day** before the rental starts and **1 day** after the rental ends.
- **Purpose**: This ensures that even if an order is returned late in the evening, there is a full day dedicated to cleaning before it goes out again.
- **Configurability**: This buffer can be enabled or disabled at the **Category level** (e.g., jewelry might not need a 1-day wash buffer, but a heavy gown does).

---

## 2. Product Availability Logic (The "Sweep Line")

The system uses a sophisticated **Sweep Line algorithm** to calculate availability. Instead of just looking at total orders, it calculates the **Peak Usage** for every single day in your requested range.

### How Availability is Calculated:
1. **Total Stock**: The system starts with the total quantity of the product (e.g., 10 units).
2. **Status Filter**: It only counts orders that are "Active" (`pending`, `scheduled`, `ongoing`, `in_use`, etc.).
3. **Date Range**: It checks for overlaps between your requested dates and existing orders.
4. **Buffer Inclusion**: By default, it extends the duration of every existing order by 1 day on both ends.

**Formula for Blocked Units (Standard):**
> `Blocked = (Actual Rentals) + (Units in Cleaning/Buffer)`

---

## 3. "Skip Gap" (Prior Cleaning) Logic

The "Skip Gap" feature (also called `buffer_override`) is designed for situations where the staff knows they can clean an item faster or have already prepared it.

### What happens when you toggle "Skip Gap"?
- The system **ignores the 1-day buffer** for the order you are currently creating.
- It only checks for **Actual Rental Date** overlaps.
- **Same-Day Turnover**: With Skip Gap ON, an item can be returned by Customer A and picked up by Customer B on the **same day**.

### The "Prior Cleaning" Math:
To prevent double-counting, the system uses this logic for every day:
> `Units Blocked = (Normal Orders) + Max(Buffer-only Units, Skip-Gap Orders)`

This means "Skip Gap" orders essentially "borrow" from the buffer time that was already reserved.

---

## 4. Order Creation Workflow

1. **Date Selection**: User picks Start and End dates.
2. **Availability Check**:
   - The system fetches all overlapping orders.
   - It calculates if the requested quantity is available after considering buffers.
   - If a conflict exists **only** in the buffer zone, the UI suggests the "Skip Gap" option.
3. **Inventory Reservation**:
   - Inventory is **not** physically deducted from the `products` table yet.
   - It is "Reserved" because it's now tied to a `scheduled` order.
   - Actual stock deduction happens only when the order status changes to `ongoing` (Pick up).

---

## 5. The Cleaning Module & Return Flow

The Cleaning Module is the physical counterpart to the logical buffer.

### The Flow:
1. **Order Return**: When an order is marked as `returned`, the system triggers the cleaning logic.
2. **Category Check**: If the product's category has `has_buffer = true`, a record is automatically created in the **Cleaning Queue**.
3. **Urgency Detection**:
   - The system looks ahead 3 days.
   - If there is an upcoming "Skip Gap" order for this product, the cleaning record is marked as **URGENT**.
   - Staff sees a notification: *"Urgently needed for Order #XYZ"*.
4. **Automation**:
   - Once the cleaning is started and completed in the dashboard, the item is physically ready.
   - **Note**: The logical availability always assumes a 1-day buffer exists for past orders to keep the calendar predictable.

---

## 6. Practical Scenarios (Date Proximity)

Assume we have **1 unit** of "Royal Gown".

### Scenario 1: Normal Buffer Conflict
- **Order A**: May 10 to May 12. (Logical Window: May 9 - May 13)
- **Order B (Requested)**: May 13 to May 15.
- **Result**: **BLOCKED**. Even though Order A ends on the 12th, the 13th is reserved for cleaning.

### Scenario 2: Skip Gap / Prior Cleaning
- **Order A**: May 10 to May 12.
- **Order B (Requested)**: May 13 to May 15 + **Skip Gap ON**.
- **Result**: **ALLOWED**. The system ignores the May 13 buffer. Customer B picks up the item the same day Customer A returns it (or the morning after).

### Scenario 3: Same-Day Return & Pickup
- **Order A**: May 10 to May 12.
- **Order B (Requested)**: May 12 to May 14 + **Skip Gap ON**.
- **Result**: **ALLOWED**. The system treats the 12th as a turnover day.

### Scenario 4: Overlapping Actual Dates
- **Order A**: May 10 to May 12.
- **Order B (Requested)**: May 11 to May 13.
- **Result**: **BLOCKED**. Even with "Skip Gap", the actual rental dates overlap. The system will never allow two people to have the same physical item on the same day.

---

## Summary Table: How Dates Interact

| Scenario | Order A Dates | Order B Dates | Skip Gap | Result | Reason |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Standard** | 10th - 12th | 14th - 16th | No | ✅ OK | 13th is the buffer day. |
| **Buffer Conflict** | 10th - 12th | 13th - 15th | No | ❌ Blocked | 13th is needed for cleaning. |
| **Skip Gap** | 10th - 12th | 13th - 15th | **Yes** | ✅ OK | Staff agrees to clean/prep by the 13th. |
| **Overlap** | 10th - 12th | 11th - 13th | Yes | ❌ Blocked | Physical overlap on the 11th and 12th. |

---

## 7. Key Takeaways for Staff

- **Buffer is Safety**: It prevents overbooking and ensures quality.
- **Skip Gap is Responsibility**: Only use it if you are sure the item can be ready.
- **Cleaning Queue is the Guide**: Check the queue to see which items need to be washed first for upcoming orders.
