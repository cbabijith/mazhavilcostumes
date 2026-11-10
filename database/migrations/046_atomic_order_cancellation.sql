-- Atomic cancellation for bookings and active rentals. Apply before deploying
-- the matching admin API. This file does not backfill or cancel existing orders.
-- Refunds remain ledger entries; unrefunded money remains refund-due unless
-- the existing explicit Keep Amount action is used. Original invoice/GST values
-- remain intact for audit; reports exclude cancelled rental invoices by status.
BEGIN;

CREATE OR REPLACE FUNCTION public.cancel_order(
  p_order_id uuid, p_staff_id uuid, p_reason text,
  p_refund_amount numeric DEFAULT 0, p_refund_mode text DEFAULT NULL,
  p_stock_returned boolean DEFAULT false
) RETURNS jsonb
LANGUAGE plpgsql SECURITY INVOKER SET search_path = public
AS $$
DECLARE
  v_order public.orders%ROWTYPE;
  v_staff public.staff%ROWTYPE;
  v_paid numeric;
  v_remaining numeric;
  v_item record;
  v_now timestamptz := now();
BEGIN
  SELECT * INTO v_staff FROM public.staff WHERE id = p_staff_id AND is_active = true;
  IF NOT FOUND OR v_staff.role NOT IN ('admin', 'super_admin', 'manager', 'staff') THEN
    RAISE EXCEPTION 'An active staff account is required' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO v_order FROM public.orders WHERE id = p_order_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Order not found' USING ERRCODE = 'P0002'; END IF;
  IF v_staff.store_id IS DISTINCT FROM v_order.store_id
     OR (v_staff.role IN ('manager', 'staff') AND v_staff.branch_id IS DISTINCT FROM v_order.branch_id) THEN
    RAISE EXCEPTION 'You cannot cancel an order outside your store or assigned branch' USING ERRCODE = '42501';
  END IF;
  IF p_reason IS NULL OR length(btrim(p_reason)) = 0 OR length(p_reason) > 2000 THEN
    RAISE EXCEPTION 'Cancellation reason is required (maximum 2000 characters)' USING ERRCODE = '22023';
  END IF;
  IF p_refund_amount IS NULL OR p_refund_amount::text IN ('NaN', 'Infinity', '-Infinity')
     OR p_refund_amount < 0 OR p_refund_amount <> round(p_refund_amount, 2) THEN
    RAISE EXCEPTION 'Refund must be a nonnegative amount with at most two decimal places' USING ERRCODE = '22023';
  END IF;
  IF p_refund_amount > 0 AND (p_refund_mode IS NULL OR p_refund_mode NOT IN ('cash','upi','gpay','bank_transfer','cheque')) THEN
    RAISE EXCEPTION 'Select a valid refund payment mode' USING ERRCODE = '22023';
  END IF;

  -- A repeated request after a lost response must not refund or restore twice.
  IF v_order.status = 'cancelled' THEN RETURN to_jsonb(v_order); END IF;
  IF v_order.status NOT IN ('pending','confirmed','scheduled','delivered','ongoing','in_use') THEN
    RAISE EXCEPTION 'This order status cannot be cancelled; finish the return instead' USING ERRCODE = 'P0001';
  END IF;
  PERFORM id FROM public.order_items WHERE order_id = p_order_id ORDER BY id FOR UPDATE;
  IF EXISTS (SELECT 1 FROM public.order_items WHERE order_id = p_order_id
      AND (coalesce(returned_quantity, 0) < 0 OR coalesce(returned_quantity, 0) > quantity)) THEN
    RAISE EXCEPTION 'Returned quantities are inconsistent; reconcile them before cancellation' USING ERRCODE = 'P0001';
  END IF;
  IF v_order.status IN ('ongoing','in_use') AND EXISTS (
      SELECT 1 FROM public.order_items WHERE order_id = p_order_id
      AND quantity > coalesce(returned_quantity, 0)
      AND (coalesce(damaged_quantity, 0) > coalesce(returned_quantity, 0)
        OR (condition_rating = 'damaged' AND coalesce(returned_quantity, 0) = 0))) THEN
    RAISE EXCEPTION 'Process damaged costumes through the return workflow before cancellation' USING ERRCODE = 'P0001';
  END IF;
  IF v_order.status IN ('ongoing','in_use') AND NOT coalesce(p_stock_returned, false)
     AND EXISTS (SELECT 1 FROM public.order_items WHERE order_id = p_order_id AND quantity > coalesce(returned_quantity, 0)) THEN
    RAISE EXCEPTION 'Confirm all outstanding costumes are back in usable condition before cancellation' USING ERRCODE = '22023';
  END IF;
  PERFORM id FROM public.payments WHERE order_id = p_order_id ORDER BY id FOR UPDATE;
  SELECT coalesce(sum(CASE WHEN payment_type = 'refund' THEN -amount ELSE amount END), 0)
    INTO v_paid FROM public.payments WHERE order_id = p_order_id;
  IF v_paid <> coalesce(v_order.amount_paid, 0) THEN
    RAISE EXCEPTION 'Payment ledger and order paid amount differ; reconcile them before cancellation' USING ERRCODE = 'P0001';
  END IF;
  IF p_refund_amount > v_paid THEN
    RAISE EXCEPTION 'Refund exceeds the remaining paid amount' USING ERRCODE = '22023';
  END IF;

  -- Only ongoing/in_use deducted stock on dispatch in the existing workflow.
  -- Subtract cumulative returned quantities, including any previously damaged
  -- returns, so neither returned nor unavailable damaged stock is restored twice.
  IF v_order.status IN ('ongoing','in_use') THEN
    FOR v_item IN
      SELECT product_id, sum(greatest(0, quantity - coalesce(returned_quantity, 0)))::integer AS outstanding
      FROM public.order_items WHERE order_id = p_order_id GROUP BY product_id ORDER BY product_id
    LOOP
      IF v_item.outstanding > 0 THEN
        UPDATE public.products SET available_quantity = available_quantity + v_item.outstanding
          WHERE id = v_item.product_id AND available_quantity + v_item.outstanding <= quantity;
        IF NOT FOUND THEN RAISE EXCEPTION 'Product stock is inconsistent; cancellation was not saved' USING ERRCODE = 'P0001'; END IF;
        UPDATE public.product_inventory SET available_quantity = available_quantity + v_item.outstanding
          WHERE product_id = v_item.product_id AND branch_id = v_order.branch_id
            AND available_quantity + v_item.outstanding <= quantity;
        IF NOT FOUND THEN RAISE EXCEPTION 'Branch stock is missing or inconsistent; cancellation was not saved' USING ERRCODE = 'P0001'; END IF;
      END IF;
    END LOOP;
    UPDATE public.order_items SET returned_quantity = quantity, is_returned = true,
      returned_at = coalesce(returned_at, v_now)
      WHERE order_id = p_order_id AND coalesce(returned_quantity, 0) < quantity;
  END IF;
  DELETE FROM public.order_reservations WHERE order_id = p_order_id;
  DELETE FROM public.cleaning_records WHERE order_id = p_order_id AND status = 'scheduled';
  UPDATE public.cleaning_records SET priority_order_id = NULL, priority = 'normal'
    WHERE priority_order_id = p_order_id AND status = 'scheduled';

  IF p_refund_amount > 0 THEN
    INSERT INTO public.payments(order_id, payment_type, amount, payment_mode, notes, created_by, payment_date)
      VALUES (p_order_id, 'refund', p_refund_amount, p_refund_mode,
        'Cancellation refund: ' || btrim(p_reason), p_staff_id, v_now);
  END IF;
  v_remaining := v_paid - p_refund_amount;
  UPDATE public.orders SET status = 'cancelled', cancellation_reason = btrim(p_reason),
    cancelled_by = p_staff_id, cancelled_at = v_now, updated_by = p_staff_id,
    updated_at = v_now, amount_paid = v_remaining,
    payment_status = CASE WHEN v_remaining >= total_amount THEN 'paid' WHEN v_remaining > 0 THEN 'partial' ELSE 'pending' END,
    has_priority_cleaning = false, has_stock_conflict = false, conflict_details = '[]'::jsonb, is_late = false
    WHERE id = p_order_id RETURNING * INTO v_order;
  INSERT INTO public.order_status_history(order_id, status, notes, changed_by)
    VALUES (p_order_id, 'cancelled', btrim(p_reason) || '; Refund recorded: ' || p_refund_amount::text, p_staff_id);
  RETURN to_jsonb(v_order);
END;
$$;

-- Only the guarded server route may pass a verified staff identity.
REVOKE ALL ON FUNCTION public.cancel_order(uuid,uuid,text,numeric,text,boolean) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.cancel_order(uuid,uuid,text,numeric,text,boolean) TO service_role;
COMMIT;
