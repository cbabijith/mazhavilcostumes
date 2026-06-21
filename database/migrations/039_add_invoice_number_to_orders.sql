-- Migration: Add invoice_number column to orders table
-- Purpose: Store a human-readable, sequential invoice number per order
--          (e.g., MAZ-2526-0042) generated at creation time.
--          Replaces the practice of showing UUID fragments (first 6-8 chars).

ALTER TABLE orders
ADD COLUMN IF NOT EXISTS invoice_number text;

-- Create unique index for invoice_number (nullable for existing orders)
CREATE UNIQUE INDEX IF NOT EXISTS orders_invoice_number_unique
ON orders (invoice_number)
WHERE invoice_number IS NOT NULL;

-- Backfill existing orders with sequential invoice numbers based on fiscal year
-- Fiscal year: April 1 – March 31 (e.g., FY 2526 = Apr 2025 – Mar 2026)
DO $$
DECLARE
  order_record RECORD;
  fiscal_start_year int;
  start_yy text;
  end_yy text;
  fiscal_suffix text;
  seq_num int;
  order_date date;
  order_month int;
  order_year int;
BEGIN
  FOR order_record IN
    SELECT id, created_at FROM orders WHERE invoice_number IS NULL ORDER BY created_at ASC
  LOOP
    order_date := (order_record.created_at AT TIME ZONE 'UTC')::date;
    order_month := EXTRACT(MONTH FROM order_date);
    order_year := EXTRACT(YEAR FROM order_date);

    IF order_month < 4 THEN
      fiscal_start_year := order_year - 1;
    ELSE
      fiscal_start_year := order_year;
    END IF;

    start_yy := substring(fiscal_start_year::text from 3 for 2);
    end_yy := substring((fiscal_start_year + 1)::text from 3 for 2);
    fiscal_suffix := start_yy || end_yy;

    -- Count how many orders in the same fiscal year already have an invoice number
    SELECT count(*) + 1 INTO seq_num
    FROM orders
    WHERE invoice_number IS NOT NULL
      AND invoice_number LIKE 'MAZ-' || fiscal_suffix || '-%';

    UPDATE orders
    SET invoice_number = 'MAZ-' || fiscal_suffix || '-' || lpad(seq_num::text, 4, '0')
    WHERE id = order_record.id;
  END LOOP;
END $$;
