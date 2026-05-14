-- Migration 017: Fix Payment Modes
-- Updates check constraint to include 'gpay' and 'other' in the payments table.

-- 1. Update payments table check constraint
-- First drop the old constraint
ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_payment_mode_check;

-- Add the new constraint with 'gpay' and 'other'
ALTER TABLE payments ADD CONSTRAINT payments_payment_mode_check 
  CHECK (payment_mode IN ('cash', 'upi', 'gpay', 'card', 'bank_transfer', 'cheque', 'other'));
