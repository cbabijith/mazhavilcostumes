# Complete Plan: Skip Gap Fix + Cleaning Tracking System

## Part 1: The Story (Simple English)

### How your business works today

1. **Customer A** rents 9 costumes (May 5–9)
2. Customer A returns costumes on May 9
3. May 10 is the **buffer day** — staff cleans and inspects those 9 costumes
4. **Customer B** comes and wants costumes on May 10. Staff says "we can do it" and uses **Skip Gap**
5. Staff **priority-cleans** 2 costumes quickly and gives them to Customer B
6. Now on May 10:
   - 2 costumes → with Customer B (priority cleaned)
   - 7 costumes → still being cleaned
   - 1 costume → was never rented, sitting free on the shelf

### What's broken right now

When **Customer C** comes and asks for May 10–12, the system shows **"8 of 10 free"** because it only sees Customer B's 2 costumes as busy. It completely ignores that 7 costumes are still in cleaning.

**Customer C should see:**
- Without Skip Gap: **1 free** (only the 1 that was never rented)
- With Skip Gap ON: **8 free** (1 free + 7 that can be priority-cleaned)

### What's missing from the system

Right now, cleaning is **invisible**. There's no record of:
- Which costumes are being cleaned
- Which orders need priority cleaning
- When cleaning is done

The buffer day is just a "block" on the calendar — but the staff can't track or manage the actual cleaning work.

---

## Part 2: What We're Building (3 Things)

### Thing 1: Fix the availability numbers

**Problem**: The system counts only "actually rented" costumes, ignores "in cleaning" costumes.

**Fix**: Use this simple rule for each day:

```
In Cleaning = costumes returned from recent orders (buffer period)
With Skip Gap Customers = costumes already given out using Skip Gap
Regular Rentals = costumes rented normally

Blocked = Regular Rentals + max(In Cleaning, With Skip Gap Customers)
Available = Total Stock - Blocked
```

**Why `max()` and not `+`?**
Because Skip Gap customers take their costumes FROM the cleaning pile. If 9 are in cleaning and 2 were taken for Skip Gap, it's not 9+2=11 blocked. It's 9 blocked (2 are already counted inside the 9).

**Files**: `orderRepository.ts` (availability calculation)

---

### Thing 2: Priority Cleaning Dashboard Card

**What staff sees on the dashboard**: A new card showing orders that used Skip Gap and need priority cleaning.

```
┌─────────────────────────────────────────────┐
│ ⚡ Priority Cleaning Required               │
│                                             │
│ 2 orders need products cleaned urgently     │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ Order #abc123 — Customer B              │ │
│ │ Pickup: May 10                          │ │
│ │ Products:                               │ │
│ │   • Gold Necklace Set × 1               │ │
│ │   • Bridal Earrings × 1                 │ │
│ │ ⚠ These overlap with Customer A's       │ │
│ │   buffer (May 5–9 order)                │ │
│ └─────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────┐ │
│ │ Order #def456 — Customer D              │ │
│ │ Pickup: May 11                          │ │
│ │ Products:                               │ │
│ │   • Silver Anklet × 2                   │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

**How it works**: Query all `scheduled` orders where `buffer_override = true` and `start_date` is today or upcoming. For each order, find which earlier orders' buffer periods overlap, and list the products.

**Files**: `dashboardService.ts` (new query), dashboard page (new card UI)

---

### Thing 3: Cleaning Tracking System

**New database table**: `cleaning_records`

```
┌──────────────────────────────────────────────────────────┐
│ cleaning_records                                         │
├──────────────────────────────────────────────────────────┤
│ id              UUID (primary key)                       │
│ product_id      UUID → products table                    │
│ order_id        UUID → orders table (which order         │
│                        returned this product)            │
│ branch_id       UUID → branches table                    │
│ quantity         INT  (how many units in cleaning)       │
│ priority        'normal' | 'urgent'                      │
│ status          'pending' | 'in_progress' | 'completed'  │
│ priority_order_id  UUID → orders table (the Skip Gap     │
│                          order that needs this cleaned)  │
│ started_at      TIMESTAMP (when cleaning started)        │
│ completed_at    TIMESTAMP (when cleaning finished)       │
│ created_at      TIMESTAMP                                │
│ updated_at      TIMESTAMP                                │
└──────────────────────────────────────────────────────────┘
```

### Cleaning Lifecycle

```
Step 1: Order A returns costumes
        → System creates cleaning_records:
          "9 units of Gold Necklace Set, status: pending, priority: normal"

Step 2: Customer B creates Skip Gap order for 2 units
        → System updates/creates cleaning_record:
          "2 units of Gold Necklace Set, status: pending, priority: URGENT,
           priority_order_id: Customer B's order"
        → Remaining: "7 units, status: pending, priority: normal"

Step 3: Staff sends 2 units for urgent cleaning
        → Staff clicks "Start Cleaning" on dashboard
        → Status: pending → in_progress

Step 4: 2 units cleaned and given to Customer B
        → Staff clicks "Done" on dashboard
        → Status: in_progress → completed
        → Cleaning count goes down by 2

Step 5: Later, remaining 7 units finish normal cleaning
        → Staff marks as completed
        → All cleaning_records for this order are done
```

### Dashboard Cleaning Widget

```
┌─────────────────────────────────────────────┐
│ 🧹 Cleaning Queue                           │
│                                             │
│ In Cleaning: 16 products                    │
│ ├── 🔴 Urgent: 4 products (2 orders)       │
│ └── 🟡 Normal: 12 products (3 orders)      │
│                                             │
│ ┌─ URGENT ─────────────────────────────────┐│
│ │ Gold Necklace Set × 2   [Start] [Done]  ││
│ │  → For Order #abc123 (Customer B, May 10)││
│ │ Bridal Earrings × 2     [Start] [Done]  ││
│ │  → For Order #def456 (Customer D, May 11)││
│ └──────────────────────────────────────────┘│
│                                             │
│ ┌─ NORMAL ─────────────────────────────────┐│
│ │ Gold Necklace Set × 7   [Start] [Done]  ││
│ │  ← From Order #xyz (Customer A, May 5-9)││
│ │ Silver Ring × 5          [Start] [Done]  ││
│ │  ← From Order #pqr (Customer E, May 3-8)││
│ └──────────────────────────────────────────┘│
└─────────────────────────────────────────────┘
```

---

## Part 3: All Changes Summary

### Database
| Change | What |
|--------|------|
| New migration `011_cleaning_records.sql` | Creates `cleaning_records` table |

### Backend (layered architecture)
| Layer | File | What |
|-------|------|------|
| Domain | `domain/types/cleaning.ts` | Types for cleaning records |
| Repository | `repository/cleaningRepository.ts` | CRUD for cleaning_records table |
| Repository | `repository/orderRepository.ts` | Fix availability calculation (max formula) |
| Service | `services/cleaningService.ts` | Business logic for cleaning lifecycle |
| Service | `services/dashboardService.ts` | Add priority cleaning + cleaning queue queries |
| Hooks | `hooks/useCleaning.ts` | TanStack Query hooks for cleaning |
| API | `app/api/cleaning/route.ts` | REST endpoints for cleaning management |

### Frontend
| File | What |
|------|------|
| `OrderForm.tsx` | Fix Skip Gap toggle visibility |
| Dashboard page | Add Priority Cleaning card + Cleaning Queue widget |
| New component | `CleaningQueue.tsx` — the cleaning management UI |

### Automated triggers
| When | What happens |
|------|-------------|
| Order status → `returned` | Auto-create cleaning_records for all items |
| Skip Gap order created | Auto-mark overlapping cleaning records as `urgent` |
| Cleaning marked `completed` | Update the product's available count |

---

## Part 4: Phases

> [!IMPORTANT]
> I suggest we do this in **2 phases** so you can test each part separately.

### Phase 1: Fix availability + Priority Cleaning dashboard (smaller, fixes your current bug)
1. Fix the `max(buffer, skipgap)` availability calculation
2. Fix Skip Gap toggle in OrderForm
3. Add "Priority Cleaning Required" card to dashboard
4. No database changes needed — just smart queries

### Phase 2: Full Cleaning Tracking (bigger, new feature)
1. New `cleaning_records` table
2. Full cleaning lifecycle (create → in_progress → completed)
3. Cleaning Queue dashboard widget with Start/Done buttons
4. Auto-create records on order return
5. Auto-mark urgent on Skip Gap order creation

---

## Questions

1. **Do you want both phases, or just Phase 1 first?**
2. **For Phase 2**: Should cleaning records be created automatically when an order is returned? Or should staff manually add items to cleaning?
3. **Buffer days**: Is 1 day buffer always enough for normal cleaning? Should this be configurable per product?

Please confirm and I'll start building!
