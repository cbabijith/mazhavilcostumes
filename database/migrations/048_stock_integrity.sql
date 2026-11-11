-- Inventory integrity: preserve checked-out stock during catalog edits and
-- serialize rental stock changes with order/item writes. No data backfill.
-- Apply only with explicit live-database approval, before the matching API.
BEGIN;

CREATE OR REPLACE FUNCTION public.change_rental_stock(p_product uuid, p_branch uuid, p_store uuid, p_delta integer)
RETURNS void LANGUAGE plpgsql SECURITY INVOKER SET search_path=public AS $$
DECLARE p public.products%ROWTYPE; i public.product_inventory%ROWTYPE;
BEGIN
  IF p_delta = 0 THEN RETURN; END IF;
  SELECT * INTO p FROM public.products WHERE id=p_product AND store_id=p_store FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Product not found in this store' USING ERRCODE='P0002'; END IF;
  IF p.available_quantity < 0 OR p.available_quantity > p.quantity
     OR p.available_quantity+p_delta NOT BETWEEN 0 AND p.quantity THEN
    RAISE EXCEPTION 'Stock for % is inconsistent or insufficient (% available, % total, change %); no changes saved', p.name,p.available_quantity,p.quantity,p_delta USING ERRCODE='P0001';
  END IF;
  SELECT * INTO i FROM public.product_inventory WHERE product_id=p_product AND branch_id=p_branch FOR UPDATE;
  IF FOUND THEN
    IF i.available_quantity < 0 OR i.available_quantity > i.quantity
       OR i.available_quantity+p_delta NOT BETWEEN 0 AND i.quantity THEN
      RAISE EXCEPTION 'Branch stock for % is inconsistent or insufficient; no changes saved',p.name USING ERRCODE='P0001';
    END IF;
    UPDATE public.product_inventory SET available_quantity=available_quantity+p_delta WHERE id=i.id;
  ELSIF EXISTS (SELECT 1 FROM public.product_inventory WHERE product_id=p_product)
    OR NOT EXISTS (SELECT 1 FROM public.branches WHERE id=p_branch AND store_id=p_store AND is_main=true)
    OR (p.branch_id IS NOT NULL AND p.branch_id<>p_branch) THEN
    RAISE EXCEPTION 'Branch stock is missing; no changes saved' USING ERRCODE='P0001';
  END IF;
  UPDATE public.products SET available_quantity=available_quantity+p_delta WHERE id=p_product;
END;
$$;

CREATE OR REPLACE FUNCTION public.check_stock_order_actor(p_order public.orders, p_staff uuid)
RETURNS void LANGUAGE plpgsql SECURITY INVOKER SET search_path=public AS $$
DECLARE s public.staff%ROWTYPE;
BEGIN
  -- NULL is reserved for internal server-only reconciliation calls. Public
  -- clients cannot execute any of these functions; routes pass verified staff.
  IF p_staff IS NULL THEN RETURN; END IF;
  SELECT * INTO s FROM public.staff WHERE id=p_staff AND is_active=true;
  IF NOT FOUND OR s.role NOT IN ('admin','super_admin','manager','staff')
    OR s.store_id IS DISTINCT FROM p_order.store_id
    OR (s.role IN ('staff','manager') AND s.branch_id IS DISTINCT FROM p_order.branch_id) THEN
    RAISE EXCEPTION 'Order is outside your authorized store or branch' USING ERRCODE='42501';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_product_stock_safe(p_id uuid,p_patch jsonb,p_inventory jsonb DEFAULT NULL,p_removed uuid[] DEFAULT '{}')
RETURNS jsonb LANGUAGE plpgsql SECURITY INVOKER SET search_path=public AS $$
DECLARE p public.products%ROWTYPE; i public.product_inventory%ROWTYPE; j jsonb; b uuid;
  q integer; a integer; assignments text; result jsonb; allowed text[] := ARRAY[
  'name','slug','sku','barcode','category_id','subcategory_id','subvariant_id','description','price_per_day','purchase_price',
  'quantity','available_quantity','images','sizes','colors','is_active','is_featured','track_inventory','low_stock_threshold',
  'updated_by','updated_at_branch_id'];
BEGIN
  SELECT * INTO p FROM public.products WHERE id=p_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Product not found' USING ERRCODE='P0002'; END IF;
  IF p.available_quantity NOT BETWEEN 0 AND p.quantity THEN
    RAISE EXCEPTION 'Stock for % needs reconciliation before editing (% available, % total)',p.name,p.available_quantity,p.quantity USING ERRCODE='P0001';
  END IF;
  IF p_patch ? 'quantity' AND ((p_patch->>'quantity')::numeric IS NULL OR (p_patch->>'quantity')::numeric<>trunc((p_patch->>'quantity')::numeric)) THEN
    RAISE EXCEPTION 'Stock quantity must be an integer' USING ERRCODE='22023';
  END IF;
  q := coalesce((p_patch->>'quantity')::integer,p.quantity);
  a := p.available_quantity+q-p.quantity;
  IF q<0 OR a NOT BETWEEN 0 AND q THEN RAISE EXCEPTION 'Total stock cannot be reduced below units currently unavailable' USING ERRCODE='22023'; END IF;
  -- Never trust an available_quantity sent by an older web/mobile form.
  p_patch := (p_patch-'available_quantity') || jsonb_build_object('quantity',q,'available_quantity',a);
  SELECT string_agg(format('%I=(jsonb_populate_record(NULL::public.products,$1)).%I',key,key),',') INTO assignments
    FROM jsonb_object_keys(p_patch) key WHERE key=ANY(allowed);
  EXECUTE 'UPDATE public.products SET '||assignments||',updated_at=now() WHERE id=$2 RETURNING to_jsonb(products.*)'
    INTO result USING p_patch,p_id;
  -- Lock allocations in a stable order after the product lock (same as rentals).
  PERFORM id FROM public.product_inventory WHERE product_id=p_id ORDER BY branch_id FOR UPDATE;
  FOR i IN SELECT * FROM public.product_inventory WHERE id=ANY(p_removed) LOOP
    IF i.product_id<>p_id OR i.available_quantity<>i.quantity THEN
      RAISE EXCEPTION 'Cannot remove an allocation with unavailable stock or belonging to another product' USING ERRCODE='22023';
    END IF;
    DELETE FROM public.product_inventory WHERE id=i.id;
  END LOOP;
  IF p_inventory IS NOT NULL THEN
    IF jsonb_typeof(p_inventory)<>'array' OR EXISTS (SELECT 1 FROM jsonb_array_elements(p_inventory) x GROUP BY x->>'branch_id' HAVING count(*)>1) THEN
      RAISE EXCEPTION 'Invalid or duplicate branch allocations' USING ERRCODE='22023';
    END IF;
    FOR j IN SELECT * FROM jsonb_array_elements(p_inventory) ORDER BY value->>'branch_id' LOOP
      b := (j->>'branch_id')::uuid; q := (j->>'quantity')::integer;
      IF q IS NULL OR q::numeric<>(j->>'quantity')::numeric OR q<0 OR NOT EXISTS(SELECT 1 FROM public.branches WHERE id=b AND store_id=p.store_id) THEN
        RAISE EXCEPTION 'Invalid branch allocation' USING ERRCODE='22023';
      END IF;
      SELECT * INTO i FROM public.product_inventory WHERE product_id=p_id AND branch_id=b;
      IF FOUND THEN
        a:=i.available_quantity+q-i.quantity;
        IF i.available_quantity NOT BETWEEN 0 AND i.quantity OR a NOT BETWEEN 0 AND q THEN
          RAISE EXCEPTION 'Branch quantity cannot discard unavailable stock; reconcile inconsistent counts first' USING ERRCODE='22023';
        END IF;
        UPDATE public.product_inventory SET quantity=q,available_quantity=a,
          low_stock_threshold=coalesce((p_patch->>'low_stock_threshold')::integer,low_stock_threshold) WHERE id=i.id;
      ELSE
        -- A first branch allocation must account for rentals already dispatched
        -- while this product was using only its global counter.
        SELECT q-coalesce(sum(oi.quantity-coalesce(oi.returned_quantity,0)),0)::integer INTO a
          FROM public.order_items oi JOIN public.orders o ON o.id=oi.order_id
          WHERE oi.product_id=p_id AND o.branch_id=b AND o.status IN ('ongoing','in_use','partial','flagged');
        IF a NOT BETWEEN 0 AND q THEN RAISE EXCEPTION 'Branch quantity is below outstanding rentals' USING ERRCODE='22023'; END IF;
        INSERT INTO public.product_inventory(product_id,branch_id,quantity,available_quantity,low_stock_threshold)
          VALUES(p_id,b,q,a,coalesce((p_patch->>'low_stock_threshold')::integer,p.low_stock_threshold,5));
      END IF;
    END LOOP;
  END IF;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_order_stock_safe(p_id uuid,p_patch jsonb,p_items jsonb DEFAULT NULL,p_staff uuid DEFAULT NULL)
RETURNS jsonb LANGUAGE plpgsql SECURITY INVOKER SET search_path=public AS $$
DECLARE o public.orders%ROWTYPE; oi public.order_items%ROWTYPE; j jsonb; before_items jsonb;
  s text; assignments text; result jsonb; delta record; q integer;
  allowed text[] := ARRAY['customer_id','start_date','end_date','event_date','pickup_time','return_time','event_type','event_location',
    'status','subtotal','discount','discount_type','gst_amount','total_amount','advance_amount','advance_payment_method',
    'payment_status','amount_paid','advance_collected','advance_collected_at','notes','delivery_method','delivery_address','pickup_address','pickup_branch_id','return_branch_id',
    'late_fee','damage_charges_total','has_priority_cleaning','has_stock_conflict','conflict_details','updated_by','updated_at_branch_id'];
BEGIN
  SELECT * INTO o FROM public.orders WHERE id=p_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Order not found' USING ERRCODE='P0002'; END IF;
  PERFORM public.check_stock_order_actor(o,p_staff);
  IF p_staff IS NOT NULL THEN p_patch:=p_patch||jsonb_build_object('updated_by',p_staff); END IF;
  s:=coalesce(p_patch->>'status',o.status);
  IF s='cancelled' AND o.status<>'cancelled' THEN RAISE EXCEPTION 'Use the guarded cancellation action' USING ERRCODE='22023'; END IF;
  IF s<>o.status AND NOT (
    (o.status='pending' AND s IN ('scheduled','returned')) OR
    (o.status='confirmed' AND s IN ('delivered','ongoing','returned')) OR
    (o.status='scheduled' AND s IN ('delivered','ongoing','returned')) OR
    (o.status='delivered' AND s IN ('in_use','ongoing')) OR
    (o.status IN ('ongoing','in_use') AND s IN ('returned','partial','flagged')) OR
    (o.status IN ('partial','flagged') AND s IN ('returned','completed','partial','flagged')) OR
    (o.status='returned' AND s='completed')) THEN
    RAISE EXCEPTION 'Invalid or stale order status transition' USING ERRCODE='P0001';
  END IF;
  PERFORM id FROM public.order_items WHERE order_id=p_id ORDER BY id FOR UPDATE;
  SELECT coalesce(jsonb_agg(to_jsonb(t)),'[]') INTO before_items FROM public.order_items t WHERE order_id=p_id;
  IF p_items IS NOT NULL AND jsonb_typeof(p_items)<>'array' THEN RAISE EXCEPTION 'Items must be an array' USING ERRCODE='22023'; END IF;
  IF p_items IS NOT NULL AND jsonb_array_length(p_items)>0 THEN
    IF EXISTS(SELECT 1 FROM jsonb_array_elements(p_items) x GROUP BY x->>'product_id' HAVING count(*)>1)
      OR EXISTS(SELECT 1 FROM public.order_items WHERE order_id=p_id GROUP BY product_id HAVING count(*)>1) THEN
      RAISE EXCEPTION 'Duplicate product lines must be reconciled before editing' USING ERRCODE='22023';
    END IF;
    IF o.status IN ('cancelled','completed','returned') THEN RAISE EXCEPTION 'Cannot edit items after finalization' USING ERRCODE='22023'; END IF;
    FOR j IN SELECT * FROM jsonb_array_elements(p_items) LOOP
      q:=(j->>'quantity')::integer;
      IF q IS NULL OR q::numeric<>(j->>'quantity')::numeric OR q<=0 OR NOT EXISTS(SELECT 1 FROM public.products WHERE id=(j->>'product_id')::uuid AND store_id=o.store_id) THEN
        RAISE EXCEPTION 'Invalid item quantity or product store' USING ERRCODE='22023';
      END IF;
      SELECT * INTO oi FROM public.order_items WHERE order_id=p_id AND product_id=(j->>'product_id')::uuid;
      IF FOUND THEN
        IF q<coalesce(oi.returned_quantity,0) THEN RAISE EXCEPTION 'Quantity cannot be below already returned units' USING ERRCODE='22023'; END IF;
        UPDATE public.order_items SET quantity=q,price_per_day=(j->>'price_per_day')::numeric,
          original_price_per_day=(j->>'original_price_per_day')::numeric,discount=coalesce((j->>'discount')::numeric,0),
          discount_type=coalesce(j->>'discount_type','flat'),subtotal=(j->>'subtotal')::numeric,
          gst_percentage=(j->>'gst_percentage')::numeric,base_amount=(j->>'base_amount')::numeric,gst_amount=(j->>'gst_amount')::numeric,
          is_returned=coalesce(returned_quantity,0)>=q WHERE id=oi.id;
      ELSE
        INSERT INTO public.order_items(order_id,product_id,quantity,price_per_day,original_price_per_day,discount,discount_type,subtotal,gst_percentage,base_amount,gst_amount)
          VALUES(p_id,(j->>'product_id')::uuid,q,(j->>'price_per_day')::numeric,(j->>'original_price_per_day')::numeric,
            coalesce((j->>'discount')::numeric,0),coalesce(j->>'discount_type','flat'),(j->>'subtotal')::numeric,
            (j->>'gst_percentage')::numeric,(j->>'base_amount')::numeric,(j->>'gst_amount')::numeric);
      END IF;
    END LOOP;
    IF EXISTS(SELECT 1 FROM public.order_items WHERE order_id=p_id AND returned_quantity>0
      AND product_id NOT IN (SELECT (x->>'product_id')::uuid FROM jsonb_array_elements(p_items) x)) THEN
      RAISE EXCEPTION 'Cannot remove an item with recorded returns' USING ERRCODE='22023';
    END IF;
    DELETE FROM public.order_items WHERE order_id=p_id AND product_id NOT IN (SELECT (x->>'product_id')::uuid FROM jsonb_array_elements(p_items) x);
  END IF;
  IF o.status IN ('ongoing','in_use','partial','flagged') AND s IN ('returned','completed')
     AND EXISTS(SELECT 1 FROM public.order_items WHERE order_id=p_id AND quantity>coalesce(returned_quantity,0)) THEN
    RAISE EXCEPTION 'Process outstanding item returns before completing this rental' USING ERRCODE='22023';
  END IF;
  -- Calculate the physical change once, from locked old/new item quantities.
  FOR delta IN
    WITH old_stock AS (SELECT (x->>'product_id')::uuid product_id,sum((x->>'quantity')::integer-coalesce((x->>'returned_quantity')::integer,0)) qty FROM jsonb_array_elements(before_items) x GROUP BY 1),
    new_stock AS (SELECT product_id,sum(quantity-coalesce(returned_quantity,0)) qty FROM public.order_items WHERE order_id=p_id GROUP BY product_id)
    SELECT coalesce(a.product_id,b.product_id) product_id,
      ((CASE WHEN o.status IN ('ongoing','in_use','partial','flagged') THEN coalesce(a.qty,0) ELSE 0 END)
       -(CASE WHEN s IN ('ongoing','in_use','partial','flagged') THEN coalesce(b.qty,0) ELSE 0 END))::integer amount
      FROM old_stock a FULL JOIN new_stock b USING(product_id) ORDER BY 1
  LOOP
    PERFORM public.change_rental_stock(delta.product_id,o.branch_id,o.store_id,delta.amount);
  END LOOP;
  SELECT string_agg(format('%I=(jsonb_populate_record(NULL::public.orders,$1)).%I',key,key),',') INTO assignments
    FROM jsonb_object_keys(p_patch) key WHERE key=ANY(allowed);
  IF assignments IS NULL THEN RETURN to_jsonb(o); END IF;
  EXECUTE 'UPDATE public.orders SET '||assignments||',updated_at=now() WHERE id=$2 RETURNING to_jsonb(orders.*)'
    INTO result USING p_patch,p_id;
  IF s<>o.status THEN INSERT INTO public.order_status_history(order_id,status,changed_by) VALUES(p_id,s,p_staff); END IF;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION public.return_order_stock_safe(p_id uuid,p_data jsonb,p_staff uuid DEFAULT NULL)
RETURNS jsonb LANGUAGE plpgsql SECURITY INVOKER SET search_path=public AS $$
DECLARE o public.orders%ROWTYPE; i public.order_items%ROWTYPE; j jsonb; delta record;
  q integer; damage numeric; damaged integer; prior_damage numeric; total_damage numeric; late numeric; extra_discount numeric;
  total numeric; final_status text; progressed boolean:=false; changed boolean:=false;
BEGIN
  SELECT * INTO o FROM public.orders WHERE id=p_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Order not found' USING ERRCODE='P0002'; END IF;
  PERFORM public.check_stock_order_actor(o,p_staff);
  IF jsonb_typeof(p_data->'items') IS DISTINCT FROM 'array' OR jsonb_array_length(p_data->'items')=0 THEN
    RAISE EXCEPTION 'Return items are required' USING ERRCODE='22023';
  END IF;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(p_data->'items') x GROUP BY x->>'item_id' HAVING count(*)>1) THEN
    RAISE EXCEPTION 'Duplicate return items are not allowed' USING ERRCODE='22023';
  END IF;
  PERFORM id FROM public.order_items WHERE order_id=p_id ORDER BY id FOR UPDATE;
  SELECT coalesce(sum(damage_charges),0) INTO prior_damage FROM public.order_items WHERE order_id=p_id;
  late:=coalesce((p_data->>'late_fee')::numeric,o.late_fee,0); extra_discount:=coalesce((p_data->>'discount')::numeric,0);
  IF late<0 OR extra_discount<0 OR late::text IN ('NaN','Infinity','-Infinity') OR extra_discount::text IN ('NaN','Infinity','-Infinity') THEN
    RAISE EXCEPTION 'Invalid return charges' USING ERRCODE='22023';
  END IF;
  FOR j IN SELECT * FROM jsonb_array_elements(p_data->'items') LOOP
    SELECT * INTO i FROM public.order_items WHERE id=(j->>'item_id')::uuid AND order_id=p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Return item does not belong to this order' USING ERRCODE='22023'; END IF;
    q:=(j->>'returned_quantity')::integer; damage:=coalesce((j->>'damage_charges')::numeric,0); damaged:=coalesce((j->>'damaged_quantity')::integer,0);
    IF q IS NULL OR q::numeric<>(j->>'returned_quantity')::numeric OR q<coalesce(i.returned_quantity,0) OR q>i.quantity OR q<0 OR damage<0 OR damaged<0 OR damaged>q
      OR damage::text IN ('NaN','Infinity','-Infinity')
      OR coalesce(j->>'condition_rating','') NOT IN ('excellent','good','fair','damaged') THEN
      RAISE EXCEPTION 'Invalid return: quantities must be cumulative, within the rented quantity, and never go backwards' USING ERRCODE='22023';
    END IF;
    progressed:=progressed OR q>coalesce(i.returned_quantity,0);
    changed:=changed OR q<>coalesce(i.returned_quantity,0) OR j->>'condition_rating' IS DISTINCT FROM i.condition_rating
      OR greatest(damage,coalesce(i.damage_charges,0))<>coalesce(i.damage_charges,0)
      OR greatest(damaged,coalesce(i.damaged_quantity,0))<>coalesce(i.damaged_quantity,0);
  END LOOP;
  -- Same cumulative return is a retry, including an additional discount that
  -- already committed. Do not apply stock, fees or history a second time.
  IF NOT changed AND late=coalesce(o.late_fee,0) THEN RETURN to_jsonb(o); END IF;
  IF o.status NOT IN ('ongoing','in_use','partial','flagged') THEN RAISE EXCEPTION 'Order cannot accept returns in this status' USING ERRCODE='P0001'; END IF;
  IF NOT progressed AND extra_discount>0 THEN RAISE EXCEPTION 'Use the order discount action when no new items are returned' USING ERRCODE='22023'; END IF;
  FOR delta IN SELECT oi.product_id,sum((x->>'returned_quantity')::integer-coalesce(oi.returned_quantity,0))::integer amount
    FROM jsonb_array_elements(p_data->'items') x JOIN public.order_items oi ON oi.id=(x->>'item_id')::uuid AND oi.order_id=p_id
    GROUP BY oi.product_id ORDER BY oi.product_id LOOP
    PERFORM public.change_rental_stock(delta.product_id,o.branch_id,o.store_id,delta.amount);
  END LOOP;
  FOR j IN SELECT * FROM jsonb_array_elements(p_data->'items') LOOP
    UPDATE public.order_items SET returned_quantity=(j->>'returned_quantity')::integer,
      is_returned=(j->>'returned_quantity')::integer>=quantity,returned_at=now(),condition_rating=j->>'condition_rating',
      damage_description=nullif(j->>'damage_description',''),
      damage_charges=greatest(coalesce((j->>'damage_charges')::numeric,0),coalesce(damage_charges,0)),
      damaged_quantity=greatest(coalesce((j->>'damaged_quantity')::integer,0),coalesce(damaged_quantity,0))
      WHERE id=(j->>'item_id')::uuid AND order_id=p_id;
  END LOOP;
  SELECT round(greatest(0,coalesce(o.damage_charges_total,0)-prior_damage)+coalesce(sum(damage_charges),0),2),
    CASE WHEN bool_or(condition_rating='damaged') THEN 'flagged'
      WHEN bool_or(coalesce(returned_quantity,0)<quantity) THEN 'partial' ELSE 'returned' END
    INTO total_damage,final_status FROM public.order_items WHERE order_id=p_id;
  total:=round(greatest(0,o.total_amount-coalesce(o.damage_charges_total,0)-coalesce(o.late_fee,0)+late+total_damage-extra_discount),2);
  UPDATE public.orders SET status=final_status,total_amount=total,late_fee=late,discount=round(coalesce(o.discount,0)+extra_discount,2),
    damage_charges_total=total_damage,payment_status=CASE WHEN o.payment_status='refund_waived' THEN 'refund_waived'
      WHEN coalesce(o.amount_paid,0)>=total THEN 'paid' WHEN coalesce(o.amount_paid,0)>0 THEN 'partial' ELSE 'pending' END,
    has_stock_conflict=false,conflict_details='[]',updated_at=now(),updated_by=coalesce(p_staff,updated_by)
    WHERE id=p_id RETURNING * INTO o;
  INSERT INTO public.order_status_history(order_id,status,notes,changed_by) VALUES(p_id,final_status,p_data->>'notes',p_staff);
  RETURN to_jsonb(o);
END;
$$;

CREATE OR REPLACE FUNCTION public.delete_order_stock_safe(p_id uuid,p_staff uuid DEFAULT NULL)
RETURNS void LANGUAGE plpgsql SECURITY INVOKER SET search_path=public AS $$
DECLARE o public.orders%ROWTYPE; delta record;
BEGIN
  SELECT * INTO o FROM public.orders WHERE id=p_id FOR UPDATE;
  IF NOT FOUND THEN RETURN; END IF;
  PERFORM public.check_stock_order_actor(o,p_staff);
  PERFORM id FROM public.order_items WHERE order_id=p_id ORDER BY id FOR UPDATE;
  IF o.status IN ('ongoing','in_use','partial','flagged') THEN
    FOR delta IN SELECT product_id,sum(quantity-coalesce(returned_quantity,0))::integer amount
      FROM public.order_items WHERE order_id=p_id GROUP BY product_id ORDER BY product_id LOOP
      PERFORM public.change_rental_stock(delta.product_id,o.branch_id,o.store_id,delta.amount);
    END LOOP;
  END IF;
  DELETE FROM public.cleaning_records WHERE order_id=p_id AND status='scheduled';
  DELETE FROM public.orders WHERE id=p_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_branch_inventory_stock_safe(p_id uuid,p_patch jsonb DEFAULT '{}',p_adjustment integer DEFAULT NULL)
RETURNS jsonb LANGUAGE plpgsql SECURITY INVOKER SET search_path=public AS $$
DECLARE i public.product_inventory%ROWTYPE; q integer; a integer;
BEGIN
  SELECT * INTO i FROM public.product_inventory WHERE id=p_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Inventory not found' USING ERRCODE='P0002'; END IF;
  PERFORM id FROM public.products WHERE id=i.product_id FOR UPDATE;
  SELECT * INTO i FROM public.product_inventory WHERE id=p_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Inventory not found' USING ERRCODE='P0002'; END IF;
  q:=CASE WHEN p_adjustment IS NULL THEN coalesce((p_patch->>'quantity')::integer,i.quantity) ELSE i.quantity+p_adjustment END;
  a:=i.available_quantity+q-i.quantity;
  IF i.available_quantity NOT BETWEEN 0 AND i.quantity OR q<0 OR a NOT BETWEEN 0 AND q THEN
    RAISE EXCEPTION 'Branch stock needs reconciliation or the new total is below unavailable units' USING ERRCODE='22023';
  END IF;
  IF p_patch ? 'is_active' THEN
    -- Preserve the existing endpoint's optional metadata update on deployments
    -- with that column; a missing column must fail rather than silently succeed.
    EXECUTE 'UPDATE public.product_inventory SET is_active=($1->>''is_active'')::boolean WHERE id=$2' USING p_patch,p_id;
  END IF;
  UPDATE public.product_inventory SET quantity=q,available_quantity=a,
    low_stock_threshold=coalesce((p_patch->>'low_stock_threshold')::integer,low_stock_threshold),updated_at=now()
    WHERE id=p_id RETURNING * INTO i;
  RETURN to_jsonb(i);
END;
$$;

REVOKE ALL ON FUNCTION public.change_rental_stock(uuid,uuid,uuid,integer) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.change_rental_stock(uuid,uuid,uuid,integer) TO service_role;
REVOKE ALL ON FUNCTION public.check_stock_order_actor(public.orders,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.check_stock_order_actor(public.orders,uuid) TO service_role;
REVOKE ALL ON FUNCTION public.update_product_stock_safe(uuid,jsonb,jsonb,uuid[]) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.update_product_stock_safe(uuid,jsonb,jsonb,uuid[]) TO service_role;
REVOKE ALL ON FUNCTION public.update_order_stock_safe(uuid,jsonb,jsonb,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.update_order_stock_safe(uuid,jsonb,jsonb,uuid) TO service_role;
REVOKE ALL ON FUNCTION public.return_order_stock_safe(uuid,jsonb,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.return_order_stock_safe(uuid,jsonb,uuid) TO service_role;
REVOKE ALL ON FUNCTION public.delete_order_stock_safe(uuid,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.delete_order_stock_safe(uuid,uuid) TO service_role;
REVOKE ALL ON FUNCTION public.update_branch_inventory_stock_safe(uuid,jsonb,integer) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.update_branch_inventory_stock_safe(uuid,jsonb,integer) TO service_role;
COMMIT;
