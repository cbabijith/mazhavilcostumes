-- ============================================================================
-- Migration 028: Import First 500 Products from CSV (product02csv.csv) - Part 1
-- Purpose:   Inserts categories and the first 500 products with correct
--            prices, quantities, and inventory mappings.
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
-- INSERT FIRST 500 PRODUCTS
-- ════════════════════════════════════════════════════════════════════════════

-- Product #1: TOP-83
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-83',
  'top-83-black-velvet-bahubali',
  'Black velvet Bahubali',
  'Black velvet Bahubali',
  'TOP-83',
  150.00,
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
    WHERE p.barcode = 'TOP-83' 
       OR (p.slug = 'top-83-black-velvet-bahubali' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #2: TOP-82
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-82',
  'top-82-thiruvathira-red',
  'Thiruvathira Red',
  'Thiruvathira Red',
  'TOP-82',
  150.00,
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
    WHERE p.barcode = 'TOP-82' 
       OR (p.slug = 'top-82-thiruvathira-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #3: TOP-81
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-81',
  'top-81-thiruvathira-green',
  'Thiruvathira Green',
  'Thiruvathira Green',
  'TOP-81',
  150.00,
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
    WHERE p.barcode = 'TOP-81' 
       OR (p.slug = 'top-81-thiruvathira-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #4: TOP-80
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-80',
  'top-80-green-seq-velvet-blouse',
  'Green seq velvet blouse',
  'Green seq velvet blouse',
  'TOP-80',
  125.00,
  1000.00,
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
    WHERE p.barcode = 'TOP-80' 
       OR (p.slug = 'top-80-green-seq-velvet-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #5: TOP-79
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-79',
  'top-79-white-minukku-cloth',
  'White minukku cloth',
  'White minukku cloth',
  'TOP-79',
  125.00,
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
    WHERE p.barcode = 'TOP-79' 
       OR (p.slug = 'top-79-white-minukku-cloth' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #6: TOP-78
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-78',
  'top-78-white-brocade-choli-blouse',
  'White brocade choli blouse',
  'White brocade choli blouse',
  'TOP-78',
  150.00,
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
    WHERE p.barcode = 'TOP-78' 
       OR (p.slug = 'top-78-white-brocade-choli-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #7: TOP-77
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-77',
  'top-77-black-brocade-choli-blouse',
  'Black brocade choli blouse',
  'Black brocade choli blouse',
  'TOP-77',
  150.00,
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
    WHERE p.barcode = 'TOP-77' 
       OR (p.slug = 'top-77-black-brocade-choli-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #8: TOP-76
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-76',
  'top-76-whitegreen-oppana-top',
  'White/Green Oppana top',
  'White/Green Oppana top',
  'TOP-76',
  175.00,
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
    WHERE p.barcode = 'TOP-76' 
       OR (p.slug = 'top-76-whitegreen-oppana-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #9: TOP-75
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-75',
  'top-75-white-red-oppana-top',
  'White/ Red oppana top',
  'White/ Red oppana top',
  'TOP-75',
  175.00,
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
    WHERE p.barcode = 'TOP-75' 
       OR (p.slug = 'top-75-white-red-oppana-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #10: TOP-74
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-74',
  'top-74-gold-full-sleeve-long-top',
  'Gold full sleeve long top',
  'Gold full sleeve long top',
  'TOP-74',
  150.00,
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
    WHERE p.barcode = 'TOP-74' 
       OR (p.slug = 'top-74-gold-full-sleeve-long-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #11: TOP-73
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-73',
  'top-73-neriyathu-blouse-puff-sleeve',
  'Neriyathu blouse puff sleeve',
  'Neriyathu blouse puff sleeve',
  'TOP-73',
  125.00,
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
    WHERE p.barcode = 'TOP-73' 
       OR (p.slug = 'top-73-neriyathu-blouse-puff-sleeve' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #12: TOP-72
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-72',
  'top-72-off-whiteflower-design-long-top',
  'Off whiteflower design long top',
  'Off whiteflower design long top',
  'TOP-72',
  125.00,
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
    WHERE p.barcode = 'TOP-72' 
       OR (p.slug = 'top-72-off-whiteflower-design-long-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #13: TOP-71
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-71',
  'top-71-red-white-polka-dot-top',
  'Red white polka dot top',
  'Red white polka dot top',
  'TOP-71',
  125.00,
  500.00,
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
    WHERE p.barcode = 'TOP-71' 
       OR (p.slug = 'top-71-red-white-polka-dot-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #14: TOP-70
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-70',
  'top-70-black-puff-sleevesmall-top',
  'Black puff sleevesmall top',
  'Black puff sleevesmall top',
  'TOP-70',
  125.00,
  500.00,
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
    WHERE p.barcode = 'TOP-70' 
       OR (p.slug = 'top-70-black-puff-sleevesmall-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #15: TOP-69
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-69',
  'top-69-green-brocade-puff-short-top',
  'Green brocade puff short top',
  'Green brocade puff short top',
  'TOP-69',
  150.00,
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
    WHERE p.barcode = 'TOP-69' 
       OR (p.slug = 'top-69-green-brocade-puff-short-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #16: TOP-68
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-68',
  'top-68-gold-puff-sleeve-long-top',
  'Gold puff sleeve long top',
  'Gold puff sleeve long top',
  'TOP-68',
  125.00,
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
    WHERE p.barcode = 'TOP-68' 
       OR (p.slug = 'top-68-gold-puff-sleeve-long-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #17: TOP-67
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-67',
  'top-67-full-plain-blacklong-top',
  'Full plain blackLong top',
  'Full plain blackLong top',
  'TOP-67',
  150.00,
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
    WHERE p.barcode = 'TOP-67' 
       OR (p.slug = 'top-67-full-plain-blacklong-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #18: TOP-66
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-66',
  'top-66-gold-satin-sleeveless-top-king',
  'Gold satin sleeveless top king',
  'Gold satin sleeveless top king',
  'TOP-66',
  125.00,
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
    WHERE p.barcode = 'TOP-66' 
       OR (p.slug = 'top-66-gold-satin-sleeveless-top-king' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #19: TOP-65
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-65',
  'top-65-yellow-full-sequence',
  'Yellow full sequence',
  'Yellow full sequence',
  'TOP-65',
  80.00,
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
    WHERE p.barcode = 'TOP-65' 
       OR (p.slug = 'top-65-yellow-full-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #20: TOP-64
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-64',
  'top-64-pink-full-seq-top-long',
  'Pink full seq top long',
  'Pink full seq top long',
  'TOP-64',
  150.00,
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
    WHERE p.barcode = 'TOP-64' 
       OR (p.slug = 'top-64-pink-full-seq-top-long' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #21: TOP-63
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-63',
  'top-63-gold-full-seq-top-long',
  'Gold full seq top long',
  'Gold full seq top long',
  'TOP-63',
  150.00,
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
    WHERE p.barcode = 'TOP-63' 
       OR (p.slug = 'top-63-gold-full-seq-top-long' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #22: TOP-62
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-62',
  'top-62-black-net-gold-dot',
  'Black net gold dot',
  'Black net gold dot',
  'TOP-62',
  150.00,
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
    WHERE p.barcode = 'TOP-62' 
       OR (p.slug = 'top-62-black-net-gold-dot' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #23: TOP-61
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-61',
  'top-61-pista-gree-gold-border',
  'Pista gree gold border',
  'Pista gree gold border',
  'TOP-61',
  125.00,
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
    WHERE p.barcode = 'TOP-61' 
       OR (p.slug = 'top-61-pista-gree-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #24: TOP-60
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-60',
  'top-60-red-seq-top-gold-border',
  'Red seq top gold border',
  'Red seq top gold border',
  'TOP-60',
  125.00,
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
    WHERE p.barcode = 'TOP-60' 
       OR (p.slug = 'top-60-red-seq-top-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #25: TOP-59
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-59',
  'top-59-red-satin-black-design-neck-top',
  'Red satin black design neck top',
  'Red satin black design neck top',
  'TOP-59',
  125.00,
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
    WHERE p.barcode = 'TOP-59' 
       OR (p.slug = 'top-59-red-satin-black-design-neck-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #26: TOP-58
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-58',
  'top-58-blue-plain-with-gold-border-xl',
  'Blue plain with gold border XL',
  'Blue plain with gold border XL',
  'TOP-58',
  125.00,
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
    WHERE p.barcode = 'TOP-58' 
       OR (p.slug = 'top-58-blue-plain-with-gold-border-xl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #27: TOP-57
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-57',
  'top-57-pink-with-gold-border-xl',
  'Pink with gold border XL',
  'Pink with gold border XL',
  'TOP-57',
  125.00,
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
    WHERE p.barcode = 'TOP-57' 
       OR (p.slug = 'top-57-pink-with-gold-border-xl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #28: TOP-56
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-56',
  'top-56-green-with-gold-border-xl',
  'Green with gold border XL',
  'Green with gold border XL',
  'TOP-56',
  125.00,
  500.00,
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
    WHERE p.barcode = 'TOP-56' 
       OR (p.slug = 'top-56-green-with-gold-border-xl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #29: TOP-55
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-55',
  'top-55-red-with-gold-border-xl',
  'Red with gold border XL',
  'Red with gold border XL',
  'TOP-55',
  125.00,
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
    WHERE p.barcode = 'TOP-55' 
       OR (p.slug = 'top-55-red-with-gold-border-xl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #30: TOP-54
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-54',
  'top-54-plain-red-with-border',
  'Plain red with border',
  'Plain red with border',
  'TOP-54',
  80.00,
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
    WHERE p.barcode = 'TOP-54' 
       OR (p.slug = 'top-54-plain-red-with-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #31: TOP-53
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-53',
  'top-53-plain-red-blouseno-brocade',
  'Plain red blouse(No brocade)',
  'Plain red blouse(No brocade)',
  'TOP-53',
  80.00,
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
    WHERE p.barcode = 'TOP-53' 
       OR (p.slug = 'top-53-plain-red-blouseno-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #32: TOP-52
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-52',
  'top-52-blue-check-brocade-thiruvatira-blouse',
  'Blue check brocade thiruvatira blouse',
  'Blue check brocade thiruvatira blouse',
  'TOP-52',
  125.00,
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
    WHERE p.barcode = 'TOP-52' 
       OR (p.slug = 'top-52-blue-check-brocade-thiruvatira-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #33: TOP-51
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-51',
  'top-51-green-check-brocadethiruvathira-blouse',
  'Green check brocadeThiruvathira blouse',
  'Green check brocadeThiruvathira blouse',
  'TOP-51',
  125.00,
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
    WHERE p.barcode = 'TOP-51' 
       OR (p.slug = 'top-51-green-check-brocadethiruvathira-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #34: TOP-50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-50',
  'top-50-majenta-brocade-blouse',
  'Majenta brocade blouse',
  'Majenta brocade blouse',
  'TOP-50',
  125.00,
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
    WHERE p.barcode = 'TOP-50' 
       OR (p.slug = 'top-50-majenta-brocade-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #35: TOP-49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-49',
  'top-49-blue-brocade-blouse',
  'Blue brocade blouse',
  'Blue brocade blouse',
  'TOP-49',
  125.00,
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
    WHERE p.barcode = 'TOP-49' 
       OR (p.slug = 'top-49-blue-brocade-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #36: TOP-48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-48',
  'top-48-orange-velvet',
  'Orange velvet',
  'Orange velvet',
  'TOP-48',
  125.00,
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
    WHERE p.barcode = 'TOP-48' 
       OR (p.slug = 'top-48-orange-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #37: TOP-47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-47',
  'top-47-pista-green-blouse',
  'Pista green blouse',
  'Pista green blouse',
  'TOP-47',
  125.00,
  500.00,
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
    WHERE p.barcode = 'TOP-47' 
       OR (p.slug = 'top-47-pista-green-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #38: TOP-46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-46',
  'top-46-red-white-flower',
  'Red white flower',
  'Red white flower',
  'TOP-46',
  80.00,
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
    WHERE p.barcode = 'TOP-46' 
       OR (p.slug = 'top-46-red-white-flower' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #39: TOP-45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-45',
  'top-45-black-dot-small',
  'Black dot small',
  'Black dot small',
  'TOP-45',
  80.00,
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
    WHERE p.barcode = 'TOP-45' 
       OR (p.slug = 'top-45-black-dot-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #40: TOP-44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-44',
  'top-44-majenta-brocade',
  'Majenta brocade',
  'Majenta brocade',
  'TOP-44',
  125.00,
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
    WHERE p.barcode = 'TOP-44' 
       OR (p.slug = 'top-44-majenta-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #41: TOP-43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-43',
  'top-43-whitered-dot',
  'White/Red dot',
  'White/Red dot',
  'TOP-43',
  50.00,
  250.00,
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
    WHERE p.barcode = 'TOP-43' 
       OR (p.slug = 'top-43-whitered-dot' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #42: TOP-42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-42',
  'top-42-greenyellow-dot-puff',
  'GREEN/YELLOW DOT PUFF',
  'GREEN/YELLOW DOT PUFF',
  'TOP-42',
  50.00,
  250.00,
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
    WHERE p.barcode = 'TOP-42' 
       OR (p.slug = 'top-42-greenyellow-dot-puff' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #43: TOP-41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-41',
  'top-41-blue-gold',
  'BLUE GOLD',
  'BLUE GOLD',
  'TOP-41',
  125.00,
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
    WHERE p.barcode = 'TOP-41' 
       OR (p.slug = 'top-41-blue-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #44: TOP-40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-40',
  'top-40-orange-full-sleeve',
  'ORANGE FULL SLEEVE',
  'ORANGE FULL SLEEVE',
  'TOP-40',
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
    WHERE p.barcode = 'TOP-40' 
       OR (p.slug = 'top-40-orange-full-sleeve' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #45: TOP-39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-39',
  'top-39-gold-full',
  'GOLD FULL',
  'GOLD FULL',
  'TOP-39',
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
    WHERE p.barcode = 'TOP-39' 
       OR (p.slug = 'top-39-gold-full' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #46: TOP-38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-38',
  'top-38-silverblack',
  'SILVER/BLACK',
  'SILVER/BLACK',
  'TOP-38',
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
    WHERE p.barcode = 'TOP-38' 
       OR (p.slug = 'top-38-silverblack' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #47: TOP-37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-37',
  'top-37-blackgold',
  'BLACK/GOLD',
  'BLACK/GOLD',
  'TOP-37',
  150.00,
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
    WHERE p.barcode = 'TOP-37' 
       OR (p.slug = 'top-37-blackgold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #48: TOP-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-36',
  'top-36-rajastani-blouse',
  'RAJASTANI BLOUSE',
  'RAJASTANI BLOUSE',
  'TOP-36',
  125.00,
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
    WHERE p.barcode = 'TOP-36' 
       OR (p.slug = 'top-36-rajastani-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #49: TOP-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-35',
  'top-35-majentagreen',
  'MAJENTA/GREEN',
  'MAJENTA/GREEN',
  'TOP-35',
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
    WHERE p.barcode = 'TOP-35' 
       OR (p.slug = 'top-35-majentagreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #50: TOP-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-34',
  'top-34-majentablue',
  'MAJENTA/BLUE',
  'MAJENTA/BLUE',
  'TOP-34',
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
    WHERE p.barcode = 'TOP-34' 
       OR (p.slug = 'top-34-majentablue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #51: TOP-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-33',
  'top-33-green-sequence',
  'GREEN SEQUENCE',
  'GREEN SEQUENCE',
  'TOP-33',
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
    WHERE p.barcode = 'TOP-33' 
       OR (p.slug = 'top-33-green-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #52: TOP-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-32',
  'top-32-green-mirror',
  'GREEN MIRROR',
  'GREEN MIRROR',
  'TOP-32',
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
    WHERE p.barcode = 'TOP-32' 
       OR (p.slug = 'top-32-green-mirror' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #53: TOP-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-31',
  'top-31-black-puff',
  'BLACK PUFF',
  'BLACK PUFF',
  'TOP-31',
  125.00,
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
    WHERE p.barcode = 'TOP-31' 
       OR (p.slug = 'top-31-black-puff' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #54: TOP-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-30',
  'top-30-light-yellow-puff',
  'LIGHT YELLOW PUFF',
  'LIGHT YELLOW PUFF',
  'TOP-30',
  125.00,
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
    WHERE p.barcode = 'TOP-30' 
       OR (p.slug = 'top-30-light-yellow-puff' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #55: TOP-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-29',
  'top-29-yellow-puff',
  'YELLOW PUFF',
  'YELLOW PUFF',
  'TOP-29',
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
    WHERE p.barcode = 'TOP-29' 
       OR (p.slug = 'top-29-yellow-puff' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #56: TOP-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-28',
  'top-28-bluepink',
  'BLUE/PINK',
  'BLUE/PINK',
  'TOP-28',
  80.00,
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
    WHERE p.barcode = 'TOP-28' 
       OR (p.slug = 'top-28-bluepink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #57: TOP-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-27',
  'top-27-violet',
  'VIOLET',
  'VIOLET',
  'TOP-27',
  80.00,
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
    WHERE p.barcode = 'TOP-27' 
       OR (p.slug = 'top-27-violet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #58: TOP-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-26',
  'top-26-redpink',
  'RED/PINK',
  'RED/PINK',
  'TOP-26',
  125.00,
  500.00,
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
    WHERE p.barcode = 'TOP-26' 
       OR (p.slug = 'top-26-redpink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #59: TOP-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-25',
  'top-25-gold',
  'GOLD',
  'GOLD',
  'TOP-25',
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
    WHERE p.barcode = 'TOP-25' 
       OR (p.slug = 'top-25-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #60: TOP-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-24',
  'top-24-gold',
  'GOLD',
  'GOLD',
  'TOP-24',
  125.00,
  500.00,
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
    WHERE p.barcode = 'TOP-24' 
       OR (p.slug = 'top-24-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #61: TOP-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-23',
  'top-23-gold',
  'GOLD',
  'GOLD',
  'TOP-23',
  80.00,
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
    WHERE p.barcode = 'TOP-23' 
       OR (p.slug = 'top-23-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #62: TOP-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-22',
  'top-22-gold',
  'GOLD',
  'GOLD',
  'TOP-22',
  125.00,
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
    WHERE p.barcode = 'TOP-22' 
       OR (p.slug = 'top-22-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #63: TOP-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-21',
  'top-21-gold',
  'GOLD',
  'GOLD',
  'TOP-21',
  50.00,
  250.00,
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
    WHERE p.barcode = 'TOP-21' 
       OR (p.slug = 'top-21-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #64: TOP-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-20',
  'top-20-gold-puff',
  'GOLD PUFF',
  'GOLD PUFF',
  'TOP-20',
  80.00,
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
    WHERE p.barcode = 'TOP-20' 
       OR (p.slug = 'top-20-gold-puff' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #65: TOP-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-19',
  'top-19-black-velvet',
  'BLACK VELVET',
  'BLACK VELVET',
  'TOP-19',
  150.00,
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
    WHERE p.barcode = 'TOP-19' 
       OR (p.slug = 'top-19-black-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #66: TOP-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-18',
  'top-18-black-velvet',
  'BLACK VELVET',
  'BLACK VELVET',
  'TOP-18',
  125.00,
  500.00,
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
    WHERE p.barcode = 'TOP-18' 
       OR (p.slug = 'top-18-black-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #67: TOP-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-17',
  'top-17-blue-puff',
  'BLUE PUFF',
  'BLUE PUFF',
  'TOP-17',
  80.00,
  300.00,
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
    WHERE p.barcode = 'TOP-17' 
       OR (p.slug = 'top-17-blue-puff' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #68: TOP-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-16',
  'top-16-orange-velvet',
  'ORANGE VELVET',
  'ORANGE VELVET',
  'TOP-16',
  125.00,
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
    WHERE p.barcode = 'TOP-16' 
       OR (p.slug = 'top-16-orange-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #69: TOP-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-15',
  'top-15-majenda-velvet',
  'MAJENDA VELVET',
  'MAJENDA VELVET',
  'TOP-15',
  125.00,
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
    WHERE p.barcode = 'TOP-15' 
       OR (p.slug = 'top-15-majenda-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #70: TOP-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-14',
  'top-14-blue-velvet',
  'BLUE VELVET',
  'BLUE VELVET',
  'TOP-14',
  150.00,
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
    WHERE p.barcode = 'TOP-14' 
       OR (p.slug = 'top-14-blue-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #71: TOP-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-13',
  'top-13-blue-puff',
  'BLUE PUFF',
  'BLUE PUFF',
  'TOP-13',
  125.00,
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
    WHERE p.barcode = 'TOP-13' 
       OR (p.slug = 'top-13-blue-puff' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #72: TOP-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-12',
  'top-12-blue-velvet',
  'BLUE VELVET',
  'BLUE VELVET',
  'TOP-12',
  150.00,
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
    WHERE p.barcode = 'TOP-12' 
       OR (p.slug = 'top-12-blue-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #73: TOP-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-11',
  'top-11-blue-velvet',
  'BLUE VELVET',
  'BLUE VELVET',
  'TOP-11',
  125.00,
  500.00,
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
    WHERE p.barcode = 'TOP-11' 
       OR (p.slug = 'top-11-blue-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #74: TOP-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-10',
  'top-10-green-velvet',
  'GREEN VELVET',
  'GREEN VELVET',
  'TOP-10',
  125.00,
  500.00,
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
    WHERE p.barcode = 'TOP-10' 
       OR (p.slug = 'top-10-green-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #75: TOP-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-9',
  'top-9-green-velvet',
  'GREEN VELVET',
  'GREEN VELVET',
  'TOP-9',
  150.00,
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
    WHERE p.barcode = 'TOP-9' 
       OR (p.slug = 'top-9-green-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #76: TOP-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-8',
  'top-8-red-velvet',
  'RED VELVET',
  'RED VELVET',
  'TOP-8',
  150.00,
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
    WHERE p.barcode = 'TOP-8' 
       OR (p.slug = 'top-8-red-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #77: TOP-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-7',
  'top-7-green-velvet',
  'GREEN VELVET',
  'GREEN VELVET',
  'TOP-7',
  80.00,
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
    WHERE p.barcode = 'TOP-7' 
       OR (p.slug = 'top-7-green-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #78: TOP-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-6',
  'top-6-red-velvet',
  'RED VELVET',
  'RED VELVET',
  'TOP-6',
  125.00,
  500.00,
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
    WHERE p.barcode = 'TOP-6' 
       OR (p.slug = 'top-6-red-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #79: TOP-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-5',
  'top-5-red',
  'RED',
  'RED',
  'TOP-5',
  125.00,
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
    WHERE p.barcode = 'TOP-5' 
       OR (p.slug = 'top-5-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #80: TOP-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-4',
  'top-4-red',
  'RED',
  'RED',
  'TOP-4',
  50.00,
  250.00,
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
    WHERE p.barcode = 'TOP-4' 
       OR (p.slug = 'top-4-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #81: TOP-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-3',
  'top-3-red',
  'RED',
  'RED',
  'TOP-3',
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
    WHERE p.barcode = 'TOP-3' 
       OR (p.slug = 'top-3-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #82: TOP-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-2',
  'top-2-red',
  'RED',
  'RED',
  'TOP-2',
  80.00,
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
    WHERE p.barcode = 'TOP-2' 
       OR (p.slug = 'top-2-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #83: TOP-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'top' AND store_id = s.id LIMIT 1),
  b.id,
  'TOP-1',
  'top-1-black',
  'BLACK',
  'BLACK',
  'TOP-1',
  50.00,
  300.00,
  35,
  35,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'TOP-1' 
       OR (p.slug = 'top-1-black' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #84: THIRUV-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'thiruvathira' AND store_id = s.id LIMIT 1),
  b.id,
  'THIRUV-5',
  'thiruv-5-set-mundu-light-kasavu-kids',
  'Set mundu light kasavu kids',
  'Set mundu light kasavu kids',
  'THIRUV-5',
  225.00,
  750.00,
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
    WHERE p.barcode = 'THIRUV-5' 
       OR (p.slug = 'thiruv-5-set-mundu-light-kasavu-kids' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #85: THIRUV-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'thiruvathira' AND store_id = s.id LIMIT 1),
  b.id,
  'THIRUV-4',
  'thiruv-4-set-mundu-dark-kasavu-kids',
  'Set mundu dark kasavu kids',
  'Set mundu dark kasavu kids',
  'THIRUV-4',
  225.00,
  750.00,
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
    WHERE p.barcode = 'THIRUV-4' 
       OR (p.slug = 'thiruv-4-set-mundu-dark-kasavu-kids' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #86: THIRUV-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'thiruvathira' AND store_id = s.id LIMIT 1),
  b.id,
  'THIRUV-3',
  'thiruv-3-set-mundu-gold-kasavu-light',
  'Set mundu gold kasavu light',
  'Set mundu gold kasavu light',
  'THIRUV-3',
  325.00,
  750.00,
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
    WHERE p.barcode = 'THIRUV-3' 
       OR (p.slug = 'thiruv-3-set-mundu-gold-kasavu-light' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #87: THIRUV-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'thiruvathira' AND store_id = s.id LIMIT 1),
  b.id,
  'THIRUV-2',
  'thiruv-2-set-mundu-gold-kasavu-dark',
  'Set mundu gold kasavu dark',
  'Set mundu gold kasavu dark',
  'THIRUV-2',
  325.00,
  750.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'THIRUV-2' 
       OR (p.slug = 'thiruv-2-set-mundu-gold-kasavu-dark' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #88: THIRUV-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'thiruvathira' AND store_id = s.id LIMIT 1),
  b.id,
  'THIRUV-1',
  'thiruv-1-set-mundu-red-kara',
  'Set mundu Red kara',
  'Set mundu Red kara',
  'THIRUV-1',
  370.00,
  750.00,
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
    WHERE p.barcode = 'THIRUV-1' 
       OR (p.slug = 'thiruv-1-set-mundu-red-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #89: SKTP-126
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-126',
  'sktp-126-black-red-gujarathi',
  'Black Red Gujarathi',
  'Black Red Gujarathi',
  'SKTP-126',
  840.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-126' 
       OR (p.slug = 'sktp-126-black-red-gujarathi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #90: SKTP-125
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-125',
  'sktp-125-white-black-border-folk',
  'White black border folk',
  'White black border folk',
  'SKTP-125',
  530.00,
  1500.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-125' 
       OR (p.slug = 'sktp-125-white-black-border-folk' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #91: SKTP-124
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-124',
  'sktp-124-offwhitered-black-border-folk',
  'Offwhite/Red black border folk',
  'Offwhite/Red black border folk',
  'SKTP-124',
  530.00,
  1600.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-124' 
       OR (p.slug = 'sktp-124-offwhitered-black-border-folk' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #92: SKTP-123
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-123',
  'sktp-123-vadamulla-orange-folk',
  'Vadamulla orange folk',
  'Vadamulla orange folk',
  'SKTP-123',
  530.00,
  1500.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-123' 
       OR (p.slug = 'sktp-123-vadamulla-orange-folk' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #93: SKTP-122
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-122',
  'sktp-122-kilipacha-majenta-folk',
  'Kilipacha Majenta folk',
  'Kilipacha Majenta folk',
  'SKTP-122',
  530.00,
  1600.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-122' 
       OR (p.slug = 'sktp-122-kilipacha-majenta-folk' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #94: SKTP-121
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-121',
  'sktp-121-white-mayolpeeli-skirt',
  'White Mayolpeeli skirt',
  'White Mayolpeeli skirt',
  'SKTP-121',
  630.00,
  2100.00,
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
    WHERE p.barcode = 'SKTP-121' 
       OR (p.slug = 'sktp-121-white-mayolpeeli-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #95: SKTP-120
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-120',
  'sktp-120-black-orange-folk',
  'Black orange folk',
  'Black orange folk',
  'SKTP-120',
  530.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-120' 
       OR (p.slug = 'sktp-120-black-orange-folk' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #96: SKTP-119
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-119',
  'sktp-119-black-mirror-skirt',
  'Black mirror skirt',
  'Black mirror skirt',
  'SKTP-119',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-119' 
       OR (p.slug = 'sktp-119-black-mirror-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #97: SKTP-118
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-118',
  'sktp-118-majenta-mirror-work-small',
  'Majenta mirror work small',
  'Majenta mirror work small',
  'SKTP-118',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-118' 
       OR (p.slug = 'sktp-118-majenta-mirror-work-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #98: SKTP-117
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-117',
  'sktp-117-black-cotton-orange-print-border-and-stripes',
  'Black cotton orange print border and stripes',
  'Black cotton orange print border and stripes',
  'SKTP-117',
  470.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-117' 
       OR (p.slug = 'sktp-117-black-cotton-orange-print-border-and-stripes' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #99: SKTP-116
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-116',
  'sktp-116-orange-cotton-bluegreen-piping',
  'Orange cotton blue/green piping',
  'Orange cotton blue/green piping',
  'SKTP-116',
  420.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-116' 
       OR (p.slug = 'sktp-116-orange-cotton-bluegreen-piping' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #100: SKTP-115
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-115',
  'sktp-115-black-cotton-yellow-print-3-layer-border',
  'Black cotton yellow print 3 layer border',
  'Black cotton yellow print 3 layer border',
  'SKTP-115',
  420.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-115' 
       OR (p.slug = 'sktp-115-black-cotton-yellow-print-3-layer-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #101: SKTP-114
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-114',
  'sktp-114-black-mundu-white-red-border-with-shawl',
  'Black mundu white red border with shawl',
  'Black mundu white red border with shawl',
  'SKTP-114',
  400.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-114' 
       OR (p.slug = 'sktp-114-black-mundu-white-red-border-with-shawl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #102: SKTP-113
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-113',
  'sktp-113-white-cotton-redblack-lace-with-shawl',
  'White cotton red/black lace with shawl',
  'White cotton red/black lace with shawl',
  'SKTP-113',
  400.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-113' 
       OR (p.slug = 'sktp-113-white-cotton-redblack-lace-with-shawl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #103: SKTP-112
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-112',
  'sktp-112-majenta-rajasthani-skirt-blue-blouse-shawl-adult',
  'Majenta Rajasthani skirt blue blouse shawl Adult',
  'Majenta Rajasthani skirt blue blouse shawl Adult',
  'SKTP-112',
  800.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-112' 
       OR (p.slug = 'sktp-112-majenta-rajasthani-skirt-blue-blouse-shawl-adult' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #104: SKTP-111
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-111',
  'sktp-111-majenta-rajasthani-skirt-blue-blouse-shawl-new',
  'Majenta Rajasthani skirt blue blouse shawl new',
  'Majenta Rajasthani skirt blue blouse shawl new',
  'SKTP-111',
  630.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-111' 
       OR (p.slug = 'sktp-111-majenta-rajasthani-skirt-blue-blouse-shawl-new' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #105: SKTP-110
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-110',
  'sktp-110-fanta-net-seq-skirt-black-multi-seq-top',
  'Fanta net seq skirt black multi seq top',
  'Fanta net seq skirt black multi seq top',
  'SKTP-110',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-110' 
       OR (p.slug = 'sktp-110-fanta-net-seq-skirt-black-multi-seq-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #106: SKTP-109
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-109',
  'sktp-109-majent-multi-seq-tutu-skirt-top',
  'Majent multi seq tutu skirt top',
  'Majent multi seq tutu skirt top',
  'SKTP-109',
  260.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-109' 
       OR (p.slug = 'sktp-109-majent-multi-seq-tutu-skirt-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #107: SKTP-108
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-108',
  'sktp-108-kavi-skirtblack-border-black-blouse',
  'Kavi skirt/Black border black blouse',
  'Kavi skirt/Black border black blouse',
  'SKTP-108',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-108' 
       OR (p.slug = 'sktp-108-kavi-skirtblack-border-black-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #108: SKTP-107
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-107',
  'sktp-107-red-mundwhite-border-black-or-white-blouse',
  'Red mund/white border black or white blouse',
  'Red mund/white border black or white blouse',
  'SKTP-107',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-107' 
       OR (p.slug = 'sktp-107-red-mundwhite-border-black-or-white-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #109: SKTP-106
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-106',
  'sktp-106-yellow-mix-color-flower-skirt-green-blouse',
  'Yellow mix color flower skirt Green blouse',
  'Yellow mix color flower skirt Green blouse',
  'SKTP-106',
  370.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-106' 
       OR (p.slug = 'sktp-106-yellow-mix-color-flower-skirt-green-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #110: SKTP-105
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-105',
  'sktp-105-red-white-border-skirt-black-blouse',
  'Red white border skirt black blouse',
  'Red white border skirt black blouse',
  'SKTP-105',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-105' 
       OR (p.slug = 'sktp-105-red-white-border-skirt-black-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #111: SKTP-104
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-104',
  'sktp-104-red-skirt-blue-border-red-blouse',
  'Red skirt blue border Red blouse',
  'Red skirt blue border Red blouse',
  'SKTP-104',
  325.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-104' 
       OR (p.slug = 'sktp-104-red-skirt-blue-border-red-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #112: SKTP-103
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-103',
  'sktp-103-white-skirt-blue-border-blue-blouse',
  'White skirt blue border blue blouse',
  'White skirt blue border blue blouse',
  'SKTP-103',
  325.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-103' 
       OR (p.slug = 'sktp-103-white-skirt-blue-border-blue-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #113: SKTP-102
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-102',
  'sktp-102-yellow-skirt-violet-border-violet-blouse',
  'Yellow skirt violet border violet blouse',
  'Yellow skirt violet border violet blouse',
  'SKTP-102',
  325.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-102' 
       OR (p.slug = 'sktp-102-yellow-skirt-violet-border-violet-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #114: SKTP-101
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-101',
  'sktp-101-white-skirtblack-red-border-black-blouse',
  'White skirt/b;lack red border black blouse',
  'White skirt/b;lack red border black blouse',
  'SKTP-101',
  370.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-101' 
       OR (p.slug = 'sktp-101-white-skirtblack-red-border-black-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #115: SKTP-100
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-100',
  'sktp-100-orange-thattu-skirt-orange-blouse',
  'Orange thattu skirt Orange blouse',
  'Orange thattu skirt Orange blouse',
  'SKTP-100',
  325.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-100' 
       OR (p.slug = 'sktp-100-orange-thattu-skirt-orange-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #116: SKTP-99
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-99',
  'sktp-99-redwhite-polka-dot-skirt-red-blouse',
  'Red/White polka dot skirt Red blouse',
  'Red/White polka dot skirt Red blouse',
  'SKTP-99',
  325.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-99' 
       OR (p.slug = 'sktp-99-redwhite-polka-dot-skirt-red-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #117: SKTP-98
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-98',
  'sktp-98-blue-chunkidi-skirtyellow-border-blue-blouse',
  'Blue chunkidi skirtyellow border blue blouse',
  'Blue chunkidi skirtyellow border blue blouse',
  'SKTP-98',
  325.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-98' 
       OR (p.slug = 'sktp-98-blue-chunkidi-skirtyellow-border-blue-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #118: SKTP-97
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-97',
  'sktp-97-bluewhite-flowerwhite-round-blouse',
  'Blue/White flowerwhite round blouse',
  'Blue/White flowerwhite round blouse',
  'SKTP-97',
  420.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-97' 
       OR (p.slug = 'sktp-97-bluewhite-flowerwhite-round-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #119: SKTP-96
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-96',
  'sktp-96-whiteblue-yellow-round-skirt-red-dot-blouse',
  'White/blue yellow round skirt Red dot blouse',
  'White/blue yellow round skirt Red dot blouse',
  'SKTP-96',
  370.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-96' 
       OR (p.slug = 'sktp-96-whiteblue-yellow-round-skirt-red-dot-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #120: SKTP-95
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-95',
  'sktp-95-whiteblue-yellow-round-skirt-blue-dot-blouse',
  'White/Blue yellow round skirt blue dot blouse',
  'White/Blue yellow round skirt blue dot blouse',
  'SKTP-95',
  370.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-95' 
       OR (p.slug = 'sktp-95-whiteblue-yellow-round-skirt-blue-dot-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #121: SKTP-94
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-94',
  'sktp-94-black-yellow-majenta-big-flower-skirt-yellow-blous',
  'Black yellow Majenta big flower skirt yellow blous',
  'Black yellow Majenta big flower skirt yellow blous',
  'SKTP-94',
  370.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-94' 
       OR (p.slug = 'sktp-94-black-yellow-majenta-big-flower-skirt-yellow-blous' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #122: SKTP-93
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-93',
  'sktp-93-red-blue-big-flower-skirt-blue-blouse',
  'Red blue big flower skirt blue blouse',
  'Red blue big flower skirt blue blouse',
  'SKTP-93',
  370.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-93' 
       OR (p.slug = 'sktp-93-red-blue-big-flower-skirt-blue-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #123: SKTP-92
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-92',
  'sktp-92-blue-yellow-mix-big-flower-skirt-blue-blouse',
  'Blue yellow mix big flower skirt blue blouse',
  'Blue yellow mix big flower skirt blue blouse',
  'SKTP-92',
  370.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-92' 
       OR (p.slug = 'sktp-92-blue-yellow-mix-big-flower-skirt-blue-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #124: SKTP-91
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-91',
  'sktp-91-peacock-blue-white-small-flower-skirt-blue-blouse',
  'Peacock blue white small flower skirt blue blouse',
  'Peacock blue white small flower skirt blue blouse',
  'SKTP-91',
  370.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-91' 
       OR (p.slug = 'sktp-91-peacock-blue-white-small-flower-skirt-blue-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #125: SKTP-90
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-90',
  'sktp-90-yellowblue-merroon-dot-blue-blouse',
  'Yellow/Blue Merroon dot blue blouse',
  'Yellow/Blue Merroon dot blue blouse',
  'SKTP-90',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-90' 
       OR (p.slug = 'sktp-90-yellowblue-merroon-dot-blue-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #126: SKTP-89
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-89',
  'sktp-89-merroon-yellow-small-flower-merroon-blouse',
  'Merroon Yellow small flower Merroon blouse',
  'Merroon Yellow small flower Merroon blouse',
  'SKTP-89',
  370.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-89' 
       OR (p.slug = 'sktp-89-merroon-yellow-small-flower-merroon-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #127: SKTP-88
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-88',
  'sktp-88-majentayellow-green-flower-green-blouse',
  'Majenta/yellow green flower Green blouse',
  'Majenta/yellow green flower Green blouse',
  'SKTP-88',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-88' 
       OR (p.slug = 'sktp-88-majentayellow-green-flower-green-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #128: SKTP-87
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-87',
  'sktp-87-majenta-chunkidi-yellow-border-blouse-folk',
  'Majenta chunkidi yellow border blouse folk',
  'Majenta chunkidi yellow border blouse folk',
  'SKTP-87',
  370.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-87' 
       OR (p.slug = 'sktp-87-majenta-chunkidi-yellow-border-blouse-folk' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #129: SKTP-86
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-86',
  'sktp-86-yellow-white-dot-red-dot-green-blouse',
  'Yellow white dot red dot green blouse',
  'Yellow white dot red dot green blouse',
  'SKTP-86',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-86' 
       OR (p.slug = 'sktp-86-yellow-white-dot-red-dot-green-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #130: SKTP-85
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-85',
  'sktp-85-redwhite-dot-gree-yellow-border-red-blouse',
  'Red/White  Dot Gree yellow border Red blouse',
  'Red/White  Dot Gree yellow border Red blouse',
  'SKTP-85',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-85' 
       OR (p.slug = 'sktp-85-redwhite-dot-gree-yellow-border-red-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #131: SKTP-84
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-84',
  'sktp-84-green-white-dot-green-blouse-folk-shawl',
  'Green white dot green blouse folk & Shawl',
  'Green white dot green blouse folk & Shawl',
  'SKTP-84',
  325.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-84' 
       OR (p.slug = 'sktp-84-green-white-dot-green-blouse-folk-shawl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #132: SKTP-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-13',
  'sktp-13-black-red-dot-kids',
  'Black red dot kids',
  'Black red dot kids',
  'SKTP-13',
  290.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-13' 
       OR (p.slug = 'sktp-13-black-red-dot-kids' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #133: SKTP-83
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-83',
  'sktp-83-black-silver-peach-sequence',
  'Black silver peach sequence',
  'Black silver peach sequence',
  'SKTP-83',
  290.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-83' 
       OR (p.slug = 'sktp-83-black-silver-peach-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #134: SKTP-82
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-82',
  'sktp-82-blue-rajasthani',
  'Blue Rajasthani',
  'Blue Rajasthani',
  'SKTP-82',
  630.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-82' 
       OR (p.slug = 'sktp-82-blue-rajasthani' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #135: SKTP-81
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-81',
  'sktp-81-merrron-rajasthani',
  'Merrron Rajasthani',
  'Merrron Rajasthani',
  'SKTP-81',
  630.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-81' 
       OR (p.slug = 'sktp-81-merrron-rajasthani' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #136: SKTP-80
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-80',
  'sktp-80-red-gujarati-small',
  'Red Gujarati small',
  'Red Gujarati small',
  'SKTP-80',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-80' 
       OR (p.slug = 'sktp-80-red-gujarati-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #137: SKTP-79
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-79',
  'sktp-79-red-flaired-rajasthani',
  'Red flaired Rajasthani',
  'Red flaired Rajasthani',
  'SKTP-79',
  630.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-79' 
       OR (p.slug = 'sktp-79-red-flaired-rajasthani' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #138: SKTP-78
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-78',
  'sktp-78-white-skirt-rajasthani-set',
  'White skirt Rajasthani set',
  'White skirt Rajasthani set',
  'SKTP-78',
  630.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-78' 
       OR (p.slug = 'sktp-78-white-skirt-rajasthani-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #139: SKTP-77
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-77',
  'sktp-77-white-skirt-rajasthani-set',
  'White skirt Rajasthani set',
  'White skirt Rajasthani set',
  'SKTP-77',
  630.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-77' 
       OR (p.slug = 'sktp-77-white-skirt-rajasthani-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #140: SKTP-76
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-76',
  'sktp-76-majenta-skirt-yellow-blouse',
  'Majenta skirt yellow blouse',
  'Majenta skirt yellow blouse',
  'SKTP-76',
  630.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-76' 
       OR (p.slug = 'sktp-76-majenta-skirt-yellow-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #141: SKTP-75
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-75',
  'sktp-75-black-red-rajasthani-blaack-blouse',
  'Black red Rajasthani blaack blouse',
  'Black red Rajasthani blaack blouse',
  'SKTP-75',
  630.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-75' 
       OR (p.slug = 'sktp-75-black-red-rajasthani-blaack-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #142: SKTP-74
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-74',
  'sktp-74-gold-big-seq-top-skirt',
  'Gold big seq top skirt',
  'Gold big seq top skirt',
  'SKTP-74',
  290.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-74' 
       OR (p.slug = 'sktp-74-gold-big-seq-top-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #143: SKTP-73
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-73',
  'sktp-73-pink-shirt-bluejean-cloth-skirt-bow-tie',
  'Pink shirt bluejean cloth skirt bow tie',
  'Pink shirt bluejean cloth skirt bow tie',
  'SKTP-73',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-73' 
       OR (p.slug = 'sktp-73-pink-shirt-bluejean-cloth-skirt-bow-tie' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #144: SKTP-72
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-72',
  'sktp-72-white-net-sjirtgold-big-seq-topgloves',
  'White net sjirtGold big seq top,gloves',
  'White net sjirtGold big seq top,gloves',
  'SKTP-72',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-72' 
       OR (p.slug = 'sktp-72-white-net-sjirtgold-big-seq-topgloves' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #145: SKTP-71
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-71',
  'sktp-71-red-white-dot-skirt-white-blouse',
  'Red white dot skirt white blouse',
  'Red white dot skirt white blouse',
  'SKTP-71',
  125.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-71' 
       OR (p.slug = 'sktp-71-red-white-dot-skirt-white-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #146: SKTP-70
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-70',
  'sktp-70-blue-net-skirt-white-seq-top-kg',
  'Blue net skirt white seq top (KG)',
  'Blue net skirt white seq top (KG)',
  'SKTP-70',
  250.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-70' 
       OR (p.slug = 'sktp-70-blue-net-skirt-white-seq-top-kg' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #147: SKTP-69
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-69',
  'sktp-69-blue-rajasthani',
  'Blue Rajasthani',
  'Blue Rajasthani',
  'SKTP-69',
  370.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-69' 
       OR (p.slug = 'sktp-69-blue-rajasthani' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #148: SKTP-68
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-68',
  'sktp-68-yellow-rajasthani',
  'Yellow Rajasthani',
  'Yellow Rajasthani',
  'SKTP-68',
  420.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SKTP-68' 
       OR (p.slug = 'sktp-68-yellow-rajasthani' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #149: SKTP-67
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-67',
  'sktp-67-green-majenta-black-majenta-border',
  'Green majenta/ Black Majenta border',
  'Green majenta/ Black Majenta border',
  'SKTP-67',
  250.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-67' 
       OR (p.slug = 'sktp-67-green-majenta-black-majenta-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #150: SKTP-66
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-66',
  'sktp-66-peachblack-design',
  'Peach/Black design',
  'Peach/Black design',
  'SKTP-66',
  225.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-66' 
       OR (p.slug = 'sktp-66-peachblack-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #151: SKTP-65
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-65',
  'sktp-65-black-satin-red-sequence-top',
  'Black satin/ Red sequence top',
  'Black satin/ Red sequence top',
  'SKTP-65',
  225.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-65' 
       OR (p.slug = 'sktp-65-black-satin-red-sequence-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #152: SKTP-64
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-64',
  'sktp-64-orangegreen-tikky',
  'Orange/Green tikky',
  'Orange/Green tikky',
  'SKTP-64',
  180.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-64' 
       OR (p.slug = 'sktp-64-orangegreen-tikky' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #153: SKTP-63
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-63',
  'sktp-63-black-cotton-greengreen-top',
  'Black cotton green/Green top',
  'Black cotton green/Green top',
  'SKTP-63',
  260.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-63' 
       OR (p.slug = 'sktp-63-black-cotton-greengreen-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #154: SKTP-62
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-62',
  'sktp-62-orange-netblue-border',
  'Orange net/Blue border',
  'Orange net/Blue border',
  'SKTP-62',
  225.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-62' 
       OR (p.slug = 'sktp-62-orange-netblue-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #155: SKTP-61
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-61',
  'sktp-61-red-netgreen',
  'Red net/Green',
  'Red net/Green',
  'SKTP-61',
  180.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-61' 
       OR (p.slug = 'sktp-61-red-netgreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #156: SKTP-60
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-60',
  'sktp-60-blackwhite-small-dot',
  'Black/white small dot',
  'Black/white small dot',
  'SKTP-60',
  260.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-60' 
       OR (p.slug = 'sktp-60-blackwhite-small-dot' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #157: SKTP-59
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-59',
  'sktp-59-red-netgold-sequence',
  'Red net/Gold sequence',
  'Red net/Gold sequence',
  'SKTP-59',
  180.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-59' 
       OR (p.slug = 'sktp-59-red-netgold-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #158: SKTP-58A
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-58A',
  'sktp-58a-green-yellow-net-sequence',
  'Green yellow net sequence',
  'Green yellow net sequence',
  'SKTP-58A',
  180.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-58A' 
       OR (p.slug = 'sktp-58a-green-yellow-net-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #159: SKTP-58
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-58',
  'sktp-58-white-gold-seq-kids',
  'White gold seq kids',
  'White gold seq kids',
  'SKTP-58',
  180.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-58' 
       OR (p.slug = 'sktp-58-white-gold-seq-kids' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #160: SKTP-57
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-57',
  'sktp-57-pink-sequencesilver-sequence',
  'Pink sequence/Silver Sequence',
  'Pink sequence/Silver Sequence',
  'SKTP-57',
  225.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-57' 
       OR (p.slug = 'sktp-57-pink-sequencesilver-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #161: SKTP-56
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-56',
  'sktp-56-redwhite-cotton-skirt',
  'Red/White cotton skirt',
  'Red/White cotton skirt',
  'SKTP-56',
  250.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-56' 
       OR (p.slug = 'sktp-56-redwhite-cotton-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #162: SKTP-55
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-55',
  'sktp-55-blue-netblue-velvet',
  'Blue net/Blue velvet',
  'Blue net/Blue velvet',
  'SKTP-55',
  225.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-55' 
       OR (p.slug = 'sktp-55-blue-netblue-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #163: SKTP-54
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-54',
  'sktp-54-yellow-green-bordergreen',
  'Yellow green border/Green',
  'Yellow green border/Green',
  'SKTP-54',
  225.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-54' 
       OR (p.slug = 'sktp-54-yellow-green-bordergreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #164: SKTP-53
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-53',
  'sktp-53-kilipacha-red-border',
  'Kilipacha red border',
  'Kilipacha red border',
  'SKTP-53',
  180.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-53' 
       OR (p.slug = 'sktp-53-kilipacha-red-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #165: SKTP-52
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-52',
  'sktp-52-whiteblack-tikky',
  'White/Black tikky',
  'White/Black tikky',
  'SKTP-52',
  180.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-52' 
       OR (p.slug = 'sktp-52-whiteblack-tikky' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #166: SKTP-51
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-51',
  'sktp-51-yellowblue-diamond',
  'Yellow/Blue diamond',
  'Yellow/Blue diamond',
  'SKTP-51',
  180.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-51' 
       OR (p.slug = 'sktp-51-yellowblue-diamond' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #167: SKTP-50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-50',
  'sktp-50-kilipacha-net-darkgreenviolet',
  'Kilipacha net dark/Greenviolet',
  'Kilipacha net dark/Greenviolet',
  'SKTP-50',
  250.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-50' 
       OR (p.slug = 'sktp-50-kilipacha-net-darkgreenviolet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #168: SKTP-49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-49',
  'sktp-49-sea-green-silver-sequence',
  'Sea green silver sequence',
  'Sea green silver sequence',
  'SKTP-49',
  180.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-49' 
       OR (p.slug = 'sktp-49-sea-green-silver-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #169: SKTP-48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-48',
  'sktp-48-green-pink-tikky',
  'Green pink tikky',
  'Green pink tikky',
  'SKTP-48',
  180.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-48' 
       OR (p.slug = 'sktp-48-green-pink-tikky' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #170: SKTP-47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-47',
  'sktp-47-red-and-gold-big-sequence',
  'Red and gold big sequence',
  'Red and gold big sequence',
  'SKTP-47',
  260.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-47' 
       OR (p.slug = 'sktp-47-red-and-gold-big-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #171: SKTP-46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-46',
  'sktp-46-white-sequenceblue-border',
  'White sequence/Blue border',
  'White sequence/Blue border',
  'SKTP-46',
  470.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-46' 
       OR (p.slug = 'sktp-46-white-sequenceblue-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #172: SKTP-45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-45',
  'sktp-45-yellow-majenta-diamond',
  'Yellow /Majenta diamond',
  'Yellow /Majenta diamond',
  'SKTP-45',
  125.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-45' 
       OR (p.slug = 'sktp-45-yellow-majenta-diamond' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #173: SKTP-44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-44',
  'sktp-44-greenmajenta-satin',
  'Green/Majenta satin',
  'Green/Majenta satin',
  'SKTP-44',
  150.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-44' 
       OR (p.slug = 'sktp-44-greenmajenta-satin' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #174: SKTP-43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-43',
  'sktp-43-green-netblue-border',
  'Green Net/Blue border',
  'Green Net/Blue border',
  'SKTP-43',
  175.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-43' 
       OR (p.slug = 'sktp-43-green-netblue-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #175: SKTP-42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-42',
  'sktp-42-majentasea-blue',
  'Majenta/Sea blue',
  'Majenta/Sea blue',
  'SKTP-42',
  175.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-42' 
       OR (p.slug = 'sktp-42-majentasea-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #176: SKTP-41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-41',
  'sktp-41-orangeblue-net-slit',
  'Orange/Blue net slit',
  'Orange/Blue net slit',
  'SKTP-41',
  175.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-41' 
       OR (p.slug = 'sktp-41-orangeblue-net-slit' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #177: SKTP-40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-40',
  'sktp-40-kilipacha-dotgold-sequence',
  'Kilipacha dot/Gold sequence',
  'Kilipacha dot/Gold sequence',
  'SKTP-40',
  175.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-40' 
       OR (p.slug = 'sktp-40-kilipacha-dotgold-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #178: SKTP-39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-39',
  'sktp-39-sky-blue-readymadesilver-border',
  'Sky blue readymade/Silver border',
  'Sky blue readymade/Silver border',
  'SKTP-39',
  250.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-39' 
       OR (p.slug = 'sktp-39-sky-blue-readymadesilver-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #179: SKTP-38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-38',
  'sktp-38-sky-blue-dot-netred',
  'Sky blue dot net/Red',
  'Sky blue dot net/Red',
  'SKTP-38',
  225.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-38' 
       OR (p.slug = 'sktp-38-sky-blue-dot-netred' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #180: SKTP-37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-37',
  'sktp-37-offwhitemerroon',
  'Offwhite/Merroon',
  'Offwhite/Merroon',
  'SKTP-37',
  290.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-37' 
       OR (p.slug = 'sktp-37-offwhitemerroon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #181: SKTP-36A
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-36A',
  'sktp-36a-whitered-kid',
  'WHITE/RED KID',
  'WHITE/RED KID',
  'SKTP-36A',
  125.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-36A' 
       OR (p.slug = 'sktp-36a-whitered-kid' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #182: SKTP-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-36',
  'sktp-36-whitered-kid',
  'WHITE/RED KID',
  'WHITE/RED KID',
  'SKTP-36',
  125.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-36' 
       OR (p.slug = 'sktp-36-whitered-kid' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #183: SKTP-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-35',
  'sktp-35-whitepink',
  'WHITE/PINK',
  'WHITE/PINK',
  'SKTP-35',
  250.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-35' 
       OR (p.slug = 'sktp-35-whitepink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #184: SKTP-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-34',
  'sktp-34-whiteblue',
  'WHITE/BLUE',
  'WHITE/BLUE',
  'SKTP-34',
  250.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-34' 
       OR (p.slug = 'sktp-34-whiteblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #185: SKTP-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-33',
  'sktp-33-blue-velvet-full-design-malappuram',
  'Blue velvet full design malappuram',
  'Blue velvet full design malappuram',
  'SKTP-33',
  450.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-33' 
       OR (p.slug = 'sktp-33-blue-velvet-full-design-malappuram' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #186: SKTP-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-32',
  'sktp-32-redgold',
  'RED/GOLD',
  'RED/GOLD',
  'SKTP-32',
  450.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-32' 
       OR (p.slug = 'sktp-32-redgold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #187: SKTP-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-31',
  'sktp-31-redsilver',
  'RED/SILVER',
  'RED/SILVER',
  'SKTP-31',
  450.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-31' 
       OR (p.slug = 'sktp-31-redsilver' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #188: SKTP-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-30',
  'sktp-30-blackred',
  'BLACK/RED',
  'BLACK/RED',
  'SKTP-30',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-30' 
       OR (p.slug = 'sktp-30-blackred' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #189: SKTP-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-29',
  'sktp-29-whitesilver',
  'WHITE/SILVER',
  'WHITE/SILVER',
  'SKTP-29',
  250.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-29' 
       OR (p.slug = 'sktp-29-whitesilver' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #190: SKTP-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-28',
  'sktp-28-orange-black',
  'Orange / Black',
  'Orange / Black',
  'SKTP-28',
  260.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-28' 
       OR (p.slug = 'sktp-28-orange-black' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #191: SKTP-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-27',
  'sktp-27-yellowwhite',
  'YELLOW/WHITE',
  'YELLOW/WHITE',
  'SKTP-27',
  260.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-27' 
       OR (p.slug = 'sktp-27-yellowwhite' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #192: SKTP-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-26',
  'sktp-26-greenblue',
  'GREEN/BLUE',
  'GREEN/BLUE',
  'SKTP-26',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-26' 
       OR (p.slug = 'sktp-26-greenblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #193: SKTP-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-25',
  'sktp-25-rosegreen',
  'ROSE/GREEN',
  'ROSE/GREEN',
  'SKTP-25',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-25' 
       OR (p.slug = 'sktp-25-rosegreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #194: SKTP-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-24',
  'sktp-24-rosegold',
  'ROSE/GOLD',
  'ROSE/GOLD',
  'SKTP-24',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-24' 
       OR (p.slug = 'sktp-24-rosegold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #195: SKTP-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-23',
  'sktp-23-greenmajenta',
  'GREEN/MAJENTA',
  'GREEN/MAJENTA',
  'SKTP-23',
  400.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-23' 
       OR (p.slug = 'sktp-23-greenmajenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #196: SKTP-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-22',
  'sktp-22-whiteblue',
  'WHITE/BLUE',
  'WHITE/BLUE',
  'SKTP-22',
  225.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-22' 
       OR (p.slug = 'sktp-22-whiteblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #197: SKTP-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-21',
  'sktp-21-whiteblue',
  'WHITE/BLUE',
  'WHITE/BLUE',
  'SKTP-21',
  225.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-21' 
       OR (p.slug = 'sktp-21-whiteblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #198: SKTP-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-20',
  'sktp-20-pink-dot-netgreen',
  'Pink dot netgreen',
  'Pink dot netgreen',
  'SKTP-20',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-20' 
       OR (p.slug = 'sktp-20-pink-dot-netgreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #199: SKTP-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-19',
  'sktp-19-redblack',
  'RED/BLACK',
  'RED/BLACK',
  'SKTP-19',
  250.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-19' 
       OR (p.slug = 'sktp-19-redblack' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #200: SKTP-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-18',
  'sktp-18-yellowblue',
  'YELLOW/BLUE',
  'YELLOW/BLUE',
  'SKTP-18',
  470.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-18' 
       OR (p.slug = 'sktp-18-yellowblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #201: SKTP-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-17',
  'sktp-17-bluegold',
  'BLUE/GOLD',
  'BLUE/GOLD',
  'SKTP-17',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-17' 
       OR (p.slug = 'sktp-17-bluegold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #202: SKTP-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-16',
  'sktp-16-orangeblue',
  'ORANGE/BLUE',
  'ORANGE/BLUE',
  'SKTP-16',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-16' 
       OR (p.slug = 'sktp-16-orangeblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #203: SKTP-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-15',
  'sktp-15-orangegreen',
  'ORANGE/GREEN',
  'ORANGE/GREEN',
  'SKTP-15',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-15' 
       OR (p.slug = 'sktp-15-orangegreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #204: SKTP-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-14',
  'sktp-14-whiteblue',
  'WHITE/BLUE',
  'WHITE/BLUE',
  'SKTP-14',
  370.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-14' 
       OR (p.slug = 'sktp-14-whiteblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #205: SKTP-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-12',
  'sktp-12-black-rajastani-small',
  'BLACK RAJASTANI SMALL',
  'BLACK RAJASTANI SMALL',
  'SKTP-12',
  225.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-12' 
       OR (p.slug = 'sktp-12-black-rajastani-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #206: SKTP-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-11',
  'sktp-11-bluepink',
  'BLUE/PINK',
  'BLUE/PINK',
  'SKTP-11',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-11' 
       OR (p.slug = 'sktp-11-bluepink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #207: SKTP-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-10',
  'sktp-10-blue-net-design-majenta-big-seq-border',
  'BLUE net design Majenta big seq border',
  'BLUE net design Majenta big seq border',
  'SKTP-10',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-10' 
       OR (p.slug = 'sktp-10-blue-net-design-majenta-big-seq-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #208: SKTP-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-9',
  'sktp-9-orange-velvet-black-border',
  'Orange velvet black border',
  'Orange velvet black border',
  'SKTP-9',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-9' 
       OR (p.slug = 'sktp-9-orange-velvet-black-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #209: SKTP-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-8',
  'sktp-8-black-dot-white-cotton-skirt',
  'Black dot white cotton skirt',
  'Black dot white cotton skirt',
  'SKTP-8',
  260.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-8' 
       OR (p.slug = 'sktp-8-black-dot-white-cotton-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #210: SKTP-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-7',
  'sktp-7-black-red-flower-cotton-skirt',
  'Black red flower cotton skirt',
  'Black red flower cotton skirt',
  'SKTP-7',
  260.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-7' 
       OR (p.slug = 'sktp-7-black-red-flower-cotton-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #211: SKTP-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-6',
  'sktp-6-chembaka-cotton-yellow-skirt',
  'Chembaka cotton yellow skirt',
  'Chembaka cotton yellow skirt',
  'SKTP-6',
  370.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-6' 
       OR (p.slug = 'sktp-6-chembaka-cotton-yellow-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #212: SKTP-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-5',
  'sktp-5-black-cotton-with-green-border',
  'Black cotton with green border',
  'Black cotton with green border',
  'SKTP-5',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-5' 
       OR (p.slug = 'sktp-5-black-cotton-with-green-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #213: SKTP-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-4',
  'sktp-4-purple-velvet-full-sequence',
  'Purple velvet full sequence',
  'Purple velvet full sequence',
  'SKTP-4',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-4' 
       OR (p.slug = 'sktp-4-purple-velvet-full-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #214: SKTP-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-3',
  'sktp-3-yellow-full-work-yellow-seq-border',
  'YELLOW full work Yellow seq border',
  'YELLOW full work Yellow seq border',
  'SKTP-3',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-3' 
       OR (p.slug = 'sktp-3-yellow-full-work-yellow-seq-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #215: SKTP-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-2',
  'sktp-2-pink-net-full-work',
  'PINK net full work',
  'PINK net full work',
  'SKTP-2',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-2' 
       OR (p.slug = 'sktp-2-pink-net-full-work' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #216: SKTP-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt-top' AND store_id = s.id LIMIT 1),
  b.id,
  'SKTP-1',
  'sktp-1-blue-velvet-full-design',
  'Blue velvet full design',
  'Blue velvet full design',
  'SKTP-1',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SKTP-1' 
       OR (p.slug = 'sktp-1-blue-velvet-full-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #217: SKIRT-90
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-90',
  'skirt-90-slit-yellow-red',
  'Slit Yellow red',
  'Slit Yellow red',
  'SKIRT-90',
  180.00,
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
    WHERE p.barcode = 'SKIRT-90' 
       OR (p.slug = 'skirt-90-slit-yellow-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #218: SKIRT-89
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-89',
  'skirt-89-slit-skirt-blue-green',
  'Slit skirt blue green',
  'Slit skirt blue green',
  'SKIRT-89',
  180.00,
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
    WHERE p.barcode = 'SKIRT-89' 
       OR (p.slug = 'skirt-89-slit-skirt-blue-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #219: SKIRT-88
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-88',
  'skirt-88-white-net-with-silver-seq',
  'White net with silver seq',
  'White net with silver seq',
  'SKIRT-88',
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
    WHERE p.barcode = 'SKIRT-88' 
       OR (p.slug = 'skirt-88-white-net-with-silver-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #220: SKIRT-87
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-87',
  'skirt-87-white-bh-skirt',
  'White BH skirt',
  'White BH skirt',
  'SKIRT-87',
  325.00,
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
    WHERE p.barcode = 'SKIRT-87' 
       OR (p.slug = 'skirt-87-white-bh-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #221: SKIRT-86
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-86',
  'skirt-86-black-silver-thread-and-sequence',
  'Black silver thread and sequence',
  'Black silver thread and sequence',
  'SKIRT-86',
  325.00,
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
    WHERE p.barcode = 'SKIRT-86' 
       OR (p.slug = 'skirt-86-black-silver-thread-and-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #222: SKIRT-85
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-85',
  'skirt-85-black-cotton-orange-flower-skirt',
  'Black cotton orange flower skirt',
  'Black cotton orange flower skirt',
  'SKIRT-85',
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
    WHERE p.barcode = 'SKIRT-85' 
       OR (p.slug = 'skirt-85-black-cotton-orange-flower-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #223: SKIRT-84
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-84',
  'skirt-84-white-skirt-tube-workgold-border',
  'White skirt (tube work),Gold border',
  'White skirt (tube work),Gold border',
  'SKIRT-84',
  370.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-84' 
       OR (p.slug = 'skirt-84-white-skirt-tube-workgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #224: SKIRT-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-10',
  'skirt-10-white-skirt-tube-work-gold-border',
  'White skirt tube work gold border',
  'White skirt tube work gold border',
  'SKIRT-10',
  370.00,
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
    WHERE p.barcode = 'SKIRT-10' 
       OR (p.slug = 'skirt-10-white-skirt-tube-work-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #225: SKIRT-83
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-83',
  'skirt-83-sky-blue-dot-net-majenta-velvet-border',
  'Sky blue dot net majenta velvet border',
  'Sky blue dot net majenta velvet border',
  'SKIRT-83',
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
    WHERE p.barcode = 'SKIRT-83' 
       OR (p.slug = 'skirt-83-sky-blue-dot-net-majenta-velvet-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #226: SKIRT-82
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-82',
  'skirt-82-red-net-gold-seq-border',
  'Red net gold seq border',
  'Red net gold seq border',
  'SKIRT-82',
  225.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-82' 
       OR (p.slug = 'skirt-82-red-net-gold-seq-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #227: SKIRT-81
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-81',
  'skirt-81-lavender-light-violet-tutu-skirt',
  'Lavender light violet Tutu Skirt',
  'Lavender light violet Tutu Skirt',
  'SKIRT-81',
  180.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-81' 
       OR (p.slug = 'skirt-81-lavender-light-violet-tutu-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #228: SKIRT-80
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-80',
  'skirt-80-pink-polka-dot-tutu-skirt',
  'Pink Polka dot tutu skirt',
  'Pink Polka dot tutu skirt',
  'SKIRT-80',
  180.00,
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
    WHERE p.barcode = 'SKIRT-80' 
       OR (p.slug = 'skirt-80-pink-polka-dot-tutu-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #229: SKIRT-79
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-79',
  'skirt-79-yellow-net-sunflower-skirt-small',
  'yellow net Sunflower  skirt small',
  'yellow net Sunflower  skirt small',
  'SKIRT-79',
  180.00,
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
    WHERE p.barcode = 'SKIRT-79' 
       OR (p.slug = 'skirt-79-yellow-net-sunflower-skirt-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #230: SKIRT-78
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-78',
  'skirt-78-royal-blue-net-gold-dot-skirt-with-gold-border',
  'Royal blue net gold dot skirt with Gold border',
  'Royal blue net gold dot skirt with Gold border',
  'SKIRT-78',
  250.00,
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
    WHERE p.barcode = 'SKIRT-78' 
       OR (p.slug = 'skirt-78-royal-blue-net-gold-dot-skirt-with-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #231: SKIRT-77
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-77',
  'skirt-77-orange-tu-tu-skirt',
  'Orange Tu Tu skirt',
  'Orange Tu Tu skirt',
  'SKIRT-77',
  180.00,
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
    WHERE p.barcode = 'SKIRT-77' 
       OR (p.slug = 'skirt-77-orange-tu-tu-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #232: SKIRT-76
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-76',
  'skirt-76-orange-net-skirt-with-gold-border',
  'Orange net skirt with gold border',
  'Orange net skirt with gold border',
  'SKIRT-76',
  260.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-76' 
       OR (p.slug = 'skirt-76-orange-net-skirt-with-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #233: SKIRT-75
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-75',
  'skirt-75-neriyathu-long-with-gold',
  'Neriyathu long with Gold',
  'Neriyathu long with Gold',
  'SKIRT-75',
  175.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-75' 
       OR (p.slug = 'skirt-75-neriyathu-long-with-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #234: SKIRT-74
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-74',
  'skirt-74-gold-shimmer-with-gold-sequence-border',
  'Gold shimmer with gold sequence border',
  'Gold shimmer with gold sequence border',
  'SKIRT-74',
  175.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-74' 
       OR (p.slug = 'skirt-74-gold-shimmer-with-gold-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #235: SKIRT-73
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-73',
  'skirt-73-gold-shimmer-dotred-green-border',
  'Gold shimmer dot/Red green border',
  'Gold shimmer dot/Red green border',
  'SKIRT-73',
  125.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-73' 
       OR (p.slug = 'skirt-73-gold-shimmer-dotred-green-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #236: SKIRT-72
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-72',
  'skirt-72-pink-white',
  'Pink/ White',
  'Pink/ White',
  'SKIRT-72',
  150.00,
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
    WHERE p.barcode = 'SKIRT-72' 
       OR (p.slug = 'skirt-72-pink-white' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #237: SKIRT-71
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-71',
  'skirt-71-green-white',
  'Green / White',
  'Green / White',
  'SKIRT-71',
  150.00,
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
    WHERE p.barcode = 'SKIRT-71' 
       OR (p.slug = 'skirt-71-green-white' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #238: SKIRT-70
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-70',
  'skirt-70-bluewhite',
  'blue/White',
  'blue/White',
  'SKIRT-70',
  150.00,
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
    WHERE p.barcode = 'SKIRT-70' 
       OR (p.slug = 'skirt-70-bluewhite' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #239: SKIRT-69
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-69',
  'skirt-69-multi-colour',
  'Multi colour',
  'Multi colour',
  'SKIRT-69',
  175.00,
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
    WHERE p.barcode = 'SKIRT-69' 
       OR (p.slug = 'skirt-69-multi-colour' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #240: SKIRT-68
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-68',
  'skirt-68-purple-gold-dot',
  'Purple Gold dot',
  'Purple Gold dot',
  'SKIRT-68',
  150.00,
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
    WHERE p.barcode = 'SKIRT-68' 
       OR (p.slug = 'skirt-68-purple-gold-dot' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #241: SKIRT-67C
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-67C',
  'skirt-67c-majenta-flower-skirt',
  'Majenta flower skirt',
  'Majenta flower skirt',
  'SKIRT-67C',
  175.00,
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
    WHERE p.barcode = 'SKIRT-67C' 
       OR (p.slug = 'skirt-67c-majenta-flower-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #242: SKIRT-67B
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-67B',
  'skirt-67b-majenta-embroidery-skirt',
  'Majenta embroidery skirt',
  'Majenta embroidery skirt',
  'SKIRT-67B',
  175.00,
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
    WHERE p.barcode = 'SKIRT-67B' 
       OR (p.slug = 'skirt-67b-majenta-embroidery-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #243: SKIRT-67A
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-67A',
  'skirt-67a-purple-embroidery-skirt',
  'Purple embroidery skirt',
  'Purple embroidery skirt',
  'SKIRT-67A',
  175.00,
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
    WHERE p.barcode = 'SKIRT-67A' 
       OR (p.slug = 'skirt-67a-purple-embroidery-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #244: SKIRT-67
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-67',
  'skirt-67-green-embroidery-skirt',
  'Green embroidery skirt',
  'Green embroidery skirt',
  'SKIRT-67',
  175.00,
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
    WHERE p.barcode = 'SKIRT-67' 
       OR (p.slug = 'skirt-67-green-embroidery-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #245: SKIRT-66
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-66',
  'skirt-66-orange-netbluefreen-sequence-border',
  'Orange net/Bluefreen sequence border',
  'Orange net/Bluefreen sequence border',
  'SKIRT-66',
  175.00,
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
    WHERE p.barcode = 'SKIRT-66' 
       OR (p.slug = 'skirt-66-orange-netbluefreen-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #246: SKIRT-65
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-65',
  'skirt-65-sky-blue-satingold-satin-border',
  'Sky blue satin/Gold satin border',
  'Sky blue satin/Gold satin border',
  'SKIRT-65',
  175.00,
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
    WHERE p.barcode = 'SKIRT-65' 
       OR (p.slug = 'skirt-65-sky-blue-satingold-satin-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #247: SKIRT-64
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-64',
  'skirt-64-white-dot-net-red-border',
  'White dot net/ Red border',
  'White dot net/ Red border',
  'SKIRT-64',
  150.00,
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
    WHERE p.barcode = 'SKIRT-64' 
       OR (p.slug = 'skirt-64-white-dot-net-red-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #248: SKIRT-63
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-63',
  'skirt-63-green-net-blue-gold-sequence-border',
  'Green net/ Blue gold sequence border',
  'Green net/ Blue gold sequence border',
  'SKIRT-63',
  175.00,
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
    WHERE p.barcode = 'SKIRT-63' 
       OR (p.slug = 'skirt-63-green-net-blue-gold-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #249: SKIRT-62
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-62',
  'skirt-62-red-dot-netblue-gold-border',
  'Red dot net/Blue gold border',
  'Red dot net/Blue gold border',
  'SKIRT-62',
  180.00,
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
    WHERE p.barcode = 'SKIRT-62' 
       OR (p.slug = 'skirt-62-red-dot-netblue-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #250: SKIRT-61
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-61',
  'skirt-61-blue-sequence-mayilpeeli-skirt',
  'Blue sequence/ Mayilpeeli skirt',
  'Blue sequence/ Mayilpeeli skirt',
  'SKIRT-61',
  250.00,
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
    WHERE p.barcode = 'SKIRT-61' 
       OR (p.slug = 'skirt-61-blue-sequence-mayilpeeli-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #251: SKIRT-60
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-60',
  'skirt-60-white-flower-net-gold-sequence-border',
  'White flower net gold sequence border',
  'White flower net gold sequence border',
  'SKIRT-60',
  150.00,
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
    WHERE p.barcode = 'SKIRT-60' 
       OR (p.slug = 'skirt-60-white-flower-net-gold-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #252: SKIRT-59
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-59',
  'skirt-59-red-netblue-small',
  'Red net/Blue small',
  'Red net/Blue small',
  'SKIRT-59',
  175.00,
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
    WHERE p.barcode = 'SKIRT-59' 
       OR (p.slug = 'skirt-59-red-netblue-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #253: SKIRT-58
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-58',
  'skirt-58-green-blue-slit',
  'Green blue slit',
  'Green blue slit',
  'SKIRT-58',
  125.00,
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
    WHERE p.barcode = 'SKIRT-58' 
       OR (p.slug = 'skirt-58-green-blue-slit' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #254: SKIRT-57
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-57',
  'skirt-57-multi-colour-slt-skirt',
  'Multi colour slt skirt',
  'Multi colour slt skirt',
  'SKIRT-57',
  150.00,
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
    WHERE p.barcode = 'SKIRT-57' 
       OR (p.slug = 'skirt-57-multi-colour-slt-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #255: SKIRT-56
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-56',
  'skirt-56-blue-netmajenta-gold-border',
  'Blue net/Majenta gold border',
  'Blue net/Majenta gold border',
  'SKIRT-56',
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
    WHERE p.barcode = 'SKIRT-56' 
       OR (p.slug = 'skirt-56-blue-netmajenta-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #256: SKIRT-55
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-55',
  'skirt-55-red-net-self-designblue-bprder',
  'Red net self design/Blue bprder',
  'Red net self design/Blue bprder',
  'SKIRT-55',
  125.00,
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
    WHERE p.barcode = 'SKIRT-55' 
       OR (p.slug = 'skirt-55-red-net-self-designblue-bprder' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #257: SKIRT-54
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-54',
  'skirt-54-majenta-net-green-small',
  'Majenta net/ Green Small',
  'Majenta net/ Green Small',
  'SKIRT-54',
  175.00,
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
    WHERE p.barcode = 'SKIRT-54' 
       OR (p.slug = 'skirt-54-majenta-net-green-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #258: SKIRT-53
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-53',
  'skirt-53-sky-blue-net-dotgold-sequence-border',
  'Sky blue net dot/Gold sequence border',
  'Sky blue net dot/Gold sequence border',
  'SKIRT-53',
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
    WHERE p.barcode = 'SKIRT-53' 
       OR (p.slug = 'skirt-53-sky-blue-net-dotgold-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #259: SKIRT-52
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-52',
  'skirt-52-green-net-gold-dotgold-border',
  'Green net gold dot/Gold border',
  'Green net gold dot/Gold border',
  'SKIRT-52',
  180.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-52' 
       OR (p.slug = 'skirt-52-green-net-gold-dotgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #260: SKIRT-51
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-51',
  'skirt-51-gold-banyanclothgreen-seq-border',
  'Gold banyancloth/Green seq Border',
  'Gold banyancloth/Green seq Border',
  'SKIRT-51',
  225.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-51' 
       OR (p.slug = 'skirt-51-gold-banyanclothgreen-seq-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #261: SKIRT-50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-50',
  'skirt-50-copper-sulphatefull-sequence-border',
  'Copper sulphate/Full sequence border',
  'Copper sulphate/Full sequence border',
  'SKIRT-50',
  260.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-50' 
       OR (p.slug = 'skirt-50-copper-sulphatefull-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #262: SKIRT-49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-49',
  'skirt-49-peacock-bluegold-printgold-border',
  'Peacock bluegold print/Gold border',
  'Peacock bluegold print/Gold border',
  'SKIRT-49',
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
    WHERE p.barcode = 'SKIRT-49' 
       OR (p.slug = 'skirt-49-peacock-bluegold-printgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #263: SKIRT-48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-48',
  'skirt-48-plain-blackgold-border',
  'Plain black/Gold Border',
  'Plain black/Gold Border',
  'SKIRT-48',
  225.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-48' 
       OR (p.slug = 'skirt-48-plain-blackgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #264: SKIRT-47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-47',
  'skirt-47-red-seq-design-small-sequence-border',
  'Red seq design/ small sequence border',
  'Red seq design/ small sequence border',
  'SKIRT-47',
  250.00,
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
    WHERE p.barcode = 'SKIRT-47' 
       OR (p.slug = 'skirt-47-red-seq-design-small-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #265: SKIRT-46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-46',
  'skirt-46-majenta-banyan-clothslit-longborder',
  'Majenta banyan cloth/Slit longborder',
  'Majenta banyan cloth/Slit longborder',
  'SKIRT-46',
  180.00,
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
    WHERE p.barcode = 'SKIRT-46' 
       OR (p.slug = 'skirt-46-majenta-banyan-clothslit-longborder' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #266: SKIRT-45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-45',
  'skirt-45-majenta-full-sequencegold-border',
  'Majenta full sequence/Gold border',
  'Majenta full sequence/Gold border',
  'SKIRT-45',
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
    WHERE p.barcode = 'SKIRT-45' 
       OR (p.slug = 'skirt-45-majenta-full-sequencegold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #267: SKIRT-44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-44',
  'skirt-44-dark-greenmajenta-baniyan-cloth',
  'Dark green/Majenta baniyan cloth',
  'Dark green/Majenta baniyan cloth',
  'SKIRT-44',
  225.00,
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
    WHERE p.barcode = 'SKIRT-44' 
       OR (p.slug = 'skirt-44-dark-greenmajenta-baniyan-cloth' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #268: SKIRT-43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-43',
  'skirt-43-light-pinkgold-sequence-border',
  'Light pink/Gold sequence border',
  'Light pink/Gold sequence border',
  'SKIRT-43',
  325.00,
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
    WHERE p.barcode = 'SKIRT-43' 
       OR (p.slug = 'skirt-43-light-pinkgold-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #269: SKIRT-42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-42',
  'skirt-42-majenta-net-manbgo-design-border-small',
  'Majenta net/ manbgo design border small',
  'Majenta net/ manbgo design border small',
  'SKIRT-42',
  260.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-42' 
       OR (p.slug = 'skirt-42-majenta-net-manbgo-design-border-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #270: SKIRT-41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-41',
  'skirt-41-black-gold-embroideryred-border',
  'Black gold embroidery/Red border',
  'Black gold embroidery/Red border',
  'SKIRT-41',
  290.00,
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
    WHERE p.barcode = 'SKIRT-41' 
       OR (p.slug = 'skirt-41-black-gold-embroideryred-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #271: SKIRT-40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-40',
  'skirt-40-yellow-net-small-dotblue-seq-border',
  'Yellow net small dot/Blue seq border',
  'Yellow net small dot/Blue seq border',
  'SKIRT-40',
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
    WHERE p.barcode = 'SKIRT-40' 
       OR (p.slug = 'skirt-40-yellow-net-small-dotblue-seq-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #272: SKIRT-39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-39',
  'skirt-39-majenta-dotgold-border',
  'Majenta dot/Gold border',
  'Majenta dot/Gold border',
  'SKIRT-39',
  225.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-39' 
       OR (p.slug = 'skirt-39-majenta-dotgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #273: SKIRT-38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-38',
  'skirt-38-peacock-skirt',
  'Peacock skirt',
  'Peacock skirt',
  'SKIRT-38',
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
    WHERE p.barcode = 'SKIRT-38' 
       OR (p.slug = 'skirt-38-peacock-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #274: SKIRT-37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-37',
  'skirt-37-red-net-red-embroidery-border',
  'Red net/ Red embroidery border',
  'Red net/ Red embroidery border',
  'SKIRT-37',
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
    WHERE p.barcode = 'SKIRT-37' 
       OR (p.slug = 'skirt-37-red-net-red-embroidery-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #275: SKIRT-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-36',
  'skirt-36-royal-blue-netgold-miror-border',
  'Royal blue net/Gold miror border',
  'Royal blue net/Gold miror border',
  'SKIRT-36',
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
    WHERE p.barcode = 'SKIRT-36' 
       OR (p.slug = 'skirt-36-royal-blue-netgold-miror-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #276: SKIRT-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-35',
  'skirt-35-royal-blue-full-seq-goldmajenta-border',
  'Royal blue full seq gold/Majenta border',
  'Royal blue full seq gold/Majenta border',
  'SKIRT-35',
  290.00,
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
    WHERE p.barcode = 'SKIRT-35' 
       OR (p.slug = 'skirt-35-royal-blue-full-seq-goldmajenta-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #277: SKIRT-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-34',
  'skirt-34-yellow-netmirror-border',
  'Yellow net/Mirror border',
  'Yellow net/Mirror border',
  'SKIRT-34',
  290.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-34' 
       OR (p.slug = 'skirt-34-yellow-netmirror-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #278: SKIRT-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-33',
  'skirt-33-peach-emroideryblack-border',
  'Peach emroidery/Black border',
  'Peach emroidery/Black border',
  'SKIRT-33',
  325.00,
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
    WHERE p.barcode = 'SKIRT-33' 
       OR (p.slug = 'skirt-33-peach-emroideryblack-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #279: SKIRT-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-32',
  'skirt-32-red-netblue-sequence-border',
  'Red net/Blue sequence border',
  'Red net/Blue sequence border',
  'SKIRT-32',
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
    WHERE p.barcode = 'SKIRT-32' 
       OR (p.slug = 'skirt-32-red-netblue-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #280: SKIRT-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-31',
  'skirt-31-royal-blue-embroideryred-sequence-border',
  'Royal blue embroidery/Red sequence border',
  'Royal blue embroidery/Red sequence border',
  'SKIRT-31',
  290.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-31' 
       OR (p.slug = 'skirt-31-royal-blue-embroideryred-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #281: SKIRT-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-30',
  'skirt-30-sky-blue-silver-sequencesilver-border',
  'Sky blue silver sequence/Silver border',
  'Sky blue silver sequence/Silver border',
  'SKIRT-30',
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
    WHERE p.barcode = 'SKIRT-30' 
       OR (p.slug = 'skirt-30-sky-blue-silver-sequencesilver-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #282: SKIRT-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-29',
  'skirt-29-green-sequencered-border',
  'Green sequence/Red Border',
  'Green sequence/Red Border',
  'SKIRT-29',
  290.00,
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
    WHERE p.barcode = 'SKIRT-29' 
       OR (p.slug = 'skirt-29-green-sequencered-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #283: SKIRT-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-28',
  'skirt-28-red-round-embroidery-sequence-border',
  'Red round embroidery/ Sequence border',
  'Red round embroidery/ Sequence border',
  'SKIRT-28',
  290.00,
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
    WHERE p.barcode = 'SKIRT-28' 
       OR (p.slug = 'skirt-28-red-round-embroidery-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #284: SKIRT-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-27',
  'skirt-27-red-full-gold-dotgold-sequence-border',
  'Red full gold dot/gold sequence border',
  'Red full gold dot/gold sequence border',
  'SKIRT-27',
  325.00,
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
    WHERE p.barcode = 'SKIRT-27' 
       OR (p.slug = 'skirt-27-red-full-gold-dotgold-sequence-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #285: SKIRT-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-26',
  'skirt-26-yellow-netred-diamond-border',
  'Yellow net/Red diamond border',
  'Yellow net/Red diamond border',
  'SKIRT-26',
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
    WHERE p.barcode = 'SKIRT-26' 
       OR (p.slug = 'skirt-26-yellow-netred-diamond-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #286: SKIRT-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-25',
  'skirt-25-plain-green-netgold-border',
  'Plain green net/Gold Border',
  'Plain green net/Gold Border',
  'SKIRT-25',
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
    WHERE p.barcode = 'SKIRT-25' 
       OR (p.slug = 'skirt-25-plain-green-netgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #287: SKIRT-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-24',
  'skirt-24-gold-dotgold-border',
  'Gold dot/Gold border',
  'Gold dot/Gold border',
  'SKIRT-24',
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
    WHERE p.barcode = 'SKIRT-24' 
       OR (p.slug = 'skirt-24-gold-dotgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #288: SKIRT-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-23',
  'skirt-23-majebta-embroidery-border',
  'Majebta Embroidery border',
  'Majebta Embroidery border',
  'SKIRT-23',
  325.00,
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
    WHERE p.barcode = 'SKIRT-23' 
       OR (p.slug = 'skirt-23-majebta-embroidery-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #289: SKIRT-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-22',
  'skirt-22-majenta-netmango-design-border',
  'Majenta net/Mango design border',
  'Majenta net/Mango design border',
  'SKIRT-22',
  325.00,
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
    WHERE p.barcode = 'SKIRT-22' 
       OR (p.slug = 'skirt-22-majenta-netmango-design-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #290: SKIRT-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-21',
  'skirt-21-red-gold-mirror2-line-border',
  'Red gold mirror/2 line border',
  'Red gold mirror/2 line border',
  'SKIRT-21',
  260.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-21' 
       OR (p.slug = 'skirt-21-red-gold-mirror2-line-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #291: SKIRT-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-20',
  'skirt-20-white-gold-design',
  'White gold design',
  'White gold design',
  'SKIRT-20',
  260.00,
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
    WHERE p.barcode = 'SKIRT-20' 
       OR (p.slug = 'skirt-20-white-gold-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #292: SKIRT-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-19',
  'skirt-19-yellow-green-border',
  'Yellow Green Border',
  'Yellow Green Border',
  'SKIRT-19',
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
    WHERE p.barcode = 'SKIRT-19' 
       OR (p.slug = 'skirt-19-yellow-green-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #293: SKIRT-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-18',
  'skirt-18-black-dot-skirt',
  'Black dot skirt',
  'Black dot skirt',
  'SKIRT-18',
  260.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-18' 
       OR (p.slug = 'skirt-18-black-dot-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #294: SKIRT-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-17',
  'skirt-17-blue-netgold-majenta-square-design',
  'Blue net/Gold Majenta square design',
  'Blue net/Gold Majenta square design',
  'SKIRT-17',
  325.00,
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
    WHERE p.barcode = 'SKIRT-17' 
       OR (p.slug = 'skirt-17-blue-netgold-majenta-square-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #295: SKIRT-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-16',
  'skirt-16-kilipacha-gold-dotgold-border',
  'Kilipacha gold dot/Gold border',
  'Kilipacha gold dot/Gold border',
  'SKIRT-16',
  225.00,
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
    WHERE p.barcode = 'SKIRT-16' 
       OR (p.slug = 'skirt-16-kilipacha-gold-dotgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #296: SKIRT-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-15',
  'skirt-15-orange-flower-net-skirt',
  'Orange flower net skirt',
  'Orange flower net skirt',
  'SKIRT-15',
  260.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-15' 
       OR (p.slug = 'skirt-15-orange-flower-net-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #297: SKIRT-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-14',
  'skirt-14-majentagold-triangle-design',
  'Majenta/Gold triangle design',
  'Majenta/Gold triangle design',
  'SKIRT-14',
  325.00,
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
    WHERE p.barcode = 'SKIRT-14' 
       OR (p.slug = 'skirt-14-majentagold-triangle-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #298: SKIRT-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-13',
  'skirt-13-kilipachamajenta-border',
  'Kilipacha/Majenta border',
  'Kilipacha/Majenta border',
  'SKIRT-13',
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
    WHERE p.barcode = 'SKIRT-13' 
       OR (p.slug = 'skirt-13-kilipachamajenta-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #299: SKIRT-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-12',
  'skirt-12-red-stripes',
  'Red stripes',
  'Red stripes',
  'SKIRT-12',
  370.00,
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
    WHERE p.barcode = 'SKIRT-12' 
       OR (p.slug = 'skirt-12-red-stripes' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #300: SKIRT-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-11',
  'skirt-11-whitegold',
  'WHITE/GOLD',
  'WHITE/GOLD',
  'SKIRT-11',
  225.00,
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
    WHERE p.barcode = 'SKIRT-11' 
       OR (p.slug = 'skirt-11-whitegold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #301: SKIRT-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-9',
  'skirt-9-redgreen',
  'RED/GREEN',
  'RED/GREEN',
  'SKIRT-9',
  225.00,
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
    WHERE p.barcode = 'SKIRT-9' 
       OR (p.slug = 'skirt-9-redgreen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #302: SKIRT-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-8',
  'skirt-8-bluegold',
  'BLUE/GOLD',
  'BLUE/GOLD',
  'SKIRT-8',
  175.00,
  500.00,
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
    WHERE p.barcode = 'SKIRT-8' 
       OR (p.slug = 'skirt-8-bluegold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #303: SKIRT-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-7',
  'skirt-7-white-silver-sequence-skirt',
  'White silver sequence skirt',
  'White silver sequence skirt',
  'SKIRT-7',
  225.00,
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
    WHERE p.barcode = 'SKIRT-7' 
       OR (p.slug = 'skirt-7-white-silver-sequence-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #304: SKIRT-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-6',
  'skirt-6-goldgold',
  'GOLD/GOLD',
  'GOLD/GOLD',
  'SKIRT-6',
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
    WHERE p.barcode = 'SKIRT-6' 
       OR (p.slug = 'skirt-6-goldgold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #305: SKIRT-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-5',
  'skirt-5-whitegold',
  'WHITE/GOLD',
  'WHITE/GOLD',
  'SKIRT-5',
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
    WHERE p.barcode = 'SKIRT-5' 
       OR (p.slug = 'skirt-5-whitegold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #306: SKIRT-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-4',
  'skirt-4-yellow',
  'YELLOW',
  'YELLOW',
  'SKIRT-4',
  325.00,
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
    WHERE p.barcode = 'SKIRT-4' 
       OR (p.slug = 'skirt-4-yellow' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #307: SKIRT-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-3',
  'skirt-3-redpink',
  'RED/PINK',
  'RED/PINK',
  'SKIRT-3',
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
    WHERE p.barcode = 'SKIRT-3' 
       OR (p.slug = 'skirt-3-redpink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #308: SKIRT-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-2',
  'skirt-2-goldblack',
  'GOLD/BLACK',
  'GOLD/BLACK',
  'SKIRT-2',
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
    WHERE p.barcode = 'SKIRT-2' 
       OR (p.slug = 'skirt-2-goldblack' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #309: SKIRT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'skirt' AND store_id = s.id LIMIT 1),
  b.id,
  'SKIRT-1',
  'skirt-1-redwhite',
  'RED/WHITE',
  'RED/WHITE',
  'SKIRT-1',
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
    WHERE p.barcode = 'SKIRT-1' 
       OR (p.slug = 'skirt-1-redwhite' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #310: SHAWL-45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-45',
  'shawl-45-yellow-dot-net-shawl-with-border',
  'Yellow dot net shawl with border',
  'Yellow dot net shawl with border',
  'SHAWL-45',
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
    WHERE p.barcode = 'SHAWL-45' 
       OR (p.slug = 'shawl-45-yellow-dot-net-shawl-with-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #311: SHAWL-44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-44',
  'shawl-44-red-dot-net-shawl-with-border',
  'Red dot net shawl with border',
  'Red dot net shawl with border',
  'SHAWL-44',
  50.00,
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
    WHERE p.barcode = 'SHAWL-44' 
       OR (p.slug = 'shawl-44-red-dot-net-shawl-with-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #312: SHAWL-43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-43',
  'shawl-43-green-netlili-pacha',
  'Green net(Lili pacha)',
  'Green net(Lili pacha)',
  'SHAWL-43',
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
    WHERE p.barcode = 'SHAWL-43' 
       OR (p.slug = 'shawl-43-green-netlili-pacha' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #313: SHAWL-42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-42',
  'shawl-42-long-gold-net-with-border',
  'Long gold net with border',
  'Long gold net with border',
  'SHAWL-42',
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
    WHERE p.barcode = 'SHAWL-42' 
       OR (p.slug = 'shawl-42-long-gold-net-with-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #314: SHAWL-41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-41',
  'shawl-41-gold-with-stone-border',
  'Gold with stone border',
  'Gold with stone border',
  'SHAWL-41',
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
    WHERE p.barcode = 'SHAWL-41' 
       OR (p.slug = 'shawl-41-gold-with-stone-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #315: SHAWL-40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-40',
  'shawl-40-sky-blue-sequence-medium',
  'SKY BLUE SEQUENCE MEDIUM',
  'SKY BLUE SEQUENCE MEDIUM',
  'SHAWL-40',
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
    WHERE p.barcode = 'SHAWL-40' 
       OR (p.slug = 'shawl-40-sky-blue-sequence-medium' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #316: SHAWL-39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-39',
  'shawl-39-sky-blue-net',
  'SKY BLUE NET',
  'SKY BLUE NET',
  'SHAWL-39',
  30.00,
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
    WHERE p.barcode = 'SHAWL-39' 
       OR (p.slug = 'shawl-39-sky-blue-net' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #317: SHAWL-38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-38',
  'shawl-38-bluegold-border',
  'BLUE/GOLD BORDER',
  'BLUE/GOLD BORDER',
  'SHAWL-38',
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
    WHERE p.barcode = 'SHAWL-38' 
       OR (p.slug = 'shawl-38-bluegold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #318: SHAWL-37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-37',
  'shawl-37-greenblue-border-small',
  'GREEN/BLUE BORDER SMALL',
  'GREEN/BLUE BORDER SMALL',
  'SHAWL-37',
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
    WHERE p.barcode = 'SHAWL-37' 
       OR (p.slug = 'shawl-37-greenblue-border-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #319: SHAWL-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-36',
  'shawl-36-greenblue-border',
  'GREEN/BLUE BORDER',
  'GREEN/BLUE BORDER',
  'SHAWL-36',
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
    WHERE p.barcode = 'SHAWL-36' 
       OR (p.slug = 'shawl-36-greenblue-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #320: SHAWL-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-35',
  'shawl-35-green-net-gold-dot-medium',
  'GREEN NET/ GOLD DOT MEDIUM',
  'GREEN NET/ GOLD DOT MEDIUM',
  'SHAWL-35',
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
    WHERE p.barcode = 'SHAWL-35' 
       OR (p.slug = 'shawl-35-green-net-gold-dot-medium' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #321: SHAWL-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-34',
  'shawl-34-greengold-border-small',
  'GREEN/GOLD BORDER SMALL',
  'GREEN/GOLD BORDER SMALL',
  'SHAWL-34',
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
    WHERE p.barcode = 'SHAWL-34' 
       OR (p.slug = 'shawl-34-greengold-border-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #322: SHAWL-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-33',
  'shawl-33-greengold-border-large',
  'GREEN/GOLD BORDER LARGE',
  'GREEN/GOLD BORDER LARGE',
  'SHAWL-33',
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
    WHERE p.barcode = 'SHAWL-33' 
       OR (p.slug = 'shawl-33-greengold-border-large' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #323: SHAWL-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-32',
  'shawl-32-green-netgold-border-medium',
  'GREEN NET/GOLD BORDER MEDIUM',
  'GREEN NET/GOLD BORDER MEDIUM',
  'SHAWL-32',
  30.00,
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
    WHERE p.barcode = 'SHAWL-32' 
       OR (p.slug = 'shawl-32-green-netgold-border-medium' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #324: SHAWL-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-31',
  'shawl-31-orangegold-border-large',
  'ORANGE/GOLD BORDER LARGE',
  'ORANGE/GOLD BORDER LARGE',
  'SHAWL-31',
  30.00,
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
    WHERE p.barcode = 'SHAWL-31' 
       OR (p.slug = 'shawl-31-orangegold-border-large' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #325: SHAWL-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-30',
  'shawl-30-orange-gold-border-medium',
  'ORANGE /GOLD BORDER MEDIUM',
  'ORANGE /GOLD BORDER MEDIUM',
  'SHAWL-30',
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
    WHERE p.barcode = 'SHAWL-30' 
       OR (p.slug = 'shawl-30-orange-gold-border-medium' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #326: SHAWL-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-29',
  'shawl-29-red-embroidery',
  'RED EMBROIDERY',
  'RED EMBROIDERY',
  'SHAWL-29',
  30.00,
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
    WHERE p.barcode = 'SHAWL-29' 
       OR (p.slug = 'shawl-29-red-embroidery' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #327: SHAWL-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-28',
  'shawl-28-redgold-embroidery-medium',
  'RED/GOLD EMBROIDERY MEDIUM',
  'RED/GOLD EMBROIDERY MEDIUM',
  'SHAWL-28',
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
    WHERE p.barcode = 'SHAWL-28' 
       OR (p.slug = 'shawl-28-redgold-embroidery-medium' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #328: SHAWL-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-27',
  'shawl-27-redgold-dot-small',
  'RED/GOLD DOT SMALL',
  'RED/GOLD DOT SMALL',
  'SHAWL-27',
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
    WHERE p.barcode = 'SHAWL-27' 
       OR (p.slug = 'shawl-27-redgold-dot-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #329: SHAWL-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-26',
  'shawl-26-red-netbig-dot-small-size',
  'RED NET/BIG DOT SMALL SIZE',
  'RED NET/BIG DOT SMALL SIZE',
  'SHAWL-26',
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
    WHERE p.barcode = 'SHAWL-26' 
       OR (p.slug = 'shawl-26-red-netbig-dot-small-size' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #330: SHAWL-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-25',
  'shawl-25-redgold-border',
  'RED/GOLD BORDER',
  'RED/GOLD BORDER',
  'SHAWL-25',
  30.00,
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
    WHERE p.barcode = 'SHAWL-25' 
       OR (p.slug = 'shawl-25-redgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #331: SHAWL-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-24',
  'shawl-24-red-plain-net',
  'RED PLAIN NET',
  'RED PLAIN NET',
  'SHAWL-24',
  30.00,
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
    WHERE p.barcode = 'SHAWL-24' 
       OR (p.slug = 'shawl-24-red-plain-net' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #332: SHAWL-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-23',
  'shawl-23-redsilver-border',
  'RED/SILVER BORDER',
  'RED/SILVER BORDER',
  'SHAWL-23',
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
    WHERE p.barcode = 'SHAWL-23' 
       OR (p.slug = 'shawl-23-redsilver-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #333: SHAWL-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-22',
  'shawl-22-red-plain',
  'RED PLAIN',
  'RED PLAIN',
  'SHAWL-22',
  30.00,
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
    WHERE p.barcode = 'SHAWL-22' 
       OR (p.slug = 'shawl-22-red-plain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #334: SHAWL-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-21',
  'shawl-21-whitesilver-border-medium',
  'WHITE/SILVER BORDER MEDIUM',
  'WHITE/SILVER BORDER MEDIUM',
  'SHAWL-21',
  30.00,
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
    WHERE p.barcode = 'SHAWL-21' 
       OR (p.slug = 'shawl-21-whitesilver-border-medium' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #335: SHAWL-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-20',
  'shawl-20-white-net',
  'WHITE NET',
  'WHITE NET',
  'SHAWL-20',
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
    WHERE p.barcode = 'SHAWL-20' 
       OR (p.slug = 'shawl-20-white-net' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #336: SHAWL-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-19',
  'shawl-19-white-plain',
  'WHITE PLAIN',
  'WHITE PLAIN',
  'SHAWL-19',
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
    WHERE p.barcode = 'SHAWL-19' 
       OR (p.slug = 'shawl-19-white-plain' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #337: SHAWL-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-18',
  'shawl-18-blackgreen-border',
  'BLACK/GREEN BORDER',
  'BLACK/GREEN BORDER',
  'SHAWL-18',
  30.00,
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
    WHERE p.barcode = 'SHAWL-18' 
       OR (p.slug = 'shawl-18-blackgreen-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #338: SHAWL-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-17',
  'shawl-17-blacksmall-dot',
  'BLACK/SMALL DOT',
  'BLACK/SMALL DOT',
  'SHAWL-17',
  30.00,
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
    WHERE p.barcode = 'SHAWL-17' 
       OR (p.slug = 'shawl-17-blacksmall-dot' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #339: SHAWL-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-16',
  'shawl-16-blackgold-border',
  'BLACK/GOLD BORDER',
  'BLACK/GOLD BORDER',
  'SHAWL-16',
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
    WHERE p.barcode = 'SHAWL-16' 
       OR (p.slug = 'shawl-16-blackgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #340: SHAWL-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-15',
  'shawl-15-plain-majenta',
  'PLAIN MAJENTA',
  'PLAIN MAJENTA',
  'SHAWL-15',
  30.00,
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
    WHERE p.barcode = 'SHAWL-15' 
       OR (p.slug = 'shawl-15-plain-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #341: SHAWL-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-14',
  'shawl-14-magenta-gold-embroidery',
  'MAGENTA GOLD EMBROIDERY',
  'MAGENTA GOLD EMBROIDERY',
  'SHAWL-14',
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
    WHERE p.barcode = 'SHAWL-14' 
       OR (p.slug = 'shawl-14-magenta-gold-embroidery' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #342: SHAWL-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-13',
  'shawl-13-majenta-dot-medium',
  'MAJENTA DOT MEDIUM',
  'MAJENTA DOT MEDIUM',
  'SHAWL-13',
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
    WHERE p.barcode = 'SHAWL-13' 
       OR (p.slug = 'shawl-13-majenta-dot-medium' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #343: SHAWL-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-12',
  'shawl-12-majenta-small',
  'MAJENTA SMALL',
  'MAJENTA SMALL',
  'SHAWL-12',
  30.00,
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
    WHERE p.barcode = 'SHAWL-12' 
       OR (p.slug = 'shawl-12-majenta-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #344: SHAWL-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-11',
  'shawl-11-majenta-border-embroidery',
  'MAJENTA BORDER EMBROIDERY',
  'MAJENTA BORDER EMBROIDERY',
  'SHAWL-11',
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
    WHERE p.barcode = 'SHAWL-11' 
       OR (p.slug = 'shawl-11-majenta-border-embroidery' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #345: SHAWL-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-10',
  'shawl-10-gold-embroidery',
  'GOLD EMBROIDERY',
  'GOLD EMBROIDERY',
  'SHAWL-10',
  30.00,
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
    WHERE p.barcode = 'SHAWL-10' 
       OR (p.slug = 'shawl-10-gold-embroidery' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #346: SHAWL-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-9',
  'shawl-9-gold-net-dot-sequence',
  'GOLD NET DOT SEQUENCE',
  'GOLD NET DOT SEQUENCE',
  'SHAWL-9',
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
    WHERE p.barcode = 'SHAWL-9' 
       OR (p.slug = 'shawl-9-gold-net-dot-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #347: SHAWL-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-8',
  'shawl-8-gold-net-mirror',
  'GOLD NET MIRROR',
  'GOLD NET MIRROR',
  'SHAWL-8',
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
    WHERE p.barcode = 'SHAWL-8' 
       OR (p.slug = 'shawl-8-gold-net-mirror' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #348: SHAWL-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-7',
  'shawl-7-gold-net',
  'GOLD NET',
  'GOLD NET',
  'SHAWL-7',
  30.00,
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
    WHERE p.barcode = 'SHAWL-7' 
       OR (p.slug = 'shawl-7-gold-net' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #349: SHAWL-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-6',
  'shawl-6-goldgold-satin',
  'GOLD/GOLD SATIN',
  'GOLD/GOLD SATIN',
  'SHAWL-6',
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
    WHERE p.barcode = 'SHAWL-6' 
       OR (p.slug = 'shawl-6-goldgold-satin' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #350: SHAWL-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-5',
  'shawl-5-goldgold-border',
  'GOLD/GOLD BORDER',
  'GOLD/GOLD BORDER',
  'SHAWL-5',
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
    WHERE p.barcode = 'SHAWL-5' 
       OR (p.slug = 'shawl-5-goldgold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #351: SHAWL-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-4',
  'shawl-4-goldblack-border',
  'GOLD/BLACK BORDER',
  'GOLD/BLACK BORDER',
  'SHAWL-4',
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
    WHERE p.barcode = 'SHAWL-4' 
       OR (p.slug = 'shawl-4-goldblack-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #352: SHAWL-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-3',
  'shawl-3-gold-pearl',
  'GOLD /PEARL',
  'GOLD /PEARL',
  'SHAWL-3',
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
    WHERE p.barcode = 'SHAWL-3' 
       OR (p.slug = 'shawl-3-gold-pearl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #353: SHAWL-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-2',
  'shawl-2-gold-big-dots',
  'GOLD BIG DOTS',
  'GOLD BIG DOTS',
  'SHAWL-2',
  30.00,
  0.00,
  38,
  38,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SHAWL-2' 
       OR (p.slug = 'shawl-2-gold-big-dots' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #354: SHAWL-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'shawl' AND store_id = s.id LIMIT 1),
  b.id,
  'SHAWL-1',
  'shawl-1-gold-sequence-dot',
  'GOLD SEQUENCE DOT',
  'GOLD SEQUENCE DOT',
  'SHAWL-1',
  30.00,
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
    WHERE p.barcode = 'SHAWL-1' 
       OR (p.slug = 'shawl-1-gold-sequence-dot' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #355: SEMI-56
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-56',
  'semi-56-mehandi-green-renga-pooja-skirt-model-up',
  'Mehandi green renga pooja Skirt model UP',
  'Mehandi green renga pooja Skirt model UP',
  'SEMI-56',
  1000.00,
  3200.00,
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
    WHERE p.barcode = 'SEMI-56' 
       OR (p.slug = 'semi-56-mehandi-green-renga-pooja-skirt-model-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #356: SEMI-55
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-55',
  'semi-55-black-brocade-red-border-crossfril-kacha-model-hss',
  'Black brocade Red border crossfril kacha model HSS',
  'Black brocade Red border crossfril kacha model HSS',
  'SEMI-55',
  1500.00,
  3200.00,
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
    WHERE p.barcode = 'SEMI-55' 
       OR (p.slug = 'semi-55-black-brocade-red-border-crossfril-kacha-model-hss' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #357: SEMI-54
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-54',
  'semi-54-majentdark-green-kacha-crossfril-lp',
  'Majent/dark green kacha crossfril LP',
  'Majent/dark green kacha crossfril LP',
  'SEMI-54',
  1000.00,
  2800.00,
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
    WHERE p.barcode = 'SEMI-54' 
       OR (p.slug = 'semi-54-majentdark-green-kacha-crossfril-lp' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #358: SEMI-53
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-53',
  'semi-53-parrot-greenmajenta-crossfril-adult-hss',
  'Parrot green/Majenta crossfril adult HSS',
  'Parrot green/Majenta crossfril adult HSS',
  'SEMI-53',
  1200.00,
  3200.00,
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
    WHERE p.barcode = 'SEMI-53' 
       OR (p.slug = 'semi-53-parrot-greenmajenta-crossfril-adult-hss' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #359: SEMI-52
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-52',
  'semi-52-kacha-offwhitemarroon-crossfril-big',
  'Kacha Offwhite/Marroon crossfril Big',
  'Kacha Offwhite/Marroon crossfril Big',
  'SEMI-52',
  1200.00,
  3200.00,
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
    WHERE p.barcode = 'SEMI-52' 
       OR (p.slug = 'semi-52-kacha-offwhitemarroon-crossfril-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #360: SEMI-51
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-51',
  'semi-51-orange-marroon-skirt-cross-frill-saree-type',
  'Orange Marroon skirt cross frill saree type',
  'Orange Marroon skirt cross frill saree type',
  'SEMI-51',
  1050.00,
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
    WHERE p.barcode = 'SEMI-51' 
       OR (p.slug = 'semi-51-orange-marroon-skirt-cross-frill-saree-type' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #361: SEMI-50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-50',
  'semi-50-plain-green-skirt-bh',
  'Plain green skirt BH',
  'Plain green skirt BH',
  'SEMI-50',
  750.00,
  2200.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SEMI-50' 
       OR (p.slug = 'semi-50-plain-green-skirt-bh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #362: SEMI-49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-49',
  'semi-49-ravana-set-kg',
  'Ravana set KG',
  'Ravana set KG',
  'SEMI-49',
  530.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-49' 
       OR (p.slug = 'semi-49-ravana-set-kg' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #363: SEMI-48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-48',
  'semi-48-yellow-net-pant-dawani',
  'Yellow net pant dawani',
  'Yellow net pant dawani',
  'SEMI-48',
  370.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-48' 
       OR (p.slug = 'semi-48-yellow-net-pant-dawani' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #364: SEMI-47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-47',
  'semi-47-peacock-blue',
  'Peacock blue',
  'Peacock blue',
  'SEMI-47',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-47' 
       OR (p.slug = 'semi-47-peacock-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #365: SEMI-46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-46',
  'semi-46-green-red',
  'Green Red',
  'Green Red',
  'SEMI-46',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-46' 
       OR (p.slug = 'semi-46-green-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #366: SEMI-45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-45',
  'semi-45-royal-blue-red',
  'Royal blue red',
  'Royal blue red',
  'SEMI-45',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-45' 
       OR (p.slug = 'semi-45-royal-blue-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #367: SEMI-44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-44',
  'semi-44-green-dot-saree-model-red-top',
  'Green dot saree model Red top',
  'Green dot saree model Red top',
  'SEMI-44',
  750.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-44' 
       OR (p.slug = 'semi-44-green-dot-saree-model-red-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #368: SEMI-43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-43',
  'semi-43-full-black-dot-saree-model',
  'Full black dot saree model',
  'Full black dot saree model',
  'SEMI-43',
  750.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-43' 
       OR (p.slug = 'semi-43-full-black-dot-saree-model' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #369: SEMI-42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-42',
  'semi-42-black-satin-silver-seq-nagam-dress',
  'Black satin silver seq Nagam dress',
  'Black satin silver seq Nagam dress',
  'SEMI-42',
  750.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-42' 
       OR (p.slug = 'semi-42-black-satin-silver-seq-nagam-dress' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #370: SEMI-41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-41',
  'semi-41-yellow-satinblue-dhothi-manichithra-thazhu-semi',
  'Yellow satin/blue dhothi Manichithra thazhu semi',
  'Yellow satin/blue dhothi Manichithra thazhu semi',
  'SEMI-41',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-41' 
       OR (p.slug = 'semi-41-yellow-satinblue-dhothi-manichithra-thazhu-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #371: SEMI-40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-40',
  'semi-40-white-pleated-pant-saree-net-dot-no-blouse',
  'White pleated pant & saree net dot no blouse',
  'White pleated pant & saree net dot no blouse',
  'SEMI-40',
  1050.00,
  3200.00,
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
    WHERE p.barcode = 'SEMI-40' 
       OR (p.slug = 'semi-40-white-pleated-pant-saree-net-dot-no-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #372: SEMI-39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-39',
  'semi-39-dark-blue-light-blue-check-saree-semi',
  'Dark Blue Light Blue check saree semi',
  'Dark Blue Light Blue check saree semi',
  'SEMI-39',
  1260.00,
  3200.00,
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
    WHERE p.barcode = 'SEMI-39' 
       OR (p.slug = 'semi-39-dark-blue-light-blue-check-saree-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #373: SEMI-38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-38',
  'semi-38-green-blue-check-mode-semi',
  'Green Blue check mode; semi',
  'Green Blue check mode; semi',
  'SEMI-38',
  1260.00,
  3200.00,
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
    WHERE p.barcode = 'SEMI-38' 
       OR (p.slug = 'semi-38-green-blue-check-mode-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #374: SEMI-37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-37',
  'semi-37-violet-majenta-saree-model-semi',
  'Violet Majenta Saree model semi',
  'Violet Majenta Saree model semi',
  'SEMI-37',
  1300.00,
  3200.00,
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
    WHERE p.barcode = 'SEMI-37' 
       OR (p.slug = 'semi-37-violet-majenta-saree-model-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #375: SEMI-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-36',
  'semi-36-blue-orange-skirt-bh',
  'Blue/ Orange Skirt BH',
  'Blue/ Orange Skirt BH',
  'SEMI-36',
  420.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SEMI-36' 
       OR (p.slug = 'semi-36-blue-orange-skirt-bh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #376: SEMI-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-35',
  'semi-35-blue-majentarenga-pooja-kg',
  'Blue Majenta/Renga pooja KG',
  'Blue Majenta/Renga pooja KG',
  'SEMI-35',
  370.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-35' 
       OR (p.slug = 'semi-35-blue-majentarenga-pooja-kg' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #377: SEMI-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-34',
  'semi-34-violetmajenta-brocade',
  'Violet/Majenta brocade',
  'Violet/Majenta brocade',
  'SEMI-34',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-34' 
       OR (p.slug = 'semi-34-violetmajenta-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #378: SEMI-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-33',
  'semi-33-sky-blue-majenta-bh',
  'Sky blue/ Majenta BH',
  'Sky blue/ Majenta BH',
  'SEMI-33',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-33' 
       OR (p.slug = 'semi-33-sky-blue-majenta-bh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #379: SEMI-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-32',
  'semi-32-peacock-bluered-skirt-bh',
  'Peacock blue/Red skirt BH',
  'Peacock blue/Red skirt BH',
  'SEMI-32',
  470.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-32' 
       OR (p.slug = 'semi-32-peacock-bluered-skirt-bh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #380: SEMI-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-31',
  'semi-31-green-skirtmajenta-brocade-bh',
  'Green skirt/Majenta brocade BH',
  'Green skirt/Majenta brocade BH',
  'SEMI-31',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-31' 
       OR (p.slug = 'semi-31-green-skirtmajenta-brocade-bh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #381: SEMI-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-30',
  'semi-30-gteen-skirtred-parts-bh',
  'Gteen skirt/Red parts BH',
  'Gteen skirt/Red parts BH',
  'SEMI-30',
  530.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-30' 
       OR (p.slug = 'semi-30-gteen-skirtred-parts-bh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #382: SEMI-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-29',
  'semi-29-blue-skirt-green-manichithra-thazhu',
  'Blue skirt/ Green Manichithra thazhu',
  'Blue skirt/ Green Manichithra thazhu',
  'SEMI-29',
  530.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-29' 
       OR (p.slug = 'semi-29-blue-skirt-green-manichithra-thazhu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #383: SEMI-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-28',
  'semi-28-vadamulla-surf-blue-renga-pooja-model',
  'Vadamulla surf blue Renga pooja model',
  'Vadamulla surf blue Renga pooja model',
  'SEMI-28',
  470.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-28' 
       OR (p.slug = 'semi-28-vadamulla-surf-blue-renga-pooja-model' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #384: SEMI-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-27',
  'semi-27-neriyathu-skirt-half-saree',
  'Neriyathu skirt half saree',
  'Neriyathu skirt half saree',
  'SEMI-27',
  420.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-27' 
       OR (p.slug = 'semi-27-neriyathu-skirt-half-saree' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #385: SEMI-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-26',
  'semi-26-kilipaha-dot-skirtred-blouse',
  'Kilipaha dot skirt,Red blouse',
  'Kilipaha dot skirt,Red blouse',
  'SEMI-26',
  530.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-26' 
       OR (p.slug = 'semi-26-kilipaha-dot-skirtred-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #386: SEMI-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-25',
  'semi-25-violet-skirt-green-brocade-skirt-bh',
  'Violet skirt green brocade skirt BH',
  'Violet skirt green brocade skirt BH',
  'SEMI-25',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-25' 
       OR (p.slug = 'semi-25-violet-skirt-green-brocade-skirt-bh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #387: SEMI-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-24',
  'semi-24-pista-green-violet-brocade-skirt-model-bh',
  'Pista green violet brocade skirt model BH',
  'Pista green violet brocade skirt model BH',
  'SEMI-24',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-24' 
       OR (p.slug = 'semi-24-pista-green-violet-brocade-skirt-model-bh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #388: SEMI-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-23',
  'semi-23-blue-majenta-brocade-skirt-model-bh',
  'Blue Majenta brocade skirt model BH',
  'Blue Majenta brocade skirt model BH',
  'SEMI-23',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-23' 
       OR (p.slug = 'semi-23-blue-majenta-brocade-skirt-model-bh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #389: SEMI-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-22',
  'semi-22-red-blue-skirt-model-bh',
  'Red blue skirt model BH',
  'Red blue skirt model BH',
  'SEMI-22',
  580.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-22' 
       OR (p.slug = 'semi-22-red-blue-skirt-model-bh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #390: SEMI-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-21',
  'semi-21-black-and-gold-snake-dance-type-old',
  'Black and Gold snake dance type Old',
  'Black and Gold snake dance type Old',
  'SEMI-21',
  370.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-21' 
       OR (p.slug = 'semi-21-black-and-gold-snake-dance-type-old' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #391: SEMI-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-20',
  'semi-20-brownblack-border-yellow-blouse',
  'Brown/Black border, yellow blouse',
  'Brown/Black border, yellow blouse',
  'SEMI-20',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-20' 
       OR (p.slug = 'semi-20-brownblack-border-yellow-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #392: SEMI-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-19',
  'semi-19-brownmajenta-skirt',
  'Brown/Majenta skirt',
  'Brown/Majenta skirt',
  'SEMI-19',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-19' 
       OR (p.slug = 'semi-19-brownmajenta-skirt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #393: SEMI-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-18',
  'semi-18-orange-skirt-green-blouse',
  'Orange skirt/ Green blouse',
  'Orange skirt/ Green blouse',
  'SEMI-18',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-18' 
       OR (p.slug = 'semi-18-orange-skirt-green-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #394: SEMI-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-17',
  'semi-17-majenta-skir-green-blouse',
  'Majenta skir/ Green blouse',
  'Majenta skir/ Green blouse',
  'SEMI-17',
  325.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-17' 
       OR (p.slug = 'semi-17-majenta-skir-green-blouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #395: SEMI-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-16',
  'semi-16-orange-satin-blue-semi',
  'Orange satin/ Blue semi',
  'Orange satin/ Blue semi',
  'SEMI-16',
  470.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-16' 
       OR (p.slug = 'semi-16-orange-satin-blue-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #396: SEMI-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-15',
  'semi-15-blue-satinorange-semi',
  'Blue satin/Orange semi',
  'Blue satin/Orange semi',
  'SEMI-15',
  470.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-15' 
       OR (p.slug = 'semi-15-blue-satinorange-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #397: SEMI-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-14',
  'semi-14-merroon-kannagi-set',
  'Merroon Kannagi set',
  'Merroon Kannagi set',
  'SEMI-14',
  680.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-14' 
       OR (p.slug = 'semi-14-merroon-kannagi-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #398: SEMI-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-13',
  'semi-13-ashmajenta-saree-model',
  'Ash/Majenta saree model',
  'Ash/Majenta saree model',
  'SEMI-13',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-13' 
       OR (p.slug = 'semi-13-ashmajenta-saree-model' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #399: SEMI-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-12',
  'semi-12-pista-greenviolet-brocade-semi',
  'Pista green/Violet brocade semi',
  'Pista green/Violet brocade semi',
  'SEMI-12',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-12' 
       OR (p.slug = 'semi-12-pista-greenviolet-brocade-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #400: SEMI-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-11',
  'semi-11-full-red-saree-type-semi',
  'Full red saree type semi',
  'Full red saree type semi',
  'SEMI-11',
  530.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-11' 
       OR (p.slug = 'semi-11-full-red-saree-type-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #401: SEMI-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-10',
  'semi-10-redblue-check-semi',
  'Red/Blue check semi',
  'Red/Blue check semi',
  'SEMI-10',
  530.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-10' 
       OR (p.slug = 'semi-10-redblue-check-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #402: SEMI-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-9',
  'semi-9-bluevioletmajenta-semi',
  'Blueviolet/Majenta semi',
  'Blueviolet/Majenta semi',
  'SEMI-9',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-9' 
       OR (p.slug = 'semi-9-bluevioletmajenta-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #403: SEMI-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-8',
  'semi-8-kilipacha-vadamulla-semi',
  'Kilipacha/ Vadamulla semi',
  'Kilipacha/ Vadamulla semi',
  'SEMI-8',
  370.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-8' 
       OR (p.slug = 'semi-8-kilipacha-vadamulla-semi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #404: SEMI-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-7',
  'semi-7-majenta-pant-green-brocade',
  'Majenta pant/ Green brocade',
  'Majenta pant/ Green brocade',
  'SEMI-7',
  370.00,
  1800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SEMI-7' 
       OR (p.slug = 'semi-7-majenta-pant-green-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #405: SEMI-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-6',
  'semi-6-black-silver-sequence-snakle-set',
  'Black silver sequence /Snakle set',
  'Black silver sequence /Snakle set',
  'SEMI-6',
  530.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-6' 
       OR (p.slug = 'semi-6-black-silver-sequence-snakle-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #406: SEMI-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-5',
  'semi-5-black-gold-new',
  'Black gold new',
  'Black gold new',
  'SEMI-5',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-5' 
       OR (p.slug = 'semi-5-black-gold-new' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #407: SEMI-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-4',
  'semi-4-black-gold-old',
  'Black gold old',
  'Black gold old',
  'SEMI-4',
  530.00,
  1800.00,
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
    WHERE p.barcode = 'SEMI-4' 
       OR (p.slug = 'semi-4-black-gold-old' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #408: SEMI-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-3',
  'semi-3-re-pantblack-vlouse',
  'Re pant/Black vlouse',
  'Re pant/Black vlouse',
  'SEMI-3',
  630.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-3' 
       OR (p.slug = 'semi-3-re-pantblack-vlouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #409: SEMI-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-2',
  'semi-2-black-pantblue-back-seat',
  'Black Pant/Blue back seat',
  'Black Pant/Blue back seat',
  'SEMI-2',
  580.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-2' 
       OR (p.slug = 'semi-2-black-pantblue-back-seat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #410: SEMI-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'semi-classical' AND store_id = s.id LIMIT 1),
  b.id,
  'SEMI-1',
  'semi-1-majenta-pantgreen-brocade',
  'Majenta pant/Green brocade',
  'Majenta pant/Green brocade',
  'SEMI-1',
  750.00,
  2200.00,
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
    WHERE p.barcode = 'SEMI-1' 
       OR (p.slug = 'semi-1-majenta-pantgreen-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #411: CROWN-46
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
  'CROWN-46',
  'crown-46-rubber-crown',
  'Rubber crown',
  'Rubber crown',
  'CROWN-46',
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
    WHERE p.barcode = 'CROWN-46' 
       OR (p.slug = 'crown-46-rubber-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #412: MASK-11
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
  'MASK-11',
  'mask-11-horror-mask-with-wig',
  'Horror mask with wig',
  'Horror mask with wig',
  'MASK-11',
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
    WHERE p.barcode = 'MASK-11' 
       OR (p.slug = 'mask-11-horror-mask-with-wig' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #413: LINGAM-1
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
  'LINGAM-1',
  'lingam-1-siva-lingam-light-weight-black',
  'Siva lingam light weight black',
  'Siva lingam light weight black',
  'LINGAM-1',
  450.00,
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
    WHERE p.barcode = 'LINGAM-1' 
       OR (p.slug = 'lingam-1-siva-lingam-light-weight-black' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #414: THEYYAM-2
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
  'THEYYAM-2',
  'theyyam-2-theyyam-vatta-mudi-small',
  'Theyyam vatta mudi small',
  'Theyyam vatta mudi small',
  'THEYYAM-2',
  450.00,
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
    WHERE p.barcode = 'THEYYAM-2' 
       OR (p.slug = 'theyyam-2-theyyam-vatta-mudi-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #415: TREE-2
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
  'TREE-2',
  'tree-2-tree-cutout-big-with-stand',
  'Tree cutout big with stand',
  'Tree cutout big with stand',
  'TREE-2',
  400.00,
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
    WHERE p.barcode = 'TREE-2' 
       OR (p.slug = 'tree-2-tree-cutout-big-with-stand' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #416: PALLAKKU-1
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
  'PALLAKKU-1',
  'pallakku-1-pallakku',
  'Pallakku',
  'Pallakku',
  'PALLAKKU-1',
  560.00,
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
    WHERE p.barcode = 'PALLAKKU-1' 
       OR (p.slug = 'pallakku-1-pallakku' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #417: NETTIPATTAM-1
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
  'NETTIPATTAM-1',
  'nettipattam-1-nettipattam-small',
  'Nettipattam small',
  'Nettipattam small',
  'NETTIPATTAM-1',
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
    WHERE p.barcode = 'NETTIPATTAM-1' 
       OR (p.slug = 'nettipattam-1-nettipattam-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #418: MAYILPEELI-1
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
  'MAYILPEELI-1',
  'mayilpeeli-1-mayilpeeli-wings-tie-at-back',
  'Mayilpeeli wings tie at back',
  'Mayilpeeli wings tie at back',
  'MAYILPEELI-1',
  350.00,
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
    WHERE p.barcode = 'MAYILPEELI-1' 
       OR (p.slug = 'mayilpeeli-1-mayilpeeli-wings-tie-at-back' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #419: KALAPPA-1
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
  'KALAPPA-1',
  'kalappa-1-kalappa',
  'Kalappa',
  'Kalappa',
  'KALAPPA-1',
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
    WHERE p.barcode = 'KALAPPA-1' 
       OR (p.slug = 'kalappa-1-kalappa' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #420: THEYYAM-1
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
  'THEYYAM-1',
  'theyyam-1-theyyam-big-vatta-mudi',
  'Theyyam big vatta mudi',
  'Theyyam big vatta mudi',
  'THEYYAM-1',
  675.00,
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
    WHERE p.barcode = 'THEYYAM-1' 
       OR (p.slug = 'theyyam-1-theyyam-big-vatta-mudi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #421: TREE-1
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
  'TREE-1',
  'tree-1-tree-cutout-cardboard',
  'Tree cutout cardboard',
  'Tree cutout cardboard',
  'TREE-1',
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
    WHERE p.barcode = 'TREE-1' 
       OR (p.slug = 'tree-1-tree-cutout-cardboard' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #422: STICK-7
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
  'STICK-7',
  'stick-7-stick',
  'Stick',
  'Stick',
  'STICK-7',
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
    WHERE p.barcode = 'STICK-7' 
       OR (p.slug = 'stick-7-stick' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #423: POOKOODA-5
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
  'POOKOODA-5',
  'pookooda-5-gold-paint-small-pookooda',
  'Gold paint small pookooda',
  'Gold paint small pookooda',
  'POOKOODA-5',
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
    WHERE p.barcode = 'POOKOODA-5' 
       OR (p.slug = 'pookooda-5-gold-paint-small-pookooda' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #424: MURAM-4
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
  'MURAM-4',
  'muram-4-nellu-koriyidunna-muram',
  'Nellu koriyidunna muram',
  'Nellu koriyidunna muram',
  'MURAM-4',
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
    WHERE p.barcode = 'MURAM-4' 
       OR (p.slug = 'muram-4-nellu-koriyidunna-muram' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #425: KUTTA-6
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
  'KUTTA-6',
  'kutta-6-kashmiri-kutta',
  'Kashmiri kutta',
  'Kashmiri kutta',
  'KUTTA-6',
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
    WHERE p.barcode = 'KUTTA-6' 
       OR (p.slug = 'kutta-6-kashmiri-kutta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #426: HANDBELT-2
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
  'HANDBELT-2',
  'handbelt-2-hip-tying-belt-with-hand',
  'Hip tying belt with hand',
  'Hip tying belt with hand',
  'HANDBELT-2',
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
    WHERE p.barcode = 'HANDBELT-2' 
       OR (p.slug = 'handbelt-2-hip-tying-belt-with-hand' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #427: SKULLMALA-2
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
  'SKULLMALA-2',
  'skullmala-2-skull-mala-plastic',
  'Skull mala plastic',
  'Skull mala plastic',
  'SKULLMALA-2',
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
    WHERE p.barcode = 'SKULLMALA-2' 
       OR (p.slug = 'skullmala-2-skull-mala-plastic' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #428: HEAD-2
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
  'HEAD-2',
  'head-2-head-green-paintwhite-paint',
  'Head green paint/white paint',
  'Head green paint/white paint',
  'HEAD-2',
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
    WHERE p.barcode = 'HEAD-2' 
       OR (p.slug = 'head-2-head-green-paintwhite-paint' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #429: GADHA-3
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
  'GADHA-3',
  'gadha-3-gadha-gold-new',
  'Gadha gold new',
  'Gadha gold new',
  'GADHA-3',
  220.00,
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
    WHERE p.barcode = 'GADHA-3' 
       OR (p.slug = 'gadha-3-gadha-gold-new' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #430: HANDCUFF-2
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
  'HANDCUFF-2',
  'handcuff-2-for-handleghead',
  'For hand,leg,head',
  'For hand,leg,head',
  'HANDCUFF-2',
  325.00,
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
    WHERE p.barcode = 'HANDCUFF-2' 
       OR (p.slug = 'handcuff-2-for-handleghead' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #431: HANDCUFF-1
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
  'HANDCUFF-1',
  'handcuff-1-for-hands-ony',
  'For hands on;y',
  'For hands on;y',
  'HANDCUFF-1',
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
    WHERE p.barcode = 'HANDCUFF-1' 
       OR (p.slug = 'handcuff-1-for-hands-ony' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #432: HAND-1
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
  'HAND-1',
  'hand-1-bhadrakali-hand-6',
  'Bhadrakali hand-6',
  'Bhadrakali hand-6',
  'HAND-1',
  350.00,
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
    WHERE p.barcode = 'HAND-1' 
       OR (p.slug = 'hand-1-bhadrakali-hand-6' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #433: CAP-17
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
  'CAP-17',
  'cap-17-tricolour-cap',
  'Tricolour cap',
  'Tricolour cap',
  'CAP-17',
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
    WHERE p.barcode = 'CAP-17' 
       OR (p.slug = 'cap-17-tricolour-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #434: KOODU-1
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
  'KOODU-1',
  'koodu-1-thatha-koodu',
  'Thatha koodu',
  'Thatha koodu',
  'KOODU-1',
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
    WHERE p.barcode = 'KOODU-1' 
       OR (p.slug = 'koodu-1-thatha-koodu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #435: RANTHAL-2
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
  'RANTHAL-2',
  'ranthal-2-small-ranthal',
  'Small ranthal',
  'Small ranthal',
  'RANTHAL-2',
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
    WHERE p.barcode = 'RANTHAL-2' 
       OR (p.slug = 'ranthal-2-small-ranthal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #436: RANTHAL-1
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
  'RANTHAL-1',
  'ranthal-1-big-ranthal',
  'Big ranthal',
  'Big ranthal',
  'RANTHAL-1',
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
    WHERE p.barcode = 'RANTHAL-1' 
       OR (p.slug = 'ranthal-1-big-ranthal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #437: KUTTA-8
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
  'KUTTA-8',
  'kutta-8-kutta-for-pookari',
  'Kutta for pookari',
  'Kutta for pookari',
  'KUTTA-8',
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
    WHERE p.barcode = 'KUTTA-8' 
       OR (p.slug = 'kutta-8-kutta-for-pookari' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #438: KUTTA-7
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
  'KUTTA-7',
  'kutta-7-kutta-with-cover-lid',
  'Kutta with cover lid',
  'Kutta with cover lid',
  'KUTTA-7',
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
    WHERE p.barcode = 'KUTTA-7' 
       OR (p.slug = 'kutta-7-kutta-with-cover-lid' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #439: CROWN-45
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
  'CROWN-45',
  'crown-45-back-cardboard-simple',
  'B;ack cardboard simple',
  'B;ack cardboard simple',
  'CROWN-45',
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
    WHERE p.barcode = 'CROWN-45' 
       OR (p.slug = 'crown-45-back-cardboard-simple' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #440: CROWN-44
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
  'CROWN-44',
  'crown-44-yellow-red-rain-drop-arch',
  'Yellow red rain drop arch',
  'Yellow red rain drop arch',
  'CROWN-44',
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
    WHERE p.barcode = 'CROWN-44' 
       OR (p.slug = 'crown-44-yellow-red-rain-drop-arch' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #441: CROWN-43
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
  'CROWN-43',
  'crown-43-sponge-centre-crownthick-yellow-stone',
  'Sponge centre crown/thick yellow stone',
  'Sponge centre crown/thick yellow stone',
  'CROWN-43',
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
    WHERE p.barcode = 'CROWN-43' 
       OR (p.slug = 'crown-43-sponge-centre-crownthick-yellow-stone' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #442: CROWN-42
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
  'CROWN-42',
  'crown-42-white-pearl-blue-rain-drop',
  'White pearl blue rain drop',
  'White pearl blue rain drop',
  'CROWN-42',
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
    WHERE p.barcode = 'CROWN-42' 
       OR (p.slug = 'crown-42-white-pearl-blue-rain-drop' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #443: CROWN-41
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
  'CROWN-41',
  'crown-41-white-stone-blue-green-beeds',
  'White stone/ blue green beeds',
  'White stone/ blue green beeds',
  'CROWN-41',
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
    WHERE p.barcode = 'CROWN-41' 
       OR (p.slug = 'crown-41-white-stone-blue-green-beeds' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #444: CROWN-40
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
  'CROWN-40',
  'crown-40-silver-kudam-type',
  'Silver kudam type',
  'Silver kudam type',
  'CROWN-40',
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
    WHERE p.barcode = 'CROWN-40' 
       OR (p.slug = 'crown-40-silver-kudam-type' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #445: CROWN-39
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
  'CROWN-39',
  'crown-39-white-pearlgreen-raindrop-round',
  'White pearl/green raindrop round',
  'White pearl/green raindrop round',
  'CROWN-39',
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
    WHERE p.barcode = 'CROWN-39' 
       OR (p.slug = 'crown-39-white-pearlgreen-raindrop-round' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #446: CROWN-38
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
  'CROWN-38',
  'crown-38-white-stone-with-red-raindrop',
  'White stone with red raindrop',
  'White stone with red raindrop',
  'CROWN-38',
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
    WHERE p.barcode = 'CROWN-38' 
       OR (p.slug = 'crown-38-white-stone-with-red-raindrop' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #447: CROWN-37
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
  'CROWN-37',
  'crown-37-ravana-crown',
  'Ravana Crown',
  'Ravana Crown',
  'CROWN-37',
  350.00,
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
    WHERE p.barcode = 'CROWN-37' 
       OR (p.slug = 'crown-37-ravana-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #448: STICK-6
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
  'STICK-6',
  'stick-6-dhandiya-stick',
  'Dhandiya Stick',
  'Dhandiya Stick',
  'STICK-6',
  30.00,
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
    WHERE p.barcode = 'STICK-6' 
       OR (p.slug = 'stick-6-dhandiya-stick' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #449: CUTOUT-3
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
  'CUTOUT-3',
  'cutout-3-lion',
  'Lion',
  'Lion',
  'CUTOUT-3',
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
    WHERE p.barcode = 'CUTOUT-3' 
       OR (p.slug = 'cutout-3-lion' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #450: CUTOUT-2
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
  'CUTOUT-2',
  'cutout-2-kaala',
  'Kaala',
  'Kaala',
  'CUTOUT-2',
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
    WHERE p.barcode = 'CUTOUT-2' 
       OR (p.slug = 'cutout-2-kaala' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #451: CUTOUT-1
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
  'CUTOUT-1',
  'cutout-1-elephant-front-view',
  'Elephant front view',
  'Elephant front view',
  'CUTOUT-1',
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
    WHERE p.barcode = 'CUTOUT-1' 
       OR (p.slug = 'cutout-1-elephant-front-view' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #452: CHARKA-1
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
  'CHARKA-1',
  'charka-1-charka',
  'Charka',
  'Charka',
  'CHARKA-1',
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
    WHERE p.barcode = 'CHARKA-1' 
       OR (p.slug = 'charka-1-charka' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #453: KAVADI-4
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
  'KAVADI-4',
  'kavadi-4-new-thrishur-kavadi',
  'New Thrishur Kavadi',
  'New Thrishur Kavadi',
  'KAVADI-4',
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
    WHERE p.barcode = 'KAVADI-4' 
       OR (p.slug = 'kavadi-4-new-thrishur-kavadi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #454: POOKOODA-4
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
  'POOKOODA-4',
  'pookooda-4-bamboo-pookooda',
  'Bamboo pookooda',
  'Bamboo pookooda',
  'POOKOODA-4',
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
    WHERE p.barcode = 'POOKOODA-4' 
       OR (p.slug = 'pookooda-4-bamboo-pookooda' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #455: POOKOODA-3
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
  'POOKOODA-3',
  'pookooda-3-black-wire',
  'Black wire',
  'Black wire',
  'POOKOODA-3',
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
    WHERE p.barcode = 'POOKOODA-3' 
       OR (p.slug = 'pookooda-3-black-wire' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #456: POOKOODA-2
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
  'POOKOODA-2',
  'pookooda-2-light-weight-oval',
  'Light weight Oval',
  'Light weight Oval',
  'POOKOODA-2',
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
    WHERE p.barcode = 'POOKOODA-2' 
       OR (p.slug = 'pookooda-2-light-weight-oval' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #457: KUDAM-4
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
  'KUDAM-4',
  'kudam-4-red-black-velvet-kudam',
  'Red black velvet kudam',
  'Red black velvet kudam',
  'KUDAM-4',
  150.00,
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
    WHERE p.barcode = 'KUDAM-4' 
       OR (p.slug = 'kudam-4-red-black-velvet-kudam' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #458: POMSTICK-3
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
  'POMSTICK-3',
  'pomstick-3-majenta-green-blue-red-mix',
  'Majenta green blue red mix',
  'Majenta green blue red mix',
  'POMSTICK-3',
  30.00,
  0.00,
  38,
  38,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'POMSTICK-3' 
       OR (p.slug = 'pomstick-3-majenta-green-blue-red-mix' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #459: POMSTICK-2
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
  'POMSTICK-2',
  'pomstick-2-silver',
  'Silver',
  'Silver',
  'POMSTICK-2',
  30.00,
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
    WHERE p.barcode = 'POMSTICK-2' 
       OR (p.slug = 'pomstick-2-silver' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #460: POMSTICK-1
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
  'POMSTICK-1',
  'pomstick-1-gold',
  'Gold',
  'Gold',
  'POMSTICK-1',
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
    WHERE p.barcode = 'POMSTICK-1' 
       OR (p.slug = 'pomstick-1-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #461: MASK-10
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
  'MASK-10',
  'mask-10-narasimham-mask',
  'Narasimham Mask',
  'Narasimham Mask',
  'MASK-10',
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
    WHERE p.barcode = 'MASK-10' 
       OR (p.slug = 'mask-10-narasimham-mask' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #462: MASK-9
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
  'MASK-9',
  'mask-9-halloween-mask',
  'Halloween Mask',
  'Halloween Mask',
  'MASK-9',
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
    WHERE p.barcode = 'MASK-9' 
       OR (p.slug = 'mask-9-halloween-mask' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #463: VEENA-4
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
  'VEENA-4',
  'veena-4-light-weight-veena',
  'Light weight veena',
  'Light weight veena',
  'VEENA-4',
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
    WHERE p.barcode = 'VEENA-4' 
       OR (p.slug = 'veena-4-light-weight-veena' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #464: BUTTERFLY-3
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
  'BUTTERFLY-3',
  'butterfly-3-butterfly-wings-pink',
  'Butterfly wings Pink',
  'Butterfly wings Pink',
  'BUTTERFLY-3',
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
    WHERE p.barcode = 'BUTTERFLY-3' 
       OR (p.slug = 'butterfly-3-butterfly-wings-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #465: BUTTERFLY-2
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
  'BUTTERFLY-2',
  'butterfly-2-butterfly-wings-white',
  'Butterfly wings white',
  'Butterfly wings white',
  'BUTTERFLY-2',
  30.00,
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
    WHERE p.barcode = 'BUTTERFLY-2' 
       OR (p.slug = 'butterfly-2-butterfly-wings-white' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #466: CROWN-36
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
  'CROWN-36',
  'crown-36-new-krishna-stone-kettu-crown',
  'New Krishna stone kettu crown',
  'New Krishna stone kettu crown',
  'CROWN-36',
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
    WHERE p.barcode = 'CROWN-36' 
       OR (p.slug = 'crown-36-new-krishna-stone-kettu-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #467: CROWN-35
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
  'CROWN-35',
  'crown-35-swathi-thirunal-crown',
  'Swathi Thirunal crown',
  'Swathi Thirunal crown',
  'CROWN-35',
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
    WHERE p.barcode = 'CROWN-35' 
       OR (p.slug = 'crown-35-swathi-thirunal-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #468: CROWN-34
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
  'CROWN-34',
  'crown-34-mayilpeeli-crown',
  'Mayilpeeli crown',
  'Mayilpeeli crown',
  'CROWN-34',
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
    WHERE p.barcode = 'CROWN-34' 
       OR (p.slug = 'crown-34-mayilpeeli-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #469: CROWN-33
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
  'CROWN-33',
  'crown-33-black-velvet-5-kombu-crown',
  'Black velvet 5 kombu crown',
  'Black velvet 5 kombu crown',
  'CROWN-33',
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
    WHERE p.barcode = 'CROWN-33' 
       OR (p.slug = 'crown-33-black-velvet-5-kombu-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #470: CROWN-32
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
  'CROWN-32',
  'crown-32-gandharva-crown',
  'Gandharva crown',
  'Gandharva crown',
  'CROWN-32',
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
    WHERE p.barcode = 'CROWN-32' 
       OR (p.slug = 'crown-32-gandharva-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #471: CROSS-1
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
  'CROSS-1',
  'cross-1-kurishu-big',
  'Kurishu big',
  'Kurishu big',
  'CROSS-1',
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
    WHERE p.barcode = 'CROSS-1' 
       OR (p.slug = 'cross-1-kurishu-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #472: HANDBELT-1
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
  'HANDBELT-1',
  'handbelt-1-handbelt',
  'Handbelt',
  'Handbelt',
  'HANDBELT-1',
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
    WHERE p.barcode = 'HANDBELT-1' 
       OR (p.slug = 'handbelt-1-handbelt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #473: SKULLMALA-1
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
  'SKULLMALA-1',
  'skullmala-1-thalayotti-mala',
  'Thalayotti mala',
  'Thalayotti mala',
  'SKULLMALA-1',
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
    WHERE p.barcode = 'SKULLMALA-1' 
       OR (p.slug = 'skullmala-1-thalayotti-mala' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #474: KAVADI-3
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
  'KAVADI-3',
  'kavadi-3-velvet-strong-kavadi',
  'Velvet strong Kavadi',
  'Velvet strong Kavadi',
  'KAVADI-3',
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
    WHERE p.barcode = 'KAVADI-3' 
       OR (p.slug = 'kavadi-3-velvet-strong-kavadi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #475: KAVADI-2
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
  'KAVADI-2',
  'kavadi-2-velvet-kavadi',
  'Velvet kavadi',
  'Velvet kavadi',
  'KAVADI-2',
  150.00,
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
    WHERE p.barcode = 'KAVADI-2' 
       OR (p.slug = 'kavadi-2-velvet-kavadi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #476: KAVADI-1
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
  'KAVADI-1',
  'kavadi-1-small-kavadi-cardboard',
  'Small kavadi cardboard',
  'Small kavadi cardboard',
  'KAVADI-1',
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
    WHERE p.barcode = 'KAVADI-1' 
       OR (p.slug = 'kavadi-1-small-kavadi-cardboard' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #477: POOKOODA-1
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
  'POOKOODA-1',
  'pookooda-1-brass-pookooda-with-handle',
  'Brass pookooda with handle',
  'Brass pookooda with handle',
  'POOKOODA-1',
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
    WHERE p.barcode = 'POOKOODA-1' 
       OR (p.slug = 'pookooda-1-brass-pookooda-with-handle' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #478: DAMARU-2
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
  'DAMARU-2',
  'damaru-2-big-damaru',
  'Big Damaru',
  'Big Damaru',
  'DAMARU-2',
  50.00,
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
    WHERE p.barcode = 'DAMARU-2' 
       OR (p.slug = 'damaru-2-big-damaru' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #479: DAMARU-1
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
  'DAMARU-1',
  'damaru-1-small-damaru',
  'Small damaru',
  'Small damaru',
  'DAMARU-1',
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
    WHERE p.barcode = 'DAMARU-1' 
       OR (p.slug = 'damaru-1-small-damaru' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #480: MADHALAM-1
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
  'MADHALAM-1',
  'madhalam-1-madhalam',
  'Madhalam',
  'Madhalam',
  'MADHALAM-1',
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
    WHERE p.barcode = 'MADHALAM-1' 
       OR (p.slug = 'madhalam-1-madhalam' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #481: CHENDA-1
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
  'CHENDA-1',
  'chenda-1-chenda',
  'Chenda',
  'Chenda',
  'CHENDA-1',
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
    WHERE p.barcode = 'CHENDA-1' 
       OR (p.slug = 'chenda-1-chenda' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #482: KOMBU-1
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
  'KOMBU-1',
  'kombu-1-kombu-musical-instrument',
  'Kombu musical instrument',
  'Kombu musical instrument',
  'KOMBU-1',
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
    WHERE p.barcode = 'KOMBU-1' 
       OR (p.slug = 'kombu-1-kombu-musical-instrument' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #483: VEENA-3
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
  'VEENA-3',
  'veena-3-pullor-kudam-veena-big',
  'Pullor kudam veena big',
  'Pullor kudam veena big',
  'VEENA-3',
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
    WHERE p.barcode = 'VEENA-3' 
       OR (p.slug = 'veena-3-pullor-kudam-veena-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #484: VEENA-2
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
  'VEENA-2',
  'veena-2-original-veena',
  'Original veena',
  'Original veena',
  'VEENA-2',
  840.00,
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
    WHERE p.barcode = 'VEENA-2' 
       OR (p.slug = 'veena-2-original-veena' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #485: VEENA-1
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
  'VEENA-1',
  'veena-1-pullor-veena',
  'Pullor veena',
  'Pullor veena',
  'VEENA-1',
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
    WHERE p.barcode = 'VEENA-1' 
       OR (p.slug = 'veena-1-pullor-veena' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #486: DUFF-1
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
  'DUFF-1',
  'duff-1-duff',
  'Duff',
  'Duff',
  'DUFF-1',
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
    WHERE p.barcode = 'DUFF-1' 
       OR (p.slug = 'duff-1-duff' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #487: FLAME-1
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
  'FLAME-1',
  'flame-1-flame-cutout-to-hold',
  'Flame cutout to hold',
  'Flame cutout to hold',
  'FLAME-1',
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
    WHERE p.barcode = 'FLAME-1' 
       OR (p.slug = 'flame-1-flame-cutout-to-hold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #488: LAMP-1
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
  'LAMP-1',
  'lamp-1-alladin-lamp',
  'Alladin lamp',
  'Alladin lamp',
  'LAMP-1',
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
    WHERE p.barcode = 'LAMP-1' 
       OR (p.slug = 'lamp-1-alladin-lamp' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #489: KUDAM-3
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
  'KUDAM-3',
  'kudam-3-karakatta-kudam',
  'Karakatta kudam',
  'Karakatta kudam',
  'KUDAM-3',
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
    WHERE p.barcode = 'KUDAM-3' 
       OR (p.slug = 'kudam-3-karakatta-kudam' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #490: KUDAM-2
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
  'KUDAM-2',
  'kudam-2-velvet-kudam-big',
  'Velvet kudam big',
  'Velvet kudam big',
  'KUDAM-2',
  175.00,
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
    WHERE p.barcode = 'KUDAM-2' 
       OR (p.slug = 'kudam-2-velvet-kudam-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #491: KUDAM-1
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
  'KUDAM-1',
  'kudam-1-brown-painted-small-kudam',
  'Brown painted small kudam',
  'Brown painted small kudam',
  'KUDAM-1',
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
    WHERE p.barcode = 'KUDAM-1' 
       OR (p.slug = 'kudam-1-brown-painted-small-kudam' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #492: VENCHA-2
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
  'VENCHA-2',
  'vencha-2-venchamaram-small',
  'Venchamaram small',
  'Venchamaram small',
  'VENCHA-2',
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
    WHERE p.barcode = 'VENCHA-2' 
       OR (p.slug = 'vencha-2-venchamaram-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #493: VENCHA-1
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
  'VENCHA-1',
  'vencha-1-venchamaram-big',
  'Venchamaram big',
  'Venchamaram big',
  'VENCHA-1',
  220.00,
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
    WHERE p.barcode = 'VENCHA-1' 
       OR (p.slug = 'vencha-1-venchamaram-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #494: MURAM-3
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
  'MURAM-3',
  'muram-3-square-muram',
  'Square muram',
  'Square muram',
  'MURAM-3',
  50.00,
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
    WHERE p.barcode = 'MURAM-3' 
       OR (p.slug = 'muram-3-square-muram' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #495: MURAM-2
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
  'MURAM-2',
  'muram-2-painted-muram',
  'Painted muram',
  'Painted muram',
  'MURAM-2',
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
    WHERE p.barcode = 'MURAM-2' 
       OR (p.slug = 'muram-2-painted-muram' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #496: MURAM-1
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
  'MURAM-1',
  'muram-1-normal-muram',
  'Normal muram',
  'Normal muram',
  'MURAM-1',
  50.00,
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
    WHERE p.barcode = 'MURAM-1' 
       OR (p.slug = 'muram-1-normal-muram' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #497: HEAD-1
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
  'HEAD-1',
  'head-1-asuran-thala',
  'Asuran thala',
  'Asuran thala',
  'HEAD-1',
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
    WHERE p.barcode = 'HEAD-1' 
       OR (p.slug = 'head-1-asuran-thala' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #498: VELAKALISET-1
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
  'VELAKALISET-1',
  'velakaliset-1-paricha-kambukaikettuscarfshawl',
  'Paricha kambu,kaikettu,scarf,shawl',
  'Paricha kambu,kaikettu,scarf,shawl',
  'VELAKALISET-1',
  200.00,
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
    WHERE p.barcode = 'VELAKALISET-1' 
       OR (p.slug = 'velakaliset-1-paricha-kambukaikettuscarfshawl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #499: GADHA-2
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
  'GADHA-2',
  'gadha-2-gadha-big',
  'Gadha big',
  'Gadha big',
  'GADHA-2',
  220.00,
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
    WHERE p.barcode = 'GADHA-2' 
       OR (p.slug = 'gadha-2-gadha-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #500: GADHA-1
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
  'GADHA-1',
  'gadha-1-gadha-small',
  'Gadha small',
  'Gadha small',
  'GADHA-1',
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
    WHERE p.barcode = 'GADHA-1' 
       OR (p.slug = 'gadha-1-gadha-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;


-- ════════════════════════════════════════════════════════════════════════════
-- GENERATE PRODUCT INVENTORY MAPPINGS FOR PART 1
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
