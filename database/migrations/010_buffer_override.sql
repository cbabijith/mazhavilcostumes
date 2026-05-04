-- Migration: Buffer Override for Orders
-- Adds buffer_override column to orders table.
-- When true, the order's availability check skips the ±1 day buffer window,
-- allowing booking on buffer days (but NEVER on actual rental days).

ALTER TABLE orders ADD COLUMN IF NOT EXISTS buffer_override BOOLEAN DEFAULT FALSE;
