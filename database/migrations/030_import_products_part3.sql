-- ============================================================================
-- Migration 030: Import Next 500 Products from CSV (product02csv.csv) - Part 3
-- Purpose:   Inserts categories and the next 500 products (rows 1001 to 1500)
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
-- INSERT NEXT 500 PRODUCTS (1001 to 1500)
-- ════════════════════════════════════════════════════════════════════════════

-- Product #1001: KAMMAL-18
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
  'KAMMAL-18',
  'kammal-18-gold-jimikki-pearl-hanging-kammal',
  'Gold jimikki pearl hanging kammal',
  'Gold jimikki pearl hanging kammal',
  'KAMMAL-18',
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
    WHERE p.barcode = 'KAMMAL-18' 
       OR (p.slug = 'kammal-18-gold-jimikki-pearl-hanging-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1002: KAMMAL-17
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
  'KAMMAL-17',
  'kammal-17-very-big-gold-jimikki-pearl-hangimg-kammal',
  'Very big gold jimikki pearl hangimg kammal',
  'Very big gold jimikki pearl hangimg kammal',
  'KAMMAL-17',
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
    WHERE p.barcode = 'KAMMAL-17' 
       OR (p.slug = 'kammal-17-very-big-gold-jimikki-pearl-hangimg-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1003: KAMMAL-16
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
  'KAMMAL-16',
  'kammal-16-full-white-flower-kammal',
  'Full white flower kammal',
  'Full white flower kammal',
  'KAMMAL-16',
  60.00,
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
    WHERE p.barcode = 'KAMMAL-16' 
       OR (p.slug = 'kammal-16-full-white-flower-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1004: KAMMAL-15
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
  'KAMMAL-15',
  'kammal-15-pearl-white-stone-merroon-stud-kammal',
  'Pearl white stone merroon stud kammal',
  'Pearl white stone merroon stud kammal',
  'KAMMAL-15',
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
    WHERE p.barcode = 'KAMMAL-15' 
       OR (p.slug = 'kammal-15-pearl-white-stone-merroon-stud-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1005: KAMMAL-14
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
  'KAMMAL-14',
  'kammal-14-gold-very-big-flower-stud-kammal',
  'Gold very big flower stud kammal',
  'Gold very big flower stud kammal',
  'KAMMAL-14',
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
    WHERE p.barcode = 'KAMMAL-14' 
       OR (p.slug = 'kammal-14-gold-very-big-flower-stud-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1006: KAMMAL-13
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
  'KAMMAL-13',
  'kammal-13-gold-small-jimikki-kammal',
  'Gold small jimikki kammal',
  'Gold small jimikki kammal',
  'KAMMAL-13',
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
    WHERE p.barcode = 'KAMMAL-13' 
       OR (p.slug = 'kammal-13-gold-small-jimikki-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1007: KAMMAL-12
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
  'KAMMAL-12',
  'kammal-12-thoda-small-kammal',
  'Thoda small kammal',
  'Thoda small kammal',
  'KAMMAL-12',
  20.00,
  0.00,
  80,
  80,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KAMMAL-12' 
       OR (p.slug = 'kammal-12-thoda-small-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1008: KAMMAL-11
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
  'KAMMAL-11',
  'kammal-11-antique-jimikki-lekshmi-stud-kammal',
  'Antique jimikki lekshmi stud kammal',
  'Antique jimikki lekshmi stud kammal',
  'KAMMAL-11',
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
    WHERE p.barcode = 'KAMMAL-11' 
       OR (p.slug = 'kammal-11-antique-jimikki-lekshmi-stud-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1009: KAMMAL-10
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
  'KAMMAL-10',
  'kammal-10-gold-heavy-hanging-with-jimikki-kammal',
  'Gold heavy hanging with jimikki kammal',
  'Gold heavy hanging with jimikki kammal',
  'KAMMAL-10',
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
    WHERE p.barcode = 'KAMMAL-10' 
       OR (p.slug = 'kammal-10-gold-heavy-hanging-with-jimikki-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1010: KAMMAL-9
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
  'KAMMAL-9',
  'kammal-9-white-stone-big-stid-kammal',
  'White stone big stid kammal',
  'White stone big stid kammal',
  'KAMMAL-9',
  70.00,
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
    WHERE p.barcode = 'KAMMAL-9' 
       OR (p.slug = 'kammal-9-white-stone-big-stid-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1011: KAMMAL-8
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
  'KAMMAL-8',
  'kammal-8-green-palakka-kammal',
  'Green palakka kammal',
  'Green palakka kammal',
  'KAMMAL-8',
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
    WHERE p.barcode = 'KAMMAL-8' 
       OR (p.slug = 'kammal-8-green-palakka-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1012: KAMMAL-7
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
  'KAMMAL-7',
  'kammal-7-temple-jimikki-big-kammal',
  'Temple jimikki big kammal',
  'Temple jimikki big kammal',
  'KAMMAL-7',
  125.00,
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
    WHERE p.barcode = 'KAMMAL-7' 
       OR (p.slug = 'kammal-7-temple-jimikki-big-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1013: KAMMAL-6
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
  'KAMMAL-6',
  'kammal-6-temple-jimikki-medium-kammal',
  'Temple jimikki medium kammal',
  'Temple jimikki medium kammal',
  'KAMMAL-6',
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
    WHERE p.barcode = 'KAMMAL-6' 
       OR (p.slug = 'kammal-6-temple-jimikki-medium-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1014: KAMMAL-5
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
  'KAMMAL-5',
  'kammal-5-gold-big-hanging-kammal',
  'Gold big hanging Kammal',
  'Gold big hanging Kammal',
  'KAMMAL-5',
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
    WHERE p.barcode = 'KAMMAL-5' 
       OR (p.slug = 'kammal-5-gold-big-hanging-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1015: KAMMAL-4
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
  'KAMMAL-4',
  'kammal-4-antique-jimikki-majenta-stone-pearl-hanging-kammal',
  'Antique Jimikki Majenta stone Pearl Hanging Kammal',
  'Antique Jimikki Majenta stone Pearl Hanging Kammal',
  'KAMMAL-4',
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
    WHERE p.barcode = 'KAMMAL-4' 
       OR (p.slug = 'kammal-4-antique-jimikki-majenta-stone-pearl-hanging-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1016: KAMMAL-3
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
  'KAMMAL-3',
  'kammal-3-gold-small-jimikki-pearl-hanging-kammal',
  'Gold small Jimikki Pearl hanging Kammal',
  'Gold small Jimikki Pearl hanging Kammal',
  'KAMMAL-3',
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
    WHERE p.barcode = 'KAMMAL-3' 
       OR (p.slug = 'kammal-3-gold-small-jimikki-pearl-hanging-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1017: KAMMAL-2
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
  'KAMMAL-2',
  'kammal-2-antique-jimikki-kammal',
  'Antique Jimikki Kammal',
  'Antique Jimikki Kammal',
  'KAMMAL-2',
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
    WHERE p.barcode = 'KAMMAL-2' 
       OR (p.slug = 'kammal-2-antique-jimikki-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1018: KAMMAL-1
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
  'KAMMAL-1',
  'kammal-1-goldwhite-pearl-very-heavy-ear-ring-kammal',
  'Gold/White Pearl very heavy ear ring Kammal',
  'Gold/White Pearl very heavy ear ring Kammal',
  'KAMMAL-1',
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
    WHERE p.barcode = 'KAMMAL-1' 
       OR (p.slug = 'kammal-1-goldwhite-pearl-very-heavy-ear-ring-kammal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1019: NECK-88
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
  'NECK-88',
  'neck-88-pichi-necklace',
  'Pichi necklace',
  'Pichi necklace',
  'NECK-88',
  80.00,
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
    WHERE p.barcode = 'NECK-88' 
       OR (p.slug = 'neck-88-pichi-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1020: NECK-87
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
  'NECK-87',
  'neck-87-green-palakka-necklace',
  'Green palakka necklace',
  'Green palakka necklace',
  'NECK-87',
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
    WHERE p.barcode = 'NECK-87' 
       OR (p.slug = 'neck-87-green-palakka-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1021: NECK-86
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
  'NECK-86',
  'neck-86-red-mango-pinch-necklace',
  'Red mango pinch necklace',
  'Red mango pinch necklace',
  'NECK-86',
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
    WHERE p.barcode = 'NECK-86' 
       OR (p.slug = 'neck-86-red-mango-pinch-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1022: NECK-85
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
  'NECK-85',
  'neck-85-elakathali-v-necklace',
  'Elakathali V necklace',
  'Elakathali V necklace',
  'NECK-85',
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
    WHERE p.barcode = 'NECK-85' 
       OR (p.slug = 'neck-85-elakathali-v-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1023: NECK-84
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
  'NECK-84',
  'neck-84-elakathali-nice-necklace',
  'Elakathali nice necklace',
  'Elakathali nice necklace',
  'NECK-84',
  70.00,
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
    WHERE p.barcode = 'NECK-84' 
       OR (p.slug = 'neck-84-elakathali-nice-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1024: NECK-83
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
  'NECK-83',
  'neck-83-white-stone-bh-necklace',
  'White stone BH necklace',
  'White stone BH necklace',
  'NECK-83',
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
    WHERE p.barcode = 'NECK-83' 
       OR (p.slug = 'neck-83-white-stone-bh-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1025: NECK-82
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
  'NECK-82',
  'neck-82-choker-vangi-necklace',
  'Choker vangi necklace',
  'Choker vangi necklace',
  'NECK-82',
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
    WHERE p.barcode = 'NECK-82' 
       OR (p.slug = 'neck-82-choker-vangi-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1026: NECK-81
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
  'NECK-81',
  'neck-81-gold-simple-choker-necklace',
  'Gold simple choker necklace',
  'Gold simple choker necklace',
  'NECK-81',
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
    WHERE p.barcode = 'NECK-81' 
       OR (p.slug = 'neck-81-gold-simple-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1027: NECK-80
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
  'NECK-80',
  'neck-80-gold-choker-with-flower-locket-necklace',
  'Gold choker with flower locket necklace',
  'Gold choker with flower locket necklace',
  'NECK-80',
  70.00,
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
    WHERE p.barcode = 'NECK-80' 
       OR (p.slug = 'neck-80-gold-choker-with-flower-locket-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1028: NECK-79
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
  'NECK-79',
  'neck-79-green-white-round-design-necklace',
  'Green white round design necklace',
  'Green white round design necklace',
  'NECK-79',
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
    WHERE p.barcode = 'NECK-79' 
       OR (p.slug = 'neck-79-green-white-round-design-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1029: NECK-78
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
  'NECK-78',
  'neck-78-kolusu-model-necklace',
  'Kolusu model necklace',
  'Kolusu model necklace',
  'NECK-78',
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
    WHERE p.barcode = 'NECK-78' 
       OR (p.slug = 'neck-78-kolusu-model-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1030: NECK-77
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
  'NECK-77',
  'neck-77-white-pearl-4-layer-necklace',
  'White pearl 4 layer necklace',
  'White pearl 4 layer necklace',
  'NECK-77',
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
    WHERE p.barcode = 'NECK-77' 
       OR (p.slug = 'neck-77-white-pearl-4-layer-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1031: NECK-76
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
  'NECK-76',
  'neck-76-gold-chain-with-lekshmi-locket-necklace',
  'Gold chain with lekshmi locket necklace',
  'Gold chain with lekshmi locket necklace',
  'NECK-76',
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
    WHERE p.barcode = 'NECK-76' 
       OR (p.slug = 'neck-76-gold-chain-with-lekshmi-locket-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1032: NECK-75
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
  'NECK-75',
  'neck-75-gold-chain-with-locket-and-bead-necklace',
  'Gold chain with locket and bead necklace',
  'Gold chain with locket and bead necklace',
  'NECK-75',
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
    WHERE p.barcode = 'NECK-75' 
       OR (p.slug = 'neck-75-gold-chain-with-locket-and-bead-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1033: NECK-74
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
  'NECK-74',
  'neck-74-white-bead-necklace',
  'White bead necklace',
  'White bead necklace',
  'NECK-74',
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
    WHERE p.barcode = 'NECK-74' 
       OR (p.slug = 'neck-74-white-bead-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1034: NECK-73
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
  'NECK-73',
  'neck-73-green-mango-pinchu-necklace',
  'Green mango pinchu necklace',
  'Green mango pinchu necklace',
  'NECK-73',
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
    WHERE p.barcode = 'NECK-73' 
       OR (p.slug = 'neck-73-green-mango-pinchu-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1035: NECK-72
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
  'NECK-72',
  'neck-72-gold-shoolam-design-necklace',
  'Gold shoolam design necklace',
  'Gold shoolam design necklace',
  'NECK-72',
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
    WHERE p.barcode = 'NECK-72' 
       OR (p.slug = 'neck-72-gold-shoolam-design-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1036: NECK-71
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
  'NECK-71',
  'neck-71-gold-chain-with-locket-necklace',
  'Gold chain with locket necklace',
  'Gold chain with locket necklace',
  'NECK-71',
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
    WHERE p.barcode = 'NECK-71' 
       OR (p.slug = 'neck-71-gold-chain-with-locket-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1037: NECK-70
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
  'NECK-70',
  'neck-70-mango-small-white-stone',
  'Mango small white stone',
  'Mango small white stone',
  'NECK-70',
  60.00,
  0.00,
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
    WHERE p.barcode = 'NECK-70' 
       OR (p.slug = 'neck-70-mango-small-white-stone' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1038: NECK-69
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
  'NECK-69',
  'neck-69-white-stone-3-layer-necklace',
  'White stone 3 layer necklace',
  'White stone 3 layer necklace',
  'NECK-69',
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
    WHERE p.barcode = 'NECK-69' 
       OR (p.slug = 'neck-69-white-stone-3-layer-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1039: NECK-68
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
  'NECK-68',
  'neck-68-majenta-stone-necklace',
  'Majenta stone necklace',
  'Majenta stone necklace',
  'NECK-68',
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
    WHERE p.barcode = 'NECK-68' 
       OR (p.slug = 'neck-68-majenta-stone-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1040: NECK-67
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
  'NECK-67',
  'neck-67-white-stone-3-layer-pearl-hanging-necklace',
  'White stone 3 layer pearl hanging necklace',
  'White stone 3 layer pearl hanging necklace',
  'NECK-67',
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
    WHERE p.barcode = 'NECK-67' 
       OR (p.slug = 'neck-67-white-stone-3-layer-pearl-hanging-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1041: NECK-66
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
  'NECK-66',
  'neck-66-white-stone-red-green-necklace',
  'White stone red green necklace',
  'White stone red green necklace',
  'NECK-66',
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
    WHERE p.barcode = 'NECK-66' 
       OR (p.slug = 'neck-66-white-stone-red-green-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1042: NECK-65
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
  'NECK-65',
  'neck-65-green-red-pearl-hanging-necklace',
  'Green red pearl hanging necklace',
  'Green red pearl hanging necklace',
  'NECK-65',
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
    WHERE p.barcode = 'NECK-65' 
       OR (p.slug = 'neck-65-green-red-pearl-hanging-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1043: NECK-64
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
  'NECK-64',
  'neck-64-majenta-green-necklace-beads-hanging',
  'Majenta green necklace beads hanging',
  'Majenta green necklace beads hanging',
  'NECK-64',
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
    WHERE p.barcode = 'NECK-64' 
       OR (p.slug = 'neck-64-majenta-green-necklace-beads-hanging' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1044: NECK-63
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
  'NECK-63',
  'neck-63-white-stone-necklace',
  'White stone necklace',
  'White stone necklace',
  'NECK-63',
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
    WHERE p.barcode = 'NECK-63' 
       OR (p.slug = 'neck-63-white-stone-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1045: NECK-62
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
  'NECK-62',
  'neck-62-red-palakka-necklace-with-locket',
  'Red palakka necklace with locket',
  'Red palakka necklace with locket',
  'NECK-62',
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
    WHERE p.barcode = 'NECK-62' 
       OR (p.slug = 'neck-62-red-palakka-necklace-with-locket' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1046: NECK-61
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
  'NECK-61',
  'neck-61-red-palakka-necklace',
  'Red palakka necklace',
  'Red palakka necklace',
  'NECK-61',
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
    WHERE p.barcode = 'NECK-61' 
       OR (p.slug = 'neck-61-red-palakka-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1047: NECK-60
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
  'NECK-60',
  'neck-60-red-white-green-stonenecklace',
  'Red white green stonenecklace',
  'Red white green stonenecklace',
  'NECK-60',
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
    WHERE p.barcode = 'NECK-60' 
       OR (p.slug = 'neck-60-red-white-green-stonenecklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1048: NECK-59
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
  'NECK-59',
  'neck-59-gold-stone-square-choker-necklace',
  'Gold stone square choker necklace',
  'Gold stone square choker necklace',
  'NECK-59',
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
    WHERE p.barcode = 'NECK-59' 
       OR (p.slug = 'neck-59-gold-stone-square-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1049: NECK-58
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
  'NECK-58',
  'neck-58-black-square-stone-choker-necklace',
  'Black square stone choker necklace',
  'Black square stone choker necklace',
  'NECK-58',
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
    WHERE p.barcode = 'NECK-58' 
       OR (p.slug = 'neck-58-black-square-stone-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1050: NECK-57
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
  'NECK-57',
  'neck-57-red-beads-round-necklace',
  'Red beads round necklace',
  'Red beads round necklace',
  'NECK-57',
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
    WHERE p.barcode = 'NECK-57' 
       OR (p.slug = 'neck-57-red-beads-round-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1051: NECK-56
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
  'NECK-56',
  'neck-56-gold-beads-hanging-necklace',
  'Gold beads hanging necklace',
  'Gold beads hanging necklace',
  'NECK-56',
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
    WHERE p.barcode = 'NECK-56' 
       OR (p.slug = 'neck-56-gold-beads-hanging-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1052: NECK-55
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
  'NECK-55',
  'neck-55-gold-round-design-necklace-with-locket',
  'Gold round design necklace with locket',
  'Gold round design necklace with locket',
  'NECK-55',
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
    WHERE p.barcode = 'NECK-55' 
       OR (p.slug = 'neck-55-gold-round-design-necklace-with-locket' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1053: NECK-54
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
  'NECK-54',
  'neck-54-gold-square-pendent-choker-necklace',
  'Gold square pendent choker necklace',
  'Gold square pendent choker necklace',
  'NECK-54',
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
    WHERE p.barcode = 'NECK-54' 
       OR (p.slug = 'neck-54-gold-square-pendent-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1054: NECK-53
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
  'NECK-53',
  'neck-53-gold-small-mango-pinch-necklace',
  'Gold small mango pinch necklace',
  'Gold small mango pinch necklace',
  'NECK-53',
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
    WHERE p.barcode = 'NECK-53' 
       OR (p.slug = 'neck-53-gold-small-mango-pinch-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1055: NECK-52
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
  'NECK-52',
  'neck-52-gold-choker-blue-stone-2-end-necklace',
  'Gold choker blue stone 2 end necklace',
  'Gold choker blue stone 2 end necklace',
  'NECK-52',
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
    WHERE p.barcode = 'NECK-52' 
       OR (p.slug = 'neck-52-gold-choker-blue-stone-2-end-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1056: NECK-51
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
  'NECK-51',
  'neck-51-gold-mango-pinch-necklace',
  'Gold mango pinch necklace',
  'Gold mango pinch necklace',
  'NECK-51',
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
    WHERE p.barcode = 'NECK-51' 
       OR (p.slug = 'neck-51-gold-mango-pinch-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1057: NECK-50
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
  'NECK-50',
  'neck-50-multi-colour-beads-simple-necklace',
  'Multi colour beads simple necklace',
  'Multi colour beads simple necklace',
  'NECK-50',
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
    WHERE p.barcode = 'NECK-50' 
       OR (p.slug = 'neck-50-multi-colour-beads-simple-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1058: NECK-49
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
  'NECK-49',
  'neck-49-broad-gold-stone-necklace',
  'Broad gold stone necklace',
  'Broad gold stone necklace',
  'NECK-49',
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
    WHERE p.barcode = 'NECK-49' 
       OR (p.slug = 'neck-49-broad-gold-stone-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1059: NECK-48
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
  'NECK-48',
  'neck-48-red-flower-necklace',
  'Red flower necklace',
  'Red flower necklace',
  'NECK-48',
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
    WHERE p.barcode = 'NECK-48' 
       OR (p.slug = 'neck-48-red-flower-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1060: NECK-47
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
  'NECK-47',
  'neck-47-green-red-flower-necklace',
  'Green red flower necklace',
  'Green red flower necklace',
  'NECK-47',
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
    WHERE p.barcode = 'NECK-47' 
       OR (p.slug = 'neck-47-green-red-flower-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1061: NECK-46
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
  'NECK-46',
  'neck-46-square-locket-choker-kammal-necklace',
  'Square locket choker kammal necklace',
  'Square locket choker kammal necklace',
  'NECK-46',
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
    WHERE p.barcode = 'NECK-46' 
       OR (p.slug = 'neck-46-square-locket-choker-kammal-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1062: NECK-45
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
  'NECK-45',
  'neck-45-mehandi-gold-veethi-necklace',
  'Mehandi gold veethi necklace',
  'Mehandi gold veethi necklace',
  'NECK-45',
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
    WHERE p.barcode = 'NECK-45' 
       OR (p.slug = 'neck-45-mehandi-gold-veethi-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1063: NECK-44
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
  'NECK-44',
  'neck-44-majenta-stonewhite-pearl-necklace',
  'Majenta stone/White pearl necklace',
  'Majenta stone/White pearl necklace',
  'NECK-44',
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
    WHERE p.barcode = 'NECK-44' 
       OR (p.slug = 'neck-44-majenta-stonewhite-pearl-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1064: NECK-43
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
  'NECK-43',
  'neck-43-green-stone-white-pearl-necklace',
  'Green stone white pearl necklace',
  'Green stone white pearl necklace',
  'NECK-43',
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
    WHERE p.barcode = 'NECK-43' 
       OR (p.slug = 'neck-43-green-stone-white-pearl-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1065: NECK-42
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
  'NECK-42',
  'neck-42-kaashu-necklace-with-red-pendent',
  'Kaashu necklace with red pendent',
  'Kaashu necklace with red pendent',
  'NECK-42',
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
    WHERE p.barcode = 'NECK-42' 
       OR (p.slug = 'neck-42-kaashu-necklace-with-red-pendent' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1066: NECK-41
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
  'NECK-41',
  'neck-41-white-green-red-stone-necklace',
  'White green red stone necklace',
  'White green red stone necklace',
  'NECK-41',
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
    WHERE p.barcode = 'NECK-41' 
       OR (p.slug = 'neck-41-white-green-red-stone-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1067: NECK-40
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
  'NECK-40',
  'neck-40-mehandi-gold-necklace-stud',
  'Mehandi gold Necklace stud',
  'Mehandi gold Necklace stud',
  'NECK-40',
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
    WHERE p.barcode = 'NECK-40' 
       OR (p.slug = 'neck-40-mehandi-gold-necklace-stud' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1068: NECK-39
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
  'NECK-39',
  'neck-39-whitegreen-heavy-choker-necklace',
  'White/Green heavy choker necklace',
  'White/Green heavy choker necklace',
  'NECK-39',
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
    WHERE p.barcode = 'NECK-39' 
       OR (p.slug = 'neck-39-whitegreen-heavy-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1069: NECK-38
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
  'NECK-38',
  'neck-38-majentawhite-stone-necklace-set',
  'Majenta/white stone necklace set',
  'Majenta/white stone necklace set',
  'NECK-38',
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
    WHERE p.barcode = 'NECK-38' 
       OR (p.slug = 'neck-38-majentawhite-stone-necklace-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1070: NECK-37
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
  'NECK-37',
  'neck-37-white-stone-necklace-pearl-hanging',
  'White stone necklace pearl hanging',
  'White stone necklace pearl hanging',
  'NECK-37',
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
    WHERE p.barcode = 'NECK-37' 
       OR (p.slug = 'neck-37-white-stone-necklace-pearl-hanging' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1071: NECK-36
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
  'NECK-36',
  'neck-36-flowergreen-red-stone-pearl-hanging-necklace',
  'Flowergreen red stone pearl hanging necklace',
  'Flowergreen red stone pearl hanging necklace',
  'NECK-36',
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
    WHERE p.barcode = 'NECK-36' 
       OR (p.slug = 'neck-36-flowergreen-red-stone-pearl-hanging-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1072: NECK-35
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
  'NECK-35',
  'neck-35-white-green-red-beads-hanging-choker-necklace',
  'White green red beads hanging choker necklace',
  'White green red beads hanging choker necklace',
  'NECK-35',
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
    WHERE p.barcode = 'NECK-35' 
       OR (p.slug = 'neck-35-white-green-red-beads-hanging-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1073: NECK-34
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
  'NECK-34',
  'neck-34-black-3-layer-choker-necklace',
  'Black 3 layer choker necklace',
  'Black 3 layer choker necklace',
  'NECK-34',
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
    WHERE p.barcode = 'NECK-34' 
       OR (p.slug = 'neck-34-black-3-layer-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1074: NECK-33
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
  'NECK-33',
  'neck-33-red-3-layer-beads-choker-necklace',
  'Red 3 layer beads choker necklace',
  'Red 3 layer beads choker necklace',
  'NECK-33',
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
    WHERE p.barcode = 'NECK-33' 
       OR (p.slug = 'neck-33-red-3-layer-beads-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1075: NECK-32
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
  'NECK-32',
  'neck-32-blue-beads-3-layer-choker-necklace',
  'Blue beads 3 layer choker necklace',
  'Blue beads 3 layer choker necklace',
  'NECK-32',
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
    WHERE p.barcode = 'NECK-32' 
       OR (p.slug = 'neck-32-blue-beads-3-layer-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1076: NECK-31
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
  'NECK-31',
  'neck-31-multi-big-square-stone-necklace',
  'Multi big square stone necklace',
  'Multi big square stone necklace',
  'NECK-31',
  60.00,
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
    WHERE p.barcode = 'NECK-31' 
       OR (p.slug = 'neck-31-multi-big-square-stone-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1077: NECK-30
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
  'NECK-30',
  'neck-30-white-big-stine-square-necklace',
  'White big stine square necklace',
  'White big stine square necklace',
  'NECK-30',
  60.00,
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
    WHERE p.barcode = 'NECK-30' 
       OR (p.slug = 'neck-30-white-big-stine-square-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1078: NECK-29
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
  'NECK-29',
  'neck-29-blue-palakka-necklace',
  'Blue Palakka Necklace',
  'Blue Palakka Necklace',
  'NECK-29',
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
    WHERE p.barcode = 'NECK-29' 
       OR (p.slug = 'neck-29-blue-palakka-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1079: NECK-28
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
  'NECK-28',
  'neck-28-temple-necklace',
  'Temple Necklace',
  'Temple Necklace',
  'NECK-28',
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
    WHERE p.barcode = 'NECK-28' 
       OR (p.slug = 'neck-28-temple-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1080: NECK-27
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
  'NECK-27',
  'neck-27-black-beads-kammal-necklace',
  'Black beads Kammal Necklace',
  'Black beads Kammal Necklace',
  'NECK-27',
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
    WHERE p.barcode = 'NECK-27' 
       OR (p.slug = 'neck-27-black-beads-kammal-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1081: NECK-26
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
  'NECK-26',
  'neck-26-temple-mango-necklace',
  'Temple Mango Necklace',
  'Temple Mango Necklace',
  'NECK-26',
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
    WHERE p.barcode = 'NECK-26' 
       OR (p.slug = 'neck-26-temple-mango-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1082: NECK-25
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
  'NECK-25',
  'neck-25-temple-3-pendent-necklace',
  'Temple 3 pendent Necklace',
  'Temple 3 pendent Necklace',
  'NECK-25',
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
    WHERE p.barcode = 'NECK-25' 
       OR (p.slug = 'neck-25-temple-3-pendent-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1083: NECK-24
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
  'NECK-24',
  'neck-24-blue-palakka-mango-pinch-necklace',
  'Blue Palakka Mango pinch Necklace',
  'Blue Palakka Mango pinch Necklace',
  'NECK-24',
  150.00,
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
    WHERE p.barcode = 'NECK-24' 
       OR (p.slug = 'neck-24-blue-palakka-mango-pinch-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1084: NECK-23
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
  'NECK-23',
  'neck-23-green-palakka-jimikki-necklace',
  'Green Palakka Jimikki Necklace',
  'Green Palakka Jimikki Necklace',
  'NECK-23',
  175.00,
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
    WHERE p.barcode = 'NECK-23' 
       OR (p.slug = 'neck-23-green-palakka-jimikki-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1085: NECK-22
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
  'NECK-22',
  'neck-22-gold-necklace-majenta-stone-hanging-necklace',
  'Gold necklace Majenta stone hanging Necklace',
  'Gold necklace Majenta stone hanging Necklace',
  'NECK-22',
  125.00,
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
    WHERE p.barcode = 'NECK-22' 
       OR (p.slug = 'neck-22-gold-necklace-majenta-stone-hanging-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1086: NECK-21
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
  'NECK-21',
  'neck-21-majenta-stone-gold-ball-hanging-necklace',
  'Majenta stone gold ball hanging Necklace',
  'Majenta stone gold ball hanging Necklace',
  'NECK-21',
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
    WHERE p.barcode = 'NECK-21' 
       OR (p.slug = 'neck-21-majenta-stone-gold-ball-hanging-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1087: NECK-20
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
  'NECK-20',
  'neck-20-black-stone-necklace',
  'Black stone Necklace',
  'Black stone Necklace',
  'NECK-20',
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
    WHERE p.barcode = 'NECK-20' 
       OR (p.slug = 'neck-20-black-stone-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1088: NECK-19
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
  'NECK-19',
  'neck-19-majenta-green-kunthan-necklace',
  'Majenta green Kunthan Necklace',
  'Majenta green Kunthan Necklace',
  'NECK-19',
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
    WHERE p.barcode = 'NECK-19' 
       OR (p.slug = 'neck-19-majenta-green-kunthan-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1089: NECK-18
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
  'NECK-18',
  'neck-18-majenta-kunthan-stone-necklace',
  'Majenta kunthan stone Necklace',
  'Majenta kunthan stone Necklace',
  'NECK-18',
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
    WHERE p.barcode = 'NECK-18' 
       OR (p.slug = 'neck-18-majenta-kunthan-stone-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1090: NECK-17
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
  'NECK-17',
  'neck-17-black-metal-multi-stone-necklace',
  'Black metal multi stone Necklace',
  'Black metal multi stone Necklace',
  'NECK-17',
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
    WHERE p.barcode = 'NECK-17' 
       OR (p.slug = 'neck-17-black-metal-multi-stone-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1091: NECK-16
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
  'NECK-16',
  'neck-16-black-metal-majentwhitegreen-necklace',
  'Black metal Majent/white/green Necklace',
  'Black metal Majent/white/green Necklace',
  'NECK-16',
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
    WHERE p.barcode = 'NECK-16' 
       OR (p.slug = 'neck-16-black-metal-majentwhitegreen-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1092: NECK-15
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
  'NECK-15',
  'neck-15-black-metal-choker-and-kammal-necklace',
  'Black metal choker and kammal Necklace',
  'Black metal choker and kammal Necklace',
  'NECK-15',
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
    WHERE p.barcode = 'NECK-15' 
       OR (p.slug = 'neck-15-black-metal-choker-and-kammal-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1093: NECK-14
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
  'NECK-14',
  'neck-14-gold-arumbu-necklace',
  'Gold Arumbu Necklace',
  'Gold Arumbu Necklace',
  'NECK-14',
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
    WHERE p.barcode = 'NECK-14' 
       OR (p.slug = 'neck-14-gold-arumbu-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1094: NECK-13
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
  'NECK-13',
  'neck-13-red-stone-kammal-necklace',
  'Red stone kammal Necklace',
  'Red stone kammal Necklace',
  'NECK-13',
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
    WHERE p.barcode = 'NECK-13' 
       OR (p.slug = 'neck-13-red-stone-kammal-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1095: NECK-12
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
  'NECK-12',
  'neck-12-3-layer-stone-kammal-necklace',
  '3 layer stone kammal Necklace',
  '3 layer stone kammal Necklace',
  'NECK-12',
  150.00,
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
    WHERE p.barcode = 'NECK-12' 
       OR (p.slug = 'neck-12-3-layer-stone-kammal-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1096: NECK-11
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
  'NECK-11',
  'neck-11-green-white-stone-kamma-lnecklace',
  'Green white stone kamma lNecklace',
  'Green white stone kamma lNecklace',
  'NECK-11',
  150.00,
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
    WHERE p.barcode = 'NECK-11' 
       OR (p.slug = 'neck-11-green-white-stone-kamma-lnecklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1097: NECK-10
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
  'NECK-10',
  'neck-10-green-kammal-necklace',
  'Green kammal Necklace',
  'Green kammal Necklace',
  'NECK-10',
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
    WHERE p.barcode = 'NECK-10' 
       OR (p.slug = 'neck-10-green-kammal-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1098: NECK-9
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
  'NECK-9',
  'neck-9-antique-blue-kammal-necklace',
  'Antique blue kammal Necklace',
  'Antique blue kammal Necklace',
  'NECK-9',
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
    WHERE p.barcode = 'NECK-9' 
       OR (p.slug = 'neck-9-antique-blue-kammal-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1099: NECK-8
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
  'NECK-8',
  'neck-8-red-beads-choker-kammal-necklace',
  'Red beads choker, Kammal Necklace',
  'Red beads choker, Kammal Necklace',
  'NECK-8',
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
    WHERE p.barcode = 'NECK-8' 
       OR (p.slug = 'neck-8-red-beads-choker-kammal-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1100: NECK-7
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
  'NECK-7',
  'neck-7-red-beads-choker-kammalchutti-necklace',
  'Red beads choker. Kammal,Chutti Necklace',
  'Red beads choker. Kammal,Chutti Necklace',
  'NECK-7',
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
    WHERE p.barcode = 'NECK-7' 
       OR (p.slug = 'neck-7-red-beads-choker-kammalchutti-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1101: NECK-6
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
  'NECK-6',
  'neck-6-gold-necklace-blue-stone-and-pearl-necklace',
  'Gold necklace blue stone and pearl Necklace',
  'Gold necklace blue stone and pearl Necklace',
  'NECK-6',
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
    WHERE p.barcode = 'NECK-6' 
       OR (p.slug = 'neck-6-gold-necklace-blue-stone-and-pearl-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1102: NECK-5
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
  'NECK-5',
  'neck-5-gold-necklaceblue-stone-necklace',
  'Gold necklace/Blue stone Necklace',
  'Gold necklace/Blue stone Necklace',
  'NECK-5',
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
    WHERE p.barcode = 'NECK-5' 
       OR (p.slug = 'neck-5-gold-necklaceblue-stone-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1103: NECK-4
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
  'NECK-4',
  'neck-4-white-kunthan-stone-heavy-choker-necklace',
  'White kunthan stone heavy choker Necklace',
  'White kunthan stone heavy choker Necklace',
  'NECK-4',
  220.00,
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
    WHERE p.barcode = 'NECK-4' 
       OR (p.slug = 'neck-4-white-kunthan-stone-heavy-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1104: NECK-3
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
  'NECK-3',
  'neck-3-black-thread-choker-new-necklace',
  'Black thread choker new Necklace',
  'Black thread choker new Necklace',
  'NECK-3',
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
    WHERE p.barcode = 'NECK-3' 
       OR (p.slug = 'neck-3-black-thread-choker-new-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1105: NECK-2
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
  'NECK-2',
  'neck-2-white-square-big-stone-kammal-necklace',
  'White square big stone, kammal Necklace',
  'White square big stone, kammal Necklace',
  'NECK-2',
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
    WHERE p.barcode = 'NECK-2' 
       OR (p.slug = 'neck-2-white-square-big-stone-kammal-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1106: NECK-1
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
  'NECK-1',
  'neck-1-gold-choker-necklace',
  'Gold Choker Necklace',
  'Gold Choker Necklace',
  'NECK-1',
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
    WHERE p.barcode = 'NECK-1' 
       OR (p.slug = 'neck-1-gold-choker-necklace' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1107: OPPMND-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPMND-7',
  'oppmnd-7-oppana-mundu-new-big',
  'Oppana Mundu New Big',
  'Oppana Mundu New Big',
  'OPPMND-7',
  225.00,
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
    WHERE p.barcode = 'OPPMND-7' 
       OR (p.slug = 'oppmnd-7-oppana-mundu-new-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1108: OPPBLS-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPBLS-7',
  'oppbls-7-oppana-blouse-big-green',
  'Oppana Blouse Big green',
  'Oppana Blouse Big green',
  'OPPBLS-7',
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
    WHERE p.barcode = 'OPPBLS-7' 
       OR (p.slug = 'oppbls-7-oppana-blouse-big-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1109: OPPTHT-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPTHT-7',
  'opptht-7-oppana-thattam-big-new',
  'Oppana thattam Big New',
  'Oppana thattam Big New',
  'OPPTHT-7',
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
    WHERE p.barcode = 'OPPTHT-7' 
       OR (p.slug = 'opptht-7-oppana-thattam-big-new' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1110: OPPTHT-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPTHT-6',
  'opptht-6-oppana-thattam-big-new',
  'Oppana thattam Big New',
  'Oppana thattam Big New',
  'OPPTHT-6',
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
    WHERE p.barcode = 'OPPTHT-6' 
       OR (p.slug = 'opptht-6-oppana-thattam-big-new' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1111: OPPBLS-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPBLS-6',
  'oppbls-6-oppana-blouse-big-green-new',
  'Oppana blouse big green new',
  'Oppana blouse big green new',
  'OPPBLS-6',
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
    WHERE p.barcode = 'OPPBLS-6' 
       OR (p.slug = 'oppbls-6-oppana-blouse-big-green-new' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1112: OPPMND-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPMND-6',
  'oppmnd-6-oppana-mundu-big-new',
  'Oppana mundu big new',
  'Oppana mundu big new',
  'OPPMND-6',
  225.00,
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
    WHERE p.barcode = 'OPPMND-6' 
       OR (p.slug = 'oppmnd-6-oppana-mundu-big-new' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1113: MANAVA-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'MANAVA-5',
  'manava-5-blue-velvet-big-dress-ornaments',
  'Blue Velvet Big Dress & Ornaments',
  'Blue Velvet Big Dress & Ornaments',
  'MANAVA-5',
  1260.00,
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
    WHERE p.barcode = 'MANAVA-5' 
       OR (p.slug = 'manava-5-blue-velvet-big-dress-ornaments' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1114: MANAVA-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'MANAVA-4',
  'manava-4-majenta-velvet-big-dress-ornaments',
  'Majenta Velvet Big dress & Ornaments',
  'Majenta Velvet Big dress & Ornaments',
  'MANAVA-4',
  1260.00,
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
    WHERE p.barcode = 'MANAVA-4' 
       OR (p.slug = 'manava-4-majenta-velvet-big-dress-ornaments' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1115: MANAVA-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'MANAVA-3',
  'manava-3-green-seq-big-dress-ornaments',
  'Green Seq Big dress & Ornaments',
  'Green Seq Big dress & Ornaments',
  'MANAVA-3',
  1050.00,
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
    WHERE p.barcode = 'MANAVA-3' 
       OR (p.slug = 'manava-3-green-seq-big-dress-ornaments' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1116: MANAVA-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'MANAVA-2',
  'manava-2-red-seq-big-dress-ornaments',
  'Red Seq big Dress & Ornaments',
  'Red Seq big Dress & Ornaments',
  'MANAVA-2',
  1050.00,
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
    WHERE p.barcode = 'MANAVA-2' 
       OR (p.slug = 'manava-2-red-seq-big-dress-ornaments' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1117: MANAVA-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'MANAVA-1',
  'manava-1-green-velvet-small-dress-ornsments',
  'Green velvet small dress & ornsments',
  'Green velvet small dress & ornsments',
  'MANAVA-1',
  800.00,
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
    WHERE p.barcode = 'MANAVA-1' 
       OR (p.slug = 'manava-1-green-velvet-small-dress-ornsments' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1118: OPPMND-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPMND-5',
  'oppmnd-5-oppana-mundu-big',
  'Oppana Mundu Big',
  'Oppana Mundu Big',
  'OPPMND-5',
  225.00,
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
    WHERE p.barcode = 'OPPMND-5' 
       OR (p.slug = 'oppmnd-5-oppana-mundu-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1119: OPPMND-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPMND-4',
  'oppmnd-4-oppana-mundu-big',
  'Oppana Mundu Big',
  'Oppana Mundu Big',
  'OPPMND-4',
  225.00,
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
    WHERE p.barcode = 'OPPMND-4' 
       OR (p.slug = 'oppmnd-4-oppana-mundu-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1120: OPPMND-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPMND-3',
  'oppmnd-3-oppana-mundu-big',
  'Oppana Mundu Big',
  'Oppana Mundu Big',
  'OPPMND-3',
  225.00,
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
    WHERE p.barcode = 'OPPMND-3' 
       OR (p.slug = 'oppmnd-3-oppana-mundu-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1121: OPPMND-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPMND-2',
  'oppmnd-2-oppana-mundu-up',
  'Oppana Mundu UP',
  'Oppana Mundu UP',
  'OPPMND-2',
  225.00,
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
    WHERE p.barcode = 'OPPMND-2' 
       OR (p.slug = 'oppmnd-2-oppana-mundu-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1122: OPPMND-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPMND-1',
  'oppmnd-1-oppana-mundu-small',
  'Oppana Mundu Small',
  'Oppana Mundu Small',
  'OPPMND-1',
  225.00,
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
    WHERE p.barcode = 'OPPMND-1' 
       OR (p.slug = 'oppmnd-1-oppana-mundu-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1123: OPPBLS-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPBLS-5',
  'oppbls-5-oppana-blouse-big-red-brocade',
  'Oppana Blouse big Red brocade',
  'Oppana Blouse big Red brocade',
  'OPPBLS-5',
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
    WHERE p.barcode = 'OPPBLS-5' 
       OR (p.slug = 'oppbls-5-oppana-blouse-big-red-brocade' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1124: OPPBLS-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPBLS-4',
  'oppbls-4-oppana-blouse-big-green',
  'Oppana Blouse Big green',
  'Oppana Blouse Big green',
  'OPPBLS-4',
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
    WHERE p.barcode = 'OPPBLS-4' 
       OR (p.slug = 'oppbls-4-oppana-blouse-big-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1125: OPPBLS-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPBLS-3',
  'oppbls-3-oppana-blouse-green-old-big',
  'Oppana Blouse Green old Big',
  'Oppana Blouse Green old Big',
  'OPPBLS-3',
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
    WHERE p.barcode = 'OPPBLS-3' 
       OR (p.slug = 'oppbls-3-oppana-blouse-green-old-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1126: OPPBLS-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPBLS-2',
  'oppbls-2-oppana-blouse-green-old-up',
  'Oppana blouse Green old UP',
  'Oppana blouse Green old UP',
  'OPPBLS-2',
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
    WHERE p.barcode = 'OPPBLS-2' 
       OR (p.slug = 'oppbls-2-oppana-blouse-green-old-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1127: OPPBLS-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPBLS-1',
  'oppbls-1-oppana-blouse-green-old-small',
  'Oppana Blouse Green old Small',
  'Oppana Blouse Green old Small',
  'OPPBLS-1',
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
    WHERE p.barcode = 'OPPBLS-1' 
       OR (p.slug = 'oppbls-1-oppana-blouse-green-old-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1128: OPPTHT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPTHT-1',
  'opptht-1-oppana-thattakam-small',
  'Oppana Thattakam Small',
  'Oppana Thattakam Small',
  'OPPTHT-1',
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
    WHERE p.barcode = 'OPPTHT-1' 
       OR (p.slug = 'opptht-1-oppana-thattakam-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1129: OPPTHT-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPTHT-2',
  'opptht-2-oppana-thattakam-up',
  'Oppana Thattakam UP',
  'Oppana Thattakam UP',
  'OPPTHT-2',
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
    WHERE p.barcode = 'OPPTHT-2' 
       OR (p.slug = 'opptht-2-oppana-thattakam-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1130: OPPTHT-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPTHT-3',
  'opptht-3-oppana-thattakam-big',
  'Oppana Thattakam Big',
  'Oppana Thattakam Big',
  'OPPTHT-3',
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
    WHERE p.barcode = 'OPPTHT-3' 
       OR (p.slug = 'opptht-3-oppana-thattakam-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1131: OPPTHT-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPTHT-4',
  'opptht-4-oppana-thattakam-big',
  'Oppana Thattakam big',
  'Oppana Thattakam big',
  'OPPTHT-4',
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
    WHERE p.barcode = 'OPPTHT-4' 
       OR (p.slug = 'opptht-4-oppana-thattakam-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1132: OPPTHT-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'oppana' AND store_id = s.id LIMIT 1),
  b.id,
  'OPPTHT-5',
  'opptht-5-oppana-thattakam-big',
  'Oppana Thattakam Big',
  'Oppana Thattakam Big',
  'OPPTHT-5',
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
    WHERE p.barcode = 'OPPTHT-5' 
       OR (p.slug = 'opptht-5-oppana-thattakam-big' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1133: MOH-60
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-60',
  'moh-60-dark-border-up',
  'Dark border UP',
  'Dark border UP',
  'MOH-60',
  800.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-60' 
       OR (p.slug = 'moh-60-dark-border-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1134: MOH-59
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-59',
  'moh-59-dark-border-up',
  'Dark border UP',
  'Dark border UP',
  'MOH-59',
  800.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-59' 
       OR (p.slug = 'moh-59-dark-border-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1135: MOH-58
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-58',
  'moh-58-dark-border-up',
  'Dark border UP',
  'Dark border UP',
  'MOH-58',
  800.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-58' 
       OR (p.slug = 'moh-58-dark-border-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1136: MOH-57
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-57',
  'moh-57-dark-border-up',
  'Dark border UP',
  'Dark border UP',
  'MOH-57',
  800.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-57' 
       OR (p.slug = 'moh-57-dark-border-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1137: MOH-56
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-56',
  'moh-56-dark-border-up',
  'Dark border UP',
  'Dark border UP',
  'MOH-56',
  800.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-56' 
       OR (p.slug = 'moh-56-dark-border-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1138: MOH-55
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-55',
  'moh-55-dark-chuttikara-old',
  'Dark Chuttikara Old',
  'Dark Chuttikara Old',
  'MOH-55',
  420.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-55' 
       OR (p.slug = 'moh-55-dark-chuttikara-old' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1139: MOH-54
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-54',
  'moh-54-dark-chuttikara-old',
  'Dark Chuttikara old',
  'Dark Chuttikara old',
  'MOH-54',
  420.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-54' 
       OR (p.slug = 'moh-54-dark-chuttikara-old' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1140: MOH-53
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-53',
  'moh-53-dark-chuttikara-old',
  'Dark chuttikara old',
  'Dark chuttikara old',
  'MOH-53',
  420.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-53' 
       OR (p.slug = 'moh-53-dark-chuttikara-old' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1141: MOH-52
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-52',
  'moh-52-dark-chuttikara-old',
  'Dark chuttikara old',
  'Dark chuttikara old',
  'MOH-52',
  420.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-52' 
       OR (p.slug = 'moh-52-dark-chuttikara-old' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1142: MOH-51
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-51',
  'moh-51-light-chutti-kara',
  'Light Chutti Kara',
  'Light Chutti Kara',
  'MOH-51',
  680.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-51' 
       OR (p.slug = 'moh-51-light-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1143: MOH-50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-50',
  'moh-50-light-chutti-kara',
  'Light Chutti Kara',
  'Light Chutti Kara',
  'MOH-50',
  680.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-50' 
       OR (p.slug = 'moh-50-light-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1144: MOH-49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-49',
  'moh-49-light-chutti-kara',
  'Light Chutti Kara',
  'Light Chutti Kara',
  'MOH-49',
  680.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-49' 
       OR (p.slug = 'moh-49-light-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1145: MOH-48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-48',
  'moh-48-light-chutti-kara',
  'Light Chutti Kara',
  'Light Chutti Kara',
  'MOH-48',
  680.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-48' 
       OR (p.slug = 'moh-48-light-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1146: MOH-47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-47',
  'moh-47-light-chutti-kara',
  'Light Chutti Kara',
  'Light Chutti Kara',
  'MOH-47',
  680.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-47' 
       OR (p.slug = 'moh-47-light-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1147: MOH-46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-46',
  'moh-46-light-chutti-kara',
  'Light Chutti Kara',
  'Light Chutti Kara',
  'MOH-46',
  680.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-46' 
       OR (p.slug = 'moh-46-light-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1148: MOH-45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-45',
  'moh-45-light-chutti-kara',
  'Light Chutti Kara',
  'Light Chutti Kara',
  'MOH-45',
  680.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-45' 
       OR (p.slug = 'moh-45-light-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1149: MOH-44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-44',
  'moh-44-light-chutti-kara',
  'Light Chutti Kara',
  'Light Chutti Kara',
  'MOH-44',
  680.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-44' 
       OR (p.slug = 'moh-44-light-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1150: MOH-43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-43',
  'moh-43-light-chutti-kara',
  'Light Chutti Kara',
  'Light Chutti Kara',
  'MOH-43',
  680.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-43' 
       OR (p.slug = 'moh-43-light-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1151: MOH-42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-42',
  'moh-42-light-chutti-kara',
  'Light Chutti Kara',
  'Light Chutti Kara',
  'MOH-42',
  680.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-42' 
       OR (p.slug = 'moh-42-light-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1152: MOH-41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-41',
  'moh-41-dark-chutti-kara',
  'Dark Chutti kara',
  'Dark Chutti kara',
  'MOH-41',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-41' 
       OR (p.slug = 'moh-41-dark-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1153: MOH-40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-40',
  'moh-40-dark-chutti-kara',
  'Dark Chutti kara',
  'Dark Chutti kara',
  'MOH-40',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-40' 
       OR (p.slug = 'moh-40-dark-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1154: MOH-39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-39',
  'moh-39-dark-chutti-kara',
  'Dark Chutti kara',
  'Dark Chutti kara',
  'MOH-39',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-39' 
       OR (p.slug = 'moh-39-dark-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1155: MOH-38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-38',
  'moh-38-dark-chutti-kara',
  'Dark Chutti kara',
  'Dark Chutti kara',
  'MOH-38',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-38' 
       OR (p.slug = 'moh-38-dark-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1156: MOH-37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-37',
  'moh-37-dark-chutti-kara',
  'Dark Chutti kara',
  'Dark Chutti kara',
  'MOH-37',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-37' 
       OR (p.slug = 'moh-37-dark-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1157: MOH-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-36',
  'moh-36-dark-chutti-kara',
  'Dark Chutti kara',
  'Dark Chutti kara',
  'MOH-36',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-36' 
       OR (p.slug = 'moh-36-dark-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1158: MOH-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-35',
  'moh-35-dark-chutti-kara',
  'Dark Chutti kara',
  'Dark Chutti kara',
  'MOH-35',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-35' 
       OR (p.slug = 'moh-35-dark-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1159: MOH-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-34',
  'moh-34-dark-chutti-kara',
  'Dark Chutti kara',
  'Dark Chutti kara',
  'MOH-34',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-34' 
       OR (p.slug = 'moh-34-dark-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1160: MOH-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-33',
  'moh-33-dark-chutti-kara',
  'Dark Chutti kara',
  'Dark Chutti kara',
  'MOH-33',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-33' 
       OR (p.slug = 'moh-33-dark-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1161: MOH-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-32',
  'moh-32-dark-chutti-kara',
  'Dark Chutti kara',
  'Dark Chutti kara',
  'MOH-32',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-32' 
       OR (p.slug = 'moh-32-dark-chutti-kara' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1162: MOH-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-31',
  'moh-31-thick-kasavu',
  'Thick Kasavu',
  'Thick Kasavu',
  'MOH-31',
  750.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-31' 
       OR (p.slug = 'moh-31-thick-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1163: MOH-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-30',
  'moh-30-thick-kasavu',
  'Thick Kasavu',
  'Thick Kasavu',
  'MOH-30',
  750.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-30' 
       OR (p.slug = 'moh-30-thick-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1164: MOH-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-29',
  'moh-29-thick-kasavu',
  'Thick Kasavu',
  'Thick Kasavu',
  'MOH-29',
  750.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-29' 
       OR (p.slug = 'moh-29-thick-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1165: MOH-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-28',
  'moh-28-thick-kasavu',
  'Thick Kasavu',
  'Thick Kasavu',
  'MOH-28',
  750.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-28' 
       OR (p.slug = 'moh-28-thick-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1166: MOH-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-27',
  'moh-27-thick-kasavu',
  'Thick Kasavu',
  'Thick Kasavu',
  'MOH-27',
  750.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-27' 
       OR (p.slug = 'moh-27-thick-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1167: MOH-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-26',
  'moh-26-thick-kasavu',
  'Thick Kasavu',
  'Thick Kasavu',
  'MOH-26',
  750.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-26' 
       OR (p.slug = 'moh-26-thick-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1168: MOH-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-25',
  'moh-25-round',
  'Round',
  'Round',
  'MOH-25',
  580.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-25' 
       OR (p.slug = 'moh-25-round' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1169: MOH-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-24',
  'moh-24-round',
  'Round',
  'Round',
  'MOH-24',
  580.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-24' 
       OR (p.slug = 'moh-24-round' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1170: MOH-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-23',
  'moh-23-round',
  'Round',
  'Round',
  'MOH-23',
  580.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-23' 
       OR (p.slug = 'moh-23-round' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1171: MOH-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-22',
  'moh-22-round',
  'Round',
  'Round',
  'MOH-22',
  580.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-22' 
       OR (p.slug = 'moh-22-round' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1172: MOH-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-21',
  'moh-21-blue-kasavu-small',
  'Blue Kasavu Small',
  'Blue Kasavu Small',
  'MOH-21',
  530.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-21' 
       OR (p.slug = 'moh-21-blue-kasavu-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1173: MOH-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-20',
  'moh-20-blue-kasavu-small',
  'Blue Kasavu Small',
  'Blue Kasavu Small',
  'MOH-20',
  530.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-20' 
       OR (p.slug = 'moh-20-blue-kasavu-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1174: MOH-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-19',
  'moh-19-blue-kasavu-small',
  'Blue Kasavu Small',
  'Blue Kasavu Small',
  'MOH-19',
  530.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-19' 
       OR (p.slug = 'moh-19-blue-kasavu-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1175: MOH-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-18',
  'moh-18-blue-kasavu-small',
  'Blue Kasavu Small',
  'Blue Kasavu Small',
  'MOH-18',
  530.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-18' 
       OR (p.slug = 'moh-18-blue-kasavu-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1176: MOH-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-17',
  'moh-17-blue-kasavu-small',
  'Blue Kasavu Small',
  'Blue Kasavu Small',
  'MOH-17',
  530.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-17' 
       OR (p.slug = 'moh-17-blue-kasavu-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1177: MOH-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-16',
  'moh-16-blue-kasavu-small',
  'Blue Kasavu Small',
  'Blue Kasavu Small',
  'MOH-16',
  530.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-16' 
       OR (p.slug = 'moh-16-blue-kasavu-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1178: MOH-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-15',
  'moh-15-blue-kasavu-large',
  'Blue Kasavu Large',
  'Blue Kasavu Large',
  'MOH-15',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-15' 
       OR (p.slug = 'moh-15-blue-kasavu-large' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1179: MOH-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-14',
  'moh-14-greenred-line',
  'Green/Red line',
  'Green/Red line',
  'MOH-14',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-14' 
       OR (p.slug = 'moh-14-greenred-line' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1180: MOH-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-13',
  'moh-13-greenred-line',
  'Green/Red line',
  'Green/Red line',
  'MOH-13',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-13' 
       OR (p.slug = 'moh-13-greenred-line' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1181: MOH-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-12',
  'moh-12-greenred-line',
  'Green/Red line',
  'Green/Red line',
  'MOH-12',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-12' 
       OR (p.slug = 'moh-12-greenred-line' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1182: MOH-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-11',
  'moh-11-greenred-line',
  'Green/Red line',
  'Green/Red line',
  'MOH-11',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-11' 
       OR (p.slug = 'moh-11-greenred-line' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1183: MOH-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-10',
  'moh-10-greenred-line',
  'Green/Red line',
  'Green/Red line',
  'MOH-10',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-10' 
       OR (p.slug = 'moh-10-greenred-line' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1184: MOH-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-9',
  'moh-9-greenred-line',
  'Green/Red line',
  'Green/Red line',
  'MOH-9',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-9' 
       OR (p.slug = 'moh-9-greenred-line' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1185: MOH-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-8',
  'moh-8-majenta',
  'Majenta',
  'Majenta',
  'MOH-8',
  580.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-8' 
       OR (p.slug = 'moh-8-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1186: MOH-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-7',
  'moh-7-majenta',
  'Majenta',
  'Majenta',
  'MOH-7',
  580.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-7' 
       OR (p.slug = 'moh-7-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1187: MOH-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-6',
  'moh-6-light-kasavu',
  'Light kasavu',
  'Light kasavu',
  'MOH-6',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-6' 
       OR (p.slug = 'moh-6-light-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1188: MOH-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-5',
  'moh-5-light-kasavu',
  'Light kasavu',
  'Light kasavu',
  'MOH-5',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-5' 
       OR (p.slug = 'moh-5-light-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1189: MOH-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-4',
  'moh-4-light-kasavu',
  'Light kasavu',
  'Light kasavu',
  'MOH-4',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-4' 
       OR (p.slug = 'moh-4-light-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1190: MOH-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-3',
  'moh-3-light-kasavu',
  'Light kasavu',
  'Light kasavu',
  'MOH-3',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-3' 
       OR (p.slug = 'moh-3-light-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1191: MOH-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-2',
  'moh-2-light-kasavu',
  'Light kasavu',
  'Light kasavu',
  'MOH-2',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-2' 
       OR (p.slug = 'moh-2-light-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1192: MOH-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'mohiniyattam' AND store_id = s.id LIMIT 1),
  b.id,
  'MOH-1',
  'moh-1-light-kasavu',
  'Light kasavu',
  'Light kasavu',
  'MOH-1',
  630.00,
  3000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOH-1' 
       OR (p.slug = 'moh-1-light-kasavu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1193: MARGAM-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'margam-kali' AND store_id = s.id LIMIT 1),
  b.id,
  'MARGAM-6',
  'margam-6-margam-kali-hss',
  'Margam kali HSS',
  'Margam kali HSS',
  'MARGAM-6',
  630.00,
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
    WHERE p.barcode = 'MARGAM-6' 
       OR (p.slug = 'margam-6-margam-kali-hss' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1194: MARGAM-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'margam-kali' AND store_id = s.id LIMIT 1),
  b.id,
  'MARGAM-5',
  'margam-5-margam-kali-lp',
  'Margam kali  LP',
  'Margam kali  LP',
  'MARGAM-5',
  630.00,
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
    WHERE p.barcode = 'MARGAM-5' 
       OR (p.slug = 'margam-5-margam-kali-lp' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1195: MARGAM-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'margam-kali' AND store_id = s.id LIMIT 1),
  b.id,
  'MARGAM-4',
  'margam-4-margam-kali',
  'Margam kali',
  'Margam kali',
  'MARGAM-4',
  630.00,
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
    WHERE p.barcode = 'MARGAM-4' 
       OR (p.slug = 'margam-4-margam-kali' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1196: MARGAM-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'margam-kali' AND store_id = s.id LIMIT 1),
  b.id,
  'MARGAM-3',
  'margam-3-margam-kali',
  'Margam Kali',
  'Margam Kali',
  'MARGAM-3',
  420.00,
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
    WHERE p.barcode = 'MARGAM-3' 
       OR (p.slug = 'margam-3-margam-kali' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1197: MARGAM-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'margam-kali' AND store_id = s.id LIMIT 1),
  b.id,
  'MARGAM-2',
  'margam-2-margam-kali',
  'Margam Kali',
  'Margam Kali',
  'MARGAM-2',
  420.00,
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
    WHERE p.barcode = 'MARGAM-2' 
       OR (p.slug = 'margam-2-margam-kali' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1198: MARGAM-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'margam-kali' AND store_id = s.id LIMIT 1),
  b.id,
  'MARGAM-1',
  'margam-1-margam-kali',
  'Margam Kali',
  'Margam Kali',
  'MARGAM-1',
  420.00,
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
    WHERE p.barcode = 'MARGAM-1' 
       OR (p.slug = 'margam-1-margam-kali' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1199: KERANAD-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-24',
  'keranad-24-red-thick-gold-border',
  'Red Thick Gold Border',
  'Red Thick Gold Border',
  'KERANAD-24',
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
    WHERE p.barcode = 'KERANAD-24' 
       OR (p.slug = 'keranad-24-red-thick-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1200: KERANAD-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-23',
  'keranad-23-red-thick-gold-border',
  'Red Thick Gold Border',
  'Red Thick Gold Border',
  'KERANAD-23',
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
    WHERE p.barcode = 'KERANAD-23' 
       OR (p.slug = 'keranad-23-red-thick-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1201: KERANAD-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-22',
  'keranad-22-red-thick-gold-border',
  'Red Thick Gold Border',
  'Red Thick Gold Border',
  'KERANAD-22',
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
    WHERE p.barcode = 'KERANAD-22' 
       OR (p.slug = 'keranad-22-red-thick-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1202: KERANAD-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-21',
  'keranad-21-red-thick-gold-border',
  'Red Thick Gold Border',
  'Red Thick Gold Border',
  'KERANAD-21',
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
    WHERE p.barcode = 'KERANAD-21' 
       OR (p.slug = 'keranad-21-red-thick-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1203: KERANAD-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-20',
  'keranad-20-red-thick-gold-border',
  'Red Thick Gold Border',
  'Red Thick Gold Border',
  'KERANAD-20',
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
    WHERE p.barcode = 'KERANAD-20' 
       OR (p.slug = 'keranad-20-red-thick-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1204: KERANAD-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-19',
  'keranad-19-red-thick-gold-border',
  'Red Thick Gold Border',
  'Red Thick Gold Border',
  'KERANAD-19',
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
    WHERE p.barcode = 'KERANAD-19' 
       OR (p.slug = 'keranad-19-red-thick-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1205: KERANAD-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-18',
  'keranad-18-red-thick-gold-border',
  'Red Thick Gold Border',
  'Red Thick Gold Border',
  'KERANAD-18',
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
    WHERE p.barcode = 'KERANAD-18' 
       OR (p.slug = 'keranad-18-red-thick-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1206: KERANAD-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-17',
  'keranad-17-red-thick-gold-border',
  'Red Thick Gold Border',
  'Red Thick Gold Border',
  'KERANAD-17',
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
    WHERE p.barcode = 'KERANAD-17' 
       OR (p.slug = 'keranad-17-red-thick-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1207: KERANAD-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-16',
  'keranad-16-vadamulla-kasavu-lp',
  'Vadamulla Kasavu LP',
  'Vadamulla Kasavu LP',
  'KERANAD-16',
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
    WHERE p.barcode = 'KERANAD-16' 
       OR (p.slug = 'keranad-16-vadamulla-kasavu-lp' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1208: KERANAD-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-15',
  'keranad-15-vadamulla-kasavu-lp',
  'Vadamulla Kasavu LP',
  'Vadamulla Kasavu LP',
  'KERANAD-15',
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
    WHERE p.barcode = 'KERANAD-15' 
       OR (p.slug = 'keranad-15-vadamulla-kasavu-lp' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1209: KERANAD-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-14',
  'keranad-14-gold-border',
  'Gold Border',
  'Gold Border',
  'KERANAD-14',
  1300.00,
  2800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KERANAD-14' 
       OR (p.slug = 'keranad-14-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1210: KERANAD-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-13',
  'keranad-13-gold-border',
  'Gold Border',
  'Gold Border',
  'KERANAD-13',
  1300.00,
  2800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KERANAD-13' 
       OR (p.slug = 'keranad-13-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1211: KERANAD-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-12',
  'keranad-12-gold-border',
  'Gold Border',
  'Gold Border',
  'KERANAD-12',
  1300.00,
  2800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KERANAD-12' 
       OR (p.slug = 'keranad-12-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1212: KERANAD-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-11',
  'keranad-11-gold-border',
  'Gold Border',
  'Gold Border',
  'KERANAD-11',
  1300.00,
  2800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KERANAD-11' 
       OR (p.slug = 'keranad-11-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1213: KERANAD-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-10',
  'keranad-10-gold-border',
  'Gold Border',
  'Gold Border',
  'KERANAD-10',
  1300.00,
  2800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KERANAD-10' 
       OR (p.slug = 'keranad-10-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1214: KERANAD-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-9',
  'keranad-9-gold-border',
  'Gold Border',
  'Gold Border',
  'KERANAD-9',
  1300.00,
  2800.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KERANAD-9' 
       OR (p.slug = 'keranad-9-gold-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1215: KERANAD-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-8',
  'keranad-8-green-border',
  'Green Border',
  'Green Border',
  'KERANAD-8',
  1050.00,
  3100.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'KERANAD-8' 
       OR (p.slug = 'keranad-8-green-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1216: KERANAD-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-7',
  'keranad-7-red-border',
  'Red Border',
  'Red Border',
  'KERANAD-7',
  370.00,
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
    WHERE p.barcode = 'KERANAD-7' 
       OR (p.slug = 'keranad-7-red-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1217: KERANAD-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-6',
  'keranad-6-red-border',
  'Red Border',
  'Red Border',
  'KERANAD-6',
  370.00,
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
    WHERE p.barcode = 'KERANAD-6' 
       OR (p.slug = 'keranad-6-red-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1218: KERANAD-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-5',
  'keranad-5-red-border',
  'Red Border',
  'Red Border',
  'KERANAD-5',
  370.00,
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
    WHERE p.barcode = 'KERANAD-5' 
       OR (p.slug = 'keranad-5-red-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1219: KERANAD-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-4',
  'keranad-4-blue-border',
  'Blue Border',
  'Blue Border',
  'KERANAD-4',
  370.00,
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
    WHERE p.barcode = 'KERANAD-4' 
       OR (p.slug = 'keranad-4-blue-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1220: KERANAD-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-3',
  'keranad-3-blue-border',
  'Blue Border',
  'Blue Border',
  'KERANAD-3',
  370.00,
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
    WHERE p.barcode = 'KERANAD-3' 
       OR (p.slug = 'keranad-3-blue-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1221: KERANAD-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-2',
  'keranad-2-blue-border',
  'Blue Border',
  'Blue Border',
  'KERANAD-2',
  370.00,
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
    WHERE p.barcode = 'KERANAD-2' 
       OR (p.slug = 'keranad-2-blue-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1222: KERANAD-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'kerala-nadanam' AND store_id = s.id LIMIT 1),
  b.id,
  'KERANAD-1',
  'keranad-1-blue-border',
  'Blue Border',
  'Blue Border',
  'KERANAD-1',
  370.00,
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
    WHERE p.barcode = 'KERANAD-1' 
       OR (p.slug = 'keranad-1-blue-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1223: KAT-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-17',
  'kat-17-majenta-net',
  'Majenta net',
  'Majenta net',
  'KAT-17',
  370.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-17' 
       OR (p.slug = 'kat-17-majenta-net' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1224: KAT-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-16',
  'kat-16-red-full-set',
  'Red full set',
  'Red full set',
  'KAT-16',
  370.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-16' 
       OR (p.slug = 'kat-16-red-full-set' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1225: KAT-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-15',
  'kat-15-majenta-net',
  'Majenta net',
  'Majenta net',
  'KAT-15',
  325.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-15' 
       OR (p.slug = 'kat-15-majenta-net' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1226: KAT-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-14',
  'kat-14-red-anarkali',
  'Red anarkali',
  'Red anarkali',
  'KAT-14',
  400.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-14' 
       OR (p.slug = 'kat-14-red-anarkali' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1227: KAT-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-13',
  'kat-13-blackred',
  'Black/Red',
  'Black/Red',
  'KAT-13',
  225.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-13' 
       OR (p.slug = 'kat-13-blackred' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1228: KAT-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-12',
  'kat-12-white-net-up',
  'White net UP',
  'White net UP',
  'KAT-12',
  175.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-12' 
       OR (p.slug = 'kat-12-white-net-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1229: KAT-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-11',
  'kat-11-white-net-front-sequence',
  'White net front sequence',
  'White net front sequence',
  'KAT-11',
  260.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-11' 
       OR (p.slug = 'kat-11-white-net-front-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1230: KAT-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-10',
  'kat-10-copper-sulphate-bluered-design',
  'Copper sulphate blue/red design',
  'Copper sulphate blue/red design',
  'KAT-10',
  325.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-10' 
       OR (p.slug = 'kat-10-copper-sulphate-bluered-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1231: KAT-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-9',
  'kat-9-peacock-blue-velvet-hss',
  'Peacock blue velvet HSS',
  'Peacock blue velvet HSS',
  'KAT-9',
  325.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-9' 
       OR (p.slug = 'kat-9-peacock-blue-velvet-hss' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1232: KAT-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-8',
  'kat-8-majenta-dotgreen-border',
  'Majenta dot/Green border',
  'Majenta dot/Green border',
  'KAT-8',
  225.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-8' 
       OR (p.slug = 'kat-8-majenta-dotgreen-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1233: KAT-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-7',
  'kat-7-majenta-dotoffwhite-border',
  'Majenta dot/offwhite border',
  'Majenta dot/offwhite border',
  'KAT-7',
  225.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-7' 
       OR (p.slug = 'kat-7-majenta-dotoffwhite-border' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1234: KAT-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-6',
  'kat-6-whitered-large',
  'White/Red Large',
  'White/Red Large',
  'KAT-6',
  290.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-6' 
       OR (p.slug = 'kat-6-whitered-large' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1235: KAT-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-5',
  'kat-5-white-net-plain-lp',
  'White net plain LP',
  'White net plain LP',
  'KAT-5',
  180.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-5' 
       OR (p.slug = 'kat-5-white-net-plain-lp' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1236: KAT-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-4',
  'kat-4-merroon-dot-net-large',
  'Merroon dot net Large',
  'Merroon dot net Large',
  'KAT-4',
  180.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-4' 
       OR (p.slug = 'kat-4-merroon-dot-net-large' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1237: KAT-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-3',
  'kat-3-merron-gold-large',
  'Merron gold Large',
  'Merron gold Large',
  'KAT-3',
  225.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-3' 
       OR (p.slug = 'kat-3-merron-gold-large' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1238: KAT-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-2',
  'kat-2-white-net-design-up',
  'White net design UP',
  'White net design UP',
  'KAT-2',
  225.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-2' 
       OR (p.slug = 'kat-2-white-net-design-up' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1239: KAT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'katak' AND store_id = s.id LIMIT 1),
  b.id,
  'KAT-1',
  'kat-1-greenblack-large',
  'Green/Black large',
  'Green/Black large',
  'KAT-1',
  260.00,
  1100.00,
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
    WHERE p.barcode = 'KAT-1' 
       OR (p.slug = 'kat-1-greenblack-large' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1240: FROC-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-11',
  'froc-11-rainbow-frock',
  'Rainbow frock',
  'Rainbow frock',
  'FROC-11',
  260.00,
  450.00,
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
    WHERE p.barcode = 'FROC-11' 
       OR (p.slug = 'froc-11-rainbow-frock' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1241: FROC-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-10',
  'froc-10-sky-blue-thattu-frock',
  'Sky blue thattu frock',
  'Sky blue thattu frock',
  'FROC-10',
  125.00,
  350.00,
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
    WHERE p.barcode = 'FROC-10' 
       OR (p.slug = 'froc-10-sky-blue-thattu-frock' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1242: FROC-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-9',
  'froc-9-majentanet-thattu-frock',
  'Majentanet Thattu frock',
  'Majentanet Thattu frock',
  'FROC-9',
  150.00,
  350.00,
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
    WHERE p.barcode = 'FROC-9' 
       OR (p.slug = 'froc-9-majentanet-thattu-frock' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1243: FROC-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-8',
  'froc-8-pinkyellow-blue-thattu-frock',
  'Pink/Yellow blue thattu frock',
  'Pink/Yellow blue thattu frock',
  'FROC-8',
  125.00,
  350.00,
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
    WHERE p.barcode = 'FROC-8' 
       OR (p.slug = 'froc-8-pinkyellow-blue-thattu-frock' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1244: FROC-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-7',
  'froc-7-royal-blue',
  'Royal Blue',
  'Royal Blue',
  'FROC-7',
  125.00,
  350.00,
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
    WHERE p.barcode = 'FROC-7' 
       OR (p.slug = 'froc-7-royal-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1245: FROC-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-6',
  'froc-6-yellow-red-thattu-frock',
  'Yellow/ Red thattu frock',
  'Yellow/ Red thattu frock',
  'FROC-6',
  125.00,
  350.00,
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
    WHERE p.barcode = 'FROC-6' 
       OR (p.slug = 'froc-6-yellow-red-thattu-frock' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1246: FROC-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-5',
  'froc-5-green-dot-netorange-sequence',
  'Green dot net/Orange sequence',
  'Green dot net/Orange sequence',
  'FROC-5',
  125.00,
  350.00,
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
    WHERE p.barcode = 'FROC-5' 
       OR (p.slug = 'froc-5-green-dot-netorange-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1247: FROC-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-4',
  'froc-4-pink',
  'Pink',
  'Pink',
  'FROC-4',
  150.00,
  350.00,
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
    WHERE p.barcode = 'FROC-4' 
       OR (p.slug = 'froc-4-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1248: FROC-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-3',
  'froc-3-red',
  'RED',
  'RED',
  'FROC-3',
  150.00,
  350.00,
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
    WHERE p.barcode = 'FROC-3' 
       OR (p.slug = 'froc-3-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1249: FROC-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-2',
  'froc-2-whiteblue',
  'WHITE/BLUE',
  'WHITE/BLUE',
  'FROC-2',
  125.00,
  350.00,
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
    WHERE p.barcode = 'FROC-2' 
       OR (p.slug = 'froc-2-whiteblue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1250: FROC-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'frock' AND store_id = s.id LIMIT 1),
  b.id,
  'FROC-1',
  'froc-1-yellow',
  'YELLOW',
  'YELLOW',
  'FROC-1',
  125.00,
  350.00,
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
    WHERE p.barcode = 'FROC-1' 
       OR (p.slug = 'froc-1-yellow' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1251: WITCH-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'WITCH-1',
  'witch-1-black-witch',
  'Black witch',
  'Black witch',
  'WITCH-1',
  225.00,
  400.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'WITCH-1' 
       OR (p.slug = 'witch-1-black-witch' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1252: CAP-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'CAP-18',
  'cap-18-convocation-cap',
  'Convocation cap',
  'Convocation cap',
  'CAP-18',
  50.00,
  75.00,
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
    WHERE p.barcode = 'CAP-18' 
       OR (p.slug = 'cap-18-convocation-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1253: ROBE-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'ROBE-1',
  'robe-1-red-velvet-robe-crown',
  'Red velvet Robe & crown',
  'Red velvet Robe & crown',
  'ROBE-1',
  370.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'ROBE-1' 
       OR (p.slug = 'robe-1-red-velvet-robe-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1254: SKELET-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'SKELET-1',
  'skelet-1-black-skeleton',
  'Black Skeleton',
  'Black Skeleton',
  'SKELET-1',
  260.00,
  350.00,
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
    WHERE p.barcode = 'SKELET-1' 
       OR (p.slug = 'skelet-1-black-skeleton' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1255: GHOST-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'GHOST-1',
  'ghost-1-white-ghost',
  'White ghost',
  'White ghost',
  'GHOST-1',
  260.00,
  350.00,
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
    WHERE p.barcode = 'GHOST-1' 
       OR (p.slug = 'ghost-1-white-ghost' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1256: FISH-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FISH-2',
  'fish-2-fish',
  'Fish',
  'Fish',
  'FISH-2',
  260.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FISH-2' 
       OR (p.slug = 'fish-2-fish' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1257: STARFISH-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'STARFISH-1',
  'starfish-1-star-fish',
  'Star fish',
  'Star fish',
  'STARFISH-1',
  325.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'STARFISH-1' 
       OR (p.slug = 'starfish-1-star-fish' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1258: MINION-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'MINION-1',
  'minion-1-minion-blue-yellow',
  'Minion Blue/ yellow',
  'Minion Blue/ yellow',
  'MINION-1',
  225.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MINION-1' 
       OR (p.slug = 'minion-1-minion-blue-yellow' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1259: APPLE-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'APPLE-1',
  'apple-1-apple',
  'Apple',
  'Apple',
  'APPLE-1',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'APPLE-1' 
       OR (p.slug = 'apple-1-apple' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1260: HEN-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'HEN-1',
  'hen-1-hen',
  'Hen',
  'Hen',
  'HEN-1',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'HEN-1' 
       OR (p.slug = 'hen-1-hen' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1261: TOM-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'TOM-1',
  'tom-1-tom',
  'Tom',
  'Tom',
  'TOM-1',
  180.00,
  350.00,
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
    WHERE p.barcode = 'TOM-1' 
       OR (p.slug = 'tom-1-tom' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1262: JERRY-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'JERRY-1',
  'jerry-1-jerry',
  'Jerry',
  'Jerry',
  'JERRY-1',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'JERRY-1' 
       OR (p.slug = 'jerry-1-jerry' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1263: PANDA-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'PANDA-1',
  'panda-1-panda',
  'Panda',
  'Panda',
  'PANDA-1',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PANDA-1' 
       OR (p.slug = 'panda-1-panda' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1264: BLACAT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'BLACAT-1',
  'blacat-1-black-cat',
  'Black cat',
  'Black cat',
  'BLACAT-1',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BLACAT-1' 
       OR (p.slug = 'blacat-1-black-cat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1265: FOX-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FOX-1',
  'fox-1-fox',
  'Fox',
  'Fox',
  'FOX-1',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FOX-1' 
       OR (p.slug = 'fox-1-fox' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1266: PIKA-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'PIKA-1',
  'pika-1-pikachu',
  'Pikachu',
  'Pikachu',
  'PIKA-1',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PIKA-1' 
       OR (p.slug = 'pika-1-pikachu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1267: MOTU-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'MOTU-1',
  'motu-1-motu',
  'Motu',
  'Motu',
  'MOTU-1',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MOTU-1' 
       OR (p.slug = 'motu-1-motu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1268: ANT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'ANT-1',
  'ant-1-ant',
  'Ant',
  'Ant',
  'ANT-1',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'ANT-1' 
       OR (p.slug = 'ant-1-ant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1269: BRINJ-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'BRINJ-1',
  'brinj-1-brinjal',
  'Brinjal',
  'Brinjal',
  'BRINJ-1',
  225.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BRINJ-1' 
       OR (p.slug = 'brinj-1-brinjal' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1270: MANGO-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'MANGO-1',
  'mango-1-mango',
  'Mango',
  'Mango',
  'MANGO-1',
  175.00,
  350.00,
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
    WHERE p.barcode = 'MANGO-1' 
       OR (p.slug = 'mango-1-mango' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1271: BANAN-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'BANAN-1',
  'banan-1-banana',
  'Banana',
  'Banana',
  'BANAN-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BANAN-1' 
       OR (p.slug = 'banan-1-banana' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1272: ORAN-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'ORAN-1',
  'oran-1-orange',
  'Orange',
  'Orange',
  'ORAN-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'ORAN-1' 
       OR (p.slug = 'oran-1-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1273: GCHILLI-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'GCHILLI-1',
  'gchilli-1-green-chilli',
  'Green Chilli',
  'Green Chilli',
  'GCHILLI-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'GCHILLI-1' 
       OR (p.slug = 'gchilli-1-green-chilli' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1274: TOMATO-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'TOMATO-1',
  'tomato-1-tomato',
  'Tomato',
  'Tomato',
  'TOMATO-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'TOMATO-1' 
       OR (p.slug = 'tomato-1-tomato' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1275: STRAW-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'STRAW-1',
  'straw-1-straw-berry',
  'Straw berry',
  'Straw berry',
  'STRAW-1',
  175.00,
  350.00,
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
    WHERE p.barcode = 'STRAW-1' 
       OR (p.slug = 'straw-1-straw-berry' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1276: CABB-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'CABB-1',
  'cabb-1-cabbage',
  'Cabbage',
  'Cabbage',
  'CABB-1',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CABB-1' 
       OR (p.slug = 'cabb-1-cabbage' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1277: LION-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'LION-1',
  'lion-1-lion',
  'Lion',
  'Lion',
  'LION-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'LION-1' 
       OR (p.slug = 'lion-1-lion' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1278: YELBIRD-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'YELBIRD-1',
  'yelbird-1-yellow-bird',
  'Yellow bird',
  'Yellow bird',
  'YELBIRD-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'YELBIRD-1' 
       OR (p.slug = 'yelbird-1-yellow-bird' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1279: FISH-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FISH-1',
  'fish-1-fish',
  'Fish',
  'Fish',
  'FISH-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FISH-1' 
       OR (p.slug = 'fish-1-fish' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1280: DUCK-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'DUCK-1',
  'duck-1-duck',
  'Duck',
  'Duck',
  'DUCK-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'DUCK-1' 
       OR (p.slug = 'duck-1-duck' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1281: PARRO-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'PARRO-1',
  'parro-1-parrot',
  'Parrot',
  'Parrot',
  'PARRO-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'PARRO-1' 
       OR (p.slug = 'parro-1-parrot' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1282: ELEPH-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'ELEPH-1',
  'eleph-1-elephant',
  'Elephant',
  'Elephant',
  'ELEPH-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'ELEPH-1' 
       OR (p.slug = 'eleph-1-elephant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1283: BLUEB-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'BLUEB-1',
  'blueb-1-blue-bird',
  'Blue bird',
  'Blue bird',
  'BLUEB-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BLUEB-1' 
       OR (p.slug = 'blueb-1-blue-bird' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1284: DEER-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'DEER-1',
  'deer-1-deer',
  'Deer',
  'Deer',
  'DEER-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'DEER-1' 
       OR (p.slug = 'deer-1-deer' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1285: FROG-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FROG-1',
  'frog-1-frog',
  'Frog',
  'Frog',
  'FROG-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FROG-1' 
       OR (p.slug = 'frog-1-frog' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1286: MONK-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'MONK-1',
  'monk-1-monkey',
  'Monkey',
  'Monkey',
  'MONK-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MONK-1' 
       OR (p.slug = 'monk-1-monkey' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1287: DOG-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'DOG-1',
  'dog-1-dog',
  'Dog',
  'Dog',
  'DOG-1',
  175.00,
  350.00,
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
    WHERE p.barcode = 'DOG-1' 
       OR (p.slug = 'dog-1-dog' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1288: BGOAT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'BGOAT-1',
  'bgoat-1-black-goat',
  'Black goat',
  'Black goat',
  'BGOAT-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BGOAT-1' 
       OR (p.slug = 'bgoat-1-black-goat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1289: ANGRY-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'ANGRY-1',
  'angry-1-angry-bird',
  'Angry bird',
  'Angry bird',
  'ANGRY-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'ANGRY-1' 
       OR (p.slug = 'angry-1-angry-bird' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1290: BBEAR-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'BBEAR-1',
  'bbear-1-brown-bear',
  'Brown bear',
  'Brown bear',
  'BBEAR-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BBEAR-1' 
       OR (p.slug = 'bbear-1-brown-bear' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1291: SHEEP-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'SHEEP-1',
  'sheep-1-sheep-white-goat',
  'Sheep white goat',
  'Sheep white goat',
  'SHEEP-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'SHEEP-1' 
       OR (p.slug = 'sheep-1-sheep-white-goat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1292: MICKEY-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'MICKEY-1',
  'mickey-1-mickey-mouse',
  'Mickey mouse',
  'Mickey mouse',
  'MICKEY-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'MICKEY-1' 
       OR (p.slug = 'mickey-1-mickey-mouse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1293: DONK-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'DONK-1',
  'donk-1-donkey',
  'Donkey',
  'Donkey',
  'DONK-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'DONK-1' 
       OR (p.slug = 'donk-1-donkey' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1294: GOAT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'GOAT-1',
  'goat-1-goat',
  'Goat',
  'Goat',
  'GOAT-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'GOAT-1' 
       OR (p.slug = 'goat-1-goat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1295: TREECOST-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'TREECOST-1',
  'treecost-1-tree-costume',
  'Tree costume',
  'Tree costume',
  'TREECOST-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'TREECOST-1' 
       OR (p.slug = 'treecost-1-tree-costume' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1296: BAL-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'BAL-1',
  'bal-1-bal-ganesh',
  'Bal Ganesh',
  'Bal Ganesh',
  'BAL-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'BAL-1' 
       OR (p.slug = 'bal-1-bal-ganesh' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1297: CHOTA-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'CHOTA-1',
  'chota-1-chotta-bheem',
  'Chotta bheem',
  'Chotta bheem',
  'CHOTA-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CHOTA-1' 
       OR (p.slug = 'chota-1-chotta-bheem' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1298: RAT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'RAT-1',
  'rat-1-rat',
  'Rat',
  'Rat',
  'RAT-1',
  175.00,
  350.00,
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
    WHERE p.barcode = 'RAT-1' 
       OR (p.slug = 'rat-1-rat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1299: CHUT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'CHUT-1',
  'chut-1-chutki',
  'Chutki',
  'Chutki',
  'CHUT-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CHUT-1' 
       OR (p.slug = 'chut-1-chutki' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1300: TIG-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'TIG-1',
  'tig-1-tiger',
  'Tiger',
  'Tiger',
  'TIG-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'TIG-1' 
       OR (p.slug = 'tig-1-tiger' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1301: GIR-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'GIR-1',
  'gir-1-giraffe',
  'Giraffe',
  'Giraffe',
  'GIR-1',
  175.00,
  350.00,
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
    WHERE p.barcode = 'GIR-1' 
       OR (p.slug = 'gir-1-giraffe' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1302: RAB-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'RAB-1',
  'rab-1-rabbit',
  'Rabbit',
  'Rabbit',
  'RAB-1',
  175.00,
  350.00,
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
    WHERE p.barcode = 'RAB-1' 
       OR (p.slug = 'rab-1-rabbit' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1303: DORA-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'DORA-1',
  'dora-1-doraman',
  'Doraman',
  'Doraman',
  'DORA-1',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'DORA-1' 
       OR (p.slug = 'dora-1-doraman' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1304: VAMAN
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'VAMAN',
  'vaman-vamanan',
  'Vamanan',
  'Vamanan',
  'VAMAN',
  470.00,
  350.00,
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
    WHERE p.barcode = 'VAMAN' 
       OR (p.slug = 'vaman-vamanan' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1305: DEVI-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'DEVI-1',
  'devi-1-mahalekshmi-devi-dress',
  'Mahalekshmi devi dress',
  'Mahalekshmi devi dress',
  'DEVI-1',
  1050.00,
  1500.00,
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
    WHERE p.barcode = 'DEVI-1' 
       OR (p.slug = 'devi-1-mahalekshmi-devi-dress' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1306: GOD-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'GOD-1',
  'god-1-krishnamurugaayyappan-vishnu',
  'Krishna,muruga,,ayyappan vishnu',
  'Krishna,muruga,,ayyappan vishnu',
  'GOD-1',
  800.00,
  350.00,
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
    WHERE p.barcode = 'GOD-1' 
       OR (p.slug = 'god-1-krishnamurugaayyappan-vishnu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1307: MAVBIG
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'MAVBIG',
  'mavbig-maveli-big-with-kuda',
  'Maveli big with kuda',
  'Maveli big with kuda',
  'MAVBIG',
  1150.00,
  4000.00,
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
    WHERE p.barcode = 'MAVBIG' 
       OR (p.slug = 'mavbig-maveli-big-with-kuda' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1308: MAVSMA
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'MAVSMA',
  'mavsma-maveli-small-with-kuda',
  'Maveli small with kuda',
  'Maveli small with kuda',
  'MAVSMA',
  900.00,
  3500.00,
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
    WHERE p.barcode = 'MAVSMA' 
       OR (p.slug = 'mavsma-maveli-small-with-kuda' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1309: FANCY-133
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-133',
  'fancy-133-tiger-costume-adult',
  'Tiger costume adult',
  'Tiger costume adult',
  'FANCY-133',
  470.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-133' 
       OR (p.slug = 'fancy-133-tiger-costume-adult' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1310: FANCY-132
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-132',
  'fancy-132-tiger-costume-medium',
  'Tiger costume Medium',
  'Tiger costume Medium',
  'FANCY-132',
  420.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-132' 
       OR (p.slug = 'fancy-132-tiger-costume-medium' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1311: FANCY-131
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-131',
  'fancy-131-tiger-costume-kids',
  'Tiger costume kids',
  'Tiger costume kids',
  'FANCY-131',
  370.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-131' 
       OR (p.slug = 'fancy-131-tiger-costume-kids' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1312: FANCY-129
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-129',
  'fancy-129-green-satin-overall-for-tree',
  'Green satin overall for TREE',
  'Green satin overall for TREE',
  'FANCY-129',
  150.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-129' 
       OR (p.slug = 'fancy-129-green-satin-overall-for-tree' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1313: FANCY-128
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-128',
  'fancy-128-yellow-saree',
  'Yellow saree',
  'Yellow saree',
  'FANCY-128',
  250.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-128' 
       OR (p.slug = 'fancy-128-yellow-saree' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1314: FANCY-127
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-127',
  'fancy-127-rajasthani-boy',
  'Rajasthani boy',
  'Rajasthani boy',
  'FANCY-127',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-127' 
       OR (p.slug = 'fancy-127-rajasthani-boy' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1315: FANCY-126
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-126',
  'fancy-126-captain-america',
  'Captain America',
  'Captain America',
  'FANCY-126',
  250.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-126' 
       OR (p.slug = 'fancy-126-captain-america' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1316: FANCY-125
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-125',
  'fancy-125-bagath-singh-white',
  'Bagath singh white',
  'Bagath singh white',
  'FANCY-125',
  250.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-125' 
       OR (p.slug = 'fancy-125-bagath-singh-white' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1317: FANCY-15A
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-15A',
  'fancy-15a-militry-adult',
  'Militry Adult',
  'Militry Adult',
  'FANCY-15A',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-15A' 
       OR (p.slug = 'fancy-15a-militry-adult' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1318: FANCY-15M
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-15M',
  'fancy-15m-militry-medium',
  'Militry Medium',
  'Militry Medium',
  'FANCY-15M',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-15M' 
       OR (p.slug = 'fancy-15m-militry-medium' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1319: FANCY-77
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-77',
  'fancy-77-pambatti',
  'Pambatti',
  'Pambatti',
  'FANCY-77',
  470.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-77' 
       OR (p.slug = 'fancy-77-pambatti' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1320: FANCY-76
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-76',
  'fancy-76-punjabi-girl',
  'Punjabi Girl',
  'Punjabi Girl',
  'FANCY-76',
  420.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-76' 
       OR (p.slug = 'fancy-76-punjabi-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1321: FANCY-112
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-112',
  'fancy-112-tree',
  'Tree',
  'Tree',
  'FANCY-112',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-112' 
       OR (p.slug = 'fancy-112-tree' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1322: FANCY-74
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-74',
  'fancy-74-sivan-costume-jada-wigrudraksha-setsnakechandr',
  'Sivan Costume( Jada wig,Rudraksha set,snake.Chandr',
  'Sivan Costume( Jada wig,Rudraksha set,snake.Chandr',
  'FANCY-74',
  470.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-74' 
       OR (p.slug = 'fancy-74-sivan-costume-jada-wigrudraksha-setsnakechandr' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1323: FANCY-73
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-73',
  'fancy-73-shakuntala',
  'Shakuntala',
  'Shakuntala',
  'FANCY-73',
  420.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-73' 
       OR (p.slug = 'fancy-73-shakuntala' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1324: FANCY-72
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-72',
  'fancy-72-spider-man-3d-small',
  'Spider Man 3D Small',
  'Spider Man 3D Small',
  'FANCY-72',
  175.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-72' 
       OR (p.slug = 'fancy-72-spider-man-3d-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1325: FANCY-71
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-71',
  'fancy-71-super-man',
  'Super Man',
  'Super Man',
  'FANCY-71',
  175.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-71' 
       OR (p.slug = 'fancy-71-super-man' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1326: FANCY-70
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-70',
  'fancy-70-super-girl',
  'Super Girl',
  'Super Girl',
  'FANCY-70',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-70' 
       OR (p.slug = 'fancy-70-super-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1327: FANCY-69
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-69',
  'fancy-69-blue-spider-girl',
  'Blue spider girl',
  'Blue spider girl',
  'FANCY-69',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-69' 
       OR (p.slug = 'fancy-69-blue-spider-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1328: FANCY-68
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-68',
  'fancy-68-spider-man-3d-large',
  'Spider man 3D Large',
  'Spider man 3D Large',
  'FANCY-68',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-68' 
       OR (p.slug = 'fancy-68-spider-man-3d-large' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1329: FANCY-67
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-67',
  'fancy-67-iron-man-3d',
  'Iron Man 3D',
  'Iron Man 3D',
  'FANCY-67',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-67' 
       OR (p.slug = 'fancy-67-iron-man-3d' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1330: FANCY-66
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-66',
  'fancy-66-punjabi-girl',
  'Punjabi Girl',
  'Punjabi Girl',
  'FANCY-66',
  370.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-66' 
       OR (p.slug = 'fancy-66-punjabi-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1331: FANCY-65
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-65',
  'fancy-65-rajasthani-boy',
  'Rajasthani Boy',
  'Rajasthani Boy',
  'FANCY-65',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-65' 
       OR (p.slug = 'fancy-65-rajasthani-boy' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1332: FANCY-64
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-64',
  'fancy-64-elsa',
  'Elsa',
  'Elsa',
  'FANCY-64',
  420.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-64' 
       OR (p.slug = 'fancy-64-elsa' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1333: FANCY-63
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-63',
  'fancy-63-rabindra-nath-tagore',
  'Rabindra nath Tagore',
  'Rabindra nath Tagore',
  'FANCY-63',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-63' 
       OR (p.slug = 'fancy-63-rabindra-nath-tagore' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1334: FANCY-62
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-62',
  'fancy-62-atm',
  'ATM',
  'ATM',
  'FANCY-62',
  225.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-62' 
       OR (p.slug = 'fancy-62-atm' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1335: FANCY-61
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-61',
  'fancy-61-indira-gandhi',
  'Indira gandhi',
  'Indira gandhi',
  'FANCY-61',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-61' 
       OR (p.slug = 'fancy-61-indira-gandhi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1336: FANCY-60
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-60',
  'fancy-60-mother-teresa',
  'Mother Teresa',
  'Mother Teresa',
  'FANCY-60',
  225.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-60' 
       OR (p.slug = 'fancy-60-mother-teresa' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1337: FANCY-59
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-59',
  'fancy-59-tripura-girl',
  'Tripura Girl',
  'Tripura Girl',
  'FANCY-59',
  400.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-59' 
       OR (p.slug = 'fancy-59-tripura-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1338: FANCY-58
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-58',
  'fancy-58-manipuri-girl',
  'Manipuri Girl',
  'Manipuri Girl',
  'FANCY-58',
  400.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-58' 
       OR (p.slug = 'fancy-58-manipuri-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1339: FANCY-57
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-57',
  'fancy-57-traffic-light',
  'Traffic light',
  'Traffic light',
  'FANCY-57',
  225.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-57' 
       OR (p.slug = 'fancy-57-traffic-light' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1340: FANCY-56
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-56',
  'fancy-56-arab-head-wrap-scarf',
  'Arab head wrap & scarf',
  'Arab head wrap & scarf',
  'FANCY-56',
  260.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-56' 
       OR (p.slug = 'fancy-56-arab-head-wrap-scarf' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1341: FANCY-55
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-55',
  'fancy-55-joker',
  'Joker',
  'Joker',
  'FANCY-55',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-55' 
       OR (p.slug = 'fancy-55-joker' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1342: FANCY-54
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-54',
  'fancy-54-jooba-type-redorange',
  'Jooba type Red/Orange',
  'Jooba type Red/Orange',
  'FANCY-54',
  260.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-54' 
       OR (p.slug = 'fancy-54-jooba-type-redorange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1343: FANCY-53
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-53',
  'fancy-53-gaoan-girl',
  'Gaoan girl',
  'Gaoan girl',
  'FANCY-53',
  290.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-53' 
       OR (p.slug = 'fancy-53-gaoan-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1344: FANCY-52
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-52',
  'fancy-52-goan-boy',
  'Goan Boy',
  'Goan Boy',
  'FANCY-52',
  225.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-52' 
       OR (p.slug = 'fancy-52-goan-boy' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1345: FANCY-51
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-51',
  'fancy-51-christian-king-back-drop-crown',
  'Christian King Back drop, Crown',
  'Christian King Back drop, Crown',
  'FANCY-51',
  250.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-51' 
       OR (p.slug = 'fancy-51-christian-king-back-drop-crown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1346: FANCY-50
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-50',
  'fancy-50-devi-costumecrown-wig-long-chainnecklacebelt',
  'Devi Costume(crown, wig, long chain,Necklace,Belt,',
  'Devi Costume(crown, wig, long chain,Necklace,Belt,',
  'FANCY-50',
  1050.00,
  1700.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-50' 
       OR (p.slug = 'fancy-50-devi-costumecrown-wig-long-chainnecklacebelt' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1347: FANCY-49
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-49',
  'fancy-49-baharath-mathacrown-wig-long-chain-necklace-b',
  'Baharath matha(crown, wig, long chain, Necklace, B',
  'Baharath matha(crown, wig, long chain, Necklace, B',
  'FANCY-49',
  800.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-49' 
       OR (p.slug = 'fancy-49-baharath-mathacrown-wig-long-chain-necklace-b' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1348: FANCY-48
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-48',
  'fancy-48-kashmiri-girl',
  'Kashmiri Girl',
  'Kashmiri Girl',
  'FANCY-48',
  370.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-48' 
       OR (p.slug = 'fancy-48-kashmiri-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1349: FANCY-47
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-47',
  'fancy-47-assamese-girl',
  'Assamese Girl',
  'Assamese Girl',
  'FANCY-47',
  325.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-47' 
       OR (p.slug = 'fancy-47-assamese-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1350: FANCY-46
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-46',
  'fancy-46-assamese-boy',
  'Assamese Boy',
  'Assamese Boy',
  'FANCY-46',
  250.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-46' 
       OR (p.slug = 'fancy-46-assamese-boy' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1351: FANCY-45
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-45',
  'fancy-45-japanese-boy',
  'Japanese Boy',
  'Japanese Boy',
  'FANCY-45',
  250.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-45' 
       OR (p.slug = 'fancy-45-japanese-boy' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1352: FANCY-44
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-44',
  'fancy-44-japanese-girl',
  'Japanese Girl',
  'Japanese Girl',
  'FANCY-44',
  250.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-44' 
       OR (p.slug = 'fancy-44-japanese-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1353: FANCY-43
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-43',
  'fancy-43-bengali-boy',
  'Bengali Boy',
  'Bengali Boy',
  'FANCY-43',
  260.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-43' 
       OR (p.slug = 'fancy-43-bengali-boy' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1354: FANCY-42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-42',
  'fancy-42-chinese-girl',
  'Chinese girl',
  'Chinese girl',
  'FANCY-42',
  350.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-42' 
       OR (p.slug = 'fancy-42-chinese-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1355: FANCY-41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-41',
  'fancy-41-chinese-boy',
  'Chinese boy',
  'Chinese boy',
  'FANCY-41',
  250.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-41' 
       OR (p.slug = 'fancy-41-chinese-boy' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1356: FANCY-40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-40',
  'fancy-40-soldier-costume',
  'Soldier costume',
  'Soldier costume',
  'FANCY-40',
  225.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-40' 
       OR (p.slug = 'fancy-40-soldier-costume' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1357: FANCY-39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-39',
  'fancy-39-nagaland-girl',
  'Nagaland girl',
  'Nagaland girl',
  'FANCY-39',
  370.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-39' 
       OR (p.slug = 'fancy-39-nagaland-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1358: FANCY-38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-38',
  'fancy-38-nagaland-boy',
  'Nagaland Boy',
  'Nagaland Boy',
  'FANCY-38',
  290.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-38' 
       OR (p.slug = 'fancy-38-nagaland-boy' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1359: FANCY-37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-37',
  'fancy-37-mizoram-girl',
  'Mizoram girl',
  'Mizoram girl',
  'FANCY-37',
  250.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-37' 
       OR (p.slug = 'fancy-37-mizoram-girl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1360: FANCY-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-36',
  'fancy-36-gandhiji',
  'Gandhiji',
  'Gandhiji',
  'FANCY-36',
  260.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-36' 
       OR (p.slug = 'fancy-36-gandhiji' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1361: FANCY-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-35',
  'fancy-35-nehru-chachagi',
  'Nehru chachagi',
  'Nehru chachagi',
  'FANCY-35',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-35' 
       OR (p.slug = 'fancy-35-nehru-chachagi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1362: FANCY-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-34',
  'fancy-34-priest-father',
  'Priest father',
  'Priest father',
  'FANCY-34',
  325.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-34' 
       OR (p.slug = 'fancy-34-priest-father' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1363: FANCY-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-33',
  'fancy-33-nun-sister',
  'Nun sister',
  'Nun sister',
  'FANCY-33',
  370.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-33' 
       OR (p.slug = 'fancy-33-nun-sister' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1364: FANCY-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-32',
  'fancy-32-skelton-gown',
  'Skelton gown',
  'Skelton gown',
  'FANCY-32',
  260.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-32' 
       OR (p.slug = 'fancy-32-skelton-gown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1365: FANCY-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-31',
  'fancy-31-halowee-gown-slit-in-hand',
  'Halowee gown slit in hand',
  'Halowee gown slit in hand',
  'FANCY-31',
  225.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-31' 
       OR (p.slug = 'fancy-31-halowee-gown-slit-in-hand' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1366: FANCY-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-30',
  'fancy-30-halloween-gown',
  'Halloween gown',
  'Halloween gown',
  'FANCY-30',
  225.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-30' 
       OR (p.slug = 'fancy-30-halloween-gown' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1367: FANCY-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-29',
  'fancy-29-halloweencoat-gold-lace-boder',
  'Halloweencoat gold lace boder',
  'Halloweencoat gold lace boder',
  'FANCY-29',
  175.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-29' 
       OR (p.slug = 'fancy-29-halloweencoat-gold-lace-boder' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1368: FANCY-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-28',
  'fancy-28-halloween-coat',
  'Halloween coat',
  'Halloween coat',
  'FANCY-28',
  150.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-28' 
       OR (p.slug = 'fancy-28-halloween-coat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1369: FANCY-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-27',
  'fancy-27-asronaut-gold-1white-1-silver-2',
  'Asronaut Gold-1.white-1 silver-2',
  'Asronaut Gold-1.white-1 silver-2',
  'FANCY-27',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-27' 
       OR (p.slug = 'fancy-27-asronaut-gold-1white-1-silver-2' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1370: FANCY-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-26',
  'fancy-26-alladin',
  'Alladin',
  'Alladin',
  'FANCY-26',
  30.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-26' 
       OR (p.slug = 'fancy-26-alladin' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1371: FANCY-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-25',
  'fancy-25-subash-chandra-bose',
  'Subash Chandra bose',
  'Subash Chandra bose',
  'FANCY-25',
  290.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-25' 
       OR (p.slug = 'fancy-25-subash-chandra-bose' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1372: FANCY-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-24',
  'fancy-24-king-costume',
  'King Costume',
  'King Costume',
  'FANCY-24',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-24' 
       OR (p.slug = 'fancy-24-king-costume' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1373: FANCY-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-23',
  'fancy-23-teacher-saree',
  'Teacher Saree',
  'Teacher Saree',
  'FANCY-23',
  225.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-23' 
       OR (p.slug = 'fancy-23-teacher-saree' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1374: FANCY-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-22',
  'fancy-22-onapottan',
  'Onapottan',
  'Onapottan',
  'FANCY-22',
  1050.00,
  4000.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-22' 
       OR (p.slug = 'fancy-22-onapottan' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1375: FANCY-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-21',
  'fancy-21-ardha-nareeshawaran',
  'Ardha nareeshawaran',
  'Ardha nareeshawaran',
  'FANCY-21',
  1050.00,
  3500.00,
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
    WHERE p.barcode = 'FANCY-21' 
       OR (p.slug = 'fancy-21-ardha-nareeshawaran' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1376: FANCY-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-20',
  'fancy-20-jhansi-rani',
  'Jhansi Rani',
  'Jhansi Rani',
  'FANCY-20',
  470.00,
  600.00,
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
    WHERE p.barcode = 'FANCY-20' 
       OR (p.slug = 'fancy-20-jhansi-rani' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1377: FANCY-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-19',
  'fancy-19-navy',
  'Navy',
  'Navy',
  'FANCY-19',
  325.00,
  400.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-19' 
       OR (p.slug = 'fancy-19-navy' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1378: FANCY-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-18',
  'fancy-18-harry-poter-with-stick',
  'Harry Poter with stick',
  'Harry Poter with stick',
  'FANCY-18',
  325.00,
  400.00,
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
    WHERE p.barcode = 'FANCY-18' 
       OR (p.slug = 'fancy-18-harry-poter-with-stick' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1379: FANCY-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-17',
  'fancy-17-nurse',
  'Nurse',
  'Nurse',
  'FANCY-17',
  290.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-17' 
       OR (p.slug = 'fancy-17-nurse' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1380: FANCY-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-16',
  'fancy-16-doctor-coat-and-stethescope',
  'Doctor coat and stethescope',
  'Doctor coat and stethescope',
  'FANCY-16',
  180.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-16' 
       OR (p.slug = 'fancy-16-doctor-coat-and-stethescope' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1381: FANCY-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-15',
  'fancy-15-militry-small',
  'Militry small',
  'Militry small',
  'FANCY-15',
  325.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-15' 
       OR (p.slug = 'fancy-15-militry-small' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1382: FANCY-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-14',
  'fancy-14-police',
  'Police',
  'Police',
  'FANCY-14',
  325.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-14' 
       OR (p.slug = 'fancy-14-police' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1383: FANCY-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-13',
  'fancy-13-abdul-kalam',
  'Abdul kalam',
  'Abdul kalam',
  'FANCY-13',
  370.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-13' 
       OR (p.slug = 'fancy-13-abdul-kalam' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1384: FANCY-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-12',
  'fancy-12-sarojini-naidu',
  'Sarojini Naidu',
  'Sarojini Naidu',
  'FANCY-12',
  260.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-12' 
       OR (p.slug = 'fancy-12-sarojini-naidu' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1385: FANCY-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-11',
  'fancy-11-ambedkar-with-diary',
  'Ambedkar with diary',
  'Ambedkar with diary',
  'FANCY-11',
  290.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-11' 
       OR (p.slug = 'fancy-11-ambedkar-with-diary' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1386: FANCY-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-10',
  'fancy-10-buterfly-wing-cloth',
  'Buterfly wing cloth',
  'Buterfly wing cloth',
  'FANCY-10',
  150.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-10' 
       OR (p.slug = 'fancy-10-buterfly-wing-cloth' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1387: FANCY-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-9',
  'fancy-9-charllie-chaplin',
  'Charllie Chaplin',
  'Charllie Chaplin',
  'FANCY-9',
  260.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-9' 
       OR (p.slug = 'fancy-9-charllie-chaplin' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1388: FANCY-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-8',
  'fancy-8-harry-potter',
  'Harry Potter',
  'Harry Potter',
  'FANCY-8',
  370.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-8' 
       OR (p.slug = 'fancy-8-harry-potter' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1389: FANCY-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-7',
  'fancy-7-narendra-modi-coat-wig',
  'Narendra Modi (Coat & Wig)',
  'Narendra Modi (Coat & Wig)',
  'FANCY-7',
  290.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-7' 
       OR (p.slug = 'fancy-7-narendra-modi-coat-wig' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1390: FANCY-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-6',
  'fancy-6-fire-man-with-extinguisher',
  'Fire man with extinguisher',
  'Fire man with extinguisher',
  'FANCY-6',
  370.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-6' 
       OR (p.slug = 'fancy-6-fire-man-with-extinguisher' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1391: FANCY-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-5',
  'fancy-5-air-hostess',
  'Air hostess',
  'Air hostess',
  'FANCY-5',
  290.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-5' 
       OR (p.slug = 'fancy-5-air-hostess' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1392: FANCY-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-4',
  'fancy-4-chef',
  'Chef',
  'Chef',
  'FANCY-4',
  290.00,
  350.00,
  1,
  1,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'FANCY-4' 
       OR (p.slug = 'fancy-4-chef' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1393: FANCY-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-3',
  'fancy-3-british-police-red-cap',
  'British police red cap',
  'British police red cap',
  'FANCY-3',
  290.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-3' 
       OR (p.slug = 'fancy-3-british-police-red-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1394: FANCY-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-2',
  'fancy-2-britis-police-black-cap',
  'Britis police black cap',
  'Britis police black cap',
  'FANCY-2',
  260.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-2' 
       OR (p.slug = 'fancy-2-britis-police-black-cap' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1395: FANCY-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'fancy-dress' AND store_id = s.id LIMIT 1),
  b.id,
  'FANCY-1',
  'fancy-1-post-man',
  'Post man',
  'Post man',
  'FANCY-1',
  290.00,
  350.00,
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
    WHERE p.barcode = 'FANCY-1' 
       OR (p.slug = 'fancy-1-post-man' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1396: CINE-42
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-42',
  'cine-42-red-velvet-myme-dress',
  'Red velvet myme dress',
  'Red velvet myme dress',
  'CINE-42',
  530.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-42' 
       OR (p.slug = 'cine-42-red-velvet-myme-dress' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1397: CINE-41
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-41',
  'cine-41-blue-oant-blue-seq-top',
  'Blue oant Blue Seq top',
  'Blue oant Blue Seq top',
  'CINE-41',
  370.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-41' 
       OR (p.slug = 'cine-41-blue-oant-blue-seq-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1398: CINE-40
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-40',
  'cine-40-black-apple-cloth-dhothi-pant-with-green-black-bl',
  'Black apple cloth dhothi pant  with green black bl',
  'Black apple cloth dhothi pant  with green black bl',
  'CINE-40',
  325.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-40' 
       OR (p.slug = 'cine-40-black-apple-cloth-dhothi-pant-with-green-black-bl' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1399: CINE-39
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-39',
  'cine-39-black-apple-cloth-dhothi-pant-red-border-balck-blo',
  'Black apple cloth dhothi pant red border balck blo',
  'Black apple cloth dhothi pant red border balck blo',
  'CINE-39',
  325.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-39' 
       OR (p.slug = 'cine-39-black-apple-cloth-dhothi-pant-red-border-balck-blo' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1400: CINE-38
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-38',
  'cine-38-yellow-full-sleeve-top-orangeblue-patiyala',
  'Yellow full sleeve top orange/blue patiyala',
  'Yellow full sleeve top orange/blue patiyala',
  'CINE-38',
  325.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-38' 
       OR (p.slug = 'cine-38-yellow-full-sleeve-top-orangeblue-patiyala' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1401: CINE-37
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-37',
  'cine-37-silver-top-green-seq-shorts-pant',
  'Silver top green seq shorts pant',
  'Silver top green seq shorts pant',
  'CINE-37',
  260.00,
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
    WHERE p.barcode = 'CINE-37' 
       OR (p.slug = 'cine-37-silver-top-green-seq-shorts-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1402: CINE-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-36',
  'cine-36-orange-top-pant-satin',
  'Orange top & pant satin',
  'Orange top & pant satin',
  'CINE-36',
  225.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-36' 
       OR (p.slug = 'cine-36-orange-top-pant-satin' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1403: CINE-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-35',
  'cine-35-black-green-top-pant-for-boys',
  'Black green top & pant for boys',
  'Black green top & pant for boys',
  'CINE-35',
  325.00,
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
    WHERE p.barcode = 'CINE-35' 
       OR (p.slug = 'cine-35-black-green-top-pant-for-boys' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1404: CINE-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-34',
  'cine-34-long-chudi-top-pant-sleevless-jacket-turban-kerchi',
  'Long chudi top pant sleevless jacket turban kerchi',
  'Long chudi top pant sleevless jacket turban kerchi',
  'CINE-34',
  470.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-34' 
       OR (p.slug = 'cine-34-long-chudi-top-pant-sleevless-jacket-turban-kerchi' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1405: CINE-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-33',
  'cine-33-long-chudi-top-patiyala-pant-satin',
  'Long chudi top & Patiyala pant satin',
  'Long chudi top & Patiyala pant satin',
  'CINE-33',
  290.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-33' 
       OR (p.slug = 'cine-33-long-chudi-top-patiyala-pant-satin' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1406: CINE-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-32',
  'cine-32-black-tikky-dhothi-pant-kids-top',
  'Black tikky dhothi pant & kids top',
  'Black tikky dhothi pant & kids top',
  'CINE-32',
  225.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-32' 
       OR (p.slug = 'cine-32-black-tikky-dhothi-pant-kids-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1407: CINE-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-31',
  'cine-31-ping-seq-topsilver-pant',
  'Ping seq top/silver pant',
  'Ping seq top/silver pant',
  'CINE-31',
  325.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-31' 
       OR (p.slug = 'cine-31-ping-seq-topsilver-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1408: CINE-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-30',
  'cine-30-red-shimmer-pant-top',
  'Red shimmer pant top',
  'Red shimmer pant top',
  'CINE-30',
  350.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-30' 
       OR (p.slug = 'cine-30-red-shimmer-pant-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1409: CINE-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-29',
  'cine-29-pink-shirt-blue-trouser-tie',
  'Pink shirt blue trouser tie',
  'Pink shirt blue trouser tie',
  'CINE-29',
  260.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-29' 
       OR (p.slug = 'cine-29-pink-shirt-blue-trouser-tie' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1410: CINE-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-28',
  'cine-28-pink-shirt-blue-trouser-tie',
  'Pink shirt blue trouser tie',
  'Pink shirt blue trouser tie',
  'CINE-28',
  325.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-28' 
       OR (p.slug = 'cine-28-pink-shirt-blue-trouser-tie' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1411: CINE-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-27',
  'cine-27-red-velvet-black-work-top-pant',
  'Red velvet black work top pant',
  'Red velvet black work top pant',
  'CINE-27',
  370.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-27' 
       OR (p.slug = 'cine-27-red-velvet-black-work-top-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1412: CINE-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-26',
  'cine-26-offwhite-shimmer-cloth-pant-top',
  'Offwhite shimmer cloth pant top',
  'Offwhite shimmer cloth pant top',
  'CINE-26',
  370.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-26' 
       OR (p.slug = 'cine-26-offwhite-shimmer-cloth-pant-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1413: CINE-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-25',
  'cine-25-silver-seq-pantgold-seq-sleeveless-top',
  'Silver seq pant/Gold seq sleeveless top',
  'Silver seq pant/Gold seq sleeveless top',
  'CINE-25',
  325.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-25' 
       OR (p.slug = 'cine-25-silver-seq-pantgold-seq-sleeveless-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1414: CINE-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-24',
  'cine-24-gold-seq-pantgold-top',
  'Gold seq pant/Gold top',
  'Gold seq pant/Gold top',
  'CINE-24',
  290.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-24' 
       OR (p.slug = 'cine-24-gold-seq-pantgold-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1415: CINE-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-23',
  'cine-23-pant-topred-white-dotred-top',
  'Pant/ TopRed white dot/Red top',
  'Pant/ TopRed white dot/Red top',
  'CINE-23',
  225.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-23' 
       OR (p.slug = 'cine-23-pant-topred-white-dotred-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1416: CINE-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-22',
  'cine-22-panttoporange-net-blue-stripes-pant',
  'PANT/TOPOrange net blue stripes pant',
  'PANT/TOPOrange net blue stripes pant',
  'CINE-22',
  180.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-22' 
       OR (p.slug = 'cine-22-panttoporange-net-blue-stripes-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1417: CINE-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-21',
  'cine-21-panttopkilipacha-punjabi-pant-top',
  'PANT/TOPKilipacha punjabi pant/ Top',
  'PANT/TOPKilipacha punjabi pant/ Top',
  'CINE-21',
  225.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-21' 
       OR (p.slug = 'cine-21-panttopkilipacha-punjabi-pant-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1418: CINE-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-20',
  'cine-20-panttopwhite-pant-white-seq-top',
  'PANT/TOPWhite pant/ white seq top',
  'PANT/TOPWhite pant/ white seq top',
  'CINE-20',
  175.00,
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
    WHERE p.barcode = 'CINE-20' 
       OR (p.slug = 'cine-20-panttopwhite-pant-white-seq-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1419: CINE-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-19',
  'cine-19-panttopgold-dhothi-pantmajenta-seq-top',
  'PANT/TOPGold dhothi pant/Majenta seq top',
  'PANT/TOPGold dhothi pant/Majenta seq top',
  'CINE-19',
  180.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-19' 
       OR (p.slug = 'cine-19-panttopgold-dhothi-pantmajenta-seq-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1420: CINE-18
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-18',
  'cine-18-panttopyellow-seq-blue-overcoat',
  'PANT/TOPYellow seq/ blue overcoat',
  'PANT/TOPYellow seq/ blue overcoat',
  'CINE-18',
  175.00,
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
    WHERE p.barcode = 'CINE-18' 
       OR (p.slug = 'cine-18-panttopyellow-seq-blue-overcoat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1421: CINE-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-17',
  'cine-17-panttopyellow-red-half-half-joker-pant',
  'PANT/TOPYellow red half & half joker pant',
  'PANT/TOPYellow red half & half joker pant',
  'CINE-17',
  260.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-17' 
       OR (p.slug = 'cine-17-panttopyellow-red-half-half-joker-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1422: CINE-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-16',
  'cine-16-panttopblueshimmer-cloth-panttop',
  'PANT/TOPBlueshimmer cloth pant/top',
  'PANT/TOPBlueshimmer cloth pant/top',
  'CINE-16',
  370.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-16' 
       OR (p.slug = 'cine-16-panttopblueshimmer-cloth-panttop' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1423: CINE-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-15',
  'cine-15-panttopyellow-white-seq-top',
  'PANT/TOPYellow/ white seq top',
  'PANT/TOPYellow/ white seq top',
  'CINE-15',
  225.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-15' 
       OR (p.slug = 'cine-15-panttopyellow-white-seq-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1424: CINE-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-14',
  'cine-14-panttoppeacock-bluemajenta-sequence',
  'PANT/TOPPeacock blue/Majenta sequence',
  'PANT/TOPPeacock blue/Majenta sequence',
  'CINE-14',
  225.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-14' 
       OR (p.slug = 'cine-14-panttoppeacock-bluemajenta-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1425: CINE-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-13',
  'cine-13-panttopblue-top-yellow-pant',
  'PANT/TOPBlue top/ Yellow pant',
  'PANT/TOPBlue top/ Yellow pant',
  'CINE-13',
  225.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-13' 
       OR (p.slug = 'cine-13-panttopblue-top-yellow-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1426: CINE-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-12',
  'cine-12-panttopkilipacha-blue-seq-topblue-net-pant',
  'PANT/TOPKilipacha blue seq top/Blue net pant',
  'PANT/TOPKilipacha blue seq top/Blue net pant',
  'CINE-12',
  260.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-12' 
       OR (p.slug = 'cine-12-panttopkilipacha-blue-seq-topblue-net-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1427: CINE-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-11',
  'cine-11-panttopgold-green-red-pant-sleevless-top',
  'PANT/TOPGold green red pant/ sleevless top',
  'PANT/TOPGold green red pant/ sleevless top',
  'CINE-11',
  225.00,
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
    WHERE p.barcode = 'CINE-11' 
       OR (p.slug = 'cine-11-panttopgold-green-red-pant-sleevless-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1428: CINE-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-10',
  'cine-10-panttopredwhite-dot-shirtblack-pant',
  'PANT/TOPRed/white dot shirt/black pant',
  'PANT/TOPRed/white dot shirt/black pant',
  'CINE-10',
  225.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-10' 
       OR (p.slug = 'cine-10-panttopredwhite-dot-shirtblack-pant' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1429: CINE-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-9',
  'cine-9-panttopred-pant-black-seq-top',
  'PANT/TOPRed pant/ black seq top',
  'PANT/TOPRed pant/ black seq top',
  'CINE-9',
  250.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-9' 
       OR (p.slug = 'cine-9-panttopred-pant-black-seq-top' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1430: CINE-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-8',
  'cine-8-shirt-green',
  'SHIRT GREEN',
  'SHIRT GREEN',
  'CINE-8',
  125.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-8' 
       OR (p.slug = 'cine-8-shirt-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1431: CINE-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-7',
  'cine-7-shirt-black',
  'SHIRT BLACK',
  'SHIRT BLACK',
  'CINE-7',
  125.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-7' 
       OR (p.slug = 'cine-7-shirt-black' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1432: CINE-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-6',
  'cine-6-shirt-red',
  'SHIRT RED',
  'SHIRT RED',
  'CINE-6',
  125.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-6' 
       OR (p.slug = 'cine-6-shirt-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1433: CINE-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-5',
  'cine-5-shirt-pink',
  'SHIRT PINK',
  'SHIRT PINK',
  'CINE-5',
  125.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-5' 
       OR (p.slug = 'cine-5-shirt-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1434: CINE-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-4',
  'cine-4-pantshirtbluewbite',
  'PANT/SHIRTBLUE/WBITE',
  'PANT/SHIRTBLUE/WBITE',
  'CINE-4',
  325.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-4' 
       OR (p.slug = 'cine-4-pantshirtbluewbite' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1435: CINE-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-3',
  'cine-3-pantshirtblackred',
  'PANT/SHIRTBLACK.RED',
  'PANT/SHIRTBLACK.RED',
  'CINE-3',
  370.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-3' 
       OR (p.slug = 'cine-3-pantshirtblackred' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1436: CINE-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-2',
  'cine-2-rajastani-boysred',
  'RAJASTANI BOYSRED',
  'RAJASTANI BOYSRED',
  'CINE-2',
  325.00,
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
    WHERE p.barcode = 'CINE-2' 
       OR (p.slug = 'cine-2-rajastani-boysred' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1437: CINE-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'cinematic' AND store_id = s.id LIMIT 1),
  b.id,
  'CINE-1',
  'cine-1-rajastani-boysorange',
  'RAJASTANI BOYSORANGE',
  'RAJASTANI BOYSORANGE',
  'CINE-1',
  325.00,
  1500.00,
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
    WHERE p.barcode = 'CINE-1' 
       OR (p.slug = 'cine-1-rajastani-boysorange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1438: CCT-36
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-36',
  'cct-36-majenta-seq',
  'Majenta Seq',
  'Majenta Seq',
  'CCT-36',
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
    WHERE p.barcode = 'CCT-36' 
       OR (p.slug = 'cct-36-majenta-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1439: CCT-35
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-35',
  'cct-35-red-seq',
  'Red Seq',
  'Red Seq',
  'CCT-35',
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
    WHERE p.barcode = 'CCT-35' 
       OR (p.slug = 'cct-35-red-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1440: CCT-34
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-34',
  'cct-34-vadamulla-chest-coat',
  'Vadamulla chest coat',
  'Vadamulla chest coat',
  'CCT-34',
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
    WHERE p.barcode = 'CCT-34' 
       OR (p.slug = 'cct-34-vadamulla-chest-coat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1441: CCT-33
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-33',
  'cct-33-wine-colour-velvet',
  'Wine colour velvet',
  'Wine colour velvet',
  'CCT-33',
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
    WHERE p.barcode = 'CCT-33' 
       OR (p.slug = 'cct-33-wine-colour-velvet' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1442: CCT-32
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-32',
  'cct-32-purple-chest-coat',
  'Purple chest coat',
  'Purple chest coat',
  'CCT-32',
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
    WHERE p.barcode = 'CCT-32' 
       OR (p.slug = 'cct-32-purple-chest-coat' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1443: CCT-31
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-31',
  'cct-31-baby-pink-seq',
  'Baby pink SEq',
  'Baby pink SEq',
  'CCT-31',
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
    WHERE p.barcode = 'CCT-31' 
       OR (p.slug = 'cct-31-baby-pink-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1444: CCT-30
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-30',
  'cct-30-kilipacha-seq',
  'Kilipacha Seq',
  'Kilipacha Seq',
  'CCT-30',
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
    WHERE p.barcode = 'CCT-30' 
       OR (p.slug = 'cct-30-kilipacha-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1445: CCT-29
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-29',
  'cct-29-violet-sequence',
  'Violet Sequence',
  'Violet Sequence',
  'CCT-29',
  125.00,
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
    WHERE p.barcode = 'CCT-29' 
       OR (p.slug = 'cct-29-violet-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1446: CCT-28
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-28',
  'cct-28-purple-velvet-sequence',
  'Purple velvet sequence',
  'Purple velvet sequence',
  'CCT-28',
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
    WHERE p.barcode = 'CCT-28' 
       OR (p.slug = 'cct-28-purple-velvet-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1447: CCT-27
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-27',
  'cct-27-majenta-thick-small-sequence',
  'Majenta thick small sequence',
  'Majenta thick small sequence',
  'CCT-27',
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
    WHERE p.barcode = 'CCT-27' 
       OR (p.slug = 'cct-27-majenta-thick-small-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1448: CCT-26
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-26',
  'cct-26-gold-big-seq',
  'Gold big seq',
  'Gold big seq',
  'CCT-26',
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
    WHERE p.barcode = 'CCT-26' 
       OR (p.slug = 'cct-26-gold-big-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1449: CCT-25
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-25',
  'cct-25-multi-colour',
  'Multi colour',
  'Multi colour',
  'CCT-25',
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
    WHERE p.barcode = 'CCT-25' 
       OR (p.slug = 'cct-25-multi-colour' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1450: CCT-24
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-24',
  'cct-24-gold-small-seq',
  'Gold small seq',
  'Gold small seq',
  'CCT-24',
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
    WHERE p.barcode = 'CCT-24' 
       OR (p.slug = 'cct-24-gold-small-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1451: CCT-23
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-23',
  'cct-23-copper-suplhate-full-diamond-seq',
  'Copper suplhate full diamond seq',
  'Copper suplhate full diamond seq',
  'CCT-23',
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
    WHERE p.barcode = 'CCT-23' 
       OR (p.slug = 'cct-23-copper-suplhate-full-diamond-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1452: CCT-22
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-22',
  'cct-22-copper-sulphate-centre-diamond',
  'Copper sulphate centre diamond',
  'Copper sulphate centre diamond',
  'CCT-22',
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
    WHERE p.barcode = 'CCT-22' 
       OR (p.slug = 'cct-22-copper-sulphate-centre-diamond' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1453: CCT-21
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-21',
  'cct-21-copper-sulphate-blue-small-seq',
  'Copper sulphate blue small seq',
  'Copper sulphate blue small seq',
  'CCT-21',
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
    WHERE p.barcode = 'CCT-21' 
       OR (p.slug = 'cct-21-copper-sulphate-blue-small-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1454: CCT-20
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-20',
  'cct-20-black-majenta-tikky',
  'Black majenta tikky',
  'Black majenta tikky',
  'CCT-20',
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
    WHERE p.barcode = 'CCT-20' 
       OR (p.slug = 'cct-20-black-majenta-tikky' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1455: CCT-19
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-19',
  'cct-19-blackblue-leaf-design',
  'Black/Blue leaf design',
  'Black/Blue leaf design',
  'CCT-19',
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
    WHERE p.barcode = 'CCT-19' 
       OR (p.slug = 'cct-19-blackblue-leaf-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1456: CCT-17
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-17',
  'cct-17-black-gold-flower-design',
  'Black gold flower design',
  'Black gold flower design',
  'CCT-17',
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
    WHERE p.barcode = 'CCT-17' 
       OR (p.slug = 'cct-17-black-gold-flower-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1457: CCT-16
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-16',
  'cct-16-blue-big-seq',
  'Blue big seq',
  'Blue big seq',
  'CCT-16',
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
    WHERE p.barcode = 'CCT-16' 
       OR (p.slug = 'cct-16-blue-big-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1458: CCT-15
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-15',
  'cct-15-blue-small-seq',
  'Blue small seq',
  'Blue small seq',
  'CCT-15',
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
    WHERE p.barcode = 'CCT-15' 
       OR (p.slug = 'cct-15-blue-small-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1459: CCT-14
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-14',
  'cct-14-majenta-zig-zag-design',
  'Majenta zig zag design',
  'Majenta zig zag design',
  'CCT-14',
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
    WHERE p.barcode = 'CCT-14' 
       OR (p.slug = 'cct-14-majenta-zig-zag-design' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1460: CCT-13
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-13',
  'cct-13-green-silver-diamond',
  'Green silver diamond',
  'Green silver diamond',
  'CCT-13',
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
    WHERE p.barcode = 'CCT-13' 
       OR (p.slug = 'cct-13-green-silver-diamond' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1461: CCT-12
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-12',
  'cct-12-green-small-seq',
  'Green small seq',
  'Green small seq',
  'CCT-12',
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
    WHERE p.barcode = 'CCT-12' 
       OR (p.slug = 'cct-12-green-small-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1462: CCT-11
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-11',
  'cct-11-green-big-seq',
  'Green big seq',
  'Green big seq',
  'CCT-11',
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
    WHERE p.barcode = 'CCT-11' 
       OR (p.slug = 'cct-11-green-big-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1463: CCT-10
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-10',
  'cct-10-majenta-small-seq',
  'Majenta small seq',
  'Majenta small seq',
  'CCT-10',
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
    WHERE p.barcode = 'CCT-10' 
       OR (p.slug = 'cct-10-majenta-small-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1464: CCT-9
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-9',
  'cct-9-majenta-big-seq',
  'Majenta big seq',
  'Majenta big seq',
  'CCT-9',
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
    WHERE p.barcode = 'CCT-9' 
       OR (p.slug = 'cct-9-majenta-big-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1465: CCT-8
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-8',
  'cct-8-red-gold-mix-centre',
  'Red gold mix centre',
  'Red gold mix centre',
  'CCT-8',
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
    WHERE p.barcode = 'CCT-8' 
       OR (p.slug = 'cct-8-red-gold-mix-centre' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1466: CCT-7
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-7',
  'cct-7-red-big-seq',
  'Red big seq',
  'Red big seq',
  'CCT-7',
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
    WHERE p.barcode = 'CCT-7' 
       OR (p.slug = 'cct-7-red-big-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1467: CCT-6
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-6',
  'cct-6-red-small-seq',
  'Red small seq',
  'Red small seq',
  'CCT-6',
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
    WHERE p.barcode = 'CCT-6' 
       OR (p.slug = 'cct-6-red-small-seq' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1468: CCT-5
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-5',
  'cct-5-orange-gold-round-sequence',
  'Orange gold round sequence',
  'Orange gold round sequence',
  'CCT-5',
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
    WHERE p.barcode = 'CCT-5' 
       OR (p.slug = 'cct-5-orange-gold-round-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1469: CCT-4
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-4',
  'cct-4-black-longsequence',
  'Black longsequence',
  'Black longsequence',
  'CCT-4',
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
    WHERE p.barcode = 'CCT-4' 
       OR (p.slug = 'cct-4-black-longsequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1470: CCT-3
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-3',
  'cct-3-black-round-seqsilver-sequence',
  'Black round seq/Silver sequence',
  'Black round seq/Silver sequence',
  'CCT-3',
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
    WHERE p.barcode = 'CCT-3' 
       OR (p.slug = 'cct-3-black-round-seqsilver-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1471: CCT-2
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-2',
  'cct-2-black-gold-sequence',
  'Black gold sequence',
  'Black gold sequence',
  'CCT-2',
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
    WHERE p.barcode = 'CCT-2' 
       OR (p.slug = 'cct-2-black-gold-sequence' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1472: CCT-1
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = 'chest-coat' AND store_id = s.id LIMIT 1),
  b.id,
  'CCT-1',
  'cct-1-black-round-tikky',
  'Black round tikky',
  'Black round tikky',
  'CCT-1',
  80.00,
  300.00,
  29,
  29,
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = 'CCT-1' 
       OR (p.slug = 'cct-1-black-round-tikky' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1473: BHN-38/64
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
  'BHN-38/64',
  'bhn-3864-mehandi-green-majenta',
  'Mehandi green & majenta',
  'Mehandi green & majenta',
  'BHN-38/64',
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
    WHERE p.barcode = 'BHN-38/64' 
       OR (p.slug = 'bhn-3864-mehandi-green-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1474: BHN-38/7
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
  'BHN-38/7',
  'bhn-387-bluemajenta-beeding-type',
  'Blue/Majenta Beeding Type',
  'Blue/Majenta Beeding Type',
  'BHN-38/7',
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
    WHERE p.barcode = 'BHN-38/7' 
       OR (p.slug = 'bhn-387-bluemajenta-beeding-type' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1475: BHN-38/14
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
  'BHN-38/14',
  'bhn-3814-bluered-beeding-type',
  'Blue/Red Beeding type',
  'Blue/Red Beeding type',
  'BHN-38/14',
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
    WHERE p.barcode = 'BHN-38/14' 
       OR (p.slug = 'bhn-3814-bluered-beeding-type' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1476: BHN-38/63
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
  'BHN-38/63',
  'bhn-3863-green-marroon-saree',
  'Green Marroon saree',
  'Green Marroon saree',
  'BHN-38/63',
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
    WHERE p.barcode = 'BHN-38/63' 
       OR (p.slug = 'bhn-3863-green-marroon-saree' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1477: BHN-36/9
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
  'BHN-36/9',
  'bhn-369-red-gold',
  'Red Gold',
  'Red Gold',
  'BHN-36/9',
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
    WHERE p.barcode = 'BHN-36/9' 
       OR (p.slug = 'bhn-369-red-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1478: BHN-24/14
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
  'BHN-24/14',
  'bhn-2414-red-gold',
  'Red Gold',
  'Red Gold',
  'BHN-24/14',
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
    WHERE p.barcode = 'BHN-24/14' 
       OR (p.slug = 'bhn-2414-red-gold' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1479: BHN-24/13
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
  'BHN-24/13',
  'bhn-2413-kilipacha-red',
  'Kilipacha Red',
  'Kilipacha Red',
  'BHN-24/13',
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
    WHERE p.barcode = 'BHN-24/13' 
       OR (p.slug = 'bhn-2413-kilipacha-red' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1480: BHN-24/12
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
  'BHN-24/12',
  'bhn-2412-dark-green-majenta',
  'Dark Green Majenta',
  'Dark Green Majenta',
  'BHN-24/12',
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
    WHERE p.barcode = 'BHN-24/12' 
       OR (p.slug = 'bhn-2412-dark-green-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1481: BHN-24/11
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
  'BHN-24/11',
  'bhn-2411-skyblue-majenta',
  'Skyblue /Majenta',
  'Skyblue /Majenta',
  'BHN-24/11',
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
    WHERE p.barcode = 'BHN-24/11' 
       OR (p.slug = 'bhn-2411-skyblue-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1482: BHN-32/9
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
  'BHN-32/9',
  'bhn-329-orange-majenta',
  'Orange-Majenta',
  'Orange-Majenta',
  'BHN-32/9',
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
    WHERE p.barcode = 'BHN-32/9' 
       OR (p.slug = 'bhn-329-orange-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1483: BHN-32/13
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
  'BHN-32/13',
  'bhn-3213-chenkal-colour-violet-very-old',
  'Chenkal colour / violet very old',
  'Chenkal colour / violet very old',
  'BHN-32/13',
  325.00,
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
    WHERE p.barcode = 'BHN-32/13' 
       OR (p.slug = 'bhn-3213-chenkal-colour-violet-very-old' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1484: BHN-36/5
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
  'BHN-36/5',
  'bhn-365-vadamally-light-orange',
  'Vadamally Light Orange',
  'Vadamally Light Orange',
  'BHN-36/5',
  370.00,
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
    WHERE p.barcode = 'BHN-36/5' 
       OR (p.slug = 'bhn-365-vadamally-light-orange' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1485: BHN-36/54
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
  'BHN-36/54',
  'bhn-3654-yellored-brocaed-green',
  'Yello/Red Brocaed green',
  'Yello/Red Brocaed green',
  'BHN-36/54',
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
    WHERE p.barcode = 'BHN-36/54' 
       OR (p.slug = 'bhn-3654-yellored-brocaed-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1486: BHN-35/6
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
  'BHN-35/6',
  'bhn-356-orangevadamulla',
  'Orange/Vadamulla',
  'Orange/Vadamulla',
  'BHN-35/6',
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
    WHERE p.barcode = 'BHN-35/6' 
       OR (p.slug = 'bhn-356-orangevadamulla' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1487: BHN-34/22
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
  'BHN-34/22',
  'bhn-3422-red-gold-old',
  'Red Gold old',
  'Red Gold old',
  'BHN-34/22',
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
    WHERE p.barcode = 'BHN-34/22' 
       OR (p.slug = 'bhn-3422-red-gold-old' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1488: BHN-30/14
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
  'BHN-30/14',
  'bhn-3014-bottle-green-dotpurple',
  'Bottle green dot/Purple',
  'Bottle green dot/Purple',
  'BHN-30/14',
  1350.00,
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
    WHERE p.barcode = 'BHN-30/14' 
       OR (p.slug = 'bhn-3014-bottle-green-dotpurple' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1489: BHN-30/13
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
  'BHN-30/13',
  'bhn-3013-navy-blue-dot-majenta',
  'Navy Blue dot Majenta',
  'Navy Blue dot Majenta',
  'BHN-30/13',
  1350.00,
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
    WHERE p.barcode = 'BHN-30/13' 
       OR (p.slug = 'bhn-3013-navy-blue-dot-majenta' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1490: BHN-32/28
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
  'BHN-32/28',
  'bhn-3228-chilli-red-green-kh-parts',
  'Chilli Red green + KH parts',
  'Chilli Red green + KH parts',
  'BHN-32/28',
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
    WHERE p.barcode = 'BHN-32/28' 
       OR (p.slug = 'bhn-3228-chilli-red-green-kh-parts' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1491: BHN-32/27
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
  'BHN-32/27',
  'bhn-3227-merron-dark-green-kh-parts',
  'Merron dark green + KH parts',
  'Merron dark green + KH parts',
  'BHN-32/27',
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
    WHERE p.barcode = 'BHN-32/27' 
       OR (p.slug = 'bhn-3227-merron-dark-green-kh-parts' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1492: BHN-37/5
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
  'BHN-37/5',
  'bhn-375-viloet-and-merroon',
  'Viloet and Merroon',
  'Viloet and Merroon',
  'BHN-37/5',
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
    WHERE p.barcode = 'BHN-37/5' 
       OR (p.slug = 'bhn-375-viloet-and-merroon' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1493: BHN-37/3
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
  'BHN-37/3',
  'bhn-373-ink-blue',
  'Ink Blue',
  'Ink Blue',
  'BHN-37/3',
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
    WHERE p.barcode = 'BHN-37/3' 
       OR (p.slug = 'bhn-373-ink-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1494: BHN-34/36
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
  'BHN-34/36',
  'bhn-3436-royal-blue-majenta-kh-parts',
  'Royal blue Majenta + KH parts',
  'Royal blue Majenta + KH parts',
  'BHN-34/36',
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
    WHERE p.barcode = 'BHN-34/36' 
       OR (p.slug = 'bhn-3436-royal-blue-majenta-kh-parts' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1495: BHN-34/35
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
  'BHN-34/35',
  'bhn-3435-kiilipacha-purple',
  'kIilipacha Purple',
  'kIilipacha Purple',
  'BHN-34/35',
  1350.00,
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
    WHERE p.barcode = 'BHN-34/35' 
       OR (p.slug = 'bhn-3435-kiilipacha-purple' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1496: BHN-34/34
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
  'BHN-34/34',
  'bhn-3434-wine-offwhite',
  'Wine Offwhite',
  'Wine Offwhite',
  'BHN-34/34',
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
    WHERE p.barcode = 'BHN-34/34' 
       OR (p.slug = 'bhn-3434-wine-offwhite' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1497: BHN-36/14
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
  'BHN-36/14',
  'bhn-3614-red-blue-green',
  'Red Blue Green',
  'Red Blue Green',
  'BHN-36/14',
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
    WHERE p.barcode = 'BHN-36/14' 
       OR (p.slug = 'bhn-3614-red-blue-green' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1498: BHN-42/4
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
  'BHN-42/4',
  'bhn-424-brown-surf-blue',
  'Brown/ Surf blue',
  'Brown/ Surf blue',
  'BHN-42/4',
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
    WHERE p.barcode = 'BHN-42/4' 
       OR (p.slug = 'bhn-424-brown-surf-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1499: BHN-42/3
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
  'BHN-42/3',
  'bhn-423-dark-green-pink',
  'Dark green/ Pink',
  'Dark green/ Pink',
  'BHN-42/3',
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
    WHERE p.barcode = 'BHN-42/3' 
       OR (p.slug = 'bhn-423-dark-green-pink' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;

-- Product #1500: BHN-42/2
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
  'BHN-42/2',
  'bhn-422-red-blue',
  'Red/ Blue',
  'Red/ Blue',
  'BHN-42/2',
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
    WHERE p.barcode = 'BHN-42/2' 
       OR (p.slug = 'bhn-422-red-blue' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;


-- ════════════════════════════════════════════════════════════════════════════
-- GENERATE PRODUCT INVENTORY MAPPINGS FOR PART 3
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
