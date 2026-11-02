-- Migration: Add trigram indexes for fast storefront product search
-- Purpose: The storefront searches products across name, description, sku,
--          and barcode using ILIKE with leading wildcards (%term%). These
--          queries cannot use B-tree indexes and would sequentially scan the
--          whole products table — which gets slow as the catalog grows.
--          pg_trgm GIN indexes make these ILIKE queries fast.
--
-- The pg_trgm extension is already enabled by migration 040.

-- Trigram index on products.name for fast name ILIKE '%term%'
CREATE INDEX IF NOT EXISTS products_name_trgm_idx
ON products USING gin (name gin_trgm_ops);

-- Trigram index on products.description for fast description ILIKE '%term%'
CREATE INDEX IF NOT EXISTS products_description_trgm_idx
ON products USING gin (description gin_trgm_ops);

-- Trigram index on products.sku for fast SKU ILIKE '%term%'
CREATE INDEX IF NOT EXISTS products_sku_trgm_idx
ON products USING gin (sku gin_trgm_ops);

-- Trigram index on products.barcode for fast barcode ILIKE '%term%'
CREATE INDEX IF NOT EXISTS products_barcode_trgm_idx
ON products USING gin (barcode gin_trgm_ops);
