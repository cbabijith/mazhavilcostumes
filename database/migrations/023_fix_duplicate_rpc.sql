-- ============================================================================
-- Migration 023: Fix Duplicate RPC Function
-- Drops all versions of get_operational_dashboard_metrics and recreates the correct one
-- ============================================================================

-- Drop the function completely (this will remove all overloads)
DROP FUNCTION IF EXISTS public.get_operational_dashboard_metrics(
  p_today_start TIMESTAMPTZ,
  p_today_end TIMESTAMPTZ,
  p_today_date DATE,
  p_yesterday_date DATE,
  p_tomorrow_date DATE,
  p_next_5_days_date DATE,
  p_branch_id UUID
);

-- Recreate with the correct version (no late_return references)
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
  -- 2.1 Today's Bookings
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_bookings
  FROM orders
  WHERE created_at >= p_today_start AND created_at <= p_today_end 
    AND status != 'cancelled'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- 2.2 Today's Delivery Total
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_delivery_total
  FROM orders
  WHERE start_date = p_today_date 
    AND status != 'cancelled'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- 2.3 Today's Delivery Done (NO late_return)
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_delivery_done
  FROM orders
  WHERE start_date = p_today_date 
    AND status IN ('ongoing', 'in_use', 'delivered', 'partial', 'returned', 'completed', 'flagged')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- 2.4 Today's Return Total
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_return_total
  FROM orders
  WHERE end_date = p_today_date 
    AND status != 'cancelled'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- 2.5 Today's Return Done
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_return_done
  FROM orders
  WHERE end_date = p_today_date 
    AND status IN ('returned', 'completed', 'flagged')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- 2.6 Prepare Delivery (next 5 days)
  SELECT COALESCE(COUNT(*), 0) INTO v_prepare_deliveries
  FROM orders
  WHERE start_date >= p_tomorrow_date AND start_date <= p_next_5_days_date 
    AND status IN ('scheduled', 'pending', 'confirmed')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- 2.7 Pending Delivery (overdue)
  SELECT COALESCE(COUNT(*), 0) INTO v_pending_deliveries
  FROM orders
  WHERE start_date < p_today_date 
    AND status IN ('scheduled', 'pending', 'confirmed')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- 2.8 Pending Return (overdue) - NO late_return, using is_late flag logic
  SELECT COALESCE(COUNT(*), 0) INTO v_pending_returns
  FROM orders
  WHERE end_date < p_today_date 
    AND status IN ('ongoing', 'in_use')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- 2.9 Revenue Due - NO late_return
  SELECT COALESCE(COUNT(*), 0), COALESCE(SUM(GREATEST(0, total_amount - amount_paid)), 0.00)
  INTO v_revenue_due_count, v_revenue_due_amount
  FROM orders
  WHERE status IN ('returned', 'partial', 'flagged') 
    AND payment_status != 'paid'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  -- 2.10 Priority Cleaning Records (urgent scheduled/pending cleaning)
  SELECT COALESCE(JSONB_AGG(t), '[]'::jsonb) INTO v_priority_cleaning
  FROM (
    SELECT 
      cr.id, 
      cr.product_id, 
      cr.quantity, 
      cr.expected_return_date, 
      cr.priority_order_id, 
      cr.notes,
      JSONB_BUILD_OBJECT('name', p.name) AS product
    FROM cleaning_records cr
    LEFT JOIN products p ON cr.product_id = p.id
    WHERE cr.status IN ('scheduled', 'pending') 
      AND cr.priority = 'urgent'
      AND (p_branch_id IS NULL OR p.branch_id = p_branch_id)
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
