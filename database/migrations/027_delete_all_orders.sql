-- e:/PROJECTS/mazhavilcostumes/database/migrations/027_delete_all_orders.sql

BEGIN;

-- 1. Delete dependent order status history logs
DELETE FROM public.order_status_history;

-- 2. Delete payments associated with orders
DELETE FROM public.payments;

-- 3. Delete damage assessments associated with returned orders
DELETE FROM public.damage_assessments;

-- 4. Delete cleaning records associated with returned orders
DELETE FROM public.cleaning_records;

-- 5. Delete order reservations blocking product stock dates
DELETE FROM public.order_reservations;

-- 6. Delete individual order item lines
DELETE FROM public.order_items;

-- 7. Delete all parent orders
DELETE FROM public.orders;

COMMIT;
