-- ============================================================================
-- Migration 020: Convert Late Status to Flag
-- Converts 'late_return' status to an 'is_late' boolean flag
-- ============================================================================

-- Step 1: Add is_late column to orders table
ALTER TABLE orders ADD COLUMN IF NOT EXISTS is_late BOOLEAN DEFAULT FALSE;

-- Step 2: Create function to automatically calculate late flag
CREATE OR REPLACE FUNCTION calculate_late_flag()
RETURNS TRIGGER AS $$
BEGIN
  -- Order is late if:
  -- 1. end_date is in the past
  -- 2. Status is one of: ongoing, in_use, delivered
  NEW.is_late := (
    (NEW.end_date IS NOT NULL) AND
    (NEW.end_date < CURRENT_DATE) AND
    (NEW.status IN ('ongoing', 'in_use', 'delivered'))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Create trigger to auto-update is_late on insert/update
DROP TRIGGER IF EXISTS trigger_update_late_flag ON orders;
CREATE TRIGGER trigger_update_late_flag
BEFORE INSERT OR UPDATE OF end_date, status ON orders
FOR EACH ROW EXECUTE FUNCTION calculate_late_flag();

-- Step 4: Migrate existing late_return orders to ongoing + is_late=true
UPDATE orders
SET status = 'ongoing',
    is_late = TRUE
WHERE status = 'late_return';

-- Step 5: Add index on is_late for better query performance
CREATE INDEX IF NOT EXISTS idx_orders_is_late ON orders(is_late) WHERE is_late = TRUE;

-- Step 6: Add comment to document the change
COMMENT ON COLUMN orders.is_late IS 'Flag indicating if the order is late (end_date < current_date and status is ongoing/in_use/delivered)';
