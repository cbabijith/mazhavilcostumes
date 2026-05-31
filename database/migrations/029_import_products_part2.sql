-- ============================================================================
-- Migration 029: Import Next 500 Products from CSV (product02csv.csv) - Part 2
-- Purpose:   Inserts categories and the next 500 products (rows 501 to 1000)
--            with correct prices, quantities, and inventory mappings.
-- ============================================================================

DO $$
DECLARE
  v_store_id UUID;
  v_branch_id UUID;
  v_created_by UUID;
BEGIN
  -- Get the store ID
  SELECT id INTO v_store_id FROM public.stores WHERE slug = 'mazhavil-costumes' LIMIT 1;
  
  -- Get the main branch ID
  SELECT id INTO v_branch_id FROM public.branches WHERE store_id = v_store_id AND is_main = true LIMIT 1;
  
  -- Get the super admin creator ID
  SELECT id INTO v_created_by FROM public.staff WHERE role = 'super_admin' LIMIT 1;

  IF v_store_id IS NULL OR v_branch_id IS NULL OR v_created_by IS NULL THEN
    RAISE EXCEPTION 'Failed to find store, main branch, or super admin user. Ensure seed scripts 003 and 004 have been run.';
  END IF;

  -- Create categories if they don't exist

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Bharathanattyam', 'bharathanattyam', v_store_id, true, true, 1, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Chest coat', 'chest-coat', v_store_id, true, true, 2, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Cinematic', 'cinematic', v_store_id, true, true, 3, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Fancy dress', 'fancy-dress', v_store_id, true, true, 4, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Frock', 'frock', v_store_id, true, true, 5, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Katak', 'katak', v_store_id, true, true, 6, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Kerala Nadanam', 'kerala-nadanam', v_store_id, true, true, 7, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Margam Kali', 'margam-kali', v_store_id, true, true, 8, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Mohiniyattam', 'mohiniyattam', v_store_id, true, true, 9, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Oppana', 'oppana', v_store_id, true, true, 10, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Ornaments', 'ornaments', v_store_id, true, true, 11, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Overcoat', 'overcoat', v_store_id, true, true, 12, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Pant', 'pant', v_store_id, true, true, 13, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Parts', 'parts', v_store_id, true, true, 14, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Property', 'property', v_store_id, true, true, 15, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Semi Classical', 'semi-classical', v_store_id, true, true, 16, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Shawl', 'shawl', v_store_id, true, true, 17, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Skirt', 'skirt', v_store_id, true, true, 18, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Skirt Top', 'skirt-top', v_store_id, true, true, 19, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Thiruvathira', 'thiruvathira', v_store_id, true, true, 20, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'Top', 'top', v_store_id, true, true, 21, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;

END $$;

-- ════════════════════════════════════════════════════════════════════════════
-- INSERT NEXT 500 PRODUCTS (501 to 1000)
-- ════════════════════════════════════════════════════════════════════════════

-- Product #501: TAIL-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'TAIL-1',
  'tail-1-hanuman-tail',
  'Hanuman tail',
  'Hanuman tail',
  'TAIL-1',
  80.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'TAIL-1' 
       OR (p.slug = 'tail-1-hanuman-tail' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #502: GUN-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'GUN-1',
  'gun-1-long-gun',
  'Long Gun',
  'Long Gun',
  'GUN-1',
  80.00,
  0.00,
  15,
  15,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'GUN-1' 
       OR (p.slug = 'gun-1-long-gun' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #503: CHAKRAM-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CHAKRAM-1',
  'chakram-1-chakram',
  'Chakram',
  'Chakram',
  'CHAKRAM-1',
  60.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CHAKRAM-1' 
       OR (p.slug = 'chakram-1-chakram' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #504: STICK-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'STICK-5',
  'stick-5-kuntham',
  'Kuntham',
  'Kuntham',
  'STICK-5',
  60.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'STICK-5' 
       OR (p.slug = 'stick-5-kuntham' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #505: STICK-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'STICK-4',
  'stick-4-chengol-blue',
  'Chengol blue',
  'Chengol blue',
  'STICK-4',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'STICK-4' 
       OR (p.slug = 'stick-4-chengol-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #506: STICK-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'STICK-3',
  'stick-3-snake-stick',
  'Snake stick',
  'Snake stick',
  'STICK-3',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'STICK-3' 
       OR (p.slug = 'stick-3-snake-stick' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #507: STICK-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'STICK-2',
  'stick-2-police-stick-lathi-wood',
  'Police stick lathi wood',
  'Police stick lathi wood',
  'STICK-2',
  60.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'STICK-2' 
       OR (p.slug = 'stick-2-police-stick-lathi-wood' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #508: STICK-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'STICK-1',
  'stick-1-police-stick-silver-end',
  'Police stick silver end',
  'Police stick silver end',
  'STICK-1',
  80.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'STICK-1' 
       OR (p.slug = 'stick-1-police-stick-silver-end' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #509: ODAKUZHAL-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'ODAKUZHAL-2',
  'odakuzhal-2-odakuzhal-pearl-hanging',
  'Odakuzhal pearl hanging',
  'Odakuzhal pearl hanging',
  'ODAKUZHAL-2',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'ODAKUZHAL-2' 
       OR (p.slug = 'odakuzhal-2-odakuzhal-pearl-hanging' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #510: ODAKUZHAL-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'ODAKUZHAL-1',
  'odakuzhal-1-odakuzhal-ordinary',
  'Odakuzhal ordinary',
  'Odakuzhal ordinary',
  'ODAKUZHAL-1',
  20.00,
  0.00,
  42,
  42,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'ODAKUZHAL-1' 
       OR (p.slug = 'odakuzhal-1-odakuzhal-ordinary' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #511: SHANGU-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'SHANGU-2',
  'shangu-2-shangu-small',
  'Shangu small',
  'Shangu small',
  'SHANGU-2',
  50.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SHANGU-2' 
       OR (p.slug = 'shangu-2-shangu-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #512: SHANGU-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'SHANGU-1',
  'shangu-1-shangu-big',
  'Shangu big',
  'Shangu big',
  'SHANGU-1',
  80.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SHANGU-1' 
       OR (p.slug = 'shangu-1-shangu-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #513: CHILAMBU-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CHILAMBU-2',
  'chilambu-2-chilambu-fiber',
  'Chilambu fiber',
  'Chilambu fiber',
  'CHILAMBU-2',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CHILAMBU-2' 
       OR (p.slug = 'chilambu-2-chilambu-fiber' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #514: CHILAMBU-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CHILAMBU-1',
  'chilambu-1-chilambu-light-weight',
  'Chilambu light weight',
  'Chilambu light weight',
  'CHILAMBU-1',
  60.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CHILAMBU-1' 
       OR (p.slug = 'chilambu-1-chilambu-light-weight' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #515: PARICHA-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'PARICHA-6',
  'paricha-6-paricha-brass',
  'Paricha brass',
  'Paricha brass',
  'PARICHA-6',
  125.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARICHA-6' 
       OR (p.slug = 'paricha-6-paricha-brass' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #516: PARICHA-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'PARICHA-5',
  'paricha-5-paricha-small-metal',
  'Paricha small metal',
  'Paricha small metal',
  'PARICHA-5',
  80.00,
  0.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARICHA-5' 
       OR (p.slug = 'paricha-5-paricha-small-metal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #517: PARICHA-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'PARICHA-4',
  'paricha-4-paricha-cardboard',
  'Paricha cardboard',
  'Paricha cardboard',
  'PARICHA-4',
  70.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARICHA-4' 
       OR (p.slug = 'paricha-4-paricha-cardboard' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #518: PARICHA-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'PARICHA-3',
  'paricha-3-paricha-painted',
  'Paricha painted',
  'Paricha painted',
  'PARICHA-3',
  125.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARICHA-3' 
       OR (p.slug = 'paricha-3-paricha-painted' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #519: PARICHA-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'PARICHA-2',
  'paricha-2-paricha-very-big-metal',
  'Paricha very big metal',
  'Paricha very big metal',
  'PARICHA-2',
  220.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARICHA-2' 
       OR (p.slug = 'paricha-2-paricha-very-big-metal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #520: PARICHA-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'PARICHA-1',
  'paricha-1-paricha-light-weight',
  'Paricha light weight',
  'Paricha light weight',
  'PARICHA-1',
  50.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARICHA-1' 
       OR (p.slug = 'paricha-1-paricha-light-weight' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #521: CHILANKA-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CHILANKA-2',
  'chilanka-2-bucklewelcrow-chilanaga',
  'Buckle/welcrow chilanaga',
  'Buckle/welcrow chilanaga',
  'CHILANKA-2',
  175.00,
  0.00,
  20,
  20,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CHILANKA-2' 
       OR (p.slug = 'chilanka-2-bucklewelcrow-chilanaga' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #522: CHILANKA-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CHILANKA-1',
  'chilanka-1-kettu-chilanka',
  'Kettu chilanka',
  'Kettu chilanka',
  'CHILANKA-1',
  80.00,
  0.00,
  30,
  30,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CHILANKA-1' 
       OR (p.slug = 'chilanka-1-kettu-chilanka' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #523: MASK-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'MASK-8',
  'mask-8-gold-eye-mask',
  'Gold eye mask',
  'Gold eye mask',
  'MASK-8',
  30.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MASK-8' 
       OR (p.slug = 'mask-8-gold-eye-mask' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #524: MASK-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'MASK-7',
  'mask-7-flexible-rubber-ganapathy-mask',
  'Flexible rubber ganapathy mask',
  'Flexible rubber ganapathy mask',
  'MASK-7',
  175.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MASK-7' 
       OR (p.slug = 'mask-7-flexible-rubber-ganapathy-mask' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #525: MASK-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'MASK-6',
  'mask-6-light-weight-ganapathy-mask',
  'Light weight ganapathy mask',
  'Light weight ganapathy mask',
  'MASK-6',
  80.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MASK-6' 
       OR (p.slug = 'mask-6-light-weight-ganapathy-mask' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #526: MASK-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'MASK-5',
  'mask-5-ganapathy-half-mask-velvet',
  'Ganapathy half mask velvet',
  'Ganapathy half mask velvet',
  'MASK-5',
  125.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MASK-5' 
       OR (p.slug = 'mask-5-ganapathy-half-mask-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #527: MASK-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'MASK-4',
  'mask-4-ganapathy-mask-full-face-red',
  'Ganapathy mask full face red',
  'Ganapathy mask full face red',
  'MASK-4',
  125.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MASK-4' 
       OR (p.slug = 'mask-4-ganapathy-mask-full-face-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #528: MASK-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'MASK-3',
  'mask-3-narasimhan-mask',
  'Narasimhan mask',
  'Narasimhan mask',
  'MASK-3',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MASK-3' 
       OR (p.slug = 'mask-3-narasimhan-mask' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #529: MASK-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'MASK-2',
  'mask-2-hanuman-mask',
  'Hanuman mask',
  'Hanuman mask',
  'MASK-2',
  30.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MASK-2' 
       OR (p.slug = 'mask-2-hanuman-mask' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #530: MASK-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'MASK-1',
  'mask-1-ganapathy-mask',
  'Ganapathy mask',
  'Ganapathy mask',
  'MASK-1',
  125.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MASK-1' 
       OR (p.slug = 'mask-1-ganapathy-mask' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #531: AVANAZHI-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'AVANAZHI-1',
  'avanazhi-1-avanazhi-ambu',
  'Avanazhi ambu',
  'Avanazhi ambu',
  'AVANAZHI-1',
  80.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'AVANAZHI-1' 
       OR (p.slug = 'avanazhi-1-avanazhi-ambu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #532: VILLU-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VILLU-1',
  'villu-1-villu',
  'Villu',
  'Villu',
  'VILLU-1',
  125.00,
  0.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VILLU-1' 
       OR (p.slug = 'villu-1-villu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #533: MAZHU-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'MAZHU-2',
  'mazhu-2-small-mazhu-wood',
  'Small mazhu wood',
  'Small mazhu wood',
  'MAZHU-2',
  60.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MAZHU-2' 
       OR (p.slug = 'mazhu-2-small-mazhu-wood' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #534: MAZHU-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'MAZHU-1',
  'mazhu-1-mazhu-fiber',
  'Mazhu fiber',
  'Mazhu fiber',
  'MAZHU-1',
  80.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MAZHU-1' 
       OR (p.slug = 'mazhu-1-mazhu-fiber' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #535: VEL-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VEL-2',
  'vel-2-vel-big',
  'Vel Big',
  'Vel Big',
  'VEL-2',
  125.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VEL-2' 
       OR (p.slug = 'vel-2-vel-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #536: VEL-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VEL-1',
  'vel-1-vel-medium',
  'Vel Medium',
  'Vel Medium',
  'VEL-1',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VEL-1' 
       OR (p.slug = 'vel-1-vel-medium' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #537: SHOOLAM-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'SHOOLAM-4',
  'shoolam-4-shoolam-sharp',
  'Shoolam sharp',
  'Shoolam sharp',
  'SHOOLAM-4',
  150.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SHOOLAM-4' 
       OR (p.slug = 'shoolam-4-shoolam-sharp' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #538: SHOOLAM-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'SHOOLAM-3',
  'shoolam-3-shoolam-big-light-weight',
  'Shoolam big light weight',
  'Shoolam big light weight',
  'SHOOLAM-3',
  150.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SHOOLAM-3' 
       OR (p.slug = 'shoolam-3-shoolam-big-light-weight' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #539: SHOOLAM-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'SHOOLAM-2',
  'shoolam-2-shoolam-small',
  'Shoolam small',
  'Shoolam small',
  'SHOOLAM-2',
  125.00,
  0.00,
  14,
  14,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SHOOLAM-2' 
       OR (p.slug = 'shoolam-2-shoolam-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #540: SHOOLAM-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'SHOOLAM-1',
  'shoolam-1-shoolam-silver',
  'Shoolam silver',
  'Shoolam silver',
  'SHOOLAM-1',
  125.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SHOOLAM-1' 
       OR (p.slug = 'shoolam-1-shoolam-silver' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #541: KAMANDALAM-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'KAMANDALAM-2',
  'kamandalam-2-big-kamandalam',
  'Big Kamandalam',
  'Big Kamandalam',
  'KAMANDALAM-2',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KAMANDALAM-2' 
       OR (p.slug = 'kamandalam-2-big-kamandalam' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #542: KAMANDALAM-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'KAMANDALAM-1',
  'kamandalam-1-small-kamandalam',
  'Small Kamandalam',
  'Small Kamandalam',
  'KAMANDALAM-1',
  60.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KAMANDALAM-1' 
       OR (p.slug = 'kamandalam-1-small-kamandalam' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #543: VALLAM-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VALLAM-1',
  'vallam-1-cardboard-vallam',
  'Cardboard vallam',
  'Cardboard vallam',
  'VALLAM-1',
  280.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VALLAM-1' 
       OR (p.slug = 'vallam-1-cardboard-vallam' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #544: UMBRELLA-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'UMBRELLA-7',
  'umbrella-7-muthukuda-big',
  'Muthukuda big',
  'Muthukuda big',
  'UMBRELLA-7',
  125.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'UMBRELLA-7' 
       OR (p.slug = 'umbrella-7-muthukuda-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #545: UMBRELLA-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'UMBRELLA-6',
  'umbrella-6-muthukuda-small',
  'Muthukuda small',
  'Muthukuda small',
  'UMBRELLA-6',
  125.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'UMBRELLA-6' 
       OR (p.slug = 'umbrella-6-muthukuda-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #546: UMBRELLA-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'UMBRELLA-5',
  'umbrella-5-olakuda-big',
  'Olakuda big',
  'Olakuda big',
  'UMBRELLA-5',
  220.00,
  0.00,
  15,
  15,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'UMBRELLA-5' 
       OR (p.slug = 'umbrella-5-olakuda-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #547: UMBRELLA-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'UMBRELLA-4',
  'umbrella-4-olakuda-small',
  'Olakuda small',
  'Olakuda small',
  'UMBRELLA-4',
  175.00,
  0.00,
  14,
  14,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'UMBRELLA-4' 
       OR (p.slug = 'umbrella-4-olakuda-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #548: UMBRELLA-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'UMBRELLA-3',
  'umbrella-3-small-blue-umbrella',
  'Small blue umbrella',
  'Small blue umbrella',
  'UMBRELLA-3',
  60.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'UMBRELLA-3' 
       OR (p.slug = 'umbrella-3-small-blue-umbrella' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #549: UMBRELLA-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'UMBRELLA-2',
  'umbrella-2-chinese-umbrella-with-side-hanging',
  'Chinese umbrella with side hanging',
  'Chinese umbrella with side hanging',
  'UMBRELLA-2',
  80.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'UMBRELLA-2' 
       OR (p.slug = 'umbrella-2-chinese-umbrella-with-side-hanging' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #550: UMBRELLA-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'UMBRELLA-1',
  'umbrella-1-chinese-umbrella-purple',
  'Chinese umbrella purple',
  'Chinese umbrella purple',
  'UMBRELLA-1',
  60.00,
  0.00,
  23,
  23,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'UMBRELLA-1' 
       OR (p.slug = 'umbrella-1-chinese-umbrella-purple' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #551: FAN-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FAN-5',
  'fan-5-mayil-peepli-vishari',
  'Mayil peepli vishari',
  'Mayil peepli vishari',
  'FAN-5',
  60.00,
  0.00,
  17,
  17,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FAN-5' 
       OR (p.slug = 'fan-5-mayil-peepli-vishari' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #552: FAN-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FAN-4',
  'fan-4-long-cloth-hanging-fan',
  'Long cloth hanging fan',
  'Long cloth hanging fan',
  'FAN-4',
  60.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FAN-4' 
       OR (p.slug = 'fan-4-long-cloth-hanging-fan' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #553: FAN-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FAN-3',
  'fan-3-colorful-cloth-veeshari',
  'Colorful cloth veeshari',
  'Colorful cloth veeshari',
  'FAN-3',
  30.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FAN-3' 
       OR (p.slug = 'fan-3-colorful-cloth-veeshari' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #554: FAN-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FAN-2',
  'fan-2-chinese-fan-with-feather',
  'Chinese fan with feather',
  'Chinese fan with feather',
  'FAN-2',
  50.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FAN-2' 
       OR (p.slug = 'fan-2-chinese-fan-with-feather' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #555: FAN-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FAN-1',
  'fan-1-chinese-fan',
  'Chinese fan',
  'Chinese fan',
  'FAN-1',
  30.00,
  0.00,
  17,
  17,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FAN-1' 
       OR (p.slug = 'fan-1-chinese-fan' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #556: KUTTA-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'KUTTA-5',
  'kutta-5-long-type-kutta',
  'Long type Kutta',
  'Long type Kutta',
  'KUTTA-5',
  60.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KUTTA-5' 
       OR (p.slug = 'kutta-5-long-type-kutta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #557: KUTTA-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'KUTTA-4',
  'kutta-4-pookada-model-kutta',
  'Pookada model Kutta',
  'Pookada model Kutta',
  'KUTTA-4',
  30.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KUTTA-4' 
       OR (p.slug = 'kutta-4-pookada-model-kutta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #558: KUTTA-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'KUTTA-3',
  'kutta-3-arivatti-model-kutta',
  'Arivatti model Kutta',
  'Arivatti model Kutta',
  'KUTTA-3',
  30.00,
  0.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KUTTA-3' 
       OR (p.slug = 'kutta-3-arivatti-model-kutta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #559: KUTTA-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'KUTTA-2',
  'kutta-2-side-paper-wrapped-kutta',
  'Side paper wrapped Kutta',
  'Side paper wrapped Kutta',
  'KUTTA-2',
  30.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KUTTA-2' 
       OR (p.slug = 'kutta-2-side-paper-wrapped-kutta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #560: KUTTA-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'KUTTA-1',
  'kutta-1-plain-kutta',
  'Plain Kutta',
  'Plain Kutta',
  'KUTTA-1',
  30.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KUTTA-1' 
       OR (p.slug = 'kutta-1-plain-kutta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #561: VAAL-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VAAL-9',
  'vaal-9-small-vaal-with-handle',
  'Small vaal with handle',
  'Small vaal with handle',
  'VAAL-9',
  10.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VAAL-9' 
       OR (p.slug = 'vaal-9-small-vaal-with-handle' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #562: VAAL-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VAAL-8',
  'vaal-8-velichapadu-gold-mediumvaal',
  'Velichapadu gold mediumVaal',
  'Velichapadu gold mediumVaal',
  'VAAL-8',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VAAL-8' 
       OR (p.slug = 'vaal-8-velichapadu-gold-mediumvaal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #563: VAAL-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VAAL-7',
  'vaal-7-asuran-vaal',
  'Asuran vaal',
  'Asuran vaal',
  'VAAL-7',
  70.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VAAL-7' 
       OR (p.slug = 'vaal-7-asuran-vaal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #564: VAAL-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VAAL-6',
  'vaal-6-heavy-vaal-with-ura-vaal',
  'Heavy vaal with ura Vaal',
  'Heavy vaal with ura Vaal',
  'VAAL-6',
  280.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VAAL-6' 
       OR (p.slug = 'vaal-6-heavy-vaal-with-ura-vaal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #565: VAAL-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VAAL-5',
  'vaal-5-vaal-with-ura-vaal',
  'Vaal with ura Vaal',
  'Vaal with ura Vaal',
  'VAAL-5',
  150.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VAAL-5' 
       OR (p.slug = 'vaal-5-vaal-with-ura-vaal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #566: VAAL-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VAAL-4',
  'vaal-4-arivaal-small-vaal',
  'Arivaal small Vaal',
  'Arivaal small Vaal',
  'VAAL-4',
  60.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VAAL-4' 
       OR (p.slug = 'vaal-4-arivaal-small-vaal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #567: VAAL-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VAAL-3',
  'vaal-3-velichapadu-vaal-gold-big-vaal',
  'Velichapadu vaal Gold big Vaal',
  'Velichapadu vaal Gold big Vaal',
  'VAAL-3',
  175.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VAAL-3' 
       OR (p.slug = 'vaal-3-velichapadu-vaal-gold-big-vaal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #568: VAAL-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VAAL-2',
  'vaal-2-velichapadu-vaal-black-vaal',
  'Velichapadu Vaal Black Vaal',
  'Velichapadu Vaal Black Vaal',
  'VAAL-2',
  125.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VAAL-2' 
       OR (p.slug = 'vaal-2-velichapadu-vaal-black-vaal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #569: VAAL-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'VAAL-1',
  'vaal-1-weightless-vaal-black-handle-vaal',
  'Weightless vaal Black handle Vaal',
  'Weightless vaal Black handle Vaal',
  'VAAL-1',
  80.00,
  0.00,
  20,
  20,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'VAAL-1' 
       OR (p.slug = 'vaal-1-weightless-vaal-black-handle-vaal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #570: BUTTERFLY-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'BUTTERFLY-1',
  'butterfly-1-butterfly-wings-big',
  'Butterfly wings big',
  'Butterfly wings big',
  'BUTTERFLY-1',
  125.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BUTTERFLY-1' 
       OR (p.slug = 'butterfly-1-butterfly-wings-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #571: FLOWER-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FLOWER-6',
  'flower-6-offwhite-sunflower-sponge',
  'Offwhite sunflower sponge',
  'Offwhite sunflower sponge',
  'FLOWER-6',
  80.00,
  0.00,
  25,
  25,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FLOWER-6' 
       OR (p.slug = 'flower-6-offwhite-sunflower-sponge' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #572: FLOWER-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FLOWER-5',
  'flower-5-big-lotus-majenta',
  'Big lotus majenta',
  'Big lotus majenta',
  'FLOWER-5',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FLOWER-5' 
       OR (p.slug = 'flower-5-big-lotus-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #573: FLOWER-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FLOWER-4',
  'flower-4-orange-sunflower-face',
  'Orange sunflower face',
  'Orange sunflower face',
  'FLOWER-4',
  80.00,
  0.00,
  16,
  16,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FLOWER-4' 
       OR (p.slug = 'flower-4-orange-sunflower-face' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #574: FLOWER-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FLOWER-3',
  'flower-3-orange-sunflower',
  'Orange sunflower',
  'Orange sunflower',
  'FLOWER-3',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FLOWER-3' 
       OR (p.slug = 'flower-3-orange-sunflower' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #575: FLOWER-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FLOWER-2',
  'flower-2-yellow-sunflower',
  'Yellow sunflower',
  'Yellow sunflower',
  'FLOWER-2',
  80.00,
  0.00,
  19,
  19,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FLOWER-2' 
       OR (p.slug = 'flower-2-yellow-sunflower' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #576: FLOWER-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'FLOWER-1',
  'flower-1-small-lotus-flower',
  'Small Lotus flower',
  'Small Lotus flower',
  'FLOWER-1',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FLOWER-1' 
       OR (p.slug = 'flower-1-small-lotus-flower' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #577: CAP-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-16',
  'cap-16-cone-shape-thoppi',
  'Cone shape thoppi',
  'Cone shape thoppi',
  'CAP-16',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-16' 
       OR (p.slug = 'cap-16-cone-shape-thoppi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #578: CAP-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-15',
  'cap-15-pala-thoppi',
  'Pala thoppi',
  'Pala thoppi',
  'CAP-15',
  50.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-15' 
       OR (p.slug = 'cap-15-pala-thoppi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #579: CAP-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-14',
  'cap-14-blue-marathi-cap',
  'Blue marathi cap',
  'Blue marathi cap',
  'CAP-14',
  125.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-14' 
       OR (p.slug = 'cap-14-blue-marathi-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #580: CAP-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-13',
  'cap-13-merroon-rajasthani-cap',
  'Merroon Rajasthani cap',
  'Merroon Rajasthani cap',
  'CAP-13',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-13' 
       OR (p.slug = 'cap-13-merroon-rajasthani-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #581: CAP-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-12',
  'cap-12-green-rajasthani-cap',
  'Green Rajasthani cap',
  'Green Rajasthani cap',
  'CAP-12',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-12' 
       OR (p.slug = 'cap-12-green-rajasthani-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #582: CAP-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-11',
  'cap-11-green-red-seqeuncerajasthani-cap',
  'Green red seqeunceRajasthani cap',
  'Green red seqeunceRajasthani cap',
  'CAP-11',
  80.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-11' 
       OR (p.slug = 'cap-11-green-red-seqeuncerajasthani-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #583: CAP-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-10',
  'cap-10-yellow-blue-sequence-rajasthani-cap',
  'Yellow blue sequence Rajasthani cap',
  'Yellow blue sequence Rajasthani cap',
  'CAP-10',
  80.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-10' 
       OR (p.slug = 'cap-10-yellow-blue-sequence-rajasthani-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #584: CAP-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-9',
  'cap-9-yellow-red-rajasthani-cap',
  'Yellow red Rajasthani cap',
  'Yellow red Rajasthani cap',
  'CAP-9',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-9' 
       OR (p.slug = 'cap-9-yellow-red-rajasthani-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #585: CAP-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-8',
  'cap-8-majenta-marathi-cap',
  'Majenta Marathi cap',
  'Majenta Marathi cap',
  'CAP-8',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-8' 
       OR (p.slug = 'cap-8-majenta-marathi-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #586: CAP-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-7',
  'cap-7-white-marathi-cap',
  'White Marathi cap',
  'White Marathi cap',
  'CAP-7',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-7' 
       OR (p.slug = 'cap-7-white-marathi-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #587: CAP-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-6',
  'cap-6-yellow-marathi-cap',
  'Yellow Marathi cap',
  'Yellow Marathi cap',
  'CAP-6',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-6' 
       OR (p.slug = 'cap-6-yellow-marathi-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #588: CAP-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-5',
  'cap-5-merron-offwhite-marathi-cap',
  'Merron offwhite marathi cap',
  'Merron offwhite marathi cap',
  'CAP-5',
  80.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-5' 
       OR (p.slug = 'cap-5-merron-offwhite-marathi-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #589: CAP-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-4',
  'cap-4-cow-boy-cap-orange',
  'Cow boy cap Orange',
  'Cow boy cap Orange',
  'CAP-4',
  80.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-4' 
       OR (p.slug = 'cap-4-cow-boy-cap-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #590: CAP-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-3',
  'cap-3-cow-boy-cap-ash',
  'Cow boy cap Ash',
  'Cow boy cap Ash',
  'CAP-3',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-3' 
       OR (p.slug = 'cap-3-cow-boy-cap-ash' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #591: CAP-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-2',
  'cap-2-white-cap',
  'White Cap',
  'White Cap',
  'CAP-2',
  30.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-2' 
       OR (p.slug = 'cap-2-white-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #592: CAP-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-1',
  'cap-1-black-cap',
  'Black cap',
  'Black cap',
  'CAP-1',
  30.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CAP-1' 
       OR (p.slug = 'cap-1-black-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #593: CROWN-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-31',
  'crown-31-mayavu-kombu-crown',
  'Mayavu kombu Crown',
  'Mayavu kombu Crown',
  'CROWN-31',
  60.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-31' 
       OR (p.slug = 'crown-31-mayavu-kombu-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #594: CROWN-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-30',
  'crown-30-luttappi-kombu-crown',
  'Luttappi kombu Crown',
  'Luttappi kombu Crown',
  'CROWN-30',
  60.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-30' 
       OR (p.slug = 'crown-30-luttappi-kombu-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #595: CROWN-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-29',
  'crown-29-mul-kereedam-crown',
  'Mul kereedam Crown',
  'Mul kereedam Crown',
  'CROWN-29',
  80.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-29' 
       OR (p.slug = 'crown-29-mul-kereedam-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #596: CROWN-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-28',
  'crown-28-cristian-king-crown-gold',
  'Cristian king crown gold',
  'Cristian king crown gold',
  'CROWN-28',
  60.00,
  0.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-28' 
       OR (p.slug = 'crown-28-cristian-king-crown-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #597: CROWN-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-27',
  'crown-27-christian-king-crown-silver',
  'Christian king crown silver',
  'Christian king crown silver',
  'CROWN-27',
  60.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-27' 
       OR (p.slug = 'crown-27-christian-king-crown-silver' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #598: CROWN-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-26',
  'crown-26-maveli-crown-cardboard',
  'Maveli crown cardboard',
  'Maveli crown cardboard',
  'CROWN-26',
  150.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-26' 
       OR (p.slug = 'crown-26-maveli-crown-cardboard' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #599: CROWN-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-25',
  'crown-25-maveli-crown-heavy',
  'Maveli crown heavy',
  'Maveli crown heavy',
  'CROWN-25',
  220.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-25' 
       OR (p.slug = 'crown-25-maveli-crown-heavy' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #600: CROWN-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-24',
  'crown-24-asuran-crown-black',
  'Asuran crown black',
  'Asuran crown black',
  'CROWN-24',
  80.00,
  0.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-24' 
       OR (p.slug = 'crown-24-asuran-crown-black' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #601: CROWN-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-23',
  'crown-23-jhansi-rani-crown',
  'Jhansi rani crown',
  'Jhansi rani crown',
  'CROWN-23',
  60.00,
  0.00,
  16,
  16,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-23' 
       OR (p.slug = 'crown-23-jhansi-rani-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #602: CROWN-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-22',
  'crown-22-green-curl-crown',
  'Green curl crown',
  'Green curl crown',
  'CROWN-22',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-22' 
       OR (p.slug = 'crown-22-green-curl-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #603: CROWN-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-21',
  'crown-21-gold-painted-crown-with-stone',
  'Gold painted crown with stone',
  'Gold painted crown with stone',
  'CROWN-21',
  125.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-21' 
       OR (p.slug = 'crown-21-gold-painted-crown-with-stone' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #604: CROWN-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-20',
  'crown-20-green-stone-crown',
  'Green stone crown',
  'Green stone crown',
  'CROWN-20',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-20' 
       OR (p.slug = 'crown-20-green-stone-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #605: CROWN-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-19',
  'crown-19-mayil-thala-crown',
  'Mayil thala Crown',
  'Mayil thala Crown',
  'CROWN-19',
  80.00,
  0.00,
  15,
  15,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-19' 
       OR (p.slug = 'crown-19-mayil-thala-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #606: CROWN-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-18',
  'crown-18-ravana-crown',
  'Ravana crown',
  'Ravana crown',
  'CROWN-18',
  220.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-18' 
       OR (p.slug = 'crown-18-ravana-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #607: CROWN-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-17',
  'crown-17-brahma-crown',
  'Brahma crown',
  'Brahma crown',
  'CROWN-17',
  175.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-17' 
       OR (p.slug = 'crown-17-brahma-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #608: CROWN-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-16',
  'crown-16-tribal-feather-crown',
  'Tribal feather crown',
  'Tribal feather crown',
  'CROWN-16',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-16' 
       OR (p.slug = 'crown-16-tribal-feather-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #609: CROWN-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-15',
  'crown-15-crown-with-white-stone-flower-crown',
  'Crown with white stone flower Crown',
  'Crown with white stone flower Crown',
  'CROWN-15',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-15' 
       OR (p.slug = 'crown-15-crown-with-white-stone-flower-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #610: CROWN-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-14',
  'crown-14-kombu-crown-white-red-stone',
  'Kombu crown white / Red stone',
  'Kombu crown white / Red stone',
  'CROWN-14',
  125.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-14' 
       OR (p.slug = 'crown-14-kombu-crown-white-red-stone' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #611: CROWN-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-13',
  'crown-13-star-crown-white-stone',
  'Star crown white stone',
  'Star crown white stone',
  'CROWN-13',
  125.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-13' 
       OR (p.slug = 'crown-13-star-crown-white-stone' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #612: CROWN-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-12',
  'crown-12-krishna-crown-blue',
  'Krishna crown blue',
  'Krishna crown blue',
  'CROWN-12',
  125.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-12' 
       OR (p.slug = 'crown-12-krishna-crown-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #613: CROWN-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-11',
  'crown-11-krishna-crown-greenorange-blue-mix',
  'Krishna crown green,orange, blue mix',
  'Krishna crown green,orange, blue mix',
  'CROWN-11',
  125.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-11' 
       OR (p.slug = 'crown-11-krishna-crown-greenorange-blue-mix' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #614: CROWN-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-10',
  'crown-10-krishna-crown-yellow-blue-crown',
  'Krishna crown yellow blue Crown',
  'Krishna crown yellow blue Crown',
  'CROWN-10',
  125.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-10' 
       OR (p.slug = 'crown-10-krishna-crown-yellow-blue-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #615: CROWN-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-9',
  'crown-9-andal-konda-gold-lace-crown',
  'Andal konda gold lace Crown',
  'Andal konda gold lace Crown',
  'CROWN-9',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-9' 
       OR (p.slug = 'crown-9-andal-konda-gold-lace-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #616: CROWN-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-8',
  'crown-8-andal-konda-stone-crown',
  'Andal konda stone Crown',
  'Andal konda stone Crown',
  'CROWN-8',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-8' 
       OR (p.slug = 'crown-8-andal-konda-stone-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #617: CROWN-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-7',
  'crown-7-gold-snake-bow-crown',
  'Gold snake bow Crown',
  'Gold snake bow Crown',
  'CROWN-7',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-7' 
       OR (p.slug = 'crown-7-gold-snake-bow-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #618: CROWN-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-6',
  'crown-6-black-flame-velvet-crown',
  'Black flame velvet Crown',
  'Black flame velvet Crown',
  'CROWN-6',
  125.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-6' 
       OR (p.slug = 'crown-6-black-flame-velvet-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #619: CROWN-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-5',
  'crown-5-blue-velvet-peacog-with-kudam-design-crown',
  'Blue velvet peacog with kudam design Crown',
  'Blue velvet peacog with kudam design Crown',
  'CROWN-5',
  150.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-5' 
       OR (p.slug = 'crown-5-blue-velvet-peacog-with-kudam-design-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #620: CROWN-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-4',
  'crown-4-black-2-line-gold-lace-crown',
  'Black 2 line gold lace Crown',
  'Black 2 line gold lace Crown',
  'CROWN-4',
  150.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-4' 
       OR (p.slug = 'crown-4-black-2-line-gold-lace-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #621: CROWN-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-3',
  'crown-3-black-velvet-bow-with-lekshmi-print-crown',
  'Black velvet bow with lekshmi print Crown',
  'Black velvet bow with lekshmi print Crown',
  'CROWN-3',
  150.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-3' 
       OR (p.slug = 'crown-3-black-velvet-bow-with-lekshmi-print-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #622: CROWN-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-2',
  'crown-2-half-ring-gold-with-crown',
  'Half ring gold with Crown',
  'Half ring gold with Crown',
  'CROWN-2',
  125.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-2' 
       OR (p.slug = 'crown-2-half-ring-gold-with-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #623: CROWN-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'property' AND store_id = s.id LIMIT 1),
  b.id,
  'CROWN-1',
  'crown-1-half-ring-silver-crown',
  'Half ring silver Crown',
  'Half ring silver Crown',
  'CROWN-1',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CROWN-1' 
       OR (p.slug = 'crown-1-half-ring-silver-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #624: PARTS-63SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-63SF',
  'parts-63sf-majenta-velvet-print-sf',
  'Majenta velvet print SF',
  'Majenta velvet print SF',
  'PARTS-63SF',
  50.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-63SF' 
       OR (p.slug = 'parts-63sf-majenta-velvet-print-sf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #625: PARTS-63BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-63BS',
  'parts-63bs-majenta-velvet-print-bs',
  'Majenta velvet print BS',
  'Majenta velvet print BS',
  'PARTS-63BS',
  125.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-63BS' 
       OR (p.slug = 'parts-63bs-majenta-velvet-print-bs' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #626: PARTS-63HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-63HS',
  'parts-63hs-majenta-velvet-print-hs',
  'Majenta velvet print HS',
  'Majenta velvet print HS',
  'PARTS-63HS',
  125.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-63HS' 
       OR (p.slug = 'parts-63hs-majenta-velvet-print-hs' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #627: PARTS-62SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-62SF',
  'parts-62sf-majenta-brocade-sf',
  'Majenta brocade SF',
  'Majenta brocade SF',
  'PARTS-62SF',
  50.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-62SF' 
       OR (p.slug = 'parts-62sf-majenta-brocade-sf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #628: PARTS-62BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-62BS',
  'parts-62bs-majenta-brocade-bs',
  'Majenta brocade BS',
  'Majenta brocade BS',
  'PARTS-62BS',
  125.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-62BS' 
       OR (p.slug = 'parts-62bs-majenta-brocade-bs' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #629: PARTS-62HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-62HS',
  'parts-62hs-majenta-brocade-hs',
  'Majenta brocade HS',
  'Majenta brocade HS',
  'PARTS-62HS',
  125.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-62HS' 
       OR (p.slug = 'parts-62hs-majenta-brocade-hs' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #630: PARTS-50LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-50LF',
  'parts-50lf-yellow-cotton-check',
  'Yellow Cotton check',
  'Yellow Cotton check',
  'PARTS-50LF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-50LF' 
       OR (p.slug = 'parts-50lf-yellow-cotton-check' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #631: PARTS-50HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-50HS',
  'parts-50hs-yellow-cotton-check',
  'Yellow Cotton Check',
  'Yellow Cotton Check',
  'PARTS-50HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-50HS' 
       OR (p.slug = 'parts-50hs-yellow-cotton-check' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #632: PARTS-61SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-61SF',
  'parts-61sf-orange-tissue-brocade-sf',
  'Orange Tissue brocade SF',
  'Orange Tissue brocade SF',
  'PARTS-61SF',
  50.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-61SF' 
       OR (p.slug = 'parts-61sf-orange-tissue-brocade-sf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #633: PARTS-61BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-61BS',
  'parts-61bs-orange-tissue-brocade-bs',
  'Orange Tissue brocade BS',
  'Orange Tissue brocade BS',
  'PARTS-61BS',
  80.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-61BS' 
       OR (p.slug = 'parts-61bs-orange-tissue-brocade-bs' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #634: PARTS-61HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-61HS',
  'parts-61hs-orange-tissue-brocade-hs',
  'Orange Tissue brocade HS',
  'Orange Tissue brocade HS',
  'PARTS-61HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-61HS' 
       OR (p.slug = 'parts-61hs-orange-tissue-brocade-hs' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #635: PARTS-60SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-60SF',
  'parts-60sf-red-manichithrathazhu-sf',
  'Red Manichithrathazhu SF',
  'Red Manichithrathazhu SF',
  'PARTS-60SF',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-60SF' 
       OR (p.slug = 'parts-60sf-red-manichithrathazhu-sf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #636: PARTS-60LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-60LF',
  'parts-60lf-red-manichithrathazhu-lf',
  'Red Manichithrathazhu LF',
  'Red Manichithrathazhu LF',
  'PARTS-60LF',
  175.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-60LF' 
       OR (p.slug = 'parts-60lf-red-manichithrathazhu-lf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #637: PARTS-60BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-60BS',
  'parts-60bs-red-manichithrathazhu-bs',
  'Red Manichithrathazhu BS',
  'Red Manichithrathazhu BS',
  'PARTS-60BS',
  150.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-60BS' 
       OR (p.slug = 'parts-60bs-red-manichithrathazhu-bs' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #638: PARTS-60HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-60HS',
  'parts-60hs-red-manichithrathazhu-hs',
  'Red Manichithrathazhu HS',
  'Red Manichithrathazhu HS',
  'PARTS-60HS',
  150.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-60HS' 
       OR (p.slug = 'parts-60hs-red-manichithrathazhu-hs' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #639: PARTS-59HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-59HS',
  'parts-59hs-black-manichithrathazhu-hs',
  'Black manichithrathazhu HS',
  'Black manichithrathazhu HS',
  'PARTS-59HS',
  125.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-59HS' 
       OR (p.slug = 'parts-59hs-black-manichithrathazhu-hs' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #640: PARTS-58BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-58BS',
  'parts-58bs-blue-big-seq-back-seat',
  'Blue big seq back seat',
  'Blue big seq back seat',
  'PARTS-58BS',
  80.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-58BS' 
       OR (p.slug = 'parts-58bs-blue-big-seq-back-seat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #641: PARTS-57LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-57LF',
  'parts-57lf-silver-chest-coat-long-fan',
  'Silver chest coat long fan',
  'Silver chest coat long fan',
  'PARTS-57LF',
  80.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-57LF' 
       OR (p.slug = 'parts-57lf-silver-chest-coat-long-fan' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #642: PARTS-57BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-57BS',
  'parts-57bs-silver-chest-coat-back-seat',
  'Silver chest coat back seat',
  'Silver chest coat back seat',
  'PARTS-57BS',
  50.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-57BS' 
       OR (p.slug = 'parts-57bs-silver-chest-coat-back-seat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #643: PARTS-57HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-57HS',
  'parts-57hs-silver-chest-coat-hals-saree',
  'Silver chest coat hals saree',
  'Silver chest coat hals saree',
  'PARTS-57HS',
  80.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-57HS' 
       OR (p.slug = 'parts-57hs-silver-chest-coat-hals-saree' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #644: PARTS-56SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-56SF',
  'parts-56sf-red-om-design',
  'Red OM design',
  'Red OM design',
  'PARTS-56SF',
  50.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-56SF' 
       OR (p.slug = 'parts-56sf-red-om-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #645: PARTS-56LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-56LF',
  'parts-56lf-red-om-design',
  'Red OM design',
  'Red OM design',
  'PARTS-56LF',
  80.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-56LF' 
       OR (p.slug = 'parts-56lf-red-om-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #646: PARTS-56BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-56BS',
  'parts-56bs-red-om-design',
  'Red OM design',
  'Red OM design',
  'PARTS-56BS',
  80.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-56BS' 
       OR (p.slug = 'parts-56bs-red-om-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #647: PARTS-56HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-56HS',
  'parts-56hs-red-om-design',
  'Red OM design',
  'Red OM design',
  'PARTS-56HS',
  80.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-56HS' 
       OR (p.slug = 'parts-56hs-red-om-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #648: PARTS-55SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-55SF',
  'parts-55sf-yellow-velvet-self-design',
  'Yellow velvet self design',
  'Yellow velvet self design',
  'PARTS-55SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-55SF' 
       OR (p.slug = 'parts-55sf-yellow-velvet-self-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #649: PARTS-55BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-55BS',
  'parts-55bs-yellow-velvet-self-design',
  'Yellow velvet self design',
  'Yellow velvet self design',
  'PARTS-55BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-55BS' 
       OR (p.slug = 'parts-55bs-yellow-velvet-self-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #650: PARTS-55HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-55HS',
  'parts-55hs-yellow-velvet-self-design',
  'Yellow velvet self design',
  'Yellow velvet self design',
  'PARTS-55HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-55HS' 
       OR (p.slug = 'parts-55hs-yellow-velvet-self-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #651: PARTS-54BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-54BS',
  'parts-54bs-blue-velvet-flower-design',
  'Blue velvet flower design',
  'Blue velvet flower design',
  'PARTS-54BS',
  125.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-54BS' 
       OR (p.slug = 'parts-54bs-blue-velvet-flower-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #652: PARTS-54HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-54HS',
  'parts-54hs-blue-velvet-flower-design',
  'Blue velvet flower design',
  'Blue velvet flower design',
  'PARTS-54HS',
  150.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-54HS' 
       OR (p.slug = 'parts-54hs-blue-velvet-flower-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #653: PARTS-53BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-53BS',
  'parts-53bs-green-velvet-sequence',
  'Green velvet sequence',
  'Green velvet sequence',
  'PARTS-53BS',
  125.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-53BS' 
       OR (p.slug = 'parts-53bs-green-velvet-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #654: PARTS-53SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-53SF',
  'parts-53sf-green-velvet-sequence',
  'Green velvet sequence',
  'Green velvet sequence',
  'PARTS-53SF',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-53SF' 
       OR (p.slug = 'parts-53sf-green-velvet-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #655: PARTS-53HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-53HS',
  'parts-53hs-green-velvet-sequence',
  'Green velvet sequence',
  'Green velvet sequence',
  'PARTS-53HS',
  125.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-53HS' 
       OR (p.slug = 'parts-53hs-green-velvet-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #656: PARTS-48LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-48LF',
  'parts-48lf-black-plain-seq-velvet-mix-long-fan-only',
  'Black plain & seq velvet mix long fan only',
  'Black plain & seq velvet mix long fan only',
  'PARTS-48LF',
  175.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-48LF' 
       OR (p.slug = 'parts-48lf-black-plain-seq-velvet-mix-long-fan-only' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #657: PARTS-45LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-45LF',
  'parts-45lf-majenta-net-round-design-border',
  'Majenta net round design border',
  'Majenta net round design border',
  'PARTS-45LF',
  125.00,
  0.00,
  17,
  17,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-45LF' 
       OR (p.slug = 'parts-45lf-majenta-net-round-design-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #658: PARTS-47BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-47BS',
  'parts-47bs-light-orange-with-orange-round-seq-border',
  'Light Orange with orange round seq border',
  'Light Orange with orange round seq border',
  'PARTS-47BS',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-47BS' 
       OR (p.slug = 'parts-47bs-light-orange-with-orange-round-seq-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #659: PARTS-45SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-45SF',
  'parts-45sf-majenta-net-round-design-border',
  'Majenta net round design border',
  'Majenta net round design border',
  'PARTS-45SF',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-45SF' 
       OR (p.slug = 'parts-45sf-majenta-net-round-design-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #660: PARTS-52LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-52LF',
  'parts-52lf-black-velvet-seq-lf',
  'Black Velvet Seq LF',
  'Black Velvet Seq LF',
  'PARTS-52LF',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-52LF' 
       OR (p.slug = 'parts-52lf-black-velvet-seq-lf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #661: PARTS-51HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-51HS',
  'parts-51hs-merroon-velvet-kacha',
  'Merroon Velvet Kacha',
  'Merroon Velvet Kacha',
  'PARTS-51HS',
  125.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-51HS' 
       OR (p.slug = 'parts-51hs-merroon-velvet-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #662: PARTS-51LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-51LF',
  'parts-51lf-merroon-velvet-kachs-lf',
  'Merroon Velvet Kachs LF',
  'Merroon Velvet Kachs LF',
  'PARTS-51LF',
  125.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-51LF' 
       OR (p.slug = 'parts-51lf-merroon-velvet-kachs-lf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #663: PARTS-51BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-51BS',
  'parts-51bs-merroon-velvet-kacha-bs',
  'Merroon Velvet Kacha BS',
  'Merroon Velvet Kacha BS',
  'PARTS-51BS',
  125.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-51BS' 
       OR (p.slug = 'parts-51bs-merroon-velvet-kacha-bs' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #664: PARTS-49HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-49HS',
  'parts-49hs-yellow-velvet-seq-kacha',
  'Yellow velvet seq kacha',
  'Yellow velvet seq kacha',
  'PARTS-49HS',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-49HS' 
       OR (p.slug = 'parts-49hs-yellow-velvet-seq-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #665: PARTS-47SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-47SF',
  'parts-47sf-light-orange-with-orange-round-seq-border',
  'Light Orange with orange round seq border',
  'Light Orange with orange round seq border',
  'PARTS-47SF',
  80.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-47SF' 
       OR (p.slug = 'parts-47sf-light-orange-with-orange-round-seq-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #666: PARTS-47LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-47LF',
  'parts-47lf-light-orange-with-orange-round-seq-border',
  'Light Orange with orange round seq border',
  'Light Orange with orange round seq border',
  'PARTS-47LF',
  80.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-47LF' 
       OR (p.slug = 'parts-47lf-light-orange-with-orange-round-seq-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #667: PARTS-47HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-47HS',
  'parts-47hs-light-orange-with-orange-round-seq-border',
  'Light Orange with orange round seq border',
  'Light Orange with orange round seq border',
  'PARTS-47HS',
  80.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-47HS' 
       OR (p.slug = 'parts-47hs-light-orange-with-orange-round-seq-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #668: PARTS-46LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-46LF',
  'parts-46lf-copper-sulphate-blue-brocade',
  'Copper sulphate blue brocade',
  'Copper sulphate blue brocade',
  'PARTS-46LF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-46LF' 
       OR (p.slug = 'parts-46lf-copper-sulphate-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #669: PARTS-46BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-46BS',
  'parts-46bs-copper-sulphate-blue-brocade',
  'Copper sulphate blue brocade',
  'Copper sulphate blue brocade',
  'PARTS-46BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-46BS' 
       OR (p.slug = 'parts-46bs-copper-sulphate-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #670: PARTS-46HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-46HS',
  'parts-46hs-copper-sulphate-blue-brocade',
  'Copper sulphate blue brocade',
  'Copper sulphate blue brocade',
  'PARTS-46HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-46HS' 
       OR (p.slug = 'parts-46hs-copper-sulphate-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #671: PARTS-45BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-45BS',
  'parts-45bs-majenta-net-round-design-border',
  'Majenta net round design border',
  'Majenta net round design border',
  'PARTS-45BS',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-45BS' 
       OR (p.slug = 'parts-45bs-majenta-net-round-design-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #672: PARTS-45HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-45HS',
  'parts-45hs-majenta-net-round-design-border',
  'Majenta net round design border',
  'Majenta net round design border',
  'PARTS-45HS',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-45HS' 
       OR (p.slug = 'parts-45hs-majenta-net-round-design-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #673: PARTS-44SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-44SF',
  'parts-44sf-majenta-velvet-sequence-kacha',
  'Majenta velvet sequence Kacha',
  'Majenta velvet sequence Kacha',
  'PARTS-44SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-44SF' 
       OR (p.slug = 'parts-44sf-majenta-velvet-sequence-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #674: PARTS-44BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-44BS',
  'parts-44bs-majenta-velvet-sequence-kacha',
  'Majenta velvet sequence Kacha',
  'Majenta velvet sequence Kacha',
  'PARTS-44BS',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-44BS' 
       OR (p.slug = 'parts-44bs-majenta-velvet-sequence-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #675: PARTS-44HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-44HS',
  'parts-44hs-majenta-velvet-sequence-kacha',
  'Majenta velvet sequence Kacha',
  'Majenta velvet sequence Kacha',
  'PARTS-44HS',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-44HS' 
       OR (p.slug = 'parts-44hs-majenta-velvet-sequence-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #676: PARTS-43SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-43SF',
  'parts-43sf-blue-violet-sequence-kacha',
  'Blue violet sequence kacha',
  'Blue violet sequence kacha',
  'PARTS-43SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-43SF' 
       OR (p.slug = 'parts-43sf-blue-violet-sequence-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #677: PARTS-43BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-43BS',
  'parts-43bs-blue-violet-sequence-kacha',
  'Blue violet sequence kacha',
  'Blue violet sequence kacha',
  'PARTS-43BS',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-43BS' 
       OR (p.slug = 'parts-43bs-blue-violet-sequence-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #678: PARTS-43HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-43HS',
  'parts-43hs-blue-violet-sequence-kacha',
  'Blue violet sequence kacha',
  'Blue violet sequence kacha',
  'PARTS-43HS',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-43HS' 
       OR (p.slug = 'parts-43hs-blue-violet-sequence-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #679: PARTS-42SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-42SF',
  'parts-42sf-gold-brocade-kacha',
  'Gold Brocade Kacha',
  'Gold Brocade Kacha',
  'PARTS-42SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-42SF' 
       OR (p.slug = 'parts-42sf-gold-brocade-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #680: PARTS-42BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-42BS',
  'parts-42bs-gold-brocade-kacha',
  'Gold Brocade Kacha',
  'Gold Brocade Kacha',
  'PARTS-42BS',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-42BS' 
       OR (p.slug = 'parts-42bs-gold-brocade-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #681: PARTS-42HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-42HS',
  'parts-42hs-gold-brocade-kacha',
  'Gold Brocade Kacha',
  'Gold Brocade Kacha',
  'PARTS-42HS',
  125.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-42HS' 
       OR (p.slug = 'parts-42hs-gold-brocade-kacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #682: PARTS-41BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-41BS',
  'parts-41bs-black-plain',
  'Black plain',
  'Black plain',
  'PARTS-41BS',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-41BS' 
       OR (p.slug = 'parts-41bs-black-plain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #683: PARTS-41HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-41HS',
  'parts-41hs-black-plain',
  'Black plain',
  'Black plain',
  'PARTS-41HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-41HS' 
       OR (p.slug = 'parts-41hs-black-plain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #684: PARTS-40SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-40SF',
  'parts-40sf-gold-dot',
  'Gold dot',
  'Gold dot',
  'PARTS-40SF',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-40SF' 
       OR (p.slug = 'parts-40sf-gold-dot' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #685: PARTS-40BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-40BS',
  'parts-40bs-gold-dot',
  'Gold dot',
  'Gold dot',
  'PARTS-40BS',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-40BS' 
       OR (p.slug = 'parts-40bs-gold-dot' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #686: PARTS-39SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-39SF',
  'parts-39sf-blue-brocade',
  'Blue Brocade',
  'Blue Brocade',
  'PARTS-39SF',
  80.00,
  0.00,
  14,
  14,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-39SF' 
       OR (p.slug = 'parts-39sf-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #687: PARTS-39BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-39BS',
  'parts-39bs-blue-brocade',
  'Blue Brocade',
  'Blue Brocade',
  'PARTS-39BS',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-39BS' 
       OR (p.slug = 'parts-39bs-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #688: PARTS-39HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-39HS',
  'parts-39hs-blue-brocade',
  'Blue Brocade',
  'Blue Brocade',
  'PARTS-39HS',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-39HS' 
       OR (p.slug = 'parts-39hs-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #689: PARTS-38SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-38SF',
  'parts-38sf-red-brocade',
  'Red Brocade',
  'Red Brocade',
  'PARTS-38SF',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-38SF' 
       OR (p.slug = 'parts-38sf-red-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #690: PARTS-38BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-38BS',
  'parts-38bs-red-brocade',
  'Red Brocade',
  'Red Brocade',
  'PARTS-38BS',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-38BS' 
       OR (p.slug = 'parts-38bs-red-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #691: PARTS-38HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-38HS',
  'parts-38hs-red-brocade',
  'Red Brocade',
  'Red Brocade',
  'PARTS-38HS',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-38HS' 
       OR (p.slug = 'parts-38hs-red-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #692: PARTS-37SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-37SF',
  'parts-37sf-green-brocade',
  'Green Brocade',
  'Green Brocade',
  'PARTS-37SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-37SF' 
       OR (p.slug = 'parts-37sf-green-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #693: PARTS-37BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-37BS',
  'parts-37bs-green-brocade',
  'Green Brocade',
  'Green Brocade',
  'PARTS-37BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-37BS' 
       OR (p.slug = 'parts-37bs-green-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #694: PARTS-37HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-37HS',
  'parts-37hs-green-brocade',
  'Green Brocade',
  'Green Brocade',
  'PARTS-37HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-37HS' 
       OR (p.slug = 'parts-37hs-green-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #695: PARTS-36LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-36LF',
  'parts-36lf-red-gold-print',
  'Red gold print',
  'Red gold print',
  'PARTS-36LF',
  80.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-36LF' 
       OR (p.slug = 'parts-36lf-red-gold-print' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #696: PARTS-36BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-36BS',
  'parts-36bs-red-gold-print',
  'Red gold print',
  'Red gold print',
  'PARTS-36BS',
  80.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-36BS' 
       OR (p.slug = 'parts-36bs-red-gold-print' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #697: PARTS-36HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-36HS',
  'parts-36hs-red-gold-print',
  'Red gold print',
  'Red gold print',
  'PARTS-36HS',
  80.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-36HS' 
       OR (p.slug = 'parts-36hs-red-gold-print' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #698: PARTS-35SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-35SF',
  'parts-35sf-red-gold-brocade-glass-border',
  'Red gold brocade glass border',
  'Red gold brocade glass border',
  'PARTS-35SF',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-35SF' 
       OR (p.slug = 'parts-35sf-red-gold-brocade-glass-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #699: PARTS-35LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-35LF',
  'parts-35lf-red-gold-brocade-glass-border',
  'Red gold brocade glass border',
  'Red gold brocade glass border',
  'PARTS-35LF',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-35LF' 
       OR (p.slug = 'parts-35lf-red-gold-brocade-glass-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #700: PARTS-35BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-35BS',
  'parts-35bs-red-gold-brocade-glass-border',
  'Red gold brocade glass border',
  'Red gold brocade glass border',
  'PARTS-35BS',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-35BS' 
       OR (p.slug = 'parts-35bs-red-gold-brocade-glass-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #701: PARTS-35HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-35HS',
  'parts-35hs-red-gold-brocade-glass-border',
  'Red gold brocade glass border',
  'Red gold brocade glass border',
  'PARTS-35HS',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-35HS' 
       OR (p.slug = 'parts-35hs-red-gold-brocade-glass-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #702: PARTS-34SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-34SF',
  'parts-34sf-violet-gold-velvet-seqence',
  'Violet gold velvet seqence',
  'Violet gold velvet seqence',
  'PARTS-34SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-34SF' 
       OR (p.slug = 'parts-34sf-violet-gold-velvet-seqence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #703: PARTS-34LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-34LF',
  'parts-34lf-violet-gold-velvet-seqence',
  'Violet gold velvet seqence',
  'Violet gold velvet seqence',
  'PARTS-34LF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-34LF' 
       OR (p.slug = 'parts-34lf-violet-gold-velvet-seqence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #704: PARTS-34BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-34BS',
  'parts-34bs-violet-gold-velvet-seqence',
  'Violet gold velvet seqence',
  'Violet gold velvet seqence',
  'PARTS-34BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-34BS' 
       OR (p.slug = 'parts-34bs-violet-gold-velvet-seqence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #705: PARTS-34HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-34HS',
  'parts-34hs-violet-gold-velvet-seqence',
  'Violet gold velvet seqence',
  'Violet gold velvet seqence',
  'PARTS-34HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-34HS' 
       OR (p.slug = 'parts-34hs-violet-gold-velvet-seqence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #706: PARTS-33SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-33SF',
  'parts-33sf-off-white-gold-thread-hs-10-bs-7-lf-1-sf-1',
  'Off white gold thread HS-10 BS-7 LF-1 SF-1',
  'Off white gold thread HS-10 BS-7 LF-1 SF-1',
  'PARTS-33SF',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-33SF' 
       OR (p.slug = 'parts-33sf-off-white-gold-thread-hs-10-bs-7-lf-1-sf-1' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #707: PARTS-33LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-33LF',
  'parts-33lf-off-white-gold-thread-hs-10-bs-7-lf-1-sf-1',
  'Off white gold thread HS-10 BS-7 LF-1 SF-1',
  'Off white gold thread HS-10 BS-7 LF-1 SF-1',
  'PARTS-33LF',
  80.00,
  0.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-33LF' 
       OR (p.slug = 'parts-33lf-off-white-gold-thread-hs-10-bs-7-lf-1-sf-1' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #708: PARTS-33BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-33BS',
  'parts-33bs-off-white-gold-thread-hs-10-bs-7-lf-1-sf-1',
  'Off white gold thread HS-10 BS-7 LF-1 SF-1',
  'Off white gold thread HS-10 BS-7 LF-1 SF-1',
  'PARTS-33BS',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-33BS' 
       OR (p.slug = 'parts-33bs-off-white-gold-thread-hs-10-bs-7-lf-1-sf-1' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #709: PARTS-33HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-33HS',
  'parts-33hs-off-white-gold-thread-hs-10-bs-7-lf-1-sf-1',
  'Off white gold thread HS-10 BS-7 LF-1 SF-1',
  'Off white gold thread HS-10 BS-7 LF-1 SF-1',
  'PARTS-33HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-33HS' 
       OR (p.slug = 'parts-33hs-off-white-gold-thread-hs-10-bs-7-lf-1-sf-1' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #710: PARTS-32SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-32SF',
  'parts-32sf-green-gold-thread-hsbssf-7',
  'Green gold thread HS,BS,SF-7',
  'Green gold thread HS,BS,SF-7',
  'PARTS-32SF',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-32SF' 
       OR (p.slug = 'parts-32sf-green-gold-thread-hsbssf-7' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #711: PARTS-32BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-32BS',
  'parts-32bs-green-gold-thread-hsbssf-7',
  'Green gold thread HS,BS,SF-7',
  'Green gold thread HS,BS,SF-7',
  'PARTS-32BS',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-32BS' 
       OR (p.slug = 'parts-32bs-green-gold-thread-hsbssf-7' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #712: PARTS-32HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-32HS',
  'parts-32hs-green-gold-thread-hsbssf-7',
  'Green gold thread HS,BS,SF-7',
  'Green gold thread HS,BS,SF-7',
  'PARTS-32HS',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-32HS' 
       OR (p.slug = 'parts-32hs-green-gold-thread-hsbssf-7' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #713: PARTS-31BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-31BS',
  'parts-31bs-green-velvet-lace-border-hs-12-bs-12',
  'Green velvet lace border HS-12 BS-12',
  'Green velvet lace border HS-12 BS-12',
  'PARTS-31BS',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-31BS' 
       OR (p.slug = 'parts-31bs-green-velvet-lace-border-hs-12-bs-12' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #714: PARTS-31HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-31HS',
  'parts-31hs-green-velvet-lace-border-hs-12-bs-12',
  'Green velvet lace border HS-12 BS-12',
  'Green velvet lace border HS-12 BS-12',
  'PARTS-31HS',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-31HS' 
       OR (p.slug = 'parts-31hs-green-velvet-lace-border-hs-12-bs-12' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #715: PARTS-30LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-30LF',
  'parts-30lf-green-flower-cloth-blue-gold-hsbflf-7',
  'Green flower cloth blue gold HS,BF,LF-7',
  'Green flower cloth blue gold HS,BF,LF-7',
  'PARTS-30LF',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-30LF' 
       OR (p.slug = 'parts-30lf-green-flower-cloth-blue-gold-hsbflf-7' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #716: PARTS-30BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-30BS',
  'parts-30bs-green-flower-cloth-blue-gold-hsbflf-7',
  'Green flower cloth blue gold HS,BF,LF-7',
  'Green flower cloth blue gold HS,BF,LF-7',
  'PARTS-30BS',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-30BS' 
       OR (p.slug = 'parts-30bs-green-flower-cloth-blue-gold-hsbflf-7' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #717: PARTS-30HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-30HS',
  'parts-30hs-green-flower-cloth-blue-gold-hsbflf-7',
  'Green flower cloth blue gold HS,BF,LF-7',
  'Green flower cloth blue gold HS,BF,LF-7',
  'PARTS-30HS',
  80.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-30HS' 
       OR (p.slug = 'parts-30hs-green-flower-cloth-blue-gold-hsbflf-7' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #718: PARTS-29SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-29SF',
  'parts-29sf-red-velvet-kacha-13bs-10-sf-9',
  'Red velvet kacha-13,BS-10 SF-9',
  'Red velvet kacha-13,BS-10 SF-9',
  'PARTS-29SF',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-29SF' 
       OR (p.slug = 'parts-29sf-red-velvet-kacha-13bs-10-sf-9' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #719: PARTS-29BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-29BS',
  'parts-29bs-red-velvet-kacha-13bs-10-sf-9',
  'Red velvet kacha-13,BS-10 SF-9',
  'Red velvet kacha-13,BS-10 SF-9',
  'PARTS-29BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-29BS' 
       OR (p.slug = 'parts-29bs-red-velvet-kacha-13bs-10-sf-9' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #720: PARTS-29HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-29HS',
  'parts-29hs-red-velvet-kacha-13bs-10-sf-9',
  'Red velvet kacha-13,BS-10 SF-9',
  'Red velvet kacha-13,BS-10 SF-9',
  'PARTS-29HS',
  80.00,
  0.00,
  13,
  13,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-29HS' 
       OR (p.slug = 'parts-29hs-red-velvet-kacha-13bs-10-sf-9' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #721: PARTS-28LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-28LF',
  'parts-28lf-red-brocade-flower-hsbslf-10',
  'Red brocade flower HS,BS,LF-10',
  'Red brocade flower HS,BS,LF-10',
  'PARTS-28LF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-28LF' 
       OR (p.slug = 'parts-28lf-red-brocade-flower-hsbslf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #722: PARTS-28BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-28BS',
  'parts-28bs-red-brocade-flower-hsbslf-10',
  'Red brocade flower HS,BS,LF-10',
  'Red brocade flower HS,BS,LF-10',
  'PARTS-28BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-28BS' 
       OR (p.slug = 'parts-28bs-red-brocade-flower-hsbslf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #723: PARTS-28HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-28HS',
  'parts-28hs-red-brocade-flower-hsbslf-10',
  'Red brocade flower HS,BS,LF-10',
  'Red brocade flower HS,BS,LF-10',
  'PARTS-28HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-28HS' 
       OR (p.slug = 'parts-28hs-red-brocade-flower-hsbslf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #724: PARTS-27LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-27LF',
  'parts-27lf-gold-brocade-flower-hsbslf-8',
  'Gold brocade flower HS,BS,LF-8',
  'Gold brocade flower HS,BS,LF-8',
  'PARTS-27LF',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-27LF' 
       OR (p.slug = 'parts-27lf-gold-brocade-flower-hsbslf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #725: PARTS-27BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-27BS',
  'parts-27bs-gold-brocade-flower-hsbslf-8',
  'Gold brocade flower HS,BS,LF-8',
  'Gold brocade flower HS,BS,LF-8',
  'PARTS-27BS',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-27BS' 
       OR (p.slug = 'parts-27bs-gold-brocade-flower-hsbslf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #726: PARTS-27HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-27HS',
  'parts-27hs-gold-brocade-flower-hsbslf-8',
  'Gold brocade flower HS,BS,LF-8',
  'Gold brocade flower HS,BS,LF-8',
  'PARTS-27HS',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-27HS' 
       OR (p.slug = 'parts-27hs-gold-brocade-flower-hsbslf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #727: PARTS-26SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-26SF',
  'parts-26sf-yellow-gold-thread-hsbssf-11',
  'Yellow gold thread HS,BS,SF-11',
  'Yellow gold thread HS,BS,SF-11',
  'PARTS-26SF',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-26SF' 
       OR (p.slug = 'parts-26sf-yellow-gold-thread-hsbssf-11' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #728: PARTS-26BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-26BS',
  'parts-26bs-yellow-gold-thread-hsbssf-11',
  'Yellow gold thread HS,BS,SF-11',
  'Yellow gold thread HS,BS,SF-11',
  'PARTS-26BS',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-26BS' 
       OR (p.slug = 'parts-26bs-yellow-gold-thread-hsbssf-11' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #729: PARTS-26HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-26HS',
  'parts-26hs-yellow-gold-thread-hsbssf-11',
  'Yellow gold thread HS,BS,SF-11',
  'Yellow gold thread HS,BS,SF-11',
  'PARTS-26HS',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-26HS' 
       OR (p.slug = 'parts-26hs-yellow-gold-thread-hsbssf-11' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #730: PARTS-25LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-25LF',
  'parts-25lf-redgold-thread-work-hsbslf-8',
  'Red/Gold thread work HS,BS,LF-8',
  'Red/Gold thread work HS,BS,LF-8',
  'PARTS-25LF',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-25LF' 
       OR (p.slug = 'parts-25lf-redgold-thread-work-hsbslf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #731: PARTS-25BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-25BS',
  'parts-25bs-redgold-thread-work-hsbslf-8',
  'Red/Gold thread work HS,BS,LF-8',
  'Red/Gold thread work HS,BS,LF-8',
  'PARTS-25BS',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-25BS' 
       OR (p.slug = 'parts-25bs-redgold-thread-work-hsbslf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #732: PARTS-25HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-25HS',
  'parts-25hs-redgold-thread-work-hsbslf-8',
  'Red/Gold thread work HS,BS,LF-8',
  'Red/Gold thread work HS,BS,LF-8',
  'PARTS-25HS',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-25HS' 
       OR (p.slug = 'parts-25hs-redgold-thread-work-hsbslf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #733: PARTS-24SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-24SF',
  'parts-24sf-black-red-design-hsbslf-10-sf-9',
  'Black & Red design HS,BS,LF-10 SF-9',
  'Black & Red design HS,BS,LF-10 SF-9',
  'PARTS-24SF',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-24SF' 
       OR (p.slug = 'parts-24sf-black-red-design-hsbslf-10-sf-9' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #734: PARTS-24LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-24LF',
  'parts-24lf-black-red-design-hsbslf-10-sf-9',
  'Black & Red design HS,BS,LF-10 SF-9',
  'Black & Red design HS,BS,LF-10 SF-9',
  'PARTS-24LF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-24LF' 
       OR (p.slug = 'parts-24lf-black-red-design-hsbslf-10-sf-9' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #735: PARTS-24BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-24BS',
  'parts-24bs-black-red-design-hsbslf-10-sf-9',
  'Black & Red design HS,BS,LF-10 SF-9',
  'Black & Red design HS,BS,LF-10 SF-9',
  'PARTS-24BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-24BS' 
       OR (p.slug = 'parts-24bs-black-red-design-hsbslf-10-sf-9' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #736: PARTS-24HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-24HS',
  'parts-24hs-black-red-design-hsbslf-10-sf-9',
  'Black & Red design HS,BS,LF-10 SF-9',
  'Black & Red design HS,BS,LF-10 SF-9',
  'PARTS-24HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-24HS' 
       OR (p.slug = 'parts-24hs-black-red-design-hsbslf-10-sf-9' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #737: PARTS-23LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-23LF',
  'parts-23lf-red-brocade-hsbslf-10',
  'Red brocade HS,BS,LF-10',
  'Red brocade HS,BS,LF-10',
  'PARTS-23LF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-23LF' 
       OR (p.slug = 'parts-23lf-red-brocade-hsbslf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #738: PARTS-23BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-23BS',
  'parts-23bs-red-brocade-hsbslf-10',
  'Red brocade HS,BS,LF-10',
  'Red brocade HS,BS,LF-10',
  'PARTS-23BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-23BS' 
       OR (p.slug = 'parts-23bs-red-brocade-hsbslf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #739: PARTS-23HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-23HS',
  'parts-23hs-red-brocade-hsbslf-10',
  'Red brocade HS,BS,LF-10',
  'Red brocade HS,BS,LF-10',
  'PARTS-23HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-23HS' 
       OR (p.slug = 'parts-23hs-red-brocade-hsbslf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #740: PARTS-22SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-22SF',
  'parts-22sf-green-brocade-hsbssflf-10',
  'Green brocade HS,BS,SF,LF-10',
  'Green brocade HS,BS,SF,LF-10',
  'PARTS-22SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-22SF' 
       OR (p.slug = 'parts-22sf-green-brocade-hsbssflf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #741: PARTS-22LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-22LF',
  'parts-22lf-green-brocade-hsbssflf-10',
  'Green brocade HS,BS,SF,LF-10',
  'Green brocade HS,BS,SF,LF-10',
  'PARTS-22LF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-22LF' 
       OR (p.slug = 'parts-22lf-green-brocade-hsbssflf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #742: PARTS-22BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-22BS',
  'parts-22bs-green-brocade-hsbssflf-10',
  'Green brocade HS,BS,SF,LF-10',
  'Green brocade HS,BS,SF,LF-10',
  'PARTS-22BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-22BS' 
       OR (p.slug = 'parts-22bs-green-brocade-hsbssflf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #743: PARTS-22HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-22HS',
  'parts-22hs-green-brocade-hsbssflf-10',
  'Green brocade HS,BS,SF,LF-10',
  'Green brocade HS,BS,SF,LF-10',
  'PARTS-22HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-22HS' 
       OR (p.slug = 'parts-22hs-green-brocade-hsbssflf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #744: PARTS-21BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-21BS',
  'parts-21bs-black-design-bs-10-hs-10',
  'Black design BS-10 HS-10',
  'Black design BS-10 HS-10',
  'PARTS-21BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-21BS' 
       OR (p.slug = 'parts-21bs-black-design-bs-10-hs-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #745: PARTS-21HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-21HS',
  'parts-21hs-black-design-bs-10-hs-10',
  'Black design BS-10 HS-10',
  'Black design BS-10 HS-10',
  'PARTS-21HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-21HS' 
       OR (p.slug = 'parts-21hs-black-design-bs-10-hs-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #746: PARTS-20SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-20SF',
  'parts-20sf-orange-apple-cloth-hs-bs-sf-8',
  'Orange apple cloth HS, BS, SF-8',
  'Orange apple cloth HS, BS, SF-8',
  'PARTS-20SF',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-20SF' 
       OR (p.slug = 'parts-20sf-orange-apple-cloth-hs-bs-sf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #747: PARTS-20BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-20BS',
  'parts-20bs-orange-apple-cloth-hs-bs-sf-8',
  'Orange apple cloth HS, BS, SF-8',
  'Orange apple cloth HS, BS, SF-8',
  'PARTS-20BS',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-20BS' 
       OR (p.slug = 'parts-20bs-orange-apple-cloth-hs-bs-sf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #748: PARTS-20HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-20HS',
  'parts-20hs-orange-apple-cloth-hs-bs-sf-8',
  'Orange apple cloth HS, BS, SF-8',
  'Orange apple cloth HS, BS, SF-8',
  'PARTS-20HS',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-20HS' 
       OR (p.slug = 'parts-20hs-orange-apple-cloth-hs-bs-sf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #749: PARTS-19SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-19SF',
  'parts-19sf-majenta-brocade-hs-bs-lf-sf-10',
  'Majenta Brocade HS, BS, LF, SF-10',
  'Majenta Brocade HS, BS, LF, SF-10',
  'PARTS-19SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-19SF' 
       OR (p.slug = 'parts-19sf-majenta-brocade-hs-bs-lf-sf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #750: PARTS-19LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-19LF',
  'parts-19lf-majenta-brocade-hs-bs-lf-sf-10',
  'Majenta Brocade HS, BS, LF, SF-10',
  'Majenta Brocade HS, BS, LF, SF-10',
  'PARTS-19LF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-19LF' 
       OR (p.slug = 'parts-19lf-majenta-brocade-hs-bs-lf-sf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #751: PARTS-19BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-19BS',
  'parts-19bs-majenta-brocade-hs-bs-lf-sf-10',
  'Majenta Brocade HS, BS, LF, SF-10',
  'Majenta Brocade HS, BS, LF, SF-10',
  'PARTS-19BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-19BS' 
       OR (p.slug = 'parts-19bs-majenta-brocade-hs-bs-lf-sf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #752: PARTS-19HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-19HS',
  'parts-19hs-majenta-brocade-hs-bs-lf-sf-10',
  'Majenta Brocade HS, BS, LF, SF-10',
  'Majenta Brocade HS, BS, LF, SF-10',
  'PARTS-19HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-19HS' 
       OR (p.slug = 'parts-19hs-majenta-brocade-hs-bs-lf-sf-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #753: PARTS-18SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-18SF',
  'parts-18sf-blue-dot-bs-10-hs-10-sf-22',
  'Blue dot BS-10 HS-10 SF-22',
  'Blue dot BS-10 HS-10 SF-22',
  'PARTS-18SF',
  80.00,
  0.00,
  22,
  22,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-18SF' 
       OR (p.slug = 'parts-18sf-blue-dot-bs-10-hs-10-sf-22' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #754: PARTS-18BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-18BS',
  'parts-18bs-blue-dot-bs-10-hs-10-sf-22',
  'Blue dot BS-10 HS-10 SF-22',
  'Blue dot BS-10 HS-10 SF-22',
  'PARTS-18BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-18BS' 
       OR (p.slug = 'parts-18bs-blue-dot-bs-10-hs-10-sf-22' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #755: PARTS-18HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-18HS',
  'parts-18hs-blue-dot-bs-10-hs-10-sf-22',
  'Blue dot BS-10 HS-10 SF-22',
  'Blue dot BS-10 HS-10 SF-22',
  'PARTS-18HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-18HS' 
       OR (p.slug = 'parts-18hs-blue-dot-bs-10-hs-10-sf-22' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #756: PARTS-17SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-17SF',
  'parts-17sf-yellow-gold-plain-hsbslfsf-12',
  'Yellow gold plain HS,BS,LF,SF-12',
  'Yellow gold plain HS,BS,LF,SF-12',
  'PARTS-17SF',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-17SF' 
       OR (p.slug = 'parts-17sf-yellow-gold-plain-hsbslfsf-12' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #757: PARTS-17LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-17LF',
  'parts-17lf-yellow-gold-plain-hsbslfsf-12',
  'Yellow gold plain HS,BS,LF,SF-12',
  'Yellow gold plain HS,BS,LF,SF-12',
  'PARTS-17LF',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-17LF' 
       OR (p.slug = 'parts-17lf-yellow-gold-plain-hsbslfsf-12' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #758: PARTS-17BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-17BS',
  'parts-17bs-yellow-gold-plain-hsbslfsf-12',
  'Yellow gold plain HS,BS,LF,SF-12',
  'Yellow gold plain HS,BS,LF,SF-12',
  'PARTS-17BS',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-17BS' 
       OR (p.slug = 'parts-17bs-yellow-gold-plain-hsbslfsf-12' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #759: PARTS-17HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-17HS',
  'parts-17hs-yellow-gold-plain-hsbslfsf-12',
  'Yellow gold plain HS,BS,LF,SF-12',
  'Yellow gold plain HS,BS,LF,SF-12',
  'PARTS-17HS',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-17HS' 
       OR (p.slug = 'parts-17hs-yellow-gold-plain-hsbslfsf-12' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #760: PARTS-16HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-16HS',
  'parts-16hs-white-gold-seq-hs-10',
  'White gold seq HS-10',
  'White gold seq HS-10',
  'PARTS-16HS',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-16HS' 
       OR (p.slug = 'parts-16hs-white-gold-seq-hs-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #761: PARTS-15SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-15SF',
  'parts-15sf-offwhite-plain-sf-10-bs-10',
  'Offwhite plain SF-10 BS-10',
  'Offwhite plain SF-10 BS-10',
  'PARTS-15SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-15SF' 
       OR (p.slug = 'parts-15sf-offwhite-plain-sf-10-bs-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #762: PARTS-15BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-15BS',
  'parts-15bs-offwhite-plain-sf-10-bs-10',
  'Offwhite plain SF-10 BS-10',
  'Offwhite plain SF-10 BS-10',
  'PARTS-15BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-15BS' 
       OR (p.slug = 'parts-15bs-offwhite-plain-sf-10-bs-10' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #763: PARTS-14SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-14SF',
  'parts-14sf-offwhite-hs-8-bs-8-sf-9',
  'Offwhite HS-8 BS-8 SF-9',
  'Offwhite HS-8 BS-8 SF-9',
  'PARTS-14SF',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-14SF' 
       OR (p.slug = 'parts-14sf-offwhite-hs-8-bs-8-sf-9' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #764: PARTS-14BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-14BS',
  'parts-14bs-offwhite-hs-8-bs-8-sf-9',
  'Offwhite HS-8 BS-8 SF-9',
  'Offwhite HS-8 BS-8 SF-9',
  'PARTS-14BS',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-14BS' 
       OR (p.slug = 'parts-14bs-offwhite-hs-8-bs-8-sf-9' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #765: PARTS-14HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-14HS',
  'parts-14hs-offwhite-hs-8-bs-8-sf-9',
  'Offwhite HS-8 BS-8 SF-9',
  'Offwhite HS-8 BS-8 SF-9',
  'PARTS-14HS',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-14HS' 
       OR (p.slug = 'parts-14hs-offwhite-hs-8-bs-8-sf-9' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #766: PARTS-13BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-13BS',
  'parts-13bs-red-velvet-small-dot-bs-5',
  'Red velvet small dot BS-5',
  'Red velvet small dot BS-5',
  'PARTS-13BS',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-13BS' 
       OR (p.slug = 'parts-13bs-red-velvet-small-dot-bs-5' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #767: PARTS-12SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-12SF',
  'parts-12sf-red-velvet-flower-design-hs-9-bs-9-sf-8',
  'Red velvet flower design HS-9 BS-9 SF-8',
  'Red velvet flower design HS-9 BS-9 SF-8',
  'PARTS-12SF',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-12SF' 
       OR (p.slug = 'parts-12sf-red-velvet-flower-design-hs-9-bs-9-sf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #768: PARTS-12BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-12BS',
  'parts-12bs-red-velvet-flower-design-hs-9-bs-9-sf-8',
  'Red velvet flower design HS-9 BS-9 SF-8',
  'Red velvet flower design HS-9 BS-9 SF-8',
  'PARTS-12BS',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-12BS' 
       OR (p.slug = 'parts-12bs-red-velvet-flower-design-hs-9-bs-9-sf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #769: PARTS-12HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-12HS',
  'parts-12hs-red-velvet-flower-design-hs-9-bs-9-sf-8',
  'Red velvet flower design HS-9 BS-9 SF-8',
  'Red velvet flower design HS-9 BS-9 SF-8',
  'PARTS-12HS',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-12HS' 
       OR (p.slug = 'parts-12hs-red-velvet-flower-design-hs-9-bs-9-sf-8' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #770: PARTS-11SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-11SF',
  'parts-11sf-gold-long-fan',
  'Gold long fan',
  'Gold long fan',
  'PARTS-11SF',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-11SF' 
       OR (p.slug = 'parts-11sf-gold-long-fan' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #771: PARTS-10SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-10SF',
  'parts-10sf-blue-velvet-lf-14-sf-14',
  'Blue velvet LF-14 SF-14',
  'Blue velvet LF-14 SF-14',
  'PARTS-10SF',
  80.00,
  0.00,
  14,
  14,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-10SF' 
       OR (p.slug = 'parts-10sf-blue-velvet-lf-14-sf-14' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #772: PARTS-10LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-10LF',
  'parts-10lf-blue-velvet-lf-14-sf-14',
  'Blue velvet LF-14 SF-14',
  'Blue velvet LF-14 SF-14',
  'PARTS-10LF',
  80.00,
  0.00,
  14,
  14,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-10LF' 
       OR (p.slug = 'parts-10lf-blue-velvet-lf-14-sf-14' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #773: PARTS-9SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-9SF',
  'parts-9sf-plain-black-velvet-hs-4-bs-4',
  'Plain black velvet HS-4 BS-4',
  'Plain black velvet HS-4 BS-4',
  'PARTS-9SF',
  80.00,
  0.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-9SF' 
       OR (p.slug = 'parts-9sf-plain-black-velvet-hs-4-bs-4' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #774: PARTS-9BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-9BS',
  'parts-9bs-plain-black-velvet-hs-4-bs-4',
  'Plain black velvet HS-4 BS-4',
  'Plain black velvet HS-4 BS-4',
  'PARTS-9BS',
  80.00,
  0.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-9BS' 
       OR (p.slug = 'parts-9bs-plain-black-velvet-hs-4-bs-4' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #775: PARTS-9HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-9HS',
  'parts-9hs-plain-black-velvet-hs-4-bs-4',
  'Plain black velvet HS-4 BS-4',
  'Plain black velvet HS-4 BS-4',
  'PARTS-9HS',
  80.00,
  0.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-9HS' 
       OR (p.slug = 'parts-9hs-plain-black-velvet-hs-4-bs-4' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #776: PARTS-8SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-8SF',
  'parts-8sf-blue-velvet-hs-13-bs-13-sf-13',
  'Blue velvet HS-13 BS-13 SF-13',
  'Blue velvet HS-13 BS-13 SF-13',
  'PARTS-8SF',
  80.00,
  0.00,
  13,
  13,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-8SF' 
       OR (p.slug = 'parts-8sf-blue-velvet-hs-13-bs-13-sf-13' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #777: PARTS-8BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-8BS',
  'parts-8bs-blue-velvet-hs-13-bs-13-sf-13',
  'Blue velvet HS-13 BS-13 SF-13',
  'Blue velvet HS-13 BS-13 SF-13',
  'PARTS-8BS',
  80.00,
  0.00,
  13,
  13,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-8BS' 
       OR (p.slug = 'parts-8bs-blue-velvet-hs-13-bs-13-sf-13' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #778: PARTS-8HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-8HS',
  'parts-8hs-blue-velvet-hs-13-bs-13-sf-13',
  'Blue velvet HS-13 BS-13 SF-13',
  'Blue velvet HS-13 BS-13 SF-13',
  'PARTS-8HS',
  80.00,
  0.00,
  13,
  13,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-8HS' 
       OR (p.slug = 'parts-8hs-blue-velvet-hs-13-bs-13-sf-13' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #779: PARTS-7SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-7SF',
  'parts-7sf-orange-velvet-full-sequence',
  'Orange velvet full sequence',
  'Orange velvet full sequence',
  'PARTS-7SF',
  80.00,
  0.00,
  15,
  15,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-7SF' 
       OR (p.slug = 'parts-7sf-orange-velvet-full-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #780: PARTS-7BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-7BS',
  'parts-7bs-orange-velvet-full-sequence',
  'Orange velvet full sequence',
  'Orange velvet full sequence',
  'PARTS-7BS',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-7BS' 
       OR (p.slug = 'parts-7bs-orange-velvet-full-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #781: PARTS-7HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-7HS',
  'parts-7hs-orange-velvet-full-sequence',
  'Orange velvet full sequence',
  'Orange velvet full sequence',
  'PARTS-7HS',
  80.00,
  0.00,
  15,
  15,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-7HS' 
       OR (p.slug = 'parts-7hs-orange-velvet-full-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #782: PARTS-6SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-6SF',
  'parts-6sf-black-velvet-mirror-border',
  'Black velvet mirror border',
  'Black velvet mirror border',
  'PARTS-6SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-6SF' 
       OR (p.slug = 'parts-6sf-black-velvet-mirror-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #783: PARTS-6BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-6BS',
  'parts-6bs-black-velvet-mirror-border',
  'Black velvet mirror border',
  'Black velvet mirror border',
  'PARTS-6BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-6BS' 
       OR (p.slug = 'parts-6bs-black-velvet-mirror-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #784: PARTS-6HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-6HS',
  'parts-6hs-black-velvet-mirror-border',
  'Black velvet mirror border',
  'Black velvet mirror border',
  'PARTS-6HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-6HS' 
       OR (p.slug = 'parts-6hs-black-velvet-mirror-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #785: PARTS-5SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-5SF',
  'parts-5sf-gold',
  'Gold',
  'Gold',
  'PARTS-5SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-5SF' 
       OR (p.slug = 'parts-5sf-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #786: PARTS-5LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-5LF',
  'parts-5lf-gold',
  'Gold',
  'Gold',
  'PARTS-5LF',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-5LF' 
       OR (p.slug = 'parts-5lf-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #787: PARTS-5BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-5BS',
  'parts-5bs-gold',
  'Gold',
  'Gold',
  'PARTS-5BS',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-5BS' 
       OR (p.slug = 'parts-5bs-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #788: PARTS-5HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-5HS',
  'parts-5hs-gold',
  'Gold',
  'Gold',
  'PARTS-5HS',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-5HS' 
       OR (p.slug = 'parts-5hs-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #789: PARTS-4SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-4SF',
  'parts-4sf-red-sequence-border-lfhsbssf',
  'Red sequence border LF/HS/BS/SF',
  'Red sequence border LF/HS/BS/SF',
  'PARTS-4SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-4SF' 
       OR (p.slug = 'parts-4sf-red-sequence-border-lfhsbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #790: PARTS-4LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-4LF',
  'parts-4lf-red-sequence-border-lfhsbssf',
  'Red sequence border LF/HS/BS/SF',
  'Red sequence border LF/HS/BS/SF',
  'PARTS-4LF',
  80.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-4LF' 
       OR (p.slug = 'parts-4lf-red-sequence-border-lfhsbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #791: PARTS-4BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-4BS',
  'parts-4bs-red-sequence-border-lfhsbssf',
  'Red sequence border LF/HS/BS/SF',
  'Red sequence border LF/HS/BS/SF',
  'PARTS-4BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-4BS' 
       OR (p.slug = 'parts-4bs-red-sequence-border-lfhsbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #792: PARTS-4HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-4HS',
  'parts-4hs-red-sequence-border-lfhsbssf',
  'Red sequence border LF/HS/BS/SF',
  'Red sequence border LF/HS/BS/SF',
  'PARTS-4HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-4HS' 
       OR (p.slug = 'parts-4hs-red-sequence-border-lfhsbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #793: PARTS-3SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-3SF',
  'parts-3sf-green-full-sequencemirror-border-hslfbssf',
  'Green full sequencemirror border HS/LF/BS/SF',
  'Green full sequencemirror border HS/LF/BS/SF',
  'PARTS-3SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-3SF' 
       OR (p.slug = 'parts-3sf-green-full-sequencemirror-border-hslfbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #794: PARTS-3LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-3LF',
  'parts-3lf-green-full-sequencemirror-border-hslfbssf',
  'Green full sequencemirror border HS/LF/BS/SF',
  'Green full sequencemirror border HS/LF/BS/SF',
  'PARTS-3LF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-3LF' 
       OR (p.slug = 'parts-3lf-green-full-sequencemirror-border-hslfbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #795: PARTS-3BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-3BS',
  'parts-3bs-green-full-sequencemirror-border-hslfbssf',
  'Green full sequencemirror border HS/LF/BS/SF',
  'Green full sequencemirror border HS/LF/BS/SF',
  'PARTS-3BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-3BS' 
       OR (p.slug = 'parts-3bs-green-full-sequencemirror-border-hslfbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #796: PARTS-3HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-3HS',
  'parts-3hs-green-full-sequencemirror-border-hslfbssf',
  'Green full sequencemirror border HS/LF/BS/SF',
  'Green full sequencemirror border HS/LF/BS/SF',
  'PARTS-3HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-3HS' 
       OR (p.slug = 'parts-3hs-green-full-sequencemirror-border-hslfbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #797: PARTS-2SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-2SF',
  'parts-2sf-black-apple-gold-design-hsbssf',
  'Black apple gold design HS/BS/SF',
  'Black apple gold design HS/BS/SF',
  'PARTS-2SF',
  80.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-2SF' 
       OR (p.slug = 'parts-2sf-black-apple-gold-design-hsbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #798: PARTS-2BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-2BS',
  'parts-2bs-black-apple-gold-design-hsbssf',
  'Black apple gold design HS/BS/SF',
  'Black apple gold design HS/BS/SF',
  'PARTS-2BS',
  80.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-2BS' 
       OR (p.slug = 'parts-2bs-black-apple-gold-design-hsbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #799: PARTS-2HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-2HS',
  'parts-2hs-black-apple-gold-design-hsbssf',
  'Black apple gold design HS/BS/SF',
  'Black apple gold design HS/BS/SF',
  'PARTS-2HS',
  80.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-2HS' 
       OR (p.slug = 'parts-2hs-black-apple-gold-design-hsbssf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #800: PARTS-1SF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-1SF',
  'parts-1sf-black-velvet-gold-sequence',
  'Black velvet gold sequence',
  'Black velvet gold sequence',
  'PARTS-1SF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-1SF' 
       OR (p.slug = 'parts-1sf-black-velvet-gold-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #801: PARTS-1LF
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-1LF',
  'parts-1lf-black-velvet-gold-sequence',
  'Black velvet gold sequence',
  'Black velvet gold sequence',
  'PARTS-1LF',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-1LF' 
       OR (p.slug = 'parts-1lf-black-velvet-gold-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #802: PARTS-1BS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-1BS',
  'parts-1bs-black-velvet-gold-sequence',
  'Black velvet gold sequence',
  'Black velvet gold sequence',
  'PARTS-1BS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-1BS' 
       OR (p.slug = 'parts-1bs-black-velvet-gold-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #803: PARTS-1HS
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'parts' AND store_id = s.id LIMIT 1),
  b.id,
  'PARTS-1HS',
  'parts-1hs-black-velvet-gold-sequence',
  'Black velvet gold sequence',
  'Black velvet gold sequence',
  'PARTS-1HS',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARTS-1HS' 
       OR (p.slug = 'parts-1hs-black-velvet-gold-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #804: PANT-75
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-75',
  'pant-75-vadaulla-small-seq',
  'Vada,ulla small seq',
  'Vada,ulla small seq',
  'PANT-75',
  225.00,
  400.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-75' 
       OR (p.slug = 'pant-75-vadaulla-small-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #805: PANT-74
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-74',
  'pant-74-kavi-pant',
  'Kavi pant',
  'Kavi pant',
  'PANT-74',
  125.00,
  300.00,
  13,
  13,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-74' 
       OR (p.slug = 'pant-74-kavi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #806: PANT-73
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-73',
  'pant-73-neriyathu-pant-dhothi-model',
  'Neriyathu pant dhothi model',
  'Neriyathu pant dhothi model',
  'PANT-73',
  150.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-73' 
       OR (p.slug = 'pant-73-neriyathu-pant-dhothi-model' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #807: PANT-72
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-72',
  'pant-72-majenta-brocade-pant-shawl-krishna',
  'Majenta brocade pant shawl Krishna',
  'Majenta brocade pant shawl Krishna',
  'PANT-72',
  225.00,
  500.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-72' 
       OR (p.slug = 'pant-72-majenta-brocade-pant-shawl-krishna' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #808: PANT-71
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-71',
  'pant-71-yellow-brocade-pant-shawl-krishna',
  'Yellow brocade pant shawl krishna',
  'Yellow brocade pant shawl krishna',
  'PANT-71',
  225.00,
  500.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-71' 
       OR (p.slug = 'pant-71-yellow-brocade-pant-shawl-krishna' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #809: PANT-70
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-70',
  'pant-70-red-brocade-pant-shawl-krishna',
  'Red brocade pant shawl Krishna',
  'Red brocade pant shawl Krishna',
  'PANT-70',
  225.00,
  500.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-70' 
       OR (p.slug = 'pant-70-red-brocade-pant-shawl-krishna' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #810: PANT-69
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-69',
  'pant-69-copper-sulphate-blue-brocade-pant-shawl-krishna',
  'Copper sulphate blue brocade pant shawl krishna',
  'Copper sulphate blue brocade pant shawl krishna',
  'PANT-69',
  225.00,
  500.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-69' 
       OR (p.slug = 'pant-69-copper-sulphate-blue-brocade-pant-shawl-krishna' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #811: PANT-68
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-68',
  'pant-68-black-folk-pant-only',
  'Black folk pant only',
  'Black folk pant only',
  'PANT-68',
  260.00,
  500.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-68' 
       OR (p.slug = 'pant-68-black-folk-pant-only' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #812: PANT-67
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-67',
  'pant-67-yello-net-gold-lace-border',
  'Yello net /Gold lace border',
  'Yello net /Gold lace border',
  'PANT-67',
  150.00,
  300.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-67' 
       OR (p.slug = 'pant-67-yello-net-gold-lace-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #813: PANT-66
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-66',
  'pant-66-majenta-net-patiyala-with-blue-gold-seq-border',
  'Majenta net patiyala with blue gold seq border',
  'Majenta net patiyala with blue gold seq border',
  'PANT-66',
  175.00,
  300.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-66' 
       OR (p.slug = 'pant-66-majenta-net-patiyala-with-blue-gold-seq-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #814: PANT-65
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-65',
  'pant-65-orange-satin-dhothi-pant',
  'Orange satin dhothi pant',
  'Orange satin dhothi pant',
  'PANT-65',
  175.00,
  300.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-65' 
       OR (p.slug = 'pant-65-orange-satin-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #815: PANT-64
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-64',
  'pant-64-white-satin-dhothi-pant',
  'White satin dhothi pant',
  'White satin dhothi pant',
  'PANT-64',
  125.00,
  300.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-64' 
       OR (p.slug = 'pant-64-white-satin-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #816: PANT-63
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-63',
  'pant-63-red-satin-dhothi-pant-thin-border',
  'Red satin dhothi pant thin border',
  'Red satin dhothi pant thin border',
  'PANT-63',
  125.00,
  300.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-63' 
       OR (p.slug = 'pant-63-red-satin-dhothi-pant-thin-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #817: PANT-62
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-62',
  'pant-62-blue-polyster-dhothi-pant',
  'Blue polyster dhothi pant',
  'Blue polyster dhothi pant',
  'PANT-62',
  125.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-62' 
       OR (p.slug = 'pant-62-blue-polyster-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #818: PANT-61
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-61',
  'pant-61-black-small-seq-pant',
  'Black small seq pant',
  'Black small seq pant',
  'PANT-61',
  175.00,
  300.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-61' 
       OR (p.slug = 'pant-61-black-small-seq-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #819: PANT-60
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-60',
  'pant-60-white-brocade-sunfleet-pant',
  'White brocade sunfleet pant',
  'White brocade sunfleet pant',
  'PANT-60',
  325.00,
  500.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-60' 
       OR (p.slug = 'pant-60-white-brocade-sunfleet-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #820: PANT-59
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-59',
  'pant-59-black-vevlet-normal-pant',
  'Black vevlet Normal Pant',
  'Black vevlet Normal Pant',
  'PANT-59',
  175.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-59' 
       OR (p.slug = 'pant-59-black-vevlet-normal-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #821: PANT-58
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-58',
  'pant-58-black-big-sequence-patiyala-pant',
  'Black big sequence Patiyala Pant',
  'Black big sequence Patiyala Pant',
  'PANT-58',
  225.00,
  400.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-58' 
       OR (p.slug = 'pant-58-black-big-sequence-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #822: PANT-57
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-57',
  'pant-57-black-pant-with-gold-sequence-zigzag-line-normal-p',
  'Black pant with gold sequence zigzag line Normal P',
  'Black pant with gold sequence zigzag line Normal P',
  'PANT-57',
  175.00,
  300.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-57' 
       OR (p.slug = 'pant-57-black-pant-with-gold-sequence-zigzag-line-normal-p' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #823: PANT-56
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-56',
  'pant-56-pist-green-majenta-border-normal-pant',
  'Pist green majenta border Normal Pant',
  'Pist green majenta border Normal Pant',
  'PANT-56',
  125.00,
  300.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-56' 
       OR (p.slug = 'pant-56-pist-green-majenta-border-normal-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #824: PANT-55
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-55',
  'pant-55-gold-satin-long-normal-pant',
  'Gold satin long Normal Pant',
  'Gold satin long Normal Pant',
  'PANT-55',
  125.00,
  300.00,
  14,
  14,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-55' 
       OR (p.slug = 'pant-55-gold-satin-long-normal-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #825: PANT-54
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-54',
  'pant-54-red-satin-black-border-34th-normal-pant',
  'Red satin black border 3/4th Normal Pant',
  'Red satin black border 3/4th Normal Pant',
  'PANT-54',
  125.00,
  300.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-54' 
       OR (p.slug = 'pant-54-red-satin-black-border-34th-normal-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #826: PANT-53
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-53',
  'pant-53-black-silver-sequence-patiyala-pant',
  'Black silver sequence Patiyala Pant',
  'Black silver sequence Patiyala Pant',
  'PANT-53',
  225.00,
  300.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-53' 
       OR (p.slug = 'pant-53-black-silver-sequence-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #827: PANT-52
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-52',
  'pant-52-green-tikky-patiyala-pant',
  'Green tikky Patiyala Pant',
  'Green tikky Patiyala Pant',
  'PANT-52',
  125.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-52' 
       OR (p.slug = 'pant-52-green-tikky-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #828: PANT-51
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-51',
  'pant-51-green-sequence-patiyala-pant',
  'Green sequence Patiyala Pant',
  'Green sequence Patiyala Pant',
  'PANT-51',
  175.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-51' 
       OR (p.slug = 'pant-51-green-sequence-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #829: PANT-50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-50',
  'pant-50-majenta-black-shimmer-cloth-patiyala-pant',
  'Majenta black shimmer cloth Patiyala Pant',
  'Majenta black shimmer cloth Patiyala Pant',
  'PANT-50',
  225.00,
  400.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-50' 
       OR (p.slug = 'pant-50-majenta-black-shimmer-cloth-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #830: PANT-49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-49',
  'pant-49-majenta-net-dot-patiyala-pant',
  'Majenta net dot Patiyala Pant',
  'Majenta net dot Patiyala Pant',
  'PANT-49',
  175.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-49' 
       OR (p.slug = 'pant-49-majenta-net-dot-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #831: PANT-48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-48',
  'pant-48-black-satin-dot-patiyala-pant',
  'Black satin dot Patiyala Pant',
  'Black satin dot Patiyala Pant',
  'PANT-48',
  125.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-48' 
       OR (p.slug = 'pant-48-black-satin-dot-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #832: PANT-47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-47',
  'pant-47-tikky-black-patiyala-pant',
  'Tikky black Patiyala Pant',
  'Tikky black Patiyala Pant',
  'PANT-47',
  125.00,
  300.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-47' 
       OR (p.slug = 'pant-47-tikky-black-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #833: PANT-46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-46',
  'pant-46-orange-sequence-patiyala-pant',
  'Orange sequence Patiyala Pant',
  'Orange sequence Patiyala Pant',
  'PANT-46',
  175.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-46' 
       OR (p.slug = 'pant-46-orange-sequence-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #834: PANT-45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-45',
  'pant-45-black-sequence-normal-pant',
  'Black sequence Normal Pant',
  'Black sequence Normal Pant',
  'PANT-45',
  175.00,
  300.00,
  18,
  18,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-45' 
       OR (p.slug = 'pant-45-black-sequence-normal-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #835: PANT-44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-44',
  'pant-44-majenta-satin-with-gold-border-dhothi-pant',
  'Majenta satin with gold border Dhothi Pant',
  'Majenta satin with gold border Dhothi Pant',
  'PANT-44',
  125.00,
  300.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-44' 
       OR (p.slug = 'pant-44-majenta-satin-with-gold-border-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #836: PANT-43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-43',
  'pant-43-gold-sequence-patiyala-pant',
  'Gold sequence Patiyala Pant',
  'Gold sequence Patiyala Pant',
  'PANT-43',
  175.00,
  300.00,
  19,
  19,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-43' 
       OR (p.slug = 'pant-43-gold-sequence-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #837: PANT-42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-42',
  'pant-42-red-net-dot-patiyala-pant',
  'Red net dot Patiyala Pant',
  'Red net dot Patiyala Pant',
  'PANT-42',
  125.00,
  300.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-42' 
       OR (p.slug = 'pant-42-red-net-dot-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #838: PANT-41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-41',
  'pant-41-yellow-orange-satin-dot-patiyala-pant',
  'Yellow orange satin dot Patiyala Pant',
  'Yellow orange satin dot Patiyala Pant',
  'PANT-41',
  125.00,
  300.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-41' 
       OR (p.slug = 'pant-41-yellow-orange-satin-dot-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #839: PANT-40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-40',
  'pant-40-blue-net-flower-patiyala-pant',
  'Blue net flower Patiyala Pant',
  'Blue net flower Patiyala Pant',
  'PANT-40',
  175.00,
  300.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-40' 
       OR (p.slug = 'pant-40-blue-net-flower-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #840: PANT-39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-39',
  'pant-39-balck-satin-dot-dhothi-pant',
  'Balck satin dot Dhothi Pant',
  'Balck satin dot Dhothi Pant',
  'PANT-39',
  125.00,
  300.00,
  13,
  13,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-39' 
       OR (p.slug = 'pant-39-balck-satin-dot-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #841: PANT-38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-38',
  'pant-38-blue-seq-dhothi-model-dhothi-pant',
  'Blue seq dhothi model Dhothi Pant',
  'Blue seq dhothi model Dhothi Pant',
  'PANT-38',
  175.00,
  300.00,
  18,
  18,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-38' 
       OR (p.slug = 'pant-38-blue-seq-dhothi-model-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #842: PANT-37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-37',
  'pant-37-kilipacha-majenta-small-patiyala-pant',
  'Kilipacha majenta small Patiyala Pant',
  'Kilipacha majenta small Patiyala Pant',
  'PANT-37',
  175.00,
  300.00,
  17,
  17,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-37' 
       OR (p.slug = 'pant-37-kilipacha-majenta-small-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #843: PANT-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-36',
  'pant-36-peacock-blue-small-patiyala-pant',
  'Peacock blue small Patiyala Pant',
  'Peacock blue small Patiyala Pant',
  'PANT-36',
  125.00,
  300.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-36' 
       OR (p.slug = 'pant-36-peacock-blue-small-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #844: PANT-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-35',
  'pant-35-blue-seq-patiyala-pant',
  'Blue seq Patiyala Pant',
  'Blue seq Patiyala Pant',
  'PANT-35',
  125.00,
  300.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-35' 
       OR (p.slug = 'pant-35-blue-seq-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #845: PANT-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-34',
  'pant-34-heavy-orange-seq-pantblue-border-patiyala-pant',
  'Heavy orange seq pant/Blue border Patiyala Pant',
  'Heavy orange seq pant/Blue border Patiyala Pant',
  'PANT-34',
  225.00,
  300.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-34' 
       OR (p.slug = 'pant-34-heavy-orange-seq-pantblue-border-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #846: PANT-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-33',
  'pant-33-light-orange-seq-pant-blue-border-patiyala-pant',
  'Light orange seq pant/ Blue border Patiyala Pant',
  'Light orange seq pant/ Blue border Patiyala Pant',
  'PANT-33',
  225.00,
  300.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-33' 
       OR (p.slug = 'pant-33-light-orange-seq-pant-blue-border-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #847: PANT-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-32',
  'pant-32-orange-tikky-pant-with-blue-border-patiyala-pant',
  'Orange tikky pant with blue border Patiyala Pant',
  'Orange tikky pant with blue border Patiyala Pant',
  'PANT-32',
  175.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-32' 
       OR (p.slug = 'pant-32-orange-tikky-pant-with-blue-border-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #848: PANT-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-31',
  'pant-31-majenta-seq-pant-green-border-patiyala-pant',
  'Majenta seq pant green border Patiyala Pant',
  'Majenta seq pant green border Patiyala Pant',
  'PANT-31',
  125.00,
  300.00,
  14,
  14,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-31' 
       OR (p.slug = 'pant-31-majenta-seq-pant-green-border-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #849: PANT-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-30',
  'pant-30-black-net-gold-dot-print-patiyala-pant',
  'Black net gold dot print Patiyala Pant',
  'Black net gold dot print Patiyala Pant',
  'PANT-30',
  125.00,
  300.00,
  28,
  28,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-30' 
       OR (p.slug = 'pant-30-black-net-gold-dot-print-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #850: PANT-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-29',
  'pant-29-plain-red-pant-up-normal-pant',
  'Plain red pant UP Normal Pant',
  'Plain red pant UP Normal Pant',
  'PANT-29',
  125.00,
  300.00,
  20,
  20,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-29' 
       OR (p.slug = 'pant-29-plain-red-pant-up-normal-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #851: PANT-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-28',
  'pant-28-red-net-patiyala-black-border-patiyala-pant',
  'Red net patiyala black border Patiyala Pant',
  'Red net patiyala black border Patiyala Pant',
  'PANT-28',
  125.00,
  300.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-28' 
       OR (p.slug = 'pant-28-red-net-patiyala-black-border-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #852: PANT-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-27',
  'pant-27-gold-seq-pant-red-side-line-normal-pant',
  'Gold seq pant red side line Normal Pant',
  'Gold seq pant red side line Normal Pant',
  'PANT-27',
  125.00,
  300.00,
  13,
  13,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-27' 
       OR (p.slug = 'pant-27-gold-seq-pant-red-side-line-normal-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #853: PANT-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-26',
  'pant-26-blue-net-gold-long-patiyala-pant',
  'Blue net gold long Patiyala Pant',
  'Blue net gold long Patiyala Pant',
  'PANT-26',
  175.00,
  300.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-26' 
       OR (p.slug = 'pant-26-blue-net-gold-long-patiyala-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #854: PANT-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-25',
  'pant-25-red-normal-pant',
  'Red Normal Pant',
  'Red Normal Pant',
  'PANT-25',
  125.00,
  300.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-25' 
       OR (p.slug = 'pant-25-red-normal-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #855: PANT-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-24',
  'pant-24-ash-normal-pant',
  'Ash Normal Pant',
  'Ash Normal Pant',
  'PANT-24',
  125.00,
  300.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-24' 
       OR (p.slug = 'pant-24-ash-normal-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #856: PANT-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-23',
  'pant-23-violet-dhothi-pant',
  'Violet Dhothi Pant',
  'Violet Dhothi Pant',
  'PANT-23',
  125.00,
  300.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-23' 
       OR (p.slug = 'pant-23-violet-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #857: PANT-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-22',
  'pant-22-blue-plain-patiyala-palazo-pant',
  'Blue plain patiyala Palazo pant',
  'Blue plain patiyala Palazo pant',
  'PANT-22',
  175.00,
  300.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-22' 
       OR (p.slug = 'pant-22-blue-plain-patiyala-palazo-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #858: PANT-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-21',
  'pant-21-pink-plain-patiyala-palazo-pant',
  'Pink plain Patiyala Palazo pant',
  'Pink plain Patiyala Palazo pant',
  'PANT-21',
  175.00,
  300.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-21' 
       OR (p.slug = 'pant-21-pink-plain-patiyala-palazo-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #859: PANT-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-20',
  'pant-20-yellow-green-border-dhothi-pant',
  'Yellow green border Dhothi Pant',
  'Yellow green border Dhothi Pant',
  'PANT-20',
  180.00,
  300.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-20' 
       OR (p.slug = 'pant-20-yellow-green-border-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #860: PANT-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-19',
  'pant-19-yellow-red-border-dhothi-pant',
  'Yellow red border Dhothi Pant',
  'Yellow red border Dhothi Pant',
  'PANT-19',
  180.00,
  300.00,
  13,
  13,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-19' 
       OR (p.slug = 'pant-19-yellow-red-border-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #861: PANT-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-18',
  'pant-18-gold-orange-big-sequence-kg-sizenormal-pant',
  'Gold /Orange big sequence KG sizeNormal Pant',
  'Gold /Orange big sequence KG sizeNormal Pant',
  'PANT-18',
  225.00,
  500.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-18' 
       OR (p.slug = 'pant-18-gold-orange-big-sequence-kg-sizenormal-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #862: PANT-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-17',
  'pant-17-green-brocade-dhothi-pant',
  'Green brocade Dhothi Pant',
  'Green brocade Dhothi Pant',
  'PANT-17',
  225.00,
  500.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-17' 
       OR (p.slug = 'pant-17-green-brocade-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #863: PANT-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-16',
  'pant-16-whiteblack-border-dhothi-pant',
  'White/Black border Dhothi Pant',
  'White/Black border Dhothi Pant',
  'PANT-16',
  260.00,
  500.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-16' 
       OR (p.slug = 'pant-16-whiteblack-border-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #864: PANT-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-15',
  'pant-15-yellow-brocade-dhothi-pant',
  'Yellow brocade Dhothi Pant',
  'Yellow brocade Dhothi Pant',
  'PANT-15',
  260.00,
  500.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-15' 
       OR (p.slug = 'pant-15-yellow-brocade-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #865: PANT-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-14',
  'pant-14-majenta-brocadekacha-dhothi-pant',
  'Majenta brocade/Kacha Dhothi Pant',
  'Majenta brocade/Kacha Dhothi Pant',
  'PANT-14',
  260.00,
  500.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-14' 
       OR (p.slug = 'pant-14-majenta-brocadekacha-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #866: PANT-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-13',
  'pant-13-red-brocade-dhothi-pant',
  'Red brocade Dhothi Pant',
  'Red brocade Dhothi Pant',
  'PANT-13',
  260.00,
  500.00,
  17,
  17,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-13' 
       OR (p.slug = 'pant-13-red-brocade-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #867: PANT-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-12',
  'pant-12-orangeviolet-dhothi-pant',
  'Orange/Violet Dhothi Pant',
  'Orange/Violet Dhothi Pant',
  'PANT-12',
  260.00,
  500.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-12' 
       OR (p.slug = 'pant-12-orangeviolet-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #868: PANT-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-11',
  'pant-11-kilipacha-brocadekacha-model-dhothi-pant',
  'Kilipacha brocade/Kacha model Dhothi Pant',
  'Kilipacha brocade/Kacha model Dhothi Pant',
  'PANT-11',
  260.00,
  500.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-11' 
       OR (p.slug = 'pant-11-kilipacha-brocadekacha-model-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #869: PANT-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-10',
  'pant-10-majenta-brocade-dhothi-pant',
  'Majenta brocade Dhothi Pant',
  'Majenta brocade Dhothi Pant',
  'PANT-10',
  260.00,
  500.00,
  19,
  19,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-10' 
       OR (p.slug = 'pant-10-majenta-brocade-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #870: PANT-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-9',
  'pant-9-blue-brocade-dhothimediumlarge-dhothi-pant',
  'Blue brocade dhothi,medium/Large Dhothi Pant',
  'Blue brocade dhothi,medium/Large Dhothi Pant',
  'PANT-9',
  260.00,
  500.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-9' 
       OR (p.slug = 'pant-9-blue-brocade-dhothimediumlarge-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #871: PANT-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-8',
  'pant-8-copper-sulphate-blue-dhothi-pant',
  'Copper sulphate blue Dhothi Pant',
  'Copper sulphate blue Dhothi Pant',
  'PANT-8',
  225.00,
  500.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-8' 
       OR (p.slug = 'pant-8-copper-sulphate-blue-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #872: PANT-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-7',
  'pant-7-blackviolet-round-lace-dhothi-pant',
  'Black/Violet round lace Dhothi Pant',
  'Black/Violet round lace Dhothi Pant',
  'PANT-7',
  260.00,
  500.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-7' 
       OR (p.slug = 'pant-7-blackviolet-round-lace-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #873: PANT-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-6',
  'pant-6-off-whitegold-border-dhothi-pant',
  'Off white/Gold border Dhothi Pant',
  'Off white/Gold border Dhothi Pant',
  'PANT-6',
  225.00,
  500.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-6' 
       OR (p.slug = 'pant-6-off-whitegold-border-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #874: PANT-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-5',
  'pant-5-green-pant-cross-pleatdhothi-pant',
  'Green pant/ Cross pleatDhothi Pant',
  'Green pant/ Cross pleatDhothi Pant',
  'PANT-5',
  260.00,
  500.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-5' 
       OR (p.slug = 'pant-5-green-pant-cross-pleatdhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #875: PANT-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-4',
  'pant-4-red-pant-cross-pleat-dhothi-pant',
  'Red pant /cross pleat Dhothi Pant',
  'Red pant /cross pleat Dhothi Pant',
  'PANT-4',
  260.00,
  500.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-4' 
       OR (p.slug = 'pant-4-red-pant-cross-pleat-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #876: PANT-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-3',
  'pant-3-green-violet-round-lace-dhothi-pant',
  'Green violet round lace Dhothi Pant',
  'Green violet round lace Dhothi Pant',
  'PANT-3',
  260.00,
  500.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-3' 
       OR (p.slug = 'pant-3-green-violet-round-lace-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #877: PANT-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-2',
  'pant-2-pista-green-gold-sequence-border-dhothi-pant',
  'Pista green Gold sequence border Dhothi Pant',
  'Pista green Gold sequence border Dhothi Pant',
  'PANT-2',
  225.00,
  500.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-2' 
       OR (p.slug = 'pant-2-pista-green-gold-sequence-border-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #878: PANT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'pant' AND store_id = s.id LIMIT 1),
  b.id,
  'PANT-1',
  'pant-1-green-apple-cloth-round-lace-dhothi-pant',
  'Green apple cloth round lace Dhothi Pant',
  'Green apple cloth round lace Dhothi Pant',
  'PANT-1',
  225.00,
  500.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANT-1' 
       OR (p.slug = 'pant-1-green-apple-cloth-round-lace-dhothi-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #879: OCT-57
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-57',
  'oct-57-black-gold-heavy-jacket',
  'Black gold heavy Jacket',
  'Black gold heavy Jacket',
  'OCT-57',
  225.00,
  300.00,
  16,
  16,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-57' 
       OR (p.slug = 'oct-57-black-gold-heavy-jacket' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #880: OCT-56
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-56',
  'oct-56-majenta-big-seq',
  'Majenta Big Seq',
  'Majenta Big Seq',
  'OCT-56',
  150.00,
  300.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-56' 
       OR (p.slug = 'oct-56-majenta-big-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #881: OCT-55
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-55',
  'oct-55-black-multi-colour-seq',
  'Black multi colour seq',
  'Black multi colour seq',
  'OCT-55',
  150.00,
  300.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-55' 
       OR (p.slug = 'oct-55-black-multi-colour-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #882: OCT-54
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-54',
  'oct-54-green-gold-sequence-full-sleeve',
  'Green gold sequence full sleeve',
  'Green gold sequence full sleeve',
  'OCT-54',
  260.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-54' 
       OR (p.slug = 'oct-54-green-gold-sequence-full-sleeve' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #883: OCT-53
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-53',
  'oct-53-blue-velvet-gold-lace-full-sleeve',
  'Blue velvet Gold Lace Full Sleeve',
  'Blue velvet Gold Lace Full Sleeve',
  'OCT-53',
  260.00,
  300.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-53' 
       OR (p.slug = 'oct-53-blue-velvet-gold-lace-full-sleeve' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #884: OCT-52
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-52',
  'oct-52-white-silver-round-design-sleeveless-coat',
  'White silver round design sleeveless coat',
  'White silver round design sleeveless coat',
  'OCT-52',
  80.00,
  300.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-52' 
       OR (p.slug = 'oct-52-white-silver-round-design-sleeveless-coat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #885: OCT-51
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-51',
  'oct-51-blue-tikky-sleeveless-coat',
  'Blue tikky sleeveless coat',
  'Blue tikky sleeveless coat',
  'OCT-51',
  80.00,
  300.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-51' 
       OR (p.slug = 'oct-51-blue-tikky-sleeveless-coat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #886: OCT-50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-50',
  'oct-50-white-silver-seq-sleeveless-overcoat',
  'White silver seq sleeveless overcoat',
  'White silver seq sleeveless overcoat',
  'OCT-50',
  150.00,
  300.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-50' 
       OR (p.slug = 'oct-50-white-silver-seq-sleeveless-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #887: OCT-49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-49',
  'oct-49-red-seq-gold-border-sleeveless-coat',
  'Red seq gold border sleeveless coat',
  'Red seq gold border sleeveless coat',
  'OCT-49',
  125.00,
  300.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-49' 
       OR (p.slug = 'oct-49-red-seq-gold-border-sleeveless-coat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #888: OCT-48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-48',
  'oct-48-orange-seq-short-sleeve-shirt',
  'Orange seq short sleeve shirt',
  'Orange seq short sleeve shirt',
  'OCT-48',
  150.00,
  300.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-48' 
       OR (p.slug = 'oct-48-orange-seq-short-sleeve-shirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #889: OCT-47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-47',
  'oct-47-white-silver-small-seq-coat-kg-size',
  'White silver small seq coat KG size',
  'White silver small seq coat KG size',
  'OCT-47',
  80.00,
  300.00,
  14,
  14,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-47' 
       OR (p.slug = 'oct-47-white-silver-small-seq-coat-kg-size' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #890: OCT-46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-46',
  'oct-46-white-silver-small-se-sleeveless-overcoat',
  'White silver small se sleeveless overcoat',
  'White silver small se sleeveless overcoat',
  'OCT-46',
  150.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-46' 
       OR (p.slug = 'oct-46-white-silver-small-se-sleeveless-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #891: OCT-45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-45',
  'oct-45-white-silver-big-seq-sleeveless-coat',
  'White silver big seq sleeveless coat',
  'White silver big seq sleeveless coat',
  'OCT-45',
  175.00,
  300.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-45' 
       OR (p.slug = 'oct-45-white-silver-big-seq-sleeveless-coat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #892: OCT-44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-44',
  'oct-44-gold-tissue-sleeveless-coat',
  'Gold tissue sleeveless coat',
  'Gold tissue sleeveless coat',
  'OCT-44',
  80.00,
  300.00,
  18,
  18,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-44' 
       OR (p.slug = 'oct-44-gold-tissue-sleeveless-coat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #893: OCT-43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-43',
  'oct-43-orange-long-sleeveless-coat',
  'Orange long sleeveless coat',
  'Orange long sleeveless coat',
  'OCT-43',
  80.00,
  300.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-43' 
       OR (p.slug = 'oct-43-orange-long-sleeveless-coat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #894: OCT-42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-42',
  'oct-42-gold-small-sequence-sleeveless-coat',
  'Gold small sequence sleeveless coat',
  'Gold small sequence sleeveless coat',
  'OCT-42',
  80.00,
  300.00,
  18,
  18,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-42' 
       OR (p.slug = 'oct-42-gold-small-sequence-sleeveless-coat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #895: OCT-41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-41',
  'oct-41-red-gold-sequence-full-sleeve-jacket',
  'Red gold sequence full sleeve Jacket',
  'Red gold sequence full sleeve Jacket',
  'OCT-41',
  250.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-41' 
       OR (p.slug = 'oct-41-red-gold-sequence-full-sleeve-jacket' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #896: OCT-40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-40',
  'oct-40-yellowblue-gold-full-sleeve-overcoat',
  'Yellow/Blue gold full sleeve Overcoat',
  'Yellow/Blue gold full sleeve Overcoat',
  'OCT-40',
  125.00,
  300.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-40' 
       OR (p.slug = 'oct-40-yellowblue-gold-full-sleeve-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #897: OCT-39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-39',
  'oct-39-black-silver-seq-sleeve-less-overcoat',
  'Black silver seq sleeve less Overcoat',
  'Black silver seq sleeve less Overcoat',
  'OCT-39',
  80.00,
  300.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-39' 
       OR (p.slug = 'oct-39-black-silver-seq-sleeve-less-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #898: OCT-38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-38',
  'oct-38-black-silver-flowerd-esign-small-overcoat',
  'Black silver flowerd esign small Overcoat',
  'Black silver flowerd esign small Overcoat',
  'OCT-38',
  125.00,
  300.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-38' 
       OR (p.slug = 'oct-38-black-silver-flowerd-esign-small-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #899: OCT-37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-37',
  'oct-37-black-small-seq-overcoat',
  'Black small seq Overcoat',
  'Black small seq Overcoat',
  'OCT-37',
  80.00,
  300.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-37' 
       OR (p.slug = 'oct-37-black-small-seq-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #900: OCT-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-36',
  'oct-36-goldblue-sleeve-less-overcoat',
  'Gold/Blue sleeve less Overcoat',
  'Gold/Blue sleeve less Overcoat',
  'OCT-36',
  80.00,
  300.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-36' 
       OR (p.slug = 'oct-36-goldblue-sleeve-less-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #901: OCT-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-35',
  'oct-35-goldblue-full-sleeve-overcoat',
  'Gold/Blue full sleeve Overcoat',
  'Gold/Blue full sleeve Overcoat',
  'OCT-35',
  125.00,
  300.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-35' 
       OR (p.slug = 'oct-35-goldblue-full-sleeve-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #902: OCT-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-34',
  'oct-34-black-gold-tikky-overcoat',
  'Black gold tikky Overcoat',
  'Black gold tikky Overcoat',
  'OCT-34',
  80.00,
  300.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-34' 
       OR (p.slug = 'oct-34-black-gold-tikky-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #903: OCT-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-33',
  'oct-33-black-gold-flower-design-overcoat',
  'Black gold flower design Overcoat',
  'Black gold flower design Overcoat',
  'OCT-33',
  125.00,
  300.00,
  19,
  19,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-33' 
       OR (p.slug = 'oct-33-black-gold-flower-design-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #904: OCT-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-32',
  'oct-32-blackmajenta-silver-round-seq-overcoat',
  'Black/Majenta silver round seq Overcoat',
  'Black/Majenta silver round seq Overcoat',
  'OCT-32',
  125.00,
  300.00,
  19,
  19,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-32' 
       OR (p.slug = 'oct-32-blackmajenta-silver-round-seq-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #905: OCT-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-31',
  'oct-31-green-diamond-overcoat',
  'Green diamond Overcoat',
  'Green diamond Overcoat',
  'OCT-31',
  125.00,
  300.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-31' 
       OR (p.slug = 'oct-31-green-diamond-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #906: OCT-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-30',
  'oct-30-black-diamond-overcoat',
  'Black diamond Overcoat',
  'Black diamond Overcoat',
  'OCT-30',
  125.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-30' 
       OR (p.slug = 'oct-30-black-diamond-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #907: OCT-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-29',
  'oct-29-majenta-diamond-overcoat',
  'Majenta diamond Overcoat',
  'Majenta diamond Overcoat',
  'OCT-29',
  125.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-29' 
       OR (p.slug = 'oct-29-majenta-diamond-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #908: OCT-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-28',
  'oct-28-purple-diamond-overcoat',
  'Purple diamond Overcoat',
  'Purple diamond Overcoat',
  'OCT-28',
  125.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-28' 
       OR (p.slug = 'oct-28-purple-diamond-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #909: OCT-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-27',
  'oct-27-majenta-small-full-sleeve-overcoat',
  'Majenta small full sleeve Overcoat',
  'Majenta small full sleeve Overcoat',
  'OCT-27',
  80.00,
  300.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-27' 
       OR (p.slug = 'oct-27-majenta-small-full-sleeve-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #910: OCT-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-26',
  'oct-26-yellow-diamond-overcoat',
  'Yellow diamond Overcoat',
  'Yellow diamond Overcoat',
  'OCT-26',
  125.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-26' 
       OR (p.slug = 'oct-26-yellow-diamond-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #911: OCT-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-25',
  'oct-25-orange-silve-diamond-overcoat',
  'Orange silve diamond Overcoat',
  'Orange silve diamond Overcoat',
  'OCT-25',
  125.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-25' 
       OR (p.slug = 'oct-25-orange-silve-diamond-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #912: OCT-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-24',
  'oct-24-multi-coat-overcoat',
  'Multi coat Overcoat',
  'Multi coat Overcoat',
  'OCT-24',
  150.00,
  300.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-24' 
       OR (p.slug = 'oct-24-multi-coat-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #913: OCT-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-23',
  'oct-23-green-big-seq-overcoat',
  'Green big seq Overcoat',
  'Green big seq Overcoat',
  'OCT-23',
  150.00,
  300.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-23' 
       OR (p.slug = 'oct-23-green-big-seq-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #914: OCT-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-22',
  'oct-22-orange-big-seqsmall-overcoat',
  'Orange big seqsmall Overcoat',
  'Orange big seqsmall Overcoat',
  'OCT-22',
  150.00,
  300.00,
  15,
  15,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-22' 
       OR (p.slug = 'oct-22-orange-big-seqsmall-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #915: OCT-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-21',
  'oct-21-orangechenkal-tikky-overcoat',
  'Orange/Chenkal tikky Overcoat',
  'Orange/Chenkal tikky Overcoat',
  'OCT-21',
  80.00,
  300.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-21' 
       OR (p.slug = 'oct-21-orangechenkal-tikky-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #916: OCT-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-20',
  'oct-20-red-small-seq-sleeve-less-overcoat',
  'Red small seq sleeve less Overcoat',
  'Red small seq sleeve less Overcoat',
  'OCT-20',
  80.00,
  300.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-20' 
       OR (p.slug = 'oct-20-red-small-seq-sleeve-less-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #917: OCT-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-19',
  'oct-19-red-big-seq-overcoat',
  'Red big seq Overcoat',
  'Red big seq Overcoat',
  'OCT-19',
  125.00,
  300.00,
  16,
  16,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-19' 
       OR (p.slug = 'oct-19-red-big-seq-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #918: OCT-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-18',
  'oct-18-black-gold-big-full-sleeve-overcoat',
  'Black gold big full sleeve Overcoat',
  'Black gold big full sleeve Overcoat',
  'OCT-18',
  225.00,
  300.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-18' 
       OR (p.slug = 'oct-18-black-gold-big-full-sleeve-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #919: OCT-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-17',
  'oct-17-blue-satin-design-overcoat',
  'Blue satin design Overcoat',
  'Blue satin design Overcoat',
  'OCT-17',
  80.00,
  300.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-17' 
       OR (p.slug = 'oct-17-blue-satin-design-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #920: OCT-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-16',
  'oct-16-blue-small-seq-sleeve-less-overcoat',
  'Blue small seq sleeve less Overcoat',
  'Blue small seq sleeve less Overcoat',
  'OCT-16',
  80.00,
  300.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-16' 
       OR (p.slug = 'oct-16-blue-small-seq-sleeve-less-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #921: OCT-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-15',
  'oct-15-blue-big-seq-sleeve-less-overcoat',
  'Blue big seq sleeve less Overcoat',
  'Blue big seq sleeve less Overcoat',
  'OCT-15',
  150.00,
  300.00,
  21,
  21,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-15' 
       OR (p.slug = 'oct-15-blue-big-seq-sleeve-less-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #922: OCT-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-14',
  'oct-14-gold-big-seq-full-sleeve-overcoat',
  'Gold big seq full sleeve Overcoat',
  'Gold big seq full sleeve Overcoat',
  'OCT-14',
  225.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-14' 
       OR (p.slug = 'oct-14-gold-big-seq-full-sleeve-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #923: OCT-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-13',
  'oct-13-gold-bi-seq-sleeve-less-overcoat',
  'Gold bi seq sleeve less Overcoat',
  'Gold bi seq sleeve less Overcoat',
  'OCT-13',
  150.00,
  300.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-13' 
       OR (p.slug = 'oct-13-gold-bi-seq-sleeve-less-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #924: OCT-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-12',
  'oct-12-green-tikky-sleeve-less-overcoat',
  'Green tikky sleeve less Overcoat',
  'Green tikky sleeve less Overcoat',
  'OCT-12',
  80.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-12' 
       OR (p.slug = 'oct-12-green-tikky-sleeve-less-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #925: OCT-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-11',
  'oct-11-green-small-sleeveless-seq-overcoat',
  'Green small sleeveless seq Overcoat',
  'Green small sleeveless seq Overcoat',
  'OCT-11',
  125.00,
  300.00,
  22,
  22,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-11' 
       OR (p.slug = 'oct-11-green-small-sleeveless-seq-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #926: OCT-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-10',
  'oct-10-blue-velvetgold-blu-seq-full-sleeve-overcoat',
  'Blue velvet/Gold blu seq full sleeve Overcoat',
  'Blue velvet/Gold blu seq full sleeve Overcoat',
  'OCT-10',
  175.00,
  300.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-10' 
       OR (p.slug = 'oct-10-blue-velvetgold-blu-seq-full-sleeve-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #927: OCT-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-9',
  'oct-9-majenta-square-mirror-overcoat',
  'Majenta square mirror Overcoat',
  'Majenta square mirror Overcoat',
  'OCT-9',
  150.00,
  300.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-9' 
       OR (p.slug = 'oct-9-majenta-square-mirror-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #928: OCT-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-8',
  'oct-8-blue-square-mirror-overcoat',
  'Blue square mirror Overcoat',
  'Blue square mirror Overcoat',
  'OCT-8',
  150.00,
  300.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-8' 
       OR (p.slug = 'oct-8-blue-square-mirror-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #929: OCT-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-7',
  'oct-7-yellow-square-mirror-overcoat',
  'Yellow square mirror Overcoat',
  'Yellow square mirror Overcoat',
  'OCT-7',
  150.00,
  300.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-7' 
       OR (p.slug = 'oct-7-yellow-square-mirror-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #930: OCT-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-6',
  'oct-6-blue-thread-work-overcoat',
  'Blue Thread work Overcoat',
  'Blue Thread work Overcoat',
  'OCT-6',
  125.00,
  300.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-6' 
       OR (p.slug = 'oct-6-blue-thread-work-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #931: OCT-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-5',
  'oct-5-red-thread-work-overcoat',
  'Red Thread work Overcoat',
  'Red Thread work Overcoat',
  'OCT-5',
  125.00,
  300.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-5' 
       OR (p.slug = 'oct-5-red-thread-work-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #932: OCT-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-4',
  'oct-4-majenta-thread-work-overcoat',
  'Majenta thread work Overcoat',
  'Majenta thread work Overcoat',
  'OCT-4',
  125.00,
  300.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-4' 
       OR (p.slug = 'oct-4-majenta-thread-work-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #933: OCT-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-3',
  'oct-3-black-thread-work-overcoat',
  'Black thread work Overcoat',
  'Black thread work Overcoat',
  'OCT-3',
  125.00,
  300.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-3' 
       OR (p.slug = 'oct-3-black-thread-work-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #934: OCT-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-2',
  'oct-2-yellow-thread-work-overcoat',
  'Yellow thread work Overcoat',
  'Yellow thread work Overcoat',
  'OCT-2',
  125.00,
  300.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-2' 
       OR (p.slug = 'oct-2-yellow-thread-work-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #935: OCT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'overcoat' AND store_id = s.id LIMIT 1),
  b.id,
  'OCT-1',
  'oct-1-orange-gold-round-sequenceovercoat',
  'Orange gold round sequenceOvercoat',
  'Orange gold round sequenceOvercoat',
  'OCT-1',
  125.00,
  300.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OCT-1' 
       OR (p.slug = 'oct-1-orange-gold-round-sequenceovercoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #936: TEMPSTO-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'TEMPSTO-1',
  'tempsto-1-temple-black-stone-full-set',
  'Temple Black stone full set',
  'Temple Black stone full set',
  'TEMPSTO-1',
  1150.00,
  3500.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'TEMPSTO-1' 
       OR (p.slug = 'tempsto-1-temple-black-stone-full-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #937: TEMPNEW-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'TEMPNEW-1',
  'tempnew-1-temple-full-set-new',
  'Temple full set new',
  'Temple full set new',
  'TEMPNEW-1',
  900.00,
  2500.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'TEMPNEW-1' 
       OR (p.slug = 'tempnew-1-temple-full-set-new' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #938: TEMPOLD-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'TEMPOLD-1',
  'tempold-1-temple-full-set',
  'Temple full set',
  'Temple full set',
  'TEMPOLD-1',
  450.00,
  2000.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'TEMPOLD-1' 
       OR (p.slug = 'tempold-1-temple-full-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #939: OPPSET-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPSET-1',
  'oppset-1-oppana-ornaments',
  'Oppana Ornaments',
  'Oppana Ornaments',
  'OPPSET-1',
  280.00,
  0.00,
  50,
  50,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'OPPSET-1' 
       OR (p.slug = 'oppset-1-oppana-ornaments' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #940: BELT-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-13',
  'belt-13-white-stone-bh-belt',
  'White stone BH belt',
  'White stone BH belt',
  'BELT-13',
  125.00,
  0.00,
  16,
  16,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-13' 
       OR (p.slug = 'belt-13-white-stone-bh-belt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #941: BELT-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-12',
  'belt-12-gold-belt-with-pendent',
  'Gold belt with pendent',
  'Gold belt with pendent',
  'BELT-12',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-12' 
       OR (p.slug = 'belt-12-gold-belt-with-pendent' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #942: BELT-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-11',
  'belt-11-gold-belt-with-hanging',
  'Gold belt with hanging',
  'Gold belt with hanging',
  'BELT-11',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-11' 
       OR (p.slug = 'belt-11-gold-belt-with-hanging' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #943: BELT-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-10',
  'belt-10-layer-manavatti-belt',
  'Layer manavatti belt',
  'Layer manavatti belt',
  'BELT-10',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-10' 
       OR (p.slug = 'belt-10-layer-manavatti-belt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #944: BELT-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-9',
  'belt-9-gold-fancy-belt-with-3-pendent',
  'Gold fancy belt with 3 pendent',
  'Gold fancy belt with 3 pendent',
  'BELT-9',
  80.00,
  0.00,
  15,
  15,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-9' 
       OR (p.slug = 'belt-9-gold-fancy-belt-with-3-pendent' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #945: BELT-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-8',
  'belt-8-mango-fancy-belt-with-centre-pendent',
  'Mango fancy belt with centre pendent',
  'Mango fancy belt with centre pendent',
  'BELT-8',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-8' 
       OR (p.slug = 'belt-8-mango-fancy-belt-with-centre-pendent' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #946: BELT-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-7',
  'belt-7-broad-gold-belt-green-red-gold-stone',
  'Broad gold belt green red gold stone',
  'Broad gold belt green red gold stone',
  'BELT-7',
  80.00,
  0.00,
  14,
  14,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-7' 
       OR (p.slug = 'belt-7-broad-gold-belt-green-red-gold-stone' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #947: BELT-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-6',
  'belt-6-pearl-yellow-red-stone-2-layer-belt',
  'Pearl yellow red stone 2 layer belt',
  'Pearl yellow red stone 2 layer belt',
  'BELT-6',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-6' 
       OR (p.slug = 'belt-6-pearl-yellow-red-stone-2-layer-belt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #948: BELT-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-5',
  'belt-5-pearl-white-stone-belt',
  'Pearl white stone belt',
  'Pearl white stone belt',
  'BELT-5',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-5' 
       OR (p.slug = 'belt-5-pearl-white-stone-belt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #949: BELT-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-4',
  'belt-4-white-stone-2-layer-belt',
  'White stone 2 layer belt',
  'White stone 2 layer belt',
  'BELT-4',
  80.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-4' 
       OR (p.slug = 'belt-4-white-stone-2-layer-belt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #950: BELT-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-3',
  'belt-3-gold-belt-merroon-beads-hanging',
  'Gold belt merroon beads hanging',
  'Gold belt merroon beads hanging',
  'BELT-3',
  60.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-3' 
       OR (p.slug = 'belt-3-gold-belt-merroon-beads-hanging' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #951: BELT-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-2',
  'belt-2-gold-hanging-belt',
  'Gold hanging belt',
  'Gold hanging belt',
  'BELT-2',
  60.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-2' 
       OR (p.slug = 'belt-2-gold-hanging-belt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #952: BELT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'BELT-1',
  'belt-1-white-stone-majenta-green-belt',
  'White stone Majenta green belt',
  'White stone Majenta green belt',
  'BELT-1',
  80.00,
  0.00,
  14,
  14,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BELT-1' 
       OR (p.slug = 'belt-1-white-stone-majenta-green-belt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #953: JADASET-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'JADASET-1',
  'jadaset-1-green-red-stone-jada',
  'Green red stone jada',
  'Green red stone jada',
  'JADASET-1',
  125.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'JADASET-1' 
       OR (p.slug = 'jadaset-1-green-red-stone-jada' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #954: RAKODI-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'RAKODI-1',
  'rakodi-1-temple-rakodi-choodamani',
  'Temple rakodi choodamani',
  'Temple rakodi choodamani',
  'RAKODI-1',
  60.00,
  0.00,
  15,
  15,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'RAKODI-1' 
       OR (p.slug = 'rakodi-1-temple-rakodi-choodamani' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #955: SUNMOON-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'SUNMOON-1',
  'sunmoon-1-temple-sun-moon',
  'Temple sun-moon',
  'Temple sun-moon',
  'SUNMOON-1',
  50.00,
  0.00,
  20,
  20,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SUNMOON-1' 
       OR (p.slug = 'sunmoon-1-temple-sun-moon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #956: MATTI-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'MATTI-5',
  'matti-5-3-layer-pearl-hanging-matti',
  '3 Layer pearl hanging matti',
  '3 Layer pearl hanging matti',
  'MATTI-5',
  80.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MATTI-5' 
       OR (p.slug = 'matti-5-3-layer-pearl-hanging-matti' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #957: MATTI-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'MATTI-4',
  'matti-4-3-layer-matti-pearl-jimmikki',
  '3 Layer matti pearl & Jimmikki',
  '3 Layer matti pearl & Jimmikki',
  'MATTI-4',
  80.00,
  0.00,
  13,
  13,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MATTI-4' 
       OR (p.slug = 'matti-4-3-layer-matti-pearl-jimmikki' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #958: MATTI-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'MATTI-3',
  'matti-3-gold-matti',
  'Gold Matti',
  'Gold Matti',
  'MATTI-3',
  90.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MATTI-3' 
       OR (p.slug = 'matti-3-gold-matti' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #959: MATTI-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'MATTI-2',
  'matti-2-veethi-koodiya-temple-matti',
  'Veethi koodiya Temple matti',
  'Veethi koodiya Temple matti',
  'MATTI-2',
  80.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MATTI-2' 
       OR (p.slug = 'matti-2-veethi-koodiya-temple-matti' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #960: MATTI-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'MATTI-1',
  'matti-1-temple-matti-normal',
  'Temple matti normal',
  'Temple matti normal',
  'MATTI-1',
  70.00,
  0.00,
  20,
  20,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MATTI-1' 
       OR (p.slug = 'matti-1-temple-matti-normal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #961: HST-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-14',
  'hst-14-antique-single-chutti-green-beads-hanging-head-set',
  'Antique single chutti green beads hanging Head set',
  'Antique single chutti green beads hanging Head set',
  'HST-14',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-14' 
       OR (p.slug = 'hst-14-antique-single-chutti-green-beads-hanging-head-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #962: HST-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-13',
  'hst-13-single-chutti-yellow-stone-pearl-hanging-head-set',
  'Single chutti yellow stone pearl hanging head set',
  'Single chutti yellow stone pearl hanging head set',
  'HST-13',
  60.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-13' 
       OR (p.slug = 'hst-13-single-chutti-yellow-stone-pearl-hanging-head-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #963: HST-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-12',
  'hst-12-single-chutti-marroon-beads-palakka-head-set',
  'Single chutti marroon beads palakka head set',
  'Single chutti marroon beads palakka head set',
  'HST-12',
  60.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-12' 
       OR (p.slug = 'hst-12-single-chutti-marroon-beads-palakka-head-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #964: HST-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-11',
  'hst-11-small-gold-arch-crown-head-set',
  'Small gold arch crown head set',
  'Small gold arch crown head set',
  'HST-11',
  70.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-11' 
       OR (p.slug = 'hst-11-small-gold-arch-crown-head-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #965: HST-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-10',
  'hst-10-gold-3-side-head-set',
  'Gold 3 side head set',
  'Gold 3 side head set',
  'HST-10',
  150.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-10' 
       OR (p.slug = 'hst-10-gold-3-side-head-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #966: HST-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-9',
  'hst-9-lekshmi-round-white-majenta-stone-chutti-hst',
  'Lekshmi round white majenta stone chutti hst',
  'Lekshmi round white majenta stone chutti hst',
  'HST-9',
  70.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-9' 
       OR (p.slug = 'hst-9-lekshmi-round-white-majenta-stone-chutti-hst' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #967: HST-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-8',
  'hst-8-single-chutti-white-red-stone-head-set',
  'Single chutti white red stone head set',
  'Single chutti white red stone head set',
  'HST-8',
  80.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-8' 
       OR (p.slug = 'hst-8-single-chutti-white-red-stone-head-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #968: HST-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-7',
  'hst-7-temple-head-set',
  'Temple head set',
  'Temple head set',
  'HST-7',
  80.00,
  0.00,
  16,
  16,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-7' 
       OR (p.slug = 'hst-7-temple-head-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #969: HST-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-6',
  'hst-6-single-chutti-temple-head-set',
  'Single chutti Temple head set',
  'Single chutti Temple head set',
  'HST-6',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-6' 
       OR (p.slug = 'hst-6-single-chutti-temple-head-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #970: HST-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-5',
  'hst-5-step-chutti-temple-head-set',
  'Step chutti temple head set',
  'Step chutti temple head set',
  'HST-5',
  80.00,
  0.00,
  23,
  23,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-5' 
       OR (p.slug = 'hst-5-step-chutti-temple-head-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #971: HST-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-4',
  'hst-4-step-crown-3-layer-head-set',
  'Step crown 3 layer head set',
  'Step crown 3 layer head set',
  'HST-4',
  150.00,
  0.00,
  7,
  7,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-4' 
       OR (p.slug = 'hst-4-step-crown-3-layer-head-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #972: HST-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-3',
  'hst-3-white-stone-head-set-3-layer',
  'White stone head set 3 layer',
  'White stone head set 3 layer',
  'HST-3',
  150.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-3' 
       OR (p.slug = 'hst-3-white-stone-head-set-3-layer' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #973: HST-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-2',
  'hst-2-white-stone-head-set-2-layer',
  'White stone head set 2 layer',
  'White stone head set 2 layer',
  'HST-2',
  125.00,
  0.00,
  13,
  13,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-2' 
       OR (p.slug = 'hst-2-white-stone-head-set-2-layer' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #974: HST-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'HST-1',
  'hst-1-white-stone-head-set-1-layer',
  'White stone head set 1 layer',
  'White stone head set 1 layer',
  'HST-1',
  80.00,
  0.00,
  28,
  28,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HST-1' 
       OR (p.slug = 'hst-1-white-stone-head-set-1-layer' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #975: LONGCH-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-23',
  'longch-23-gold-mango-long-with-locket-long-chain',
  'Gold mango long with locket long chain',
  'Gold mango long with locket long chain',
  'LONGCH-23',
  125.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-23' 
       OR (p.slug = 'longch-23-gold-mango-long-with-locket-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #976: LONGCH-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-22',
  'longch-22-kashu-mala-white-stone-long-chain',
  'Kashu mala white stone long chain',
  'Kashu mala white stone long chain',
  'LONGCH-22',
  150.00,
  0.00,
  17,
  17,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-22' 
       OR (p.slug = 'longch-22-kashu-mala-white-stone-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #977: LONGCH-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-21',
  'longch-21-pichi-long-chain',
  'Pichi long chain',
  'Pichi long chain',
  'LONGCH-21',
  125.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-21' 
       OR (p.slug = 'longch-21-pichi-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #978: LONGCH-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-20',
  'longch-20-kashmiri-set-long-chain',
  'Kashmiri set long chain',
  'Kashmiri set long chain',
  'LONGCH-20',
  125.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-20' 
       OR (p.slug = 'longch-20-kashmiri-set-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #979: LONGCH-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-19',
  'longch-19-red-palakka-long-chain',
  'Red palakka long chain',
  'Red palakka long chain',
  'LONGCH-19',
  150.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-19' 
       OR (p.slug = 'longch-19-red-palakka-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #980: LONGCH-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-18',
  'longch-18-green-palakka-long-chain',
  'Green palakka long chain',
  'Green palakka long chain',
  'LONGCH-18',
  150.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-18' 
       OR (p.slug = 'longch-18-green-palakka-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #981: LONGCH-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-17',
  'longch-17-bkue-ball-mala-long-chain',
  'Bkue ball mala long chain',
  'Bkue ball mala long chain',
  'LONGCH-17',
  80.00,
  0.00,
  11,
  11,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-17' 
       OR (p.slug = 'longch-17-bkue-ball-mala-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #982: LONGCH-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-16',
  'longch-16-red-stone-kasshu-long-chain',
  'Red stone kasshu long chain',
  'Red stone kasshu long chain',
  'LONGCH-16',
  125.00,
  0.00,
  3,
  3,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-16' 
       OR (p.slug = 'longch-16-red-stone-kasshu-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #983: LONGCH-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-15',
  'longch-15-red-ball-mala-long-chain',
  'Red ball mala long chain',
  'Red ball mala long chain',
  'LONGCH-15',
  80.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-15' 
       OR (p.slug = 'longch-15-red-ball-mala-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #984: LONGCH-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-14',
  'longch-14-green-ball-mala-long-chain',
  'Green ball mala long chain',
  'Green ball mala long chain',
  'LONGCH-14',
  80.00,
  0.00,
  5,
  5,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-14' 
       OR (p.slug = 'longch-14-green-ball-mala-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #985: LONGCH-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-13',
  'longch-13-multi-stone-locket-long-chain',
  'Multi stone locket long chain',
  'Multi stone locket long chain',
  'LONGCH-13',
  125.00,
  0.00,
  8,
  8,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-13' 
       OR (p.slug = 'longch-13-multi-stone-locket-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #986: LONGCH-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-12',
  'longch-12-mango-mala-long-chain',
  'Mango mala long chain',
  'Mango mala long chain',
  'LONGCH-12',
  80.00,
  0.00,
  21,
  21,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-12' 
       OR (p.slug = 'longch-12-mango-mala-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #987: LONGCH-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-11',
  'longch-11-big-kaashu-mala-polished-long-chain',
  'Big kaashu mala polished long chain',
  'Big kaashu mala polished long chain',
  'LONGCH-11',
  80.00,
  0.00,
  34,
  34,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-11' 
       OR (p.slug = 'longch-11-big-kaashu-mala-polished-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #988: LONGCH-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-10',
  'longch-10-small-kaashmala-medium-polished-long-chain',
  'Small kaashmala medium polished long chain',
  'Small kaashmala medium polished long chain',
  'LONGCH-10',
  70.00,
  0.00,
  17,
  17,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-10' 
       OR (p.slug = 'longch-10-small-kaashmala-medium-polished-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #989: LONGCH-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-9',
  'longch-9-small-kaashu-medium-long-chain',
  'Small kaashu medium long chain',
  'Small kaashu medium long chain',
  'LONGCH-9',
  80.00,
  0.00,
  6,
  6,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-9' 
       OR (p.slug = 'longch-9-small-kaashu-medium-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #990: LONGCH-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-8',
  'longch-8-small-kaasu-mala-long-chain',
  'small kaasu mala long chain',
  'small kaasu mala long chain',
  'LONGCH-8',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-8' 
       OR (p.slug = 'longch-8-small-kaasu-mala-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #991: LONGCH-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-7',
  'longch-7-kaasu-mala-medium-long-chain',
  'Kaasu mala medium long chain',
  'Kaasu mala medium long chain',
  'LONGCH-7',
  125.00,
  0.00,
  16,
  16,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-7' 
       OR (p.slug = 'longch-7-kaasu-mala-medium-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #992: LONGCH-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-6',
  'longch-6-white-green-beads-pendent-long-chain',
  'White green beads pendent long chain',
  'White green beads pendent long chain',
  'LONGCH-6',
  125.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-6' 
       OR (p.slug = 'longch-6-white-green-beads-pendent-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #993: LONGCH-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-5',
  'longch-5-pearl-mala-long-chain',
  'Pearl Mala long chain',
  'Pearl Mala long chain',
  'LONGCH-5',
  80.00,
  0.00,
  25,
  25,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-5' 
       OR (p.slug = 'longch-5-pearl-mala-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #994: LONGCH-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-4',
  'longch-4-gold-long-chain',
  'Gold Long chain',
  'Gold Long chain',
  'LONGCH-4',
  150.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-4' 
       OR (p.slug = 'longch-4-gold-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #995: LONGCH-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-3',
  'longch-3-temple-mango-long-chain',
  'Temple Mango long chain',
  'Temple Mango long chain',
  'LONGCH-3',
  175.00,
  0.00,
  4,
  4,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-3' 
       OR (p.slug = 'longch-3-temple-mango-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #996: LONGCH-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-2',
  'longch-2-green-stone-long-chain',
  'Green Stone Long chain',
  'Green Stone Long chain',
  'LONGCH-2',
  150.00,
  0.00,
  12,
  12,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-2' 
       OR (p.slug = 'longch-2-green-stone-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #997: LONGCH-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'LONGCH-1',
  'longch-1-blue-palakka-long-chain',
  'Blue Palakka long chain',
  'Blue Palakka long chain',
  'LONGCH-1',
  175.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LONGCH-1' 
       OR (p.slug = 'longch-1-blue-palakka-long-chain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #998: KAMMAL-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'KAMMAL-21',
  'kammal-21-white-stone-hanging-with-matti-kammal',
  'White stone hanging with matti kammal',
  'White stone hanging with matti kammal',
  'KAMMAL-21',
  80.00,
  0.00,
  10,
  10,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KAMMAL-21' 
       OR (p.slug = 'kammal-21-white-stone-hanging-with-matti-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #999: KAMMAL-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'KAMMAL-20',
  'kammal-20-gold-stone-drops-with-jimikki-kammal',
  'Gold stone drops with jimikki kammal',
  'Gold stone drops with jimikki kammal',
  'KAMMAL-20',
  80.00,
  0.00,
  2,
  2,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KAMMAL-20' 
       OR (p.slug = 'kammal-20-gold-stone-drops-with-jimikki-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1000: KAMMAL-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'ornaments' AND store_id = s.id LIMIT 1),
  b.id,
  'KAMMAL-19',
  'kammal-19-drops-with-pearly-hanging-kammal',
  'Drops with pearly hanging kammal',
  'Drops with pearly hanging kammal',
  'KAMMAL-19',
  80.00,
  0.00,
  9,
  9,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KAMMAL-19' 
       OR (p.slug = 'kammal-19-drops-with-pearly-hanging-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;


-- ════════════════════════════════════════════════════════════════════════════
-- GENERATE PRODUCT INVENTORY MAPPINGS FOR PART 2
-- ════════════════════════════════════════════════════════════════════════════

INSERT INTO public.product_inventory (
  id, product_id, branch_id, quantity, available_quantity, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  p.id,
  p.branch_id,
  p.quantity,
  p.available_quantity,
  NOW(),
  NOW()
FROM public.products p
JOIN public.stores s ON p.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND p.created_at >= NOW() - INTERVAL '1 hour'
  AND NOT EXISTS (
    SELECT 1 FROM public.product_inventory pi 
    WHERE pi.product_id = p.id
  )
ON CONFLICT (product_id, branch_id) DO NOTHING;
