-- ============================================================================
-- Migration 031: Import Final 249 Products from CSV (product02csv.csv) - Part 4
-- Purpose:   Inserts categories and the final 249 products (rows 1501 to 1749)
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
-- INSERT FINAL 249 PRODUCTS (1501 to 1749)
-- ════════════════════════════════════════════════════════════════════════════

-- Product #1501: BHN-42/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-42/1',
  'bhn-421-peacock-green-orange',
  'Peacock green/ Orange',
  'Peacock green/ Orange',
  'BHN-42/1',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-42/1' 
       OR (p.slug = 'bhn-421-peacock-green-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1502: BHN-40/50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/50',
  'bhn-4050-bottle-greenmerroon-saree-kh',
  'Bottle Green/Merroon Saree KH',
  'Bottle Green/Merroon Saree KH',
  'BHN-40/50',
  1600.00,
  3500.00,
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
    WHERE p.barcode = 'BHN-40/50' 
       OR (p.slug = 'bhn-4050-bottle-greenmerroon-saree-kh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1503: BHN-40/49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/49',
  'bhn-4049-saree-model-pink-blue',
  'Saree model pink blue',
  'Saree model pink blue',
  'BHN-40/49',
  840.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/49' 
       OR (p.slug = 'bhn-4049-saree-model-pink-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1504: BHN-40/48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/48',
  'bhn-4048-red-check',
  'Red check',
  'Red check',
  'BHN-40/48',
  1050.00,
  3500.00,
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
    WHERE p.barcode = 'BHN-40/48' 
       OR (p.slug = 'bhn-4048-red-check' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1505: BHN-40/47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/47',
  'bhn-4047-brown-surf-blue',
  'Brown/ Surf blue',
  'Brown/ Surf blue',
  'BHN-40/47',
  800.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/47' 
       OR (p.slug = 'bhn-4047-brown-surf-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1506: BHN-40/46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/46',
  'bhn-4046-brown-sulphate-blue',
  'Brown/ Sulphate blue',
  'Brown/ Sulphate blue',
  'BHN-40/46',
  800.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/46' 
       OR (p.slug = 'bhn-4046-brown-sulphate-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1507: BHN-40/45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/45',
  'bhn-4045-dark-blue-green',
  'Dark blue/ Green',
  'Dark blue/ Green',
  'BHN-40/45',
  840.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/45' 
       OR (p.slug = 'bhn-4045-dark-blue-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1508: BHN-40/44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/44',
  'bhn-4044-black-pink',
  'Black/ Pink',
  'Black/ Pink',
  'BHN-40/44',
  840.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/44' 
       OR (p.slug = 'bhn-4044-black-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1509: BHN-40/43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/43',
  'bhn-4043-black-pink',
  'Black/ Pink',
  'Black/ Pink',
  'BHN-40/43',
  840.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/43' 
       OR (p.slug = 'bhn-4043-black-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1510: BHN-40/42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/42',
  'bhn-4042-orange-red',
  'Orange/ Red',
  'Orange/ Red',
  'BHN-40/42',
  840.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/42' 
       OR (p.slug = 'bhn-4042-orange-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1511: BHN-40/41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/41',
  'bhn-4041-black-red',
  'Black/ Red',
  'Black/ Red',
  'BHN-40/41',
  800.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/41' 
       OR (p.slug = 'bhn-4041-black-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1512: BHN-40/40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/40',
  'bhn-4040-black-red',
  'Black/ Red',
  'Black/ Red',
  'BHN-40/40',
  800.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/40' 
       OR (p.slug = 'bhn-4040-black-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1513: BHN-40/39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/39',
  'bhn-4039-dark-orange-merroon',
  'Dark Orange/ Merroon',
  'Dark Orange/ Merroon',
  'BHN-40/39',
  800.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/39' 
       OR (p.slug = 'bhn-4039-dark-orange-merroon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1514: BHN-40/38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/38',
  'bhn-4038-peacock-bluemajenta',
  'Peacock blue/Majenta',
  'Peacock blue/Majenta',
  'BHN-40/38',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/38' 
       OR (p.slug = 'bhn-4038-peacock-bluemajenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1515: BHN-40/37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/37',
  'bhn-4037-dark-greenpiink',
  'Dark green/Piink',
  'Dark green/Piink',
  'BHN-40/37',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/37' 
       OR (p.slug = 'bhn-4037-dark-greenpiink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1516: BHN-40/36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/36',
  'bhn-4036-pista-green-grape',
  'Pista green Grape',
  'Pista green Grape',
  'BHN-40/36',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/36' 
       OR (p.slug = 'bhn-4036-pista-green-grape' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1517: BHN-40/35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/35',
  'bhn-4035-pista-green-grape',
  'Pista green Grape',
  'Pista green Grape',
  'BHN-40/35',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/35' 
       OR (p.slug = 'bhn-4035-pista-green-grape' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1518: BHN-40/34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/34',
  'bhn-4034-black-yellow',
  'Black/ Yellow',
  'Black/ Yellow',
  'BHN-40/34',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/34' 
       OR (p.slug = 'bhn-4034-black-yellow' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1519: BHN-40/33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/33',
  'bhn-4033-black-red',
  'Black/ Red',
  'Black/ Red',
  'BHN-40/33',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/33' 
       OR (p.slug = 'bhn-4033-black-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1520: BHN-40/32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/32',
  'bhn-4032-dark-green-pink',
  'Dark green/ Pink',
  'Dark green/ Pink',
  'BHN-40/32',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/32' 
       OR (p.slug = 'bhn-4032-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1521: BHN-40/31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/31',
  'bhn-4031-violet-orange',
  'Violet/ Orange',
  'Violet/ Orange',
  'BHN-40/31',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/31' 
       OR (p.slug = 'bhn-4031-violet-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1522: BHN-40/30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/30',
  'bhn-4030-blue-merroon',
  'Blue/ Merroon',
  'Blue/ Merroon',
  'BHN-40/30',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-40/30' 
       OR (p.slug = 'bhn-4030-blue-merroon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1523: BHN-40/29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/29',
  'bhn-4029-red-gold',
  'Red/ Gold',
  'Red/ Gold',
  'BHN-40/29',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/29' 
       OR (p.slug = 'bhn-4029-red-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1524: BHN-40/28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/28',
  'bhn-4028-kilipacha-pink',
  'Kilipacha/ Pink',
  'Kilipacha/ Pink',
  'BHN-40/28',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/28' 
       OR (p.slug = 'bhn-4028-kilipacha-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1525: BHN-40/26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/26',
  'bhn-4026-kilipacha-pink',
  'Kilipacha/ Pink',
  'Kilipacha/ Pink',
  'BHN-40/26',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/26' 
       OR (p.slug = 'bhn-4026-kilipacha-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1526: BHN-40/25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/25',
  'bhn-4025-yellow-blue-brocade',
  'yellow/ Blue brocade',
  'yellow/ Blue brocade',
  'BHN-40/25',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/25' 
       OR (p.slug = 'bhn-4025-yellow-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1527: BHN-40/24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/24',
  'bhn-4024-yellow-blue-brocade',
  'yellow/ Blue brocade',
  'yellow/ Blue brocade',
  'BHN-40/24',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/24' 
       OR (p.slug = 'bhn-4024-yellow-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1528: BHN-40/23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/23',
  'bhn-4023-orange-green',
  'Orange/ Green',
  'Orange/ Green',
  'BHN-40/23',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/23' 
       OR (p.slug = 'bhn-4023-orange-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1529: BHN-40/22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/22',
  'bhn-4022-bluepink-brocade',
  'Blue/Pink brocade',
  'Blue/Pink brocade',
  'BHN-40/22',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/22' 
       OR (p.slug = 'bhn-4022-bluepink-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1530: BHN-40/21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/21',
  'bhn-4021-red-blue',
  'Red/ Blue',
  'Red/ Blue',
  'BHN-40/21',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/21' 
       OR (p.slug = 'bhn-4021-red-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1531: BHN-40/20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/20',
  'bhn-4020-red-blue',
  'Red/ Blue',
  'Red/ Blue',
  'BHN-40/20',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/20' 
       OR (p.slug = 'bhn-4020-red-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1532: BHN-40/19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/19',
  'bhn-4019-ink-blue',
  'Ink blue',
  'Ink blue',
  'BHN-40/19',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/19' 
       OR (p.slug = 'bhn-4019-ink-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1533: BHN-40/18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/18',
  'bhn-4018-dark-green-majenta',
  'Dark green/ Majenta',
  'Dark green/ Majenta',
  'BHN-40/18',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/18' 
       OR (p.slug = 'bhn-4018-dark-green-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1534: BHN-40/17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/17',
  'bhn-4017-light-green-violet-brocade',
  'Light green/ Violet brocade',
  'Light green/ Violet brocade',
  'BHN-40/17',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/17' 
       OR (p.slug = 'bhn-4017-light-green-violet-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1535: BHN-40/16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/16',
  'bhn-4016-orange-majenta',
  'Orange/ Majenta',
  'Orange/ Majenta',
  'BHN-40/16',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/16' 
       OR (p.slug = 'bhn-4016-orange-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1536: BHN-40/15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/15',
  'bhn-4015-orange-majenta',
  'Orange/ Majenta',
  'Orange/ Majenta',
  'BHN-40/15',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/15' 
       OR (p.slug = 'bhn-4015-orange-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1537: BHN-40/14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/14',
  'bhn-4014-merroon-yellow',
  'Merroon/ Yellow',
  'Merroon/ Yellow',
  'BHN-40/14',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/14' 
       OR (p.slug = 'bhn-4014-merroon-yellow' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1538: BHN-40/13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/13',
  'bhn-4013-winecheck',
  'Wine/Check',
  'Wine/Check',
  'BHN-40/13',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/13' 
       OR (p.slug = 'bhn-4013-winecheck' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1539: BHN-40/10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/10',
  'bhn-4010-greengold',
  'Green/Gold',
  'Green/Gold',
  'BHN-40/10',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/10' 
       OR (p.slug = 'bhn-4010-greengold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1540: BHN-40/9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/9',
  'bhn-409-blackpink',
  'Black/Pink',
  'Black/Pink',
  'BHN-40/9',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/9' 
       OR (p.slug = 'bhn-409-blackpink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1541: BHN-40/6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/6',
  'bhn-406-yellow-check-green',
  'Yellow check green',
  'Yellow check green',
  'BHN-40/6',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/6' 
       OR (p.slug = 'bhn-406-yellow-check-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1542: BHN-40/5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/5',
  'bhn-405-vadamallulight-orange',
  'Vadamallu/Light orange',
  'Vadamallu/Light orange',
  'BHN-40/5',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/5' 
       OR (p.slug = 'bhn-405-vadamallulight-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1543: BHN-40/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/4',
  'bhn-404-orangepeacock-gress',
  'Orange/Peacock gress',
  'Orange/Peacock gress',
  'BHN-40/4',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/4' 
       OR (p.slug = 'bhn-404-orangepeacock-gress' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1544: BHN-40/3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/3',
  'bhn-403-peacock-greenorange-brocade',
  'Peacock green/Orange brocade',
  'Peacock green/Orange brocade',
  'BHN-40/3',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/3' 
       OR (p.slug = 'bhn-403-peacock-greenorange-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1545: BHN-40/2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/2',
  'bhn-402-violet-gold-sunfleet',
  'Violet gold sunfleet',
  'Violet gold sunfleet',
  'BHN-40/2',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/2' 
       OR (p.slug = 'bhn-402-violet-gold-sunfleet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1546: BHN-40/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-40/1',
  'bhn-401-pista-gree-dark-pink',
  'Pista gree/ dark pink',
  'Pista gree/ dark pink',
  'BHN-40/1',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-40/1' 
       OR (p.slug = 'bhn-401-pista-gree-dark-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1547: BHN-38/62
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/62',
  'bhn-3862-blue-majenta-saree-kh',
  'Blue Majenta saree KH',
  'Blue Majenta saree KH',
  'BHN-38/62',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/62' 
       OR (p.slug = 'bhn-3862-blue-majenta-saree-kh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1548: BHN-38/61
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/61',
  'bhn-3861-voiolet-check',
  'Voiolet check',
  'Voiolet check',
  'BHN-38/61',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/61' 
       OR (p.slug = 'bhn-3861-voiolet-check' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1549: BHN-38/60
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/60',
  'bhn-3860-yellow-dot-green',
  'Yellow dot/ Green',
  'Yellow dot/ Green',
  'BHN-38/60',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/60' 
       OR (p.slug = 'bhn-3860-yellow-dot-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1550: BHN-38/59
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/59',
  'bhn-3859-kanakabaram-wine',
  'Kanakabaram/ Wine',
  'Kanakabaram/ Wine',
  'BHN-38/59',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/59' 
       OR (p.slug = 'bhn-3859-kanakabaram-wine' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1551: BHN-38/58
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/58',
  'bhn-3858-kankambaram-green',
  'Kankambaram/ green',
  'Kankambaram/ green',
  'BHN-38/58',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/58' 
       OR (p.slug = 'bhn-3858-kankambaram-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1552: BHN-38/57
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/57',
  'bhn-3857-brown-surf-blue',
  'Brown/ Surf blue',
  'Brown/ Surf blue',
  'BHN-38/57',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/57' 
       OR (p.slug = 'bhn-3857-brown-surf-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1553: BHN-38/56
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/56',
  'bhn-3856-brown-surf-blue',
  'Brown/ Surf blue',
  'Brown/ Surf blue',
  'BHN-38/56',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/56' 
       OR (p.slug = 'bhn-3856-brown-surf-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1554: BHN-38/55
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/55',
  'bhn-3855-brown-surf-blue',
  'Brown/ Surf blue',
  'Brown/ Surf blue',
  'BHN-38/55',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/55' 
       OR (p.slug = 'bhn-3855-brown-surf-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1555: BHN-38/54
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/54',
  'bhn-3854-brown-surf-blue',
  'Brown/ Surf blue',
  'Brown/ Surf blue',
  'BHN-38/54',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/54' 
       OR (p.slug = 'bhn-3854-brown-surf-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1556: BHN-38/53
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/53',
  'bhn-3853-brown-surf-blue',
  'Brown/ Surf blue',
  'Brown/ Surf blue',
  'BHN-38/53',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/53' 
       OR (p.slug = 'bhn-3853-brown-surf-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1557: BHN-38/52
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/52',
  'bhn-3852-coffe-brown-green-saree',
  'Coffe brown/ Green saree',
  'Coffe brown/ Green saree',
  'BHN-38/52',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/52' 
       OR (p.slug = 'bhn-3852-coffe-brown-green-saree' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1558: BHN-38/50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/50',
  'bhn-3850-mehandi-green-blue',
  'Mehandi green/ Blue',
  'Mehandi green/ Blue',
  'BHN-38/50',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/50' 
       OR (p.slug = 'bhn-3850-mehandi-green-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1559: BHN-38/49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/49',
  'bhn-3849-black-pink',
  'Black/ Pink',
  'Black/ Pink',
  'BHN-38/49',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/49' 
       OR (p.slug = 'bhn-3849-black-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1560: BHN-38/48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/48',
  'bhn-3848-black-light-green',
  'Black/ Light green',
  'Black/ Light green',
  'BHN-38/48',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/48' 
       OR (p.slug = 'bhn-3848-black-light-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1561: BHN-38/47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/47',
  'bhn-3847-dark-red-saree',
  'Dark red saree',
  'Dark red saree',
  'BHN-38/47',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/47' 
       OR (p.slug = 'bhn-3847-dark-red-saree' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1562: BHN-38/46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/46',
  'bhn-3846-onion-colour-violet',
  'Onion colour/ Violet',
  'Onion colour/ Violet',
  'BHN-38/46',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/46' 
       OR (p.slug = 'bhn-3846-onion-colour-violet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1563: BHN-38/45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/45',
  'bhn-3845-black-red',
  'Black/ Red',
  'Black/ Red',
  'BHN-38/45',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/45' 
       OR (p.slug = 'bhn-3845-black-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1564: BHN-38/43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/43',
  'bhn-3843-bottle-green-merron-gold',
  'Bottle green/ Merron gold',
  'Bottle green/ Merron gold',
  'BHN-38/43',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/43' 
       OR (p.slug = 'bhn-3843-bottle-green-merron-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1565: BHN-38/42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/42',
  'bhn-3842-kilipacha-pink',
  'Kilipacha/ Pink',
  'Kilipacha/ Pink',
  'BHN-38/42',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/42' 
       OR (p.slug = 'bhn-3842-kilipacha-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1566: BHN-38/41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/41',
  'bhn-3841-green-orange-kh',
  'Green/ Orange KH',
  'Green/ Orange KH',
  'BHN-38/41',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/41' 
       OR (p.slug = 'bhn-3841-green-orange-kh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1567: BHN-38/40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/40',
  'bhn-3840-brown-gold-brocade',
  'Brown/ Gold brocade',
  'Brown/ Gold brocade',
  'BHN-38/40',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/40' 
       OR (p.slug = 'bhn-3840-brown-gold-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1568: BHN-38/39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/39',
  'bhn-3839-cotton-majenta-green',
  'Cotton Majenta/ Green',
  'Cotton Majenta/ Green',
  'BHN-38/39',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/39' 
       OR (p.slug = 'bhn-3839-cotton-majenta-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1569: BHN-38/38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/38',
  'bhn-3838-dark-orange-merroon',
  'Dark orange/ Merroon',
  'Dark orange/ Merroon',
  'BHN-38/38',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/38' 
       OR (p.slug = 'bhn-3838-dark-orange-merroon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1570: BHN-38/37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/37',
  'bhn-3837-dark-green-pink',
  'Dark Green/ Pink',
  'Dark Green/ Pink',
  'BHN-38/37',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/37' 
       OR (p.slug = 'bhn-3837-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1571: BHN-38/36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/36',
  'bhn-3836-dark-green-pink',
  'Dark green/ Pink',
  'Dark green/ Pink',
  'BHN-38/36',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/36' 
       OR (p.slug = 'bhn-3836-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1572: BHN-38/35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/35',
  'bhn-3835-yellow-green-red',
  'Yellow/ Green red',
  'Yellow/ Green red',
  'BHN-38/35',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/35' 
       OR (p.slug = 'bhn-3835-yellow-green-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1573: BHN-38/33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/33',
  'bhn-3833-violet-dark-orange',
  'Violet/ Dark Orange',
  'Violet/ Dark Orange',
  'BHN-38/33',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/33' 
       OR (p.slug = 'bhn-3833-violet-dark-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1574: BHN-38/32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/32',
  'bhn-3832-dark-green-pink',
  'Dark Green/ Pink',
  'Dark Green/ Pink',
  'BHN-38/32',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/32' 
       OR (p.slug = 'bhn-3832-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1575: BHN-38/31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/31',
  'bhn-3831-blue-majenta',
  'Blue/ Majenta',
  'Blue/ Majenta',
  'BHN-38/31',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/31' 
       OR (p.slug = 'bhn-3831-blue-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1576: BHN-38/30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/30',
  'bhn-3830-blue-majenta',
  'Blue/ Majenta',
  'Blue/ Majenta',
  'BHN-38/30',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/30' 
       OR (p.slug = 'bhn-3830-blue-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1577: BHN-38/29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/29',
  'bhn-3829-red-green-merroon',
  'Red/ green (Merroon)',
  'Red/ green (Merroon)',
  'BHN-38/29',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-38/29' 
       OR (p.slug = 'bhn-3829-red-green-merroon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1578: BHN-38/28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/28',
  'bhn-3828-orange-yellow-blue',
  'Orange/ Yellow Blue',
  'Orange/ Yellow Blue',
  'BHN-38/28',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/28' 
       OR (p.slug = 'bhn-3828-orange-yellow-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1579: BHN-38/27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/27',
  'bhn-3827-majenta-blue',
  'Majenta/ Blue',
  'Majenta/ Blue',
  'BHN-38/27',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/27' 
       OR (p.slug = 'bhn-3827-majenta-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1580: BHN-38/26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/26',
  'bhn-3826-kilipacaha-pink',
  'Kilipacaha/ Pink',
  'Kilipacaha/ Pink',
  'BHN-38/26',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/26' 
       OR (p.slug = 'bhn-3826-kilipacaha-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1581: BHN-38/24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/24',
  'bhn-3824-yellow-blue-brocade',
  'Yellow/ Blue Brocade',
  'Yellow/ Blue Brocade',
  'BHN-38/24',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/24' 
       OR (p.slug = 'bhn-3824-yellow-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1582: BHN-38/23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/23',
  'bhn-3823-yellow-blue-brocade',
  'Yellow/ Blue Brocade',
  'Yellow/ Blue Brocade',
  'BHN-38/23',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/23' 
       OR (p.slug = 'bhn-3823-yellow-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1583: BHN-38/22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/22',
  'bhn-3822-militry-green-merroon',
  'Militry Green/ Merroon',
  'Militry Green/ Merroon',
  'BHN-38/22',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/22' 
       OR (p.slug = 'bhn-3822-militry-green-merroon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1584: BHN-38/21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/21',
  'bhn-3821-orange-green',
  'Orange/ Green',
  'Orange/ Green',
  'BHN-38/21',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/21' 
       OR (p.slug = 'bhn-3821-orange-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1585: BHN-38/20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/20',
  'bhn-3820-red-blue',
  'Red/ Blue',
  'Red/ Blue',
  'BHN-38/20',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/20' 
       OR (p.slug = 'bhn-3820-red-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1586: BHN-38/19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/19',
  'bhn-3819-red-blue',
  'Red/ Blue',
  'Red/ Blue',
  'BHN-38/19',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/19' 
       OR (p.slug = 'bhn-3819-red-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1587: BHN-38/18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/18',
  'bhn-3818-vadamally-orange',
  'Vadamally/ Orange',
  'Vadamally/ Orange',
  'BHN-38/18',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/18' 
       OR (p.slug = 'bhn-3818-vadamally-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1588: BHN-38/17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/17',
  'bhn-3817-kunguma-color-blue',
  'Kunguma Color/ Blue',
  'Kunguma Color/ Blue',
  'BHN-38/17',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/17' 
       OR (p.slug = 'bhn-3817-kunguma-color-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1589: BHN-38/16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/16',
  'bhn-3816-orange-majenta',
  'Orange/ Majenta',
  'Orange/ Majenta',
  'BHN-38/16',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/16' 
       OR (p.slug = 'bhn-3816-orange-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1590: BHN-38/15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/15',
  'bhn-3815-peacock-green',
  'Peacock Green',
  'Peacock Green',
  'BHN-38/15',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/15' 
       OR (p.slug = 'bhn-3815-peacock-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1591: BHN-38/13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/13',
  'bhn-3813-merroon',
  'Merroon',
  'Merroon',
  'BHN-38/13',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/13' 
       OR (p.slug = 'bhn-3813-merroon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1592: BHN-38/12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/12',
  'bhn-3812-mehandi-pink',
  'Mehandi/ Pink',
  'Mehandi/ Pink',
  'BHN-38/12',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/12' 
       OR (p.slug = 'bhn-3812-mehandi-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1593: BHN-38/11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/11',
  'bhn-3811-green-dark-orange',
  'Green/ Dark Orange',
  'Green/ Dark Orange',
  'BHN-38/11',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/11' 
       OR (p.slug = 'bhn-3811-green-dark-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1594: BHN-38/10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/10',
  'bhn-3810-vadamally-yellow',
  'Vadamally/ Yellow',
  'Vadamally/ Yellow',
  'BHN-38/10',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/10' 
       OR (p.slug = 'bhn-3810-vadamally-yellow' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1595: BHN-38/9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/9',
  'bhn-389-peacock-blue-pink',
  'Peacock Blue/ Pink',
  'Peacock Blue/ Pink',
  'BHN-38/9',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/9' 
       OR (p.slug = 'bhn-389-peacock-blue-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1596: BHN-38/6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/6',
  'bhn-386-blue-light-green',
  'Blue/ Light Green',
  'Blue/ Light Green',
  'BHN-38/6',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/6' 
       OR (p.slug = 'bhn-386-blue-light-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1597: BHN-38/5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/5',
  'bhn-385-violet-pink-gold',
  'Violet Pink/ Gold',
  'Violet Pink/ Gold',
  'BHN-38/5',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/5' 
       OR (p.slug = 'bhn-385-violet-pink-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1598: BHN-38/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/4',
  'bhn-384-red-gold',
  'Red/ Gold',
  'Red/ Gold',
  'BHN-38/4',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/4' 
       OR (p.slug = 'bhn-384-red-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1599: BHN-38/3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/3',
  'bhn-383-violet-gold',
  'Violet/ Gold',
  'Violet/ Gold',
  'BHN-38/3',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/3' 
       OR (p.slug = 'bhn-383-violet-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1600: BHN-38/2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/2',
  'bhn-382-coffee-brown-orange',
  'Coffee Brown/ Orange',
  'Coffee Brown/ Orange',
  'BHN-38/2',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/2' 
       OR (p.slug = 'bhn-382-coffee-brown-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1601: BHN-38/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-38/1',
  'bhn-381-yellow-green-check',
  'Yellow/ Green Check',
  'Yellow/ Green Check',
  'BHN-38/1',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-38/1' 
       OR (p.slug = 'bhn-381-yellow-green-check' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1602: BHN-37/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-37/4',
  'bhn-374-yellow-blue-brocade',
  'Yellow/ Blue Brocade',
  'Yellow/ Blue Brocade',
  'BHN-37/4',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-37/4' 
       OR (p.slug = 'bhn-374-yellow-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1603: BHN-37/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-37/1',
  'bhn-371-blue-red',
  'Blue/ Red',
  'Blue/ Red',
  'BHN-37/1',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-37/1' 
       OR (p.slug = 'bhn-371-blue-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1604: BHN-36/53
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/53',
  'bhn-3653-orange-red',
  'Orange/ Red',
  'Orange/ Red',
  'BHN-36/53',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/53' 
       OR (p.slug = 'bhn-3653-orange-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1605: BHN-36/52
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/52',
  'bhn-3652-red-green-brocade',
  'Red/ Green Brocade',
  'Red/ Green Brocade',
  'BHN-36/52',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/52' 
       OR (p.slug = 'bhn-3652-red-green-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1606: BHN-36/51
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/51',
  'bhn-3651-purple-pink',
  'Purple/ Pink',
  'Purple/ Pink',
  'BHN-36/51',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/51' 
       OR (p.slug = 'bhn-3651-purple-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1607: BHN-36/50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/50',
  'bhn-3650-black-pink',
  'Black/ Pink',
  'Black/ Pink',
  'BHN-36/50',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/50' 
       OR (p.slug = 'bhn-3650-black-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1608: BHN-36/49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/49',
  'bhn-3649-black-pink',
  'Black/ Pink',
  'Black/ Pink',
  'BHN-36/49',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/49' 
       OR (p.slug = 'bhn-3649-black-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1609: BHN-36/48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/48',
  'bhn-3648-yellow-multi',
  'Yellow/ Multi',
  'Yellow/ Multi',
  'BHN-36/48',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/48' 
       OR (p.slug = 'bhn-3648-yellow-multi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1610: BHN-36/47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/47',
  'bhn-3647-brown-pink',
  'Brown/ Pink',
  'Brown/ Pink',
  'BHN-36/47',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/47' 
       OR (p.slug = 'bhn-3647-brown-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1611: BHN-36/46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/46',
  'bhn-3646-black-red',
  'Black/ Red',
  'Black/ Red',
  'BHN-36/46',
  750.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/46' 
       OR (p.slug = 'bhn-3646-black-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1612: BHN-36/45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/45',
  'bhn-3645-orange-red',
  'Orange/ red',
  'Orange/ red',
  'BHN-36/45',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/45' 
       OR (p.slug = 'bhn-3645-orange-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1613: BHN-36/44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/44',
  'bhn-3644-black-red',
  'Black/ Red',
  'Black/ Red',
  'BHN-36/44',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/44' 
       OR (p.slug = 'bhn-3644-black-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1614: BHN-36/43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/43',
  'bhn-3643-yellow-blue-brocade',
  'Yellow/ Blue Brocade',
  'Yellow/ Blue Brocade',
  'BHN-36/43',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/43' 
       OR (p.slug = 'bhn-3643-yellow-blue-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1615: BHN-36/42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/42',
  'bhn-3642-dark-orange-green',
  'Dark Orange/ Green',
  'Dark Orange/ Green',
  'BHN-36/42',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/42' 
       OR (p.slug = 'bhn-3642-dark-orange-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1616: BHN-36/41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/41',
  'bhn-3641-dark-green-pink',
  'Dark Green/ Pink',
  'Dark Green/ Pink',
  'BHN-36/41',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/41' 
       OR (p.slug = 'bhn-3641-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1617: BHN-36/40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/40',
  'bhn-3640-dark-green-pink',
  'Dark Green/ Pink',
  'Dark Green/ Pink',
  'BHN-36/40',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/40' 
       OR (p.slug = 'bhn-3640-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1618: BHN-36/39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/39',
  'bhn-3639-red-green',
  'Red/ Green',
  'Red/ Green',
  'BHN-36/39',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/39' 
       OR (p.slug = 'bhn-3639-red-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1619: BHN-36/38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/38',
  'bhn-3638-vadamally-navy-blue',
  'Vadamally/ Navy Blue',
  'Vadamally/ Navy Blue',
  'BHN-36/38',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/38' 
       OR (p.slug = 'bhn-3638-vadamally-navy-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1620: BHN-36/37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/37',
  'bhn-3637-vadamally-navy-blue',
  'Vadamally/ Navy Blue',
  'Vadamally/ Navy Blue',
  'BHN-36/37',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/37' 
       OR (p.slug = 'bhn-3637-vadamally-navy-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1621: BHN-36/36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/36',
  'bhn-3636-violet-dark-orange',
  'Violet/ Dark Orange',
  'Violet/ Dark Orange',
  'BHN-36/36',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/36' 
       OR (p.slug = 'bhn-3636-violet-dark-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1622: BHN-36/35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/35',
  'bhn-3635-dark-green-pink',
  'Dark Green/ Pink',
  'Dark Green/ Pink',
  'BHN-36/35',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/35' 
       OR (p.slug = 'bhn-3635-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1623: BHN-36/33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/33',
  'bhn-3633-red-green',
  'Red/ Green',
  'Red/ Green',
  'BHN-36/33',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-36/33' 
       OR (p.slug = 'bhn-3633-red-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1624: BHN-36/32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/32',
  'bhn-3632-red-gold',
  'Red/ Gold',
  'Red/ Gold',
  'BHN-36/32',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/32' 
       OR (p.slug = 'bhn-3632-red-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1625: BHN-36/31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/31',
  'bhn-3631-navy-blue-green',
  'Navy Blue/ Green',
  'Navy Blue/ Green',
  'BHN-36/31',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/31' 
       OR (p.slug = 'bhn-3631-navy-blue-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1626: BHN-36/30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/30',
  'bhn-3630-peacock-green-blue',
  'Peacock Green/ Blue',
  'Peacock Green/ Blue',
  'BHN-36/30',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/30' 
       OR (p.slug = 'bhn-3630-peacock-green-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1627: BHN-36/29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/29',
  'bhn-3629-kilipacha-pink',
  'Kilipacha/ Pink',
  'Kilipacha/ Pink',
  'BHN-36/29',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/29' 
       OR (p.slug = 'bhn-3629-kilipacha-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1628: BHN-36/28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/28',
  'bhn-3628-kilipacha-pink',
  'Kilipacha/ Pink',
  'Kilipacha/ Pink',
  'BHN-36/28',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/28' 
       OR (p.slug = 'bhn-3628-kilipacha-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1629: BHN-36/27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/27',
  'bhn-3627-peacock-blue-vadamally',
  'Peacock Blue/ Vadamally',
  'Peacock Blue/ Vadamally',
  'BHN-36/27',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/27' 
       OR (p.slug = 'bhn-3627-peacock-blue-vadamally' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1630: BHN-36/26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/26',
  'bhn-3626-blue-pink',
  'Blue/ Pink',
  'Blue/ Pink',
  'BHN-36/26',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/26' 
       OR (p.slug = 'bhn-3626-blue-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1631: BHN-36/25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/25',
  'bhn-3625-yellow-blue',
  'Yellow/ Blue',
  'Yellow/ Blue',
  'BHN-36/25',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/25' 
       OR (p.slug = 'bhn-3625-yellow-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1632: BHN-36/24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/24',
  'bhn-3624-redblue',
  'Red/Blue',
  'Red/Blue',
  'BHN-36/24',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/24' 
       OR (p.slug = 'bhn-3624-redblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1633: BHN-36/23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/23',
  'bhn-3623-redblue',
  'Red/Blue',
  'Red/Blue',
  'BHN-36/23',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/23' 
       OR (p.slug = 'bhn-3623-redblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1634: BHN-36/22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/22',
  'bhn-3622-red-orange',
  'Red/ Orange',
  'Red/ Orange',
  'BHN-36/22',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/22' 
       OR (p.slug = 'bhn-3622-red-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1635: BHN-36/21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/21',
  'bhn-3621-merroon-vadamally',
  'Merroon/ Vadamally',
  'Merroon/ Vadamally',
  'BHN-36/21',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/21' 
       OR (p.slug = 'bhn-3621-merroon-vadamally' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1636: BHN-36/20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/20',
  'bhn-3620-vadamally',
  'Vadamally',
  'Vadamally',
  'BHN-36/20',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/20' 
       OR (p.slug = 'bhn-3620-vadamally' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1637: BHN-36/19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/19',
  'bhn-3619-copper-sulphate-blue-pink',
  'Copper sulphate blue/ Pink',
  'Copper sulphate blue/ Pink',
  'BHN-36/19',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/19' 
       OR (p.slug = 'bhn-3619-copper-sulphate-blue-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1638: BHN-36/18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/18',
  'bhn-3618-blue-merroon',
  'Blue/ Merroon',
  'Blue/ Merroon',
  'BHN-36/18',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/18' 
       OR (p.slug = 'bhn-3618-blue-merroon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1639: BHN-36/17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/17',
  'bhn-3617-blue-green',
  'Blue/ Green',
  'Blue/ Green',
  'BHN-36/17',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/17' 
       OR (p.slug = 'bhn-3617-blue-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1640: BHN-36/15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/15',
  'bhn-3615-green-orange',
  'Green/ Orange',
  'Green/ Orange',
  'BHN-36/15',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/15' 
       OR (p.slug = 'bhn-3615-green-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1641: BHN-36/13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/13',
  'bhn-3613-orange-majenta',
  'Orange/ Majenta',
  'Orange/ Majenta',
  'BHN-36/13',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/13' 
       OR (p.slug = 'bhn-3613-orange-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1642: BHN-36/12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/12',
  'bhn-3612-orange-majenta',
  'Orange/ Majenta',
  'Orange/ Majenta',
  'BHN-36/12',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/12' 
       OR (p.slug = 'bhn-3612-orange-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1643: BHN-36/11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/11',
  'bhn-3611-red-saree',
  'Red Saree',
  'Red Saree',
  'BHN-36/11',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/11' 
       OR (p.slug = 'bhn-3611-red-saree' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1644: BHN-36/10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/10',
  'bhn-3610-wine-mustard',
  'Wine/ Mustard',
  'Wine/ Mustard',
  'BHN-36/10',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/10' 
       OR (p.slug = 'bhn-3610-wine-mustard' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1645: BHN-36/8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/8',
  'bhn-368-cream-red',
  'Cream/ red',
  'Cream/ red',
  'BHN-36/8',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/8' 
       OR (p.slug = 'bhn-368-cream-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1646: BHN-36/7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/7',
  'bhn-367-green-mustard',
  'Green/ Mustard',
  'Green/ Mustard',
  'BHN-36/7',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/7' 
       OR (p.slug = 'bhn-367-green-mustard' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1647: BHN-36/6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/6',
  'bhn-366-cream-red',
  'Cream/ red',
  'Cream/ red',
  'BHN-36/6',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/6' 
       OR (p.slug = 'bhn-366-cream-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1648: BHN-36/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/4',
  'bhn-364-peacock-orange',
  'Peacock/ Orange',
  'Peacock/ Orange',
  'BHN-36/4',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/4' 
       OR (p.slug = 'bhn-364-peacock-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1649: BHN-36/3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/3',
  'bhn-363-violet-pink',
  'Violet/ Pink',
  'Violet/ Pink',
  'BHN-36/3',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/3' 
       OR (p.slug = 'bhn-363-violet-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1650: BHN-36/2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/2',
  'bhn-362-majenta-surf-blue',
  'Majenta/ Surf Blue',
  'Majenta/ Surf Blue',
  'BHN-36/2',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/2' 
       OR (p.slug = 'bhn-362-majenta-surf-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1651: BHN-36/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-36/1',
  'bhn-361-yellow-dark-green',
  'Yellow/ Dark Green',
  'Yellow/ Dark Green',
  'BHN-36/1',
  420.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-36/1' 
       OR (p.slug = 'bhn-361-yellow-dark-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1652: BHN-35/5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-35/5',
  'bhn-355-yellow-pink',
  'Yellow / Pink',
  'Yellow / Pink',
  'BHN-35/5',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-35/5' 
       OR (p.slug = 'bhn-355-yellow-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1653: BHN-35/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-35/4',
  'bhn-354-mustard-yellow-violet',
  'Mustard Yellow/ Violet',
  'Mustard Yellow/ Violet',
  'BHN-35/4',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-35/4' 
       OR (p.slug = 'bhn-354-mustard-yellow-violet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1654: BHN-35/3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-35/3',
  'bhn-353-grape-wine-peacock-green',
  'Grape Wine/ Peacock Green',
  'Grape Wine/ Peacock Green',
  'BHN-35/3',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-35/3' 
       OR (p.slug = 'bhn-353-grape-wine-peacock-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1655: BHN-35/2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-35/2',
  'bhn-352-blue-dark-orange',
  'Blue/ Dark Orange',
  'Blue/ Dark Orange',
  'BHN-35/2',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-35/2' 
       OR (p.slug = 'bhn-352-blue-dark-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1656: BHN-35/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-35/1',
  'bhn-351-yellow-blue',
  'Yellow/ Blue',
  'Yellow/ Blue',
  'BHN-35/1',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-35/1' 
       OR (p.slug = 'bhn-351-yellow-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1657: BHN-34/33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/33',
  'bhn-3433-dark-pink-sky-bluesaree-model',
  'Dark Pink/ Sky Blue(saree model)',
  'Dark Pink/ Sky Blue(saree model)',
  'BHN-34/33',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-34/33' 
       OR (p.slug = 'bhn-3433-dark-pink-sky-bluesaree-model' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1658: BHN-34/32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/32',
  'bhn-3432-kilipacha-dark-blue',
  'Kilipacha/ Dark Blue',
  'Kilipacha/ Dark Blue',
  'BHN-34/32',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-34/32' 
       OR (p.slug = 'bhn-3432-kilipacha-dark-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1659: BHN-34/31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/31',
  'bhn-3431-purple-dark-orange',
  'Purple/ Dark Orange',
  'Purple/ Dark Orange',
  'BHN-34/31',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-34/31' 
       OR (p.slug = 'bhn-3431-purple-dark-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1660: BHN-34/30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/30',
  'bhn-3430-mango-yellow-green',
  'Mango Yellow/ Green',
  'Mango Yellow/ Green',
  'BHN-34/30',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-34/30' 
       OR (p.slug = 'bhn-3430-mango-yellow-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1661: BHN-34/29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/29',
  'bhn-3429-peacock-blue-majenta',
  'Peacock Blue/ Majenta',
  'Peacock Blue/ Majenta',
  'BHN-34/29',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-34/29' 
       OR (p.slug = 'bhn-3429-peacock-blue-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1662: BHN-34/28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/28',
  'bhn-3428-black-red',
  'Black/ Red',
  'Black/ Red',
  'BHN-34/28',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-34/28' 
       OR (p.slug = 'bhn-3428-black-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1663: BHN-34/27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/27',
  'bhn-3427-green-yellow',
  'Green/ Yellow',
  'Green/ Yellow',
  'BHN-34/27',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-34/27' 
       OR (p.slug = 'bhn-3427-green-yellow' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1664: BHN-34/26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/26',
  'bhn-3426-red-parrot-green',
  'Red/ Parrot Green',
  'Red/ Parrot Green',
  'BHN-34/26',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/26' 
       OR (p.slug = 'bhn-3426-red-parrot-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1665: BHN-34/24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/24',
  'bhn-3424-dark-green-pink',
  'Dark Green/ Pink',
  'Dark Green/ Pink',
  'BHN-34/24',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/24' 
       OR (p.slug = 'bhn-3424-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1666: BHN-34/23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/23',
  'bhn-3423-yellow-blue',
  'Yellow/ Blue',
  'Yellow/ Blue',
  'BHN-34/23',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/23' 
       OR (p.slug = 'bhn-3423-yellow-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1667: BHN-34/21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/21',
  'bhn-3421-kilipacha-pink',
  'Kilipacha/ Pink',
  'Kilipacha/ Pink',
  'BHN-34/21',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/21' 
       OR (p.slug = 'bhn-3421-kilipacha-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1668: BHN-34/20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/20',
  'bhn-3420-kilipacha-pink',
  'Kilipacha/ Pink',
  'Kilipacha/ Pink',
  'BHN-34/20',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/20' 
       OR (p.slug = 'bhn-3420-kilipacha-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1669: BHN-34/19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/19',
  'bhn-3419-yellow-blue',
  'Yellow / Blue',
  'Yellow / Blue',
  'BHN-34/19',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/19' 
       OR (p.slug = 'bhn-3419-yellow-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1670: BHN-34/18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/18',
  'bhn-3418-red-blue',
  'Red/ Blue',
  'Red/ Blue',
  'BHN-34/18',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/18' 
       OR (p.slug = 'bhn-3418-red-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1671: BHN-34/17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/17',
  'bhn-3417-dark-green-red',
  'Dark Green/ Red',
  'Dark Green/ Red',
  'BHN-34/17',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/17' 
       OR (p.slug = 'bhn-3417-dark-green-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1672: BHN-34/16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/16',
  'bhn-3416-copper-sulphate-blue',
  'Copper sulphate blue',
  'Copper sulphate blue',
  'BHN-34/16',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/16' 
       OR (p.slug = 'bhn-3416-copper-sulphate-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1673: BHN-34/15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/15',
  'bhn-3415-orange-blue',
  'Orange/ Blue',
  'Orange/ Blue',
  'BHN-34/15',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/15' 
       OR (p.slug = 'bhn-3415-orange-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1674: BHN-34/13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/13',
  'bhn-3413-blue-red',
  'Blue/ Red',
  'Blue/ Red',
  'BHN-34/13',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/13' 
       OR (p.slug = 'bhn-3413-blue-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1675: BHN-34/12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/12',
  'bhn-3412-orange-majenta',
  'Orange/ Majenta',
  'Orange/ Majenta',
  'BHN-34/12',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/12' 
       OR (p.slug = 'bhn-3412-orange-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1676: BHN-34/11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/11',
  'bhn-3411-violet-vadamally',
  'Violet/ vadamally',
  'Violet/ vadamally',
  'BHN-34/11',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/11' 
       OR (p.slug = 'bhn-3411-violet-vadamally' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1677: BHN-34/9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/9',
  'bhn-349-red',
  'Red',
  'Red',
  'BHN-34/9',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/9' 
       OR (p.slug = 'bhn-349-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1678: BHN-34/8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/8',
  'bhn-348-red-gold',
  'Red/ Gold',
  'Red/ Gold',
  'BHN-34/8',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/8' 
       OR (p.slug = 'bhn-348-red-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1679: BHN-34/7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/7',
  'bhn-347-peacock-green-vadamally',
  'Peacock Green/ Vadamally',
  'Peacock Green/ Vadamally',
  'BHN-34/7',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/7' 
       OR (p.slug = 'bhn-347-peacock-green-vadamally' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1680: BHN-34/6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/6',
  'bhn-346-wine-pink',
  'Wine/ Pink',
  'Wine/ Pink',
  'BHN-34/6',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/6' 
       OR (p.slug = 'bhn-346-wine-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1681: BHN-34/5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/5',
  'bhn-345-vadamallysky-blue',
  'Vadamally/Sky blue',
  'Vadamally/Sky blue',
  'BHN-34/5',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/5' 
       OR (p.slug = 'bhn-345-vadamallysky-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1682: BHN-34/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/4',
  'bhn-344-pinkviolet',
  'Pink/Violet',
  'Pink/Violet',
  'BHN-34/4',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/4' 
       OR (p.slug = 'bhn-344-pinkviolet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1683: BHN-34/3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/3',
  'bhn-343-redkilipacha',
  'Red/Kilipacha',
  'Red/Kilipacha',
  'BHN-34/3',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/3' 
       OR (p.slug = 'bhn-343-redkilipacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1684: BHN-34/2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/2',
  'bhn-342-yellow-check-green',
  'Yellow check/ Green',
  'Yellow check/ Green',
  'BHN-34/2',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/2' 
       OR (p.slug = 'bhn-342-yellow-check-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1685: BHN-34/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-34/1',
  'bhn-341-orangeblack',
  'Orange/Black',
  'Orange/Black',
  'BHN-34/1',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-34/1' 
       OR (p.slug = 'bhn-341-orangeblack' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1686: BHN-32/26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/26',
  'bhn-3226-peachgreen',
  'Peach/Green',
  'Peach/Green',
  'BHN-32/26',
  1260.00,
  3500.00,
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
    WHERE p.barcode = 'BHN-32/26' 
       OR (p.slug = 'bhn-3226-peachgreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1687: BHN-32/25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/25',
  'bhn-3225-pista-green-pink',
  'Pista Green/ Pink',
  'Pista Green/ Pink',
  'BHN-32/25',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-32/25' 
       OR (p.slug = 'bhn-3225-pista-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1688: BHN-32/24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/24',
  'bhn-3224-mango-yellow-violet',
  'Mango Yellow/ Violet',
  'Mango Yellow/ Violet',
  'BHN-32/24',
  680.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-32/24' 
       OR (p.slug = 'bhn-3224-mango-yellow-violet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1689: BHN-32/23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/23',
  'bhn-3223-dark-green-pink',
  'Dark Green/ Pink',
  'Dark Green/ Pink',
  'BHN-32/23',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-32/23' 
       OR (p.slug = 'bhn-3223-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1690: BHN-32/22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/22',
  'bhn-3222-vadamally-blue',
  'Vadamally/ Blue',
  'Vadamally/ Blue',
  'BHN-32/22',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-32/22' 
       OR (p.slug = 'bhn-3222-vadamally-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1691: BHN-32/21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/21',
  'bhn-3221-black-red',
  'Black/ Red',
  'Black/ Red',
  'BHN-32/21',
  630.00,
  3200.00,
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
    WHERE p.barcode = 'BHN-32/21' 
       OR (p.slug = 'bhn-3221-black-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1692: BHN-32/20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/20',
  'bhn-3220-red-parrot-green',
  'Red/ Parrot green',
  'Red/ Parrot green',
  'BHN-32/20',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/20' 
       OR (p.slug = 'bhn-3220-red-parrot-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1693: BHN-32/19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/19',
  'bhn-3219-pista-green-pink',
  'Pista Green/ Pink',
  'Pista Green/ Pink',
  'BHN-32/19',
  580.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/19' 
       OR (p.slug = 'bhn-3219-pista-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1694: BHN-32/18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/18',
  'bhn-3218-dark-green-pink',
  'Dark Green/ Pink',
  'Dark Green/ Pink',
  'BHN-32/18',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/18' 
       OR (p.slug = 'bhn-3218-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1695: BHN-32/16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/16',
  'bhn-3216-green-orange',
  'Green/ Orange',
  'Green/ Orange',
  'BHN-32/16',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/16' 
       OR (p.slug = 'bhn-3216-green-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1696: BHN-32/15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/15',
  'bhn-3215-kilipacha-pink',
  'Kilipacha/ Pink',
  'Kilipacha/ Pink',
  'BHN-32/15',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/15' 
       OR (p.slug = 'bhn-3215-kilipacha-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1697: BHN-32/14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/14',
  'bhn-3214-kilipacha-pink',
  'Kilipacha/ Pink',
  'Kilipacha/ Pink',
  'BHN-32/14',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/14' 
       OR (p.slug = 'bhn-3214-kilipacha-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1698: BHN-32/12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/12',
  'bhn-3212-pista-greenblue',
  'Pista Green/Blue',
  'Pista Green/Blue',
  'BHN-32/12',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/12' 
       OR (p.slug = 'bhn-3212-pista-greenblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1699: BHN-32/11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/11',
  'bhn-3211-blue-red',
  'Blue/ Red',
  'Blue/ Red',
  'BHN-32/11',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/11' 
       OR (p.slug = 'bhn-3211-blue-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1700: BHN-32/10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/10',
  'bhn-3210-orange-majenta',
  'Orange / Majenta',
  'Orange / Majenta',
  'BHN-32/10',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/10' 
       OR (p.slug = 'bhn-3210-orange-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1701: BHN-32/8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/8',
  'bhn-328-coffee-brown-orange',
  'Coffee Brown/ Orange',
  'Coffee Brown/ Orange',
  'BHN-32/8',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/8' 
       OR (p.slug = 'bhn-328-coffee-brown-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1702: BHN-32/6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/6',
  'bhn-326-pinkorange',
  'Pink/Orange',
  'Pink/Orange',
  'BHN-32/6',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/6' 
       OR (p.slug = 'bhn-326-pinkorange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1703: BHN-32/5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/5',
  'bhn-325-mango-yellow-violet',
  'Mango Yellow/ Violet',
  'Mango Yellow/ Violet',
  'BHN-32/5',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/5' 
       OR (p.slug = 'bhn-325-mango-yellow-violet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1704: BHN-32/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/4',
  'bhn-324-surf-blue-violet',
  'Surf Blue/ Violet',
  'Surf Blue/ Violet',
  'BHN-32/4',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/4' 
       OR (p.slug = 'bhn-324-surf-blue-violet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1705: BHN-32/3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/3',
  'bhn-323-bluepink',
  'Blue/Pink',
  'Blue/Pink',
  'BHN-32/3',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/3' 
       OR (p.slug = 'bhn-323-bluepink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1706: BHN-32/2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/2',
  'bhn-322-yellowdark-green',
  'Yellow/Dark Green',
  'Yellow/Dark Green',
  'BHN-32/2',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/2' 
       OR (p.slug = 'bhn-322-yellowdark-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1707: BHN-32/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-32/1',
  'bhn-321-blueorange',
  'Blue/Orange',
  'Blue/Orange',
  'BHN-32/1',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-32/1' 
       OR (p.slug = 'bhn-321-blueorange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1708: BHN-30/12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-30/12',
  'bhn-3012-redgreen',
  'Red/Green',
  'Red/Green',
  'BHN-30/12',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-30/12' 
       OR (p.slug = 'bhn-3012-redgreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1709: BHN-30/11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-30/11',
  'bhn-3011-pista-greenred',
  'Pista Green/Red',
  'Pista Green/Red',
  'BHN-30/11',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-30/11' 
       OR (p.slug = 'bhn-3011-pista-greenred' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1710: BHN-30/10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-30/10',
  'bhn-3010-mango-yellowmajenta-green',
  'Mango Yellow/Majenta Green',
  'Mango Yellow/Majenta Green',
  'BHN-30/10',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-30/10' 
       OR (p.slug = 'bhn-3010-mango-yellowmajenta-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1711: BHN-30/9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-30/9',
  'bhn-309-greenmarroon',
  'Green/Marroon',
  'Green/Marroon',
  'BHN-30/9',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-30/9' 
       OR (p.slug = 'bhn-309-greenmarroon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1712: BHN-30/8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-30/8',
  'bhn-308-greenviolet',
  'Green/Violet',
  'Green/Violet',
  'BHN-30/8',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-30/8' 
       OR (p.slug = 'bhn-308-greenviolet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1713: BHN-30/7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-30/7',
  'bhn-307-light-bluepurple',
  'Light Blue/Purple',
  'Light Blue/Purple',
  'BHN-30/7',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-30/7' 
       OR (p.slug = 'bhn-307-light-bluepurple' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1714: BHN-30/5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-30/5',
  'bhn-305-skybluelight-orange',
  'Skyblue/Light Orange',
  'Skyblue/Light Orange',
  'BHN-30/5',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-30/5' 
       OR (p.slug = 'bhn-305-skybluelight-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1715: BHN-30/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-30/4',
  'bhn-304-orangeblack',
  'Orange/Black',
  'Orange/Black',
  'BHN-30/4',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-30/4' 
       OR (p.slug = 'bhn-304-orangeblack' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1716: BHN-30/3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-30/3',
  'bhn-303-vadamayy-green',
  'Vadamayy/ Green',
  'Vadamayy/ Green',
  'BHN-30/3',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-30/3' 
       OR (p.slug = 'bhn-303-vadamayy-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1717: BHN-30/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-30/1',
  'bhn-301-coffeepink',
  'Coffee/Pink',
  'Coffee/Pink',
  'BHN-30/1',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-30/1' 
       OR (p.slug = 'bhn-301-coffeepink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1718: BHN-28/13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/13',
  'bhn-2813-kilipachared',
  'Kilipacha/Red',
  'Kilipacha/Red',
  'BHN-28/13',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/13' 
       OR (p.slug = 'bhn-2813-kilipachared' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1719: BHN-28/12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/12',
  'bhn-2812-dark-orangelight-orange',
  'Dark Orange/Light Orange',
  'Dark Orange/Light Orange',
  'BHN-28/12',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/12' 
       OR (p.slug = 'bhn-2812-dark-orangelight-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1720: BHN-28/11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/11',
  'bhn-2811-greenorange',
  'Green/Orange',
  'Green/Orange',
  'BHN-28/11',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/11' 
       OR (p.slug = 'bhn-2811-greenorange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1721: BHN-28/10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/10',
  'bhn-2810-purpleorange',
  'Purple/Orange',
  'Purple/Orange',
  'BHN-28/10',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/10' 
       OR (p.slug = 'bhn-2810-purpleorange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1722: BHN-28/9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/9',
  'bhn-289-redblue',
  'Red/Blue',
  'Red/Blue',
  'BHN-28/9',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/9' 
       OR (p.slug = 'bhn-289-redblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1723: BHN-28/8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/8',
  'bhn-288-orangemajenta',
  'Orange/Majenta',
  'Orange/Majenta',
  'BHN-28/8',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/8' 
       OR (p.slug = 'bhn-288-orangemajenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1724: BHN-28/7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/7',
  'bhn-287-orangemajenta',
  'Orange/Majenta',
  'Orange/Majenta',
  'BHN-28/7',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/7' 
       OR (p.slug = 'bhn-287-orangemajenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1725: BHN-28/6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/6',
  'bhn-286-greenpink',
  'Green/Pink',
  'Green/Pink',
  'BHN-28/6',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/6' 
       OR (p.slug = 'bhn-286-greenpink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1726: BHN-28/5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/5',
  'bhn-285-bluered',
  'Blue/Red',
  'Blue/Red',
  'BHN-28/5',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/5' 
       OR (p.slug = 'bhn-285-bluered' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1727: BHN-28/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/4',
  'bhn-284-bluelight-green',
  'Blue/Light Green',
  'Blue/Light Green',
  'BHN-28/4',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/4' 
       OR (p.slug = 'bhn-284-bluelight-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1728: BHN-28/3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/3',
  'bhn-283-blueyellow',
  'Blue/Yellow',
  'Blue/Yellow',
  'BHN-28/3',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/3' 
       OR (p.slug = 'bhn-283-blueyellow' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1729: BHN-28/2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/2',
  'bhn-282-dark-greengolden-yellow',
  'Dark Green/Golden yellow',
  'Dark Green/Golden yellow',
  'BHN-28/2',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/2' 
       OR (p.slug = 'bhn-282-dark-greengolden-yellow' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1730: BHN-28/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-28/1',
  'bhn-281-coffe-brownorange',
  'Coffe brown/Orange',
  'Coffe brown/Orange',
  'BHN-28/1',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-28/1' 
       OR (p.slug = 'bhn-281-coffe-brownorange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1731: BHN-26/9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-26/9',
  'bhn-269-greenviolet',
  'Green/Violet',
  'Green/Violet',
  'BHN-26/9',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-26/9' 
       OR (p.slug = 'bhn-269-greenviolet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1732: BHN-26/8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-26/8',
  'bhn-268-vadamallyorange',
  'Vadamally/Orange',
  'Vadamally/Orange',
  'BHN-26/8',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-26/8' 
       OR (p.slug = 'bhn-268-vadamallyorange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1733: BHN-26/7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-26/7',
  'bhn-267-bluegold',
  'Blue/Gold',
  'Blue/Gold',
  'BHN-26/7',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-26/7' 
       OR (p.slug = 'bhn-267-bluegold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1734: BHN-26/6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-26/6',
  'bhn-266-redgreen',
  'Red/Green',
  'Red/Green',
  'BHN-26/6',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-26/6' 
       OR (p.slug = 'bhn-266-redgreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1735: BHN-26/5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-26/5',
  'bhn-265-brownyellow',
  'Brown/yellow',
  'Brown/yellow',
  'BHN-26/5',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-26/5' 
       OR (p.slug = 'bhn-265-brownyellow' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1736: BHN-26/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-26/4',
  'bhn-264-orangevadamally',
  'Orange/Vadamally',
  'Orange/Vadamally',
  'BHN-26/4',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-26/4' 
       OR (p.slug = 'bhn-264-orangevadamally' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1737: BHN-26/3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-26/3',
  'bhn-263-peacock-greendark-orange',
  'Peacock Green/Dark Orange',
  'Peacock Green/Dark Orange',
  'BHN-26/3',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-26/3' 
       OR (p.slug = 'bhn-263-peacock-greendark-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1738: BHN-26/2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-26/2',
  'bhn-262-skybluered',
  'Skyblue/Red',
  'Skyblue/Red',
  'BHN-26/2',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-26/2' 
       OR (p.slug = 'bhn-262-skybluered' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1739: BHN-26/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-26/1',
  'bhn-261-violetdark-orange',
  'Violet/Dark Orange',
  'Violet/Dark Orange',
  'BHN-26/1',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-26/1' 
       OR (p.slug = 'bhn-261-violetdark-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1740: BHN-24/10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-24/10',
  'bhn-2410-bluekilipacha',
  'Blue/Kilipacha',
  'Blue/Kilipacha',
  'BHN-24/10',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-24/10' 
       OR (p.slug = 'bhn-2410-bluekilipacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1741: BHN-24/9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-24/9',
  'bhn-249-violetkilipacha',
  'Violet/Kilipacha',
  'Violet/Kilipacha',
  'BHN-24/9',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-24/9' 
       OR (p.slug = 'bhn-249-violetkilipacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1742: BHN-24/8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-24/8',
  'bhn-248-bluedark-orange',
  'Blue/Dark Orange',
  'Blue/Dark Orange',
  'BHN-24/8',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-24/8' 
       OR (p.slug = 'bhn-248-bluedark-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1743: BHN-24/7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-24/7',
  'bhn-247-greenred',
  'Green/Red',
  'Green/Red',
  'BHN-24/7',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-24/7' 
       OR (p.slug = 'bhn-247-greenred' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1744: BHN-24/6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-24/6',
  'bhn-246-bluered',
  'Blue/red',
  'Blue/red',
  'BHN-24/6',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-24/6' 
       OR (p.slug = 'bhn-246-bluered' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1745: BHN-24/5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-24/5',
  'bhn-245-greenpink',
  'Green/Pink',
  'Green/Pink',
  'BHN-24/5',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-24/5' 
       OR (p.slug = 'bhn-245-greenpink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1746: BHN-24/4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-24/4',
  'bhn-244-orangebrown',
  'Orange/Brown',
  'Orange/Brown',
  'BHN-24/4',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-24/4' 
       OR (p.slug = 'bhn-244-orangebrown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1747: BHN-24/3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-24/3',
  'bhn-243-violet-orange',
  'Violet/ Orange',
  'Violet/ Orange',
  'BHN-24/3',
  530.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-24/3' 
       OR (p.slug = 'bhn-243-violet-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1748: BHN-24/2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-24/2',
  'bhn-242-orangegreen',
  'Orange/Green',
  'Orange/Green',
  'BHN-24/2',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-24/2' 
       OR (p.slug = 'bhn-242-orangegreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1749: BHN-24/1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'bharathanattyam' AND store_id = s.id LIMIT 1),
  b.id,
  'BHN-24/1',
  'bhn-241-bluepink',
  'Blue/Pink',
  'Blue/Pink',
  'BHN-24/1',
  470.00,
  2500.00,
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
    WHERE p.barcode = 'BHN-24/1' 
       OR (p.slug = 'bhn-241-bluepink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;


-- ════════════════════════════════════════════════════════════════════════════
-- GENERATE PRODUCT INVENTORY MAPPINGS FOR PART 4
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
