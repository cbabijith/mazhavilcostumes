-- ============================================================================
-- Product Batch 1: Products 1 to 100
-- ============================================================================


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red velvet myme dress', 'red-velvet-myme-dress', 'CINE-42', 500.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CINE-42' OR (slug = 'red-velvet-myme-dress' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange Marroon skirt cross frill saree type', 'orange-marroon-skirt-cross-frill-saree-type', 'SEMI-51', 1000.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-51' OR (slug = 'orange-marroon-skirt-cross-frill-saree-type' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black velvet Bahubali', 'black-velvet-bahubali', 'TOP-83', 125.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-83' OR (slug = 'black-velvet-bahubali' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black gold heavy Jacket', 'black-gold-heavy-jacket', 'OCT-57', 200.00, 16, 16, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-57' OR (slug = 'black-gold-heavy-jacket' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black Red Gujarathi', 'black-red-gujarathi', 'SKTP-126', 800.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-126' OR (slug = 'black-red-gujarathi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White black border folk', 'white-black-border-folk', 'SKTP-125', 500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-125' OR (slug = 'white-black-border-folk' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Offwhite/Red black border folk', 'offwhitered-black-border-folk', 'SKTP-124', 500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-124' OR (slug = 'offwhitered-black-border-folk' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Vadamulla orange folk', 'vadamulla-orange-folk', 'SKTP-123', 500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-123' OR (slug = 'vadamulla-orange-folk' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kilipacha Majenta folk', 'kilipacha-majenta-folk', 'SKTP-122', 500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-122' OR (slug = 'kilipacha-majenta-folk' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Thiruvathira Red', 'thiruvathira-red', 'TOP-82', 125.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-82' OR (slug = 'thiruvathira-red' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Thiruvathira Green', 'thiruvathira-green', 'TOP-81', 125.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-81' OR (slug = 'thiruvathira-green' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Plain green skirt BH', 'plain-green-skirt-bh', 'SEMI-50', 700.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-50' OR (slug = 'plain-green-skirt-bh' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Ravana set KG', 'ravana-set-kg', 'SEMI-49', 500.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-49' OR (slug = 'ravana-set-kg' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow net pant dawani', 'yellow-net-pant-dawani', 'SEMI-48', 350.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-48' OR (slug = 'yellow-net-pant-dawani' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Peacock blue', 'peacock-blue', 'SEMI-47', 600.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-47' OR (slug = 'peacock-blue' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green Red', 'green-red', 'SEMI-46', 600.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-46' OR (slug = 'green-red' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Royal blue red', 'royal-blue-red', 'SEMI-45', 600.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-45' OR (slug = 'royal-blue-red' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue oant Blue Seq top', 'blue-oant-blue-seq-top', 'CINE-41', 350.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CINE-41' OR (slug = 'blue-oant-blue-seq-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Slit Yellow red', 'slit-yellow-red', 'SKIRT-90', 175.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-90' OR (slug = 'slit-yellow-red' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Slit skirt blue green', 'slit-skirt-blue-green', 'SKIRT-89', 175.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-89' OR (slug = 'slit-skirt-blue-green' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White net with silver seq', 'white-net-with-silver-seq', 'SKIRT-88', 250.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-88' OR (slug = 'white-net-with-silver-seq' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White BH skirt', 'white-bh-skirt', 'SKIRT-87', 300.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-87' OR (slug = 'white-bh-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green seq velvet blouse', 'green-seq-velvet-blouse', 'TOP-80', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-80' OR (slug = 'green-seq-velvet-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White minukku cloth', 'white-minukku-cloth', 'TOP-79', 100.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-79' OR (slug = 'white-minukku-cloth' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'katak' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta net', 'majenta-net', 'KAT-17', 350.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KAT-17' OR (slug = 'majenta-net' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'katak' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red full set', 'red-full-set', 'KAT-16', 350.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KAT-16' OR (slug = 'red-full-set' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Vada,ulla small seq', 'vadaulla-small-seq', 'PANT-75', 200.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PANT-75' OR (slug = 'vadaulla-small-seq' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Rubber crown', 'rubber-crown', 'CROWN-46', 100.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-46' OR (slug = 'rubber-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Horror mask with wig', 'horror-mask-with-wig', 'MASK-11', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'MASK-11' OR (slug = 'horror-mask-with-wig' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta Big Seq', 'majenta-big-seq', 'OCT-56', 125.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-56' OR (slug = 'majenta-big-seq' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black multi colour seq', 'black-multi-colour-seq', 'OCT-55', 125.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-55' OR (slug = 'black-multi-colour-seq' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta Seq', 'majenta-seq', 'CCT-36', 100.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CCT-36' OR (slug = 'majenta-seq' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red Seq', 'red-seq', 'CCT-35', 100.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CCT-35' OR (slug = 'red-seq' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Vadamulla chest coat', 'vadamulla-chest-coat', 'CCT-34', 75.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CCT-34' OR (slug = 'vadamulla-chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Wine colour velvet', 'wine-colour-velvet', 'CCT-33', 100.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CCT-33' OR (slug = 'wine-colour-velvet' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Purple chest coat', 'purple-chest-coat', 'CCT-32', 75.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CCT-32' OR (slug = 'purple-chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Baby pink SEq', 'baby-pink-seq', 'CCT-31', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CCT-31' OR (slug = 'baby-pink-seq' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kilipacha Seq', 'kilipacha-seq', 'CCT-30', 75.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CCT-30' OR (slug = 'kilipacha-seq' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White Mayolpeeli skirt', 'white-mayolpeeli-skirt', 'SKTP-121', 600.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-121' OR (slug = 'white-mayolpeeli-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black orange folk', 'black-orange-folk', 'SKTP-120', 500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-120' OR (slug = 'black-orange-folk' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'katak' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta net', 'majenta-net', 'KAT-15', 300.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KAT-15' OR (slug = 'majenta-net' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'katak' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red anarkali', 'red-anarkali', 'KAT-14', 375.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KAT-14' OR (slug = 'red-anarkali' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black mirror skirt', 'black-mirror-skirt', 'SKTP-119', 400.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-119' OR (slug = 'black-mirror-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta mirror work small', 'majenta-mirror-work-small', 'SKTP-118', 400.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-118' OR (slug = 'majenta-mirror-work-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black cotton orange print border and stripes', 'black-cotton-orange-print-border-and-stripes', 'SKTP-117', 450.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-117' OR (slug = 'black-cotton-orange-print-border-and-stripes' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange cotton blue/green piping', 'orange-cotton-bluegreen-piping', 'SKTP-116', 400.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-116' OR (slug = 'orange-cotton-bluegreen-piping' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black cotton yellow print 3 layer border', 'black-cotton-yellow-print-3-layer-border', 'SKTP-115', 400.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-115' OR (slug = 'black-cotton-yellow-print-3-layer-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black mundu white red border with shawl', 'black-mundu-white-red-border-with-shawl', 'SKTP-114', 375.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-114' OR (slug = 'black-mundu-white-red-border-with-shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White cotton red/black lace with shawl', 'white-cotton-redblack-lace-with-shawl', 'SKTP-113', 375.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-113' OR (slug = 'white-cotton-redblack-lace-with-shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta velvet print SF', 'majenta-velvet-print-sf', 'PARTS-63SF', 50.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-63SF' OR (slug = 'majenta-velvet-print-sf' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta velvet print BS', 'majenta-velvet-print-bs', 'PARTS-63BS', 100.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-63BS' OR (slug = 'majenta-velvet-print-bs' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta velvet print HS', 'majenta-velvet-print-hs', 'PARTS-63HS', 100.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-63HS' OR (slug = 'majenta-velvet-print-hs' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta brocade SF', 'majenta-brocade-sf', 'PARTS-62SF', 50.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-62SF' OR (slug = 'majenta-brocade-sf' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta brocade BS', 'majenta-brocade-bs', 'PARTS-62BS', 100.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-62BS' OR (slug = 'majenta-brocade-bs' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta brocade HS', 'majenta-brocade-hs', 'PARTS-62HS', 100.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-62HS' OR (slug = 'majenta-brocade-hs' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green gold sequence full sleeve', 'green-gold-sequence-full-sleeve', 'OCT-54', 250.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-54' OR (slug = 'green-gold-sequence-full-sleeve' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black silver thread and sequence', 'black-silver-thread-and-sequence', 'SKIRT-86', 300.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-86' OR (slug = 'black-silver-thread-and-sequence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black cotton orange flower skirt', 'black-cotton-orange-flower-skirt', 'SKIRT-85', 300.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-85' OR (slug = 'black-cotton-orange-flower-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White skirt (tube work),Gold border', 'white-skirt-tube-workgold-border', 'SKIRT-84', 350.00, 13, 13, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-84' OR (slug = 'white-skirt-tube-workgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Violet Sequence', 'violet-sequence', 'CCT-29', 100.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CCT-29' OR (slug = 'violet-sequence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Purple velvet sequence', 'purple-velvet-sequence', 'CCT-28', 100.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CCT-28' OR (slug = 'purple-velvet-sequence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'chest-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta thick small sequence', 'majenta-thick-small-sequence', 'CCT-27', 100.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CCT-27' OR (slug = 'majenta-thick-small-sequence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Siva lingam light weight black', 'siva-lingam-light-weight-black', 'LINGAM-1', 400.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'LINGAM-1' OR (slug = 'siva-lingam-light-weight-black' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Theyyam vatta mudi small', 'theyyam-vatta-mudi-small', 'THEYYAM-2', 400.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'THEYYAM-2' OR (slug = 'theyyam-vatta-mudi-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Tree cutout big with stand', 'tree-cutout-big-with-stand', 'TREE-2', 350.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TREE-2' OR (slug = 'tree-cutout-big-with-stand' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pallakku', 'pallakku', 'PALLAKKU-1', 500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PALLAKKU-1' OR (slug = 'pallakku' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Nettipattam small', 'nettipattam-small', 'NETTIPATTAM-1', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'NETTIPATTAM-1' OR (slug = 'nettipattam-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Mayilpeeli wings tie at back', 'mayilpeeli-wings-tie-at-back', 'MAYILPEELI-1', 300.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'MAYILPEELI-1' OR (slug = 'mayilpeeli-wings-tie-at-back' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kalappa', 'kalappa', 'KALAPPA-1', 100.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KALAPPA-1' OR (slug = 'kalappa' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Theyyam big vatta mudi', 'theyyam-big-vatta-mudi', 'THEYYAM-1', 600.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'THEYYAM-1' OR (slug = 'theyyam-big-vatta-mudi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Tree cutout cardboard', 'tree-cutout-cardboard', 'TREE-1', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TREE-1' OR (slug = 'tree-cutout-cardboard' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Stick', 'stick', 'STICK-7', 50.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'STICK-7' OR (slug = 'stick' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold paint small pookooda', 'gold-paint-small-pookooda', 'POOKOODA-5', 75.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'POOKOODA-5' OR (slug = 'gold-paint-small-pookooda' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Nellu koriyidunna muram', 'nellu-koriyidunna-muram', 'MURAM-4', 200.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'MURAM-4' OR (slug = 'nellu-koriyidunna-muram' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kashmiri kutta', 'kashmiri-kutta', 'KUTTA-6', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KUTTA-6' OR (slug = 'kashmiri-kutta' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Hip tying belt with hand', 'hip-tying-belt-with-hand', 'HANDBELT-2', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'HANDBELT-2' OR (slug = 'hip-tying-belt-with-hand' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Skull mala plastic', 'skull-mala-plastic', 'SKULLMALA-2', 75.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKULLMALA-2' OR (slug = 'skull-mala-plastic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Head green paint/white paint', 'head-green-paintwhite-paint', 'HEAD-2', 100.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'HEAD-2' OR (slug = 'head-green-paintwhite-paint' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gadha gold new', 'gadha-gold-new', 'GADHA-3', 200.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'GADHA-3' OR (slug = 'gadha-gold-new' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'For hand,leg,head', 'for-handleghead', 'HANDCUFF-2', 275.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'HANDCUFF-2' OR (slug = 'for-handleghead' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'For hands on;y', 'for-hands-ony', 'HANDCUFF-1', 75.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'HANDCUFF-1' OR (slug = 'for-hands-ony' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Bhadrakali hand-6', 'bhadrakali-hand-6', 'HAND-1', 300.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'HAND-1' OR (slug = 'bhadrakali-hand-6' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Tricolour cap', 'tricolour-cap', 'CAP-17', 75.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-17' OR (slug = 'tricolour-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Thatha koodu', 'thatha-koodu', 'KOODU-1', 100.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KOODU-1' OR (slug = 'thatha-koodu' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Small ranthal', 'small-ranthal', 'RANTHAL-2', 75.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'RANTHAL-2' OR (slug = 'small-ranthal' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Big ranthal', 'big-ranthal', 'RANTHAL-1', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'RANTHAL-1' OR (slug = 'big-ranthal' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kutta for pookari', 'kutta-for-pookari', 'KUTTA-8', 100.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KUTTA-8' OR (slug = 'kutta-for-pookari' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kutta with cover lid', 'kutta-with-cover-lid', 'KUTTA-7', 100.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KUTTA-7' OR (slug = 'kutta-with-cover-lid' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'B;ack cardboard simple', 'back-cardboard-simple', 'CROWN-45', 50.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-45' OR (slug = 'back-cardboard-simple' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow red rain drop arch', 'yellow-red-rain-drop-arch', 'CROWN-44', 75.00, 16, 16, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-44' OR (slug = 'yellow-red-rain-drop-arch' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Sponge centre crown/thick yellow stone', 'sponge-centre-crownthick-yellow-stone', 'CROWN-43', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-43' OR (slug = 'sponge-centre-crownthick-yellow-stone' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White pearl blue rain drop', 'white-pearl-blue-rain-drop', 'CROWN-42', 75.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-42' OR (slug = 'white-pearl-blue-rain-drop' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White stone/ blue green beeds', 'white-stone-blue-green-beeds', 'CROWN-41', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-41' OR (slug = 'white-stone-blue-green-beeds' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Silver kudam type', 'silver-kudam-type', 'CROWN-40', 75.00, 14, 14, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-40' OR (slug = 'silver-kudam-type' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White pearl/green raindrop round', 'white-pearlgreen-raindrop-round', 'CROWN-39', 75.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-39' OR (slug = 'white-pearlgreen-raindrop-round' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White stone with red raindrop', 'white-stone-with-red-raindrop', 'CROWN-38', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-38' OR (slug = 'white-stone-with-red-raindrop' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Ravana Crown', 'ravana-crown', 'CROWN-37', 300.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-37' OR (slug = 'ravana-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Dhandiya Stick', 'dhandiya-stick', 'STICK-6', 25.00, 30, 30, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'STICK-6' OR (slug = 'dhandiya-stick' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta Rajasthani skirt blue blouse shawl Adult', 'majenta-rajasthani-skirt-blue-blouse-shawl-adult', 'SKTP-112', 750.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-112' OR (slug = 'majenta-rajasthani-skirt-blue-blouse-shawl-adult' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta Rajasthani skirt blue blouse shawl new', 'majenta-rajasthani-skirt-blue-blouse-shawl-new', 'SKTP-111', 600.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-111' OR (slug = 'majenta-rajasthani-skirt-blue-blouse-shawl-new' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));
