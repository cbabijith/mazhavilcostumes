-- ============================================================================
-- Test SQL: Create a Late Order for Testing
-- Today: 2026-05-30
-- This creates an order with end_date in the past to trigger is_late=true
-- ============================================================================

-- Insert a test late order
-- end_date: 2026-05-25 (5 days ago) - should trigger is_late=true
-- status: 'ongoing' - one of the statuses that triggers late flag
INSERT INTO orders (
  id,
  store_id,
  customer_id,
  branch_id,
  status,
  start_date,
  end_date,
  event_date,
  total_amount,
  subtotal,
  gst_amount,
  advance_amount,
  amount_paid,
  payment_status,
  notes,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  '9403fc00-1042-4770-a64b-08f196a58457',
  '1e581b42-4579-4545-9ccf-edd7100364db',
  '7671abeb-4b79-47a4-966b-384c1c26b950',
  'ongoing',
  '2026-05-20',
  '2026-05-25',
  '2026-05-20',
  5000.00,
  4500.00,
  500.00,
  1000.00,
  2000.00,
  'pending',
  'Test late order - end_date is 2026-05-25, today is 2026-05-30',
  NOW(),
  NOW()
);

-- Verify the order was created and check is_late flag
SELECT
  id,
  status,
  start_date,
  end_date,
  is_late,
  notes
FROM orders
WHERE notes = 'Test late order - end_date is 2026-05-25, today is 2026-05-30'
ORDER BY created_at DESC
LIMIT 1;

-- Expected result: is_late should be TRUE because:
-- - end_date (2026-05-25) < current_date (2026-05-30)
-- - status = 'ongoing' (one of the statuses that triggers late flag)
