-- ============================================================
-- Migration: Add priority cleaning flag to orders + store_id to cleaning_records
--
-- 1. has_priority_cleaning on orders — flags Order A when Order B
--    triggers priority cleaning on its products.
-- 2. store_id on cleaning_records — ensures data consistency
--    (every cleaning record is tied to a store).
-- ============================================================

-- 1. Add has_priority_cleaning flag to orders
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS has_priority_cleaning BOOLEAN DEFAULT false;

-- 2. Add store_id to cleaning_records for data consistency
ALTER TABLE cleaning_records
  ADD COLUMN IF NOT EXISTS store_id UUID REFERENCES stores(id) ON DELETE CASCADE;

-- 3. Comments
COMMENT ON COLUMN orders.has_priority_cleaning IS
  'True when another order triggered priority cleaning for this order''s returned products';
COMMENT ON COLUMN cleaning_records.store_id IS
  'Store this cleaning record belongs to — mirrors the order''s store_id for consistency';
