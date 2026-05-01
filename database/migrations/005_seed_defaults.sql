-- ============================================================================
-- Migration 005: Default Settings
-- Seeds default configuration values for the store.
-- Run AFTER 003_seed_store.sql.
-- ============================================================================

-- GST percentage (18% default for India)
INSERT INTO settings (store_id, key, value)
SELECT id, 'gst_percentage', '18.00'
FROM stores WHERE slug = 'mazhavil-costumes'
ON CONFLICT (store_id, key) DO NOTHING;

-- Invoice prefix
INSERT INTO settings (store_id, key, value)
SELECT id, 'invoice_prefix', 'INV-'
FROM stores WHERE slug = 'mazhavil-costumes'
ON CONFLICT (store_id, key) DO NOTHING;

-- Payment terms (displayed on invoices)
INSERT INTO settings (store_id, key, value)
SELECT id, 'payment_terms', 'Payment must be made before or at the time of delivery. Security deposit is refundable upon return of items in good condition.'
FROM stores WHERE slug = 'mazhavil-costumes'
ON CONFLICT (store_id, key) DO NOTHING;

-- Authorized signature label (displayed on invoices)
INSERT INTO settings (store_id, key, value)
SELECT id, 'authorized_signature', 'Authorized Signatory'
FROM stores WHERE slug = 'mazhavil-costumes'
ON CONFLICT (store_id, key) DO NOTHING;
