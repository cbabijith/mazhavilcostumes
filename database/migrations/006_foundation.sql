-- ============================================================================
-- Migration 006: Foundation for Phase 1
-- Adds discount permissions, item-level discounts, cancellation tracking,
-- removes security deposit, adds purchase price to products.
-- ============================================================================

-- 1. Staff: discount permission toggles
ALTER TABLE staff ADD COLUMN IF NOT EXISTS can_give_product_discount BOOLEAN DEFAULT false;
ALTER TABLE staff ADD COLUMN IF NOT EXISTS can_give_order_discount BOOLEAN DEFAULT false;

-- 2. Order Items: per-item discount
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS discount DECIMAL(10, 2) DEFAULT 0;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS discount_type VARCHAR(10) DEFAULT 'flat'
    CHECK (discount_type IN ('flat', 'percent'));

-- 3. Orders: order-level discount type + cancellation tracking
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount_type VARCHAR(10) DEFAULT 'flat'
    CHECK (discount_type IN ('flat', 'percent'));
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancelled_by UUID REFERENCES staff(id) ON DELETE SET NULL;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;

-- 4. Orders: DROP security deposit columns
ALTER TABLE orders DROP COLUMN IF EXISTS security_deposit;
ALTER TABLE orders DROP COLUMN IF EXISTS deposit_collected;
ALTER TABLE orders DROP COLUMN IF EXISTS deposit_collected_at;
ALTER TABLE orders DROP COLUMN IF EXISTS deposit_payment_method;
ALTER TABLE orders DROP COLUMN IF EXISTS deposit_returned;
ALTER TABLE orders DROP COLUMN IF EXISTS deposit_returned_at;

-- 5. Drop deposit_returned index (if exists)
DROP INDEX IF EXISTS idx_orders_deposit_returned;

-- 6. Products: DROP security_deposit, ADD purchase_price
ALTER TABLE products DROP COLUMN IF EXISTS security_deposit;
ALTER TABLE products ADD COLUMN IF NOT EXISTS purchase_price DECIMAL(10, 2) DEFAULT 0;

-- 7. Index for cancellation tracking
CREATE INDEX IF NOT EXISTS idx_orders_cancelled_by ON orders(cancelled_by);
CREATE INDEX IF NOT EXISTS idx_orders_cancelled_at ON orders(cancelled_at);
