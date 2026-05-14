-- ============================================================
-- Migration: Add stock conflict flag to orders
--
-- 1. has_stock_conflict on orders — flags orders when total
--    inventory becomes insufficient due to damage/write-offs.
-- 2. conflict_details on orders — stores JSON info about the
--    conflicting products.
-- ============================================================

-- 1. Add columns to orders
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS has_stock_conflict BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS conflict_details JSONB DEFAULT '[]'::jsonb;

-- 2. Add index for faster filtering of conflict orders
CREATE INDEX IF NOT EXISTS idx_orders_stock_conflict ON orders(has_stock_conflict) WHERE has_stock_conflict = true;

-- 3. Comments
COMMENT ON COLUMN orders.has_stock_conflict IS
  'True when total product inventory (minus other reservations) is insufficient for this order';
COMMENT ON COLUMN orders.conflict_details IS
  'JSON array of conflicting products: [{productId, productName, requested, available}]';
