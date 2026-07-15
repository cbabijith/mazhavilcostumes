# Admin Performance Optimization Tasks

## Overview
The admin dashboard is slow mainly due to excessive data fetching, expensive aggregation in Node/React instead of the database, and broad query cache invalidation. This is a data/query architecture issue rather than a UI-only issue.

---

## Task 1: Optimize Orders List Query
**Priority:** High  
**Impact:** Very High

**Current Issues:**
- `orderRepository.ts:69` fetches `orders.*`, `order_items.*`, customer, branch, product, product images, and category data for every row
- Orders list API runs the main order query plus two extra count queries for action-needed and stock-conflict badges (`route.ts:66`)
- One orders page load = multiple DB hits

**Solutions:**
1. Implement pagination for order items (don't fetch all items for all orders)
2. Use SELECT only specific fields instead of `*`
3. Move badge count queries to database-level aggregation
4. Consider using database views or materialized views for common joins
5. Implement cursor-based pagination for better performance on large datasets

**Files to modify:**
- `apps/admin/repository/orderRepository.ts`
- `apps/admin/app/api/orders/route.ts`

---

## Task 2: Optimize Availability Checks
**Priority:** High  
**Impact:** High

**Current Issues:**
- Batch availability endpoint loops through cart items one-by-one (`check-availability/route.ts:43`)
- Each item calls `checkAvailability` which runs product lookup, overlapping order lookup, then nested day/order loops (`orderRepository.ts:342`)
- Sequential processing makes order create/edit slower as cart size grows
- Performance degrades as order history grows

**Solutions:**
1. Batch availability checks into a single database query
2. Use PostgreSQL window functions or CTEs for overlapping order detection
3. Add database indexes on date ranges for faster overlap queries
4. Consider caching availability results for short periods
5. Parallelize independent checks where possible

**Files to modify:**
- `apps/admin/app/api/orders/check-availability/route.ts`
- `apps/admin/repository/orderRepository.ts`

---

## Task 3: Optimize Order Background Work
**Priority:** Medium  
**Impact:** Medium

**Current Issues:**
- After create/update/delete, service starts priority-cleaning and stock-conflict recalculation
- Background work still competes with normal admin requests
- Conflict sync validates many orders one-by-one (`orderRepository.ts:639`)
- Each validation re-fetches full order details and availability

**Solutions:**
1. Move background work to a proper job queue (BullMQ, pg-boss, or Supabase Edge Functions)
2. Batch conflict validation instead of processing one-by-one
3. Add database-level triggers for conflict detection where possible
4. Implement rate limiting for background tasks
5. Consider using PostgreSQL LISTEN/NOTIFY for async updates

**Files to modify:**
- `apps/admin/repository/orderRepository.ts`
- `apps/admin/services/orderService.ts`

---

## Task 4: Optimize Product List Query
**Priority:** High  
**Impact:** High

**Current Issues:**
- Product list query fetches `products.*`, category, branch, and full `product_inventory` relations (`productRepository.ts:62`)
- Separately fetches all matching product `quantity` rows and sums them in JS (`productRepository.ts:120`)
- Unpaginated stock summing defeats pagination
- Stock totals require scanning all inventory rows

**Solutions:**
1. Move stock summing to database with a subquery or CTE
2. Add a `total_quantity` computed column or materialized view
3. Implement SELECT only specific fields instead of `*`
4. Consider denormalizing stock totals with triggers
5. Add database indexes on inventory aggregation queries

**Files to modify:**
- `apps/admin/repository/productRepository.ts`

---

## Task 5: Optimize Product Search
**Priority:** Medium  
**Impact:** Medium

**Current Issues:**
- Product search uses `%term%` `ilike` across name, slug, SKU, and barcode (`productRepository.ts:80`)
- Trigram migration only adds indexes for orders invoice and customers, not products
- Product search can become slow with a large catalog
- Leading wildcard `%term%` prevents index usage

**Solutions:**
1. Add trigram indexes to products table (name, slug, sku, barcode)
2. Consider using PostgreSQL full-text search (tsvector)
3. Implement search autocomplete with prefix matching instead of full `%term%`
4. Add search result caching
5. Consider Elasticsearch/Meilisearch for advanced search if catalog is very large

**Files to modify:**
- `database/migrations/` (add new migration for trigram indexes)
- `apps/admin/repository/productRepository.ts`

---

## Task 6: Optimize Dashboard Performance
**Priority:** Medium  
**Impact:** High

**Current Issues:**
- Dashboard is `force-dynamic` (`page.tsx:17`) - every load recomputes
- Analytics fires many parallel queries including revenue metrics, orders, cancellations, rented items, category revenue, dead stock, and cleaning records (`dashboardService.ts:452`)
- Some queries fetch rows then aggregate in JS instead of database

**Solutions:**
1. Cache dashboard metrics with appropriate TTL (5-15 minutes)
2. Move aggregations to database level
3. Implement incremental updates for metrics
4. Consider materialized views for heavy analytics
5. Use Next.js ISR (Incremental Static Regeneration) instead of force-dynamic
6. Implement lazy loading for less critical metrics

**Files to modify:**
- `apps/admin/app/dashboard/(overview)/page.tsx`
- `apps/admin/services/dashboardService.ts`

---

## Task 7: Optimize Daily Report Query
**Priority:** Low  
**Impact:** Medium

**Current Issues:**
- Daily report runs 7 queries
- Revenue-due query reads all returned/partial/flagged unpaid orders across history (`dashboardService.ts:735`)
- Performance degrades over time as order history grows

**Solutions:**
1. Add date range filtering to the revenue-due query
2. Implement pagination for historical data
3. Cache report results with appropriate TTL
4. Consider pre-computing daily revenue summaries
5. Add database indexes on status and return_date columns

**Files to modify:**
- `apps/admin/services/dashboardService.ts`

---

## Task 8: Optimize Branch Data Fetching
**Priority:** Low  
**Impact:** Low

**Current Issues:**
- `BranchSwitcher` is mounted in dashboard layout and always calls `useBranches` (`BranchSwitcher.tsx:16`)
- Branch hook uses `cache: 'no-store'`, `staleTime: 0`, and `refetchOnWindowFocus: true` (`useBranches.ts:22`)
- Branch data refetches more often than necessary

**Solutions:**
1. Add appropriate caching to branches hook (staleTime: 5-10 minutes)
2. Remove `cache: 'no-store'` unless branch data changes frequently
3. Disable `refetchOnWindowFocus` or increase threshold
4. Consider storing branches in a global store

**Files to modify:**
- `apps/admin/hooks/useBranches.ts`

---

## Task 9: Optimize Auth Overhead
**Priority:** Low  
**Impact:** Low

**Current Issues:**
- Every guarded API request calls Supabase `auth.getUser()` and then looks up the staff row (`auth.ts:82`)
- Pages with several parallel API calls pay this cost repeatedly
- Correct for security but adds overhead

**Solutions:**
1. Consider caching staff lookup result in session for short duration
2. Implement JWT token with staff info to reduce database lookups
3. Add rate limiting to prevent abuse
4. Consider using Supabase Row Level Security more extensively to offload auth logic

**Files to modify:**
- `apps/admin/lib/auth.ts`

---

## Task 10: Optimize Cache Invalidation
**Priority:** High  
**Impact:** High

**Current Issues:**
- Order mutations invalidate all order queries and cleaning queries (`useOrders.ts:166`)
- Product mutations invalidate product lists, product detail, and branch inventory (`useProducts.ts:237`)
- Broad invalidations cause heavy list endpoints to refetch after common actions

**Solutions:**
1. Implement granular cache invalidation (invalidate only affected records)
2. Use optimistic updates for common mutations
3. Implement partial refetching instead of full list refetch
4. Consider using TanStack Query's `invalidateQueries` with predicate functions
5. Add query key factories for more precise invalidation

**Files to modify:**
- `apps/admin/hooks/useOrders.ts`
- `apps/admin/hooks/useProducts.ts`
- `apps/admin/lib/query-client.ts`

---

## Implementation Priority

1. **Phase 1 (Quick Wins):** Tasks 1, 4, 8, 10 ✅ Done
2. **Phase 2 (High Impact):** Tasks 2, 5, 6 — Task 2 ✅ Done (parallelized), Tasks 5 & 6 pending
3. **Phase 3 (Long-term):** Tasks 3, 7, 9 — Pending

---

## Future: Inventory Reservations Table (Architectural)

**Priority:** Long-term  
**Impact:** 16x faster availability checks, constant-time regardless of cart size or order history

**Current Problem:**
- Availability is derived from `order_items` (billing data) every single check
- No purpose-built inventory domain model exists
- Every check fetches booking rows, transfers to Node.js, reconstructs state with JS loops

**Proposed Solution:**
- New `inventory_reservations` table (product_id, order_id, quantity, start_date, end_date, status)
- Buffer days baked into reservation dates at insert time
- PostgreSQL RPC `check_availability_batch(product_ids[], start, end)` — one indexed query
- Write reservations on order create, update on edit/cancel/return

**Effort:** 2-3 days (migration + backfill + side-by-side testing + integration tests)  
**Risk:** Medium — backfill buffer logic must match current JS logic exactly  
**Rollback:** Easy — drop table, revert code, old method still works

**Don't build until:** Current `Promise.all` fix (80ms) becomes insufficient under production load.

---

## Database Migrations Needed

1. Add trigram indexes to products table
2. Consider adding materialized views for analytics
3. Add computed columns for stock totals
4. Add indexes for date range queries on orders

---

## Monitoring & Metrics

After implementing optimizations, track:
1. Page load times (Orders list, Products list, Dashboard)
2. Database query count per page
3. Average query execution time
4. Cache hit rates
5. API response times
