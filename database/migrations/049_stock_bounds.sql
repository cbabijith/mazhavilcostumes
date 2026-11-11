-- Apply AFTER deploying the API that uses the atomic stock functions in 048.
-- No row changes: legacy mismatches remain visible for reviewed reconciliation.
BEGIN;
-- NOT VALID intentionally preserves legacy rows for reviewed reconciliation.
-- PostgreSQL still enforces these bounds for every new or updated row.
DO $$ BEGIN
  IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conrelid='public.products'::regclass AND conname='products_stock_bounds') THEN
    ALTER TABLE public.products ADD CONSTRAINT products_stock_bounds CHECK(quantity>=0 AND available_quantity BETWEEN 0 AND quantity) NOT VALID;
  END IF;
  IF NOT EXISTS(SELECT 1 FROM pg_constraint WHERE conrelid='public.product_inventory'::regclass AND conname='inventory_stock_bounds') THEN
    ALTER TABLE public.product_inventory ADD CONSTRAINT inventory_stock_bounds CHECK(quantity>=0 AND available_quantity BETWEEN 0 AND quantity) NOT VALID;
  END IF;
END $$;
COMMIT;
