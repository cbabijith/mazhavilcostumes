-- ============================================================================
-- Migration 018: Performance Optimizations
-- Creates database-level functions (RPCs) and critical indexes for performance.
-- ============================================================================

-- 1. High-Performance Indexes
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_start_date ON orders(start_date);
CREATE INDEX IF NOT EXISTS idx_orders_end_date ON orders(end_date);
CREATE INDEX IF NOT EXISTS idx_payments_payment_date ON payments(payment_date);

-- 2. Stored Procedure for Operational Dashboard Metrics
-- Aggregates 10 sequential/parallel counts/reads into 1 single roundtrip call.
CREATE OR REPLACE FUNCTION public.get_operational_dashboard_metrics(
  p_today_start TIMESTAMPTZ,
  p_today_end TIMESTAMPTZ,
  p_today_date DATE,
  p_yesterday_date DATE,
  p_tomorrow_date DATE,
  p_next_5_days_date DATE
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
  WHERE created_at >= p_today_start AND created_at <= p_today_end AND status != 'cancelled';

  -- 2.2 Today's Delivery Total
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_delivery_total
  FROM orders
  WHERE start_date = p_today_date AND status != 'cancelled';

  -- 2.3 Today's Delivery Done
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_delivery_done
  FROM orders
  WHERE start_date = p_today_date AND status IN ('ongoing', 'in_use', 'delivered', 'late_return', 'partial', 'returned', 'completed', 'flagged');

  -- 2.4 Today's Return Total
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_return_total
  FROM orders
  WHERE end_date = p_today_date AND status != 'cancelled';

  -- 2.5 Today's Return Done
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_return_done
  FROM orders
  WHERE end_date = p_today_date AND status IN ('returned', 'completed', 'flagged');

  -- 2.6 Prepare Delivery (next 5 days)
  SELECT COALESCE(COUNT(*), 0) INTO v_prepare_deliveries
  FROM orders
  WHERE start_date >= p_tomorrow_date AND start_date <= p_next_5_days_date 
    AND status IN ('scheduled', 'pending', 'confirmed');

  -- 2.7 Pending Delivery (overdue)
  SELECT COALESCE(COUNT(*), 0) INTO v_pending_deliveries
  FROM orders
  WHERE start_date < p_today_date 
    AND status IN ('scheduled', 'pending', 'confirmed');

  -- 2.8 Pending Return (overdue)
  SELECT COALESCE(COUNT(*), 0) INTO v_pending_returns
  FROM orders
  WHERE end_date < p_today_date 
    AND status IN ('ongoing', 'in_use', 'late_return');

  -- 2.9 Revenue Due
  SELECT COALESCE(COUNT(*), 0), COALESCE(SUM(GREATEST(0, total_amount - amount_paid)), 0.00)
  INTO v_revenue_due_count, v_revenue_due_amount
  FROM orders
  WHERE status IN ('returned', 'partial', 'flagged', 'late_return') AND payment_status != 'paid';

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
    WHERE cr.status IN ('scheduled', 'pending') AND cr.priority = 'urgent'
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

-- 3. Stored Procedure for Dead Stock
-- Eliminates memory-heavy JS array filters by joining and sorting database-side.
CREATE OR REPLACE FUNCTION public.get_dead_stock(
  p_ninety_days_ago TIMESTAMPTZ, 
  p_branch_id UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  name VARCHAR,
  days_idle INT,
  value DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    GREATEST(0, EXTRACT(DAY FROM (NOW() - p.created_at))::INT) as days_idle,
    p.price_per_day as value
  FROM products p
  WHERE p.is_active = true 
    AND p.deleted_at IS NULL
    AND (p_branch_id IS NULL OR p.branch_id = p_branch_id)
    AND EXTRACT(DAY FROM (NOW() - p.created_at)) >= 90
    AND p.id NOT IN (
      SELECT DISTINCT oi.product_id 
      FROM order_items oi
      INNER JOIN orders o ON oi.order_id = o.id
      WHERE o.created_at >= p_ninety_days_ago 
        AND o.status != 'cancelled'
        AND (p_branch_id IS NULL OR o.branch_id = p_branch_id)
    )
  ORDER BY days_idle DESC, value DESC
  LIMIT 5;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
