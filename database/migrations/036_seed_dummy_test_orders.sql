-- ============================================================
-- Migration: Seed 20+ Dummy Test Orders for Testing
-- Creates 1 Test Customer and 21 Orders representing various real-world scenarios.
-- Run this script in the Supabase SQL editor to seed your DB for testing.
-- To clean up afterwards, run:
-- DELETE FROM public.customers WHERE name = 'TEST DUMMY CUSTOMER';
-- ============================================================

DO $$
DECLARE
    v_store_id UUID;
    v_branch_id UUID;
    v_customer_id UUID;
    v_product_1 UUID;
    v_product_2 UUID;
    v_product_3 UUID;
    v_order_id UUID;
    i INT;
    v_status VARCHAR;
    v_payment_status VARCHAR;
    v_start_date DATE;
    v_end_date DATE;
    v_total_amount DECIMAL(10,2);
    v_amount_paid DECIMAL(10,2);
BEGIN
    -- 1. Fetch real store, branch, and active product IDs from your DB to avoid FK constraint errors
    SELECT id INTO v_store_id FROM public.stores LIMIT 1;
    SELECT id INTO v_branch_id FROM public.branches WHERE store_id = v_store_id LIMIT 1;
    
    -- Get 3 distinct active products
    SELECT id INTO v_product_1 FROM public.products WHERE is_active = true LIMIT 1;
    SELECT id INTO v_product_2 FROM public.products WHERE is_active = true AND id != v_product_1 LIMIT 1;
    SELECT id INTO v_product_3 FROM public.products WHERE is_active = true AND id NOT IN (v_product_1, v_product_2) LIMIT 1;
    
    -- Fallbacks in case multiple products aren't available
    IF v_product_2 IS NULL THEN v_product_2 := v_product_1; END IF;
    IF v_product_3 IS NULL THEN v_product_3 := v_product_1; END IF;

    IF v_store_id IS NULL OR v_branch_id IS NULL OR v_product_1 IS NULL THEN
        RAISE EXCEPTION 'Database pre-requisites missing. Please verify you have at least one store, branch, and active product.';
    END IF;

    -- 2. Create the dummy customer (ON CONFLICT phone resolves duplicates if run multiple times)
    INSERT INTO public.customers (name, phone, email, address)
    VALUES ('TEST DUMMY CUSTOMER', '0000000000', 'test_dummy@example.com', '123 Test Street')
    ON CONFLICT (phone) DO UPDATE 
    SET name = EXCLUDED.name
    RETURNING id INTO v_customer_id;

    -- 3. Create 21 orders across different scenarios (Pending, Ongoing, Overdue, Cancelled, Returned, Completed)
    FOR i IN 1..21 LOOP
        v_order_id := uuid_generate_v4();
        
        -- Scenario Distribution (cycle through 7 states to generate 3 orders per state)
        CASE (i % 7)
            WHEN 0 THEN -- Scenario A: Future Scheduled Order
                v_status := 'scheduled';
                v_payment_status := 'pending';
                v_start_date := CURRENT_DATE + (i * 2);
                v_end_date := v_start_date + 3;
                v_total_amount := 1500.00;
                v_amount_paid := 0.00;
            WHEN 1 THEN -- Scenario B: Completed Past Order
                v_status := 'completed';
                v_payment_status := 'paid';
                v_start_date := CURRENT_DATE - (i * 3) - 5;
                v_end_date := v_start_date + 4;
                v_total_amount := 2400.00;
                v_amount_paid := 2400.00;
            WHEN 2 THEN -- Scenario C: Ongoing Active Order (currently inside the rental window)
                v_status := 'ongoing';
                v_payment_status := 'partial';
                v_start_date := CURRENT_DATE - 1;
                v_end_date := CURRENT_DATE + 2;
                v_total_amount := 1800.00;
                v_amount_paid := 800.00;
            WHEN 3 THEN -- Scenario D: Overdue/Late Order (ended in the past but still marked ongoing)
                v_status := 'ongoing';
                v_payment_status := 'pending';
                v_start_date := CURRENT_DATE - 10;
                v_end_date := CURRENT_DATE - 3;
                v_total_amount := 1200.00;
                v_amount_paid := 0.00;
            WHEN 4 THEN -- Scenario E: Returned Order with partial payment settled
                v_status := 'returned';
                v_payment_status := 'partial';
                v_start_date := CURRENT_DATE - 8;
                v_end_date := CURRENT_DATE - 4;
                v_total_amount := 3000.00;
                v_amount_paid := 1500.00;
            WHEN 5 THEN -- Scenario F: Flagged Order (returned with damage assessments)
                v_status := 'flagged';
                v_payment_status := 'pending';
                v_start_date := CURRENT_DATE - 5;
                v_end_date := CURRENT_DATE - 1;
                v_total_amount := 1600.00;
                v_amount_paid := 0.00;
            WHEN 6 THEN -- Scenario G: Cancelled Order
                v_status := 'cancelled';
                v_payment_status := 'pending';
                v_start_date := CURRENT_DATE + 12;
                v_end_date := v_start_date + 2;
                v_total_amount := 900.00;
                v_amount_paid := 0.00;
        END CASE;

        -- Insert Order header (security_deposit removed)
        INSERT INTO public.orders (
            id, store_id, branch_id, customer_id, status, 
            start_date, end_date, subtotal, total_amount, amount_paid, 
            payment_status, notes
        ) VALUES (
            v_order_id, v_store_id, v_branch_id, v_customer_id, v_status,
            v_start_date, v_end_date, v_total_amount, v_total_amount, v_amount_paid,
            v_payment_status, '[DUMMY_TEST] ' || UPPER(v_status) || ' Scenario Order #' || i
        );

        -- Insert Order Item (rotate between products 1, 2, and 3)
        INSERT INTO public.order_items (
            order_id, product_id, quantity, price_per_day, subtotal
        ) VALUES (
            v_order_id, 
            CASE (i % 3)
                WHEN 0 THEN v_product_1
                WHEN 1 THEN v_product_2
                ELSE v_product_3
            END,
            1, 
            v_total_amount / 3.00, 
            v_total_amount
        );

        -- If the scenario status is returned or completed, mark items returned in full
        IF v_status IN ('completed', 'returned') THEN
            UPDATE public.order_items 
            SET is_returned = true, returned_quantity = quantity, returned_at = (v_end_date::timestamp)
            WHERE order_id = v_order_id;
        END IF;

    END LOOP;
END $$;
