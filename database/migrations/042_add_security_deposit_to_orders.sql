-- Migration 042: Add Security Deposit Columns to Orders Table
-- Adds columns for security deposit tracking to the orders table.

ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS security_deposit NUMERIC DEFAULT 0;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS deposit_collected BOOLEAN DEFAULT FALSE;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS deposit_payment_method VARCHAR(20);
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS deposit_collected_at TIMESTAMPTZ;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS deposit_returned BOOLEAN DEFAULT FALSE;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS deposit_returned_at TIMESTAMPTZ;
