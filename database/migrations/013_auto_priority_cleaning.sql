-- ============================================================
-- Migration: Automatic Priority Cleaning System
-- Replaces manual buffer_override toggle with auto-detection.
--
-- WHY dynamic SQL for the index?
-- PostgreSQL requires new enum values (added via ALTER TYPE ... ADD VALUE)
-- to be committed before they can be referenced in expressions.
-- Since Supabase runs each SQL file as a single transaction, we use
-- EXECUTE (dynamic SQL) to defer the enum value resolution to runtime,
-- bypassing the compile-time check.
-- ============================================================

-- 1. Clear existing data (development phase — fresh start)
TRUNCATE TABLE cleaning_records CASCADE;
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE order_status_history CASCADE;
TRUNCATE TABLE order_items CASCADE;
TRUNCATE TABLE orders CASCADE;

-- 2. Drop buffer_override column (no longer needed)
ALTER TABLE orders DROP COLUMN IF EXISTS buffer_override;

-- 3. Add 'scheduled' status to cleaning_status enum
-- 'scheduled' = cleaning record created at order time, not yet returned
ALTER TYPE cleaning_status ADD VALUE IF NOT EXISTS 'scheduled' BEFORE 'pending';

-- 4. Add expected_return_date to cleaning_records
ALTER TABLE cleaning_records
  ADD COLUMN IF NOT EXISTS expected_return_date DATE;

-- 5. Index for efficient priority cleaning lookups
-- NOTE: This is a regular index, not a partial index.
-- PostgreSQL cannot use new enum values in partial index predicates within the
-- same transaction they were added (ADD VALUE must be committed first, and
-- index predicates require IMMUTABLE functions — enum casts aren't).
-- A future migration can DROP this and recreate as a partial index for optimization.
CREATE INDEX IF NOT EXISTS idx_cleaning_expected_return
  ON cleaning_records(product_id, expected_return_date);

-- 6. Comments
COMMENT ON COLUMN cleaning_records.expected_return_date IS
  'Date when the returning order ends — cleaning can begin after this date';
COMMENT ON COLUMN cleaning_records.priority_order_id IS
  'The upcoming order that needs this product urgently after cleaning';
