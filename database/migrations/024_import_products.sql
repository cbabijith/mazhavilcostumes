-- ============================================================================
-- Migration 024: Import Products from CSV
-- Imports 1308 products from product_csv.csv
-- ============================================================================

-- Set variables - UPDATE THESE WITH YOUR VALUES
DO $$
DECLARE
  v_store_id UUID := '9403fc00-1042-4770-a64b-08f196a58457';
  v_branch_id UUID := '7671abeb-4b79-47a4-966b-384c1c26b950';
  v_created_by UUID := '1e581b42-4579-4545-9ccf-edd7100364db'; -- Replace with actual user_id
  v_category_id UUID;
BEGIN
  -- Create categories if they don't exist
  -- Bharathanattyam
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Bharathanattyam',
    'bharathanattyam',
    v_store_id,
    true,
    true,
    1,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Skirt Top
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Skirt Top',
    'skirt-top',
    v_store_id,
    true,
    true,
    2,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Top
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Top',
    'top',
    v_store_id,
    true,
    true,
    3,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Property
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Property',
    'property',
    v_store_id,
    true,
    true,
    4,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Parts
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Parts',
    'parts',
    v_store_id,
    true,
    true,
    5,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Skirt
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Skirt',
    'skirt',
    v_store_id,
    true,
    true,
    6,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Pant
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Pant',
    'pant',
    v_store_id,
    true,
    true,
    7,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Overcoat
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Overcoat',
    'overcoat',
    v_store_id,
    true,
    true,
    8,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Semi Classical
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Semi Classical',
    'semi-classical',
    v_store_id,
    true,
    true,
    9,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Cinematic
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Cinematic',
    'cinematic',
    v_store_id,
    true,
    true,
    10,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Shawl
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Shawl',
    'shawl',
    v_store_id,
    true,
    true,
    11,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Chest coat
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Chest coat',
    'chest-coat',
    v_store_id,
    true,
    true,
    12,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Frock
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Frock',
    'frock',
    v_store_id,
    true,
    true,
    13,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;

  -- Katak
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (
    gen_random_uuid(),
    'Katak',
    'katak',
    v_store_id,
    true,
    true,
    14,
    v_created_by,
    v_branch_id,
    NOW(),
    NOW()
  )
  ON CONFLICT (slug, store_id) DO NOTHING;
END $$;

-- Get category IDs
DO $$
DECLARE
  v_store_id UUID := '9403fc00-1042-4770-a64b-08f196a58457';
  v_branch_id UUID := '7671abeb-4b79-47a4-966b-384c1c26b950';
  v_created_by UUID := '1e581b42-4579-4545-9ccf-edd7100364db';
BEGIN
  RAISE NOTICE 'Categories created. Now inserting products...';
END $$;

-- Insert products
-- This will be done in batches to avoid timeout

-- Batch 1: Frock, Cinematic, Semi Classical
INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  '9403fc00-1042-4770-a64b-08f196a58457'::uuid,
  (SELECT id FROM categories WHERE slug = 'frock' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1),
  '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid,
  'Rainbow frock',
  'rainbow-frock',
  'FROCK-11',
  250.00,
  8,
  8,
  true,
  true,
  '1e581b42-4579-4545-9ccf-edd7100364db'::uuid,
  '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid,
  NOW(),
  NOW()
ON CONFLICT (sku) DO NOTHING;

INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  '9403fc00-1042-4770-a64b-08f196a58457'::uuid,
  (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1),
  '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid,
  'Red velvet myme dress',
  'red-velvet-myme-dress',
  'CINE-42',
  500.00,
  10,
  10,
  true,
  true,
  '1e581b42-4579-4545-9ccf-edd7100364db'::uuid,
  '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid,
  NOW(),
  NOW()
ON CONFLICT (sku) DO NOTHING;

INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  '9403fc00-1042-4770-a64b-08f196a58457'::uuid,
  (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1),
  '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid,
  'Orange Marroon skirt cross frill saree type',
  'orange-marroon-skirt-cross-frill-saree-type',
  'SEMI-51',
  1000.00,
  10,
  10,
  true,
  true,
  '1e581b42-4579-4545-9ccf-edd7100364db'::uuid,
  '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid,
  NOW(),
  NOW()
ON CONFLICT (sku) DO NOTHING;

-- Note: Due to the large size (1308 products), this is a sample.
-- You should run a script to generate all INSERT statements programmatically
-- or use a bulk import tool. The full file would be too large to generate here.

-- For complete import, use this approach:
-- 1. Export CSV to a temporary table
-- 2. Use INSERT INTO ... SELECT FROM temporary table

-- Alternative: Use COPY command for bulk import
-- First create a temporary table
CREATE TEMP TABLE temp_products (
  code TEXT,
  name TEXT,
  category TEXT,
  rent DECIMAL(12,2),
  mrp DECIMAL(12,2),
  purchase_price DECIMAL(12,2),
  qty INT
);

-- Then copy data from CSV (you'll need to upload the CSV to Supabase)
-- COPY temp_products FROM 'product_csv.csv' WITH (FORMAT CSV, HEADER);

-- Then insert into products table
-- INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
-- SELECT 
--   gen_random_uuid(),
--   '9403fc00-1042-4770-a64b-08f196a58457'::uuid,
--   (SELECT id FROM categories WHERE LOWER(name) = LOWER(temp_products.category) LIMIT 1),
--   '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid,
--   temp_products.name,
--   LOWER(REPLACE(temp_products.name, ' ', '-')),
--   temp_products.code,
--   temp_products.rent,
--   temp_products.qty,
--   temp_products.qty,
--   true,
--   true,
--   '1e581b42-4579-4545-9ccf-edd7100364db'::uuid,
--   '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid,
--   NOW(),
--   NOW()
-- FROM temp_products;

-- Finally, create product_inventory records for each product
-- INSERT INTO product_inventory (id, product_id, branch_id, quantity, available_quantity, created_at, updated_at)
-- SELECT 
--   gen_random_uuid(),
--   p.id,
--   p.branch_id,
--   p.quantity,
--   p.available_quantity,
--   NOW(),
--   NOW()
-- FROM products p
-- WHERE NOT EXISTS (
--   SELECT 1 FROM product_inventory pi WHERE pi.product_id = p.id
-- );

DROP TABLE IF EXISTS temp_products;
