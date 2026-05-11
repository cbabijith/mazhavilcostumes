-- ============================================================================
-- Migration 015: Add damaged_quantity to order_items
-- Tracks how many units were marked as damaged during return processing.
-- This allows the damage assessment system to create the correct number
-- of assessment rows (only for damaged units, not all returned units).
-- ============================================================================

ALTER TABLE order_items ADD COLUMN IF NOT EXISTS damaged_quantity INTEGER DEFAULT 0;
