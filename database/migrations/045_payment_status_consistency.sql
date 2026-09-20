-- ============================================================================
-- Migration 045: payment_status consistency + Revenue-Due truthfulness
--
-- BACKGROUND (2026-09-20):
--   Seven live orders (MAZ-2627-1006/1025/1043/1167/1246/1289/1292) ended up
--   status='returned', payment_status='partial' while total_amount ==
--   amount_paid (fully settled) and all items returned. They surfaced as
--   phantom "Revenue Due" on the dashboard (revenueDueCount=7 with
--   revenueDueAmount=₹0) and as "pending" in the orders list, even though
--   nothing was actually due. The rows were repaired on 2026-09-20 via a
--   one-time script; this migration installs the permanent guards.
--
-- WHAT THIS DOES (all idempotent — safe to re-run):
--   1. Backfills payment_status to match (total_amount, amount_paid)
--      arithmetic — skips 'refund_waived' (a deliberate manual state) and
--      cancelled orders (cancel-flow semantics own those).
--   2. Backfills auto-completion: returned/partial orders that are fully
--      paid with every unit physically back become 'completed' (exactly
--      what orderService.checkAndAutoComplete would do).
--   3. Un-sticks 'ongoing'/'in_use' orders whose every item is already
--      returned → 'returned' (so they can complete / show correctly).
--   4. Creates a BEFORE INSERT/UPDATE trigger that normalizes
--      payment_status on every future write, so NO code path (stale
--      deployment, script, mobile app) can persist an inconsistent flag.
--   5. Hardens get_operational_dashboard_metrics: revenue-due is counted by
--      ACTUAL outstanding balance, not the flag; pending-returns excludes
--      orders whose items are all physically back.
-- ============================================================================

-- ─── 1. Normalize payment_status (skip refund_waived + cancelled) ───────────
UPDATE orders o
SET payment_status = CASE
      WHEN COALESCE(o.amount_paid, 0) >= COALESCE(o.total_amount, 0) THEN 'paid'
      WHEN COALESCE(o.amount_paid, 0) > 0 THEN 'partial'
      ELSE 'pending'
    END,
    updated_at = NOW()
WHERE o.status <> 'cancelled'
  AND o.payment_status IS DISTINCT FROM 'refund_waived'
  AND o.payment_status IS DISTINCT FROM (
    CASE
      WHEN COALESCE(o.amount_paid, 0) >= COALESCE(o.total_amount, 0) THEN 'paid'
      WHEN COALESCE(o.amount_paid, 0) > 0 THEN 'partial'
      ELSE 'pending'
    END);

-- ─── 2. Un-stick ongoing/in_use orders whose items are ALL returned ─────────
WITH unstuck AS (
  UPDATE orders o
  SET status = 'returned',
      updated_at = NOW()
  WHERE o.status IN ('ongoing', 'in_use')
    AND EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.id)
    AND NOT EXISTS (
      SELECT 1 FROM order_items oi
      WHERE oi.order_id = o.id
        AND COALESCE(oi.returned_quantity, 0) < oi.quantity
    )
  RETURNING o.id
)
INSERT INTO order_status_history (order_id, status, notes)
SELECT id, 'returned',
       'Backfill: status was stuck at ongoing/in_use although every item is returned'
FROM unstuck;

-- ─── 3. Auto-complete returned/partial + paid + all items back ──────────────
WITH completed AS (
  UPDATE orders o
  SET status = 'completed',
      updated_at = NOW()
  WHERE o.status IN ('returned', 'partial')
    AND o.payment_status = 'paid'
    AND EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.id)
    AND NOT EXISTS (
      SELECT 1 FROM order_items oi
      WHERE oi.order_id = o.id
        AND COALESCE(oi.returned_quantity, 0) < oi.quantity
    )
  RETURNING o.id
)
INSERT INTO order_status_history (order_id, status, notes)
SELECT id, 'completed',
       'Backfill: auto-completed (items returned + payment settled)'
FROM completed;

-- ─── 4. Trigger: keep payment_status consistent forever ─────────────────────
CREATE OR REPLACE FUNCTION public.normalize_orders_payment_status()
RETURNS TRIGGER AS $$
BEGIN
  -- 'refund_waived' is a deliberate manual decision — never touch it.
  IF NEW.payment_status IS DISTINCT FROM 'refund_waived' THEN
    NEW.payment_status := CASE
      WHEN COALESCE(NEW.amount_paid, 0) >= COALESCE(NEW.total_amount, 0) THEN 'paid'
      WHEN COALESCE(NEW.amount_paid, 0) > 0 THEN 'partial'
      ELSE 'pending'
    END;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS normalize_orders_payment_status ON orders;
CREATE TRIGGER normalize_orders_payment_status
  BEFORE INSERT OR UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION public.normalize_orders_payment_status();

-- ─── 5. Harden the dashboard RPC ────────────────────────────────────────────
-- The live DB carries TWO overloads of this function (6-param from migration
-- 018 + 7-param from 019 — CREATE OR REPLACE cannot change a signature, so
-- 019 silently created an overload). Any call that omits p_branch_id gets
-- PGRST203 "could not choose best candidate" and the dashboard falls back to
-- all-zero cards. Drop the stale 6-param overload first.
DROP FUNCTION IF EXISTS public.get_operational_dashboard_metrics(
  TIMESTAMPTZ, TIMESTAMPTZ, DATE, DATE, DATE, DATE);

CREATE OR REPLACE FUNCTION public.get_operational_dashboard_metrics(
  p_today_start TIMESTAMPTZ,
  p_today_end TIMESTAMPTZ,
  p_today_date DATE,
  p_yesterday_date DATE,
  p_tomorrow_date DATE,
  p_next_5_days_date DATE,
  p_branch_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_todays_bookings INT;
  v_todays_delivery_total INT;
  v_todays_delivery_done INT;
  v_todays_return_total INT;
  v_todays_return_done INT;
  v_prepare_deliveries INT;
  v_pending_deliveries INT;
  v_pending_returns INT;
  v_revenue_due_count INT;
  v_revenue_due_amount DECIMAL(12, 2);
  v_priority_cleaning JSONB;
BEGIN
  -- Today's Bookings
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_bookings
  FROM orders
  WHERE created_at >= p_today_start AND created_at <= p_today_end
    AND status != 'cancelled'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- Today's Delivery Total
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_delivery_total
  FROM orders
  WHERE start_date = p_today_date
    AND status != 'cancelled'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- Today's Delivery Done
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_delivery_done
  FROM orders
  WHERE start_date = p_today_date
    AND status IN ('ongoing', 'in_use', 'delivered', 'late_return', 'partial', 'returned', 'completed', 'flagged')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- Today's Return Total
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_return_total
  FROM orders
  WHERE end_date = p_today_date
    AND status != 'cancelled'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- Today's Return Done
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_return_done
  FROM orders
  WHERE end_date = p_today_date
    AND status IN ('returned', 'completed', 'flagged')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- Prepare Delivery (next 5 days)
  SELECT COALESCE(COUNT(*), 0) INTO v_prepare_deliveries
  FROM orders
  WHERE start_date >= p_tomorrow_date AND start_date <= p_next_5_days_date
    AND status IN ('scheduled', 'pending', 'confirmed')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- Pending Delivery (overdue pickup)
  SELECT COALESCE(COUNT(*), 0) INTO v_pending_deliveries
  FROM orders
  WHERE start_date < p_today_date
    AND status IN ('scheduled', 'pending', 'confirmed')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- Pending Return (overdue): active orders past end_date that still have
  -- units physically out with the customer (an order whose every unit is
  -- returned is not "pending return" even if its status flag lagged behind).
  SELECT COALESCE(COUNT(*), 0) INTO v_pending_returns
  FROM orders o
  WHERE o.end_date < p_today_date
    AND o.status IN ('ongoing', 'in_use', 'late_return')
    AND EXISTS (
      SELECT 1 FROM order_items oi
      WHERE oi.order_id = o.id
        AND COALESCE(oi.returned_quantity, 0) < oi.quantity
    )
    AND (p_branch_id IS NULL OR o.branch_id = p_branch_id);

  -- Revenue Due: counted by ACTUAL outstanding balance, not the
  -- payment_status flag — a stale flag can never create phantom dues.
  SELECT COALESCE(COUNT(*), 0), COALESCE(SUM(GREATEST(0, total_amount - amount_paid)), 0.00)
  INTO v_revenue_due_count, v_revenue_due_amount
  FROM orders
  WHERE status IN ('returned', 'partial', 'flagged', 'late_return')
    AND payment_status != 'refund_waived'
    AND GREATEST(0, COALESCE(total_amount, 0) - COALESCE(amount_paid, 0)) > 0.005
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- Priority Cleaning Records (urgent scheduled/pending cleaning)
  SELECT COALESCE(JSONB_AGG(t), '[]'::jsonb) INTO v_priority_cleaning
  FROM (
    SELECT
      cr.id,
      cr.product_id,
      cr.quantity,
      cr.expected_return_date,
      cr.priority_order_id,
      cr.notes,
      JSONB_BUILD_OBJECT('name', pr.name) AS product
    FROM cleaning_records cr
    LEFT JOIN products pr ON cr.product_id = pr.id
    WHERE cr.status IN ('scheduled', 'pending')
      AND cr.priority = 'urgent'
      AND (p_branch_id IS NULL OR pr.branch_id = p_branch_id)
    ORDER BY cr.expected_return_date ASC
    LIMIT 10
  ) t;

  RETURN JSONB_BUILD_OBJECT(
    'todaysBookings', v_todays_bookings,
    'todaysDeliveryTotal', v_todays_delivery_total,
    'todaysDeliveryDone', v_todays_delivery_done,
    'todaysReturnTotal', v_todays_return_total,
    'todaysReturnDone', v_todays_return_done,
    'prepareDeliveries', v_prepare_deliveries,
    'pendingDeliveries', v_pending_deliveries,
    'pendingReturns', v_pending_returns,
    'revenueDueCount', v_revenue_due_count,
    'revenueDueAmount', v_revenue_due_amount,
    'priorityCleaning', v_priority_cleaning
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- VERIFICATION (run after applying):
--   SELECT count(*) FROM orders WHERE status <> 'cancelled'
--     AND payment_status <> 'refund_waived'
--     AND payment_status <> (CASE WHEN COALESCE(amount_paid,0) >= COALESCE(total_amount,0)
--           THEN 'paid' WHEN COALESCE(amount_paid,0) > 0 THEN 'partial' ELSE 'pending' END);
--   -- expected: 0
-- ============================================================================
