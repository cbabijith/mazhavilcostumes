-- Rentocostume — Clean Order Data for Live Launch
-- ============================================================================
-- Description:
-- Clears all transactional order data (orders, items, status history, payments,
-- cleaning records, reservations, damage assessments) to start fresh for live launch.
--
-- Preserves: Categories, Products, Customers, Branches, Staff, Stores, and Banners.
-- Resets: Product available quantities, inventory levels, and rental metrics.
-- ============================================================================

BEGIN;

-- 1. Delete order status history logs
DELETE FROM public.order_status_history;

-- 2. Delete payments associated with orders
DELETE FROM public.payments;

-- 3. Delete damage assessments
DELETE FROM public.damage_assessments;

-- 4. Delete cleaning records
DELETE FROM public.cleaning_records;

-- 5. Delete order reservations (unblocks calendar dates)
DELETE FROM public.order_reservations;

-- 6. Delete order items
DELETE FROM public.order_items;

-- 7. Delete all orders
DELETE FROM public.orders;

-- 8. Reset product availability and rental statistics
UPDATE public.products 
SET 
  available_quantity = quantity,
  total_rentals = 0,
  total_revenue = 0.00,
  last_rented_at = NULL;

-- 9. Reset branch-level inventory availability
UPDATE public.product_inventory 
SET 
  available_quantity = quantity;

COMMIT;
