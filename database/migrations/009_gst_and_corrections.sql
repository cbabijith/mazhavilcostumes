-- ============================================================================
-- Migration 009: GST & Corrections
-- - Adds gst_percentage to categories (category-level GST)
-- - Adds per-item GST tracking to order_items
-- - Removes staff discount permission columns (all can give discounts now)
-- - Removes gst_percentage setting key (GST rate now on categories)
-- ============================================================================

-- 1. Categories: add GST percentage (default 5%)
ALTER TABLE categories ADD COLUMN IF NOT EXISTS gst_percentage DECIMAL(5,2) DEFAULT 5.00;

-- 2. Order Items: add GST tracking fields
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS gst_percentage DECIMAL(5,2) DEFAULT 0;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS base_amount DECIMAL(10,2) DEFAULT 0;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS gst_amount DECIMAL(10,2) DEFAULT 0;

-- 3. Staff: remove discount permission columns (all staff can now give discounts)
ALTER TABLE staff DROP COLUMN IF EXISTS can_give_product_discount;
ALTER TABLE staff DROP COLUMN IF EXISTS can_give_order_discount;

-- 4. Remove the gst_percentage setting key (GST rate now lives on categories)
-- The is_gst_enabled setting key remains (global toggle)
DELETE FROM settings WHERE key = 'gst_percentage';
