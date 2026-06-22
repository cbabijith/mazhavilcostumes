-- Migration: Add trigram indexes for fast ILIKE search
-- Purpose: Speed up order search by invoice_number and customer name/phone/email
--          ILIKE with leading wildcard (%term%) can't use B-tree indexes.
--          pg_trgm GIN indexes make these queries fast.

-- Enable trigram extension (safe if already enabled)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Trigram index on orders.invoice_number for fast ILIKE '%term%'
CREATE INDEX IF NOT EXISTS orders_invoice_number_trgm_idx
ON orders USING gin (invoice_number gin_trgm_ops);

-- Trigram indexes on customers table for fast name/phone/email ILIKE
CREATE INDEX IF NOT EXISTS customers_name_trgm_idx
ON customers USING gin (name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS customers_phone_trgm_idx
ON customers USING gin (phone gin_trgm_ops);

CREATE INDEX IF NOT EXISTS customers_email_trgm_idx
ON customers USING gin (email gin_trgm_ops);
