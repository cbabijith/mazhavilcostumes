-- Migration: Add original_price_per_day to order_items
-- Purpose: Track the product's actual price at order creation time,
--          so staff can override price_per_day upward per order without
--          losing the ability to validate against the original price.

ALTER TABLE order_items
ADD COLUMN IF NOT EXISTS original_price_per_day numeric(10,2) DEFAULT NULL;
