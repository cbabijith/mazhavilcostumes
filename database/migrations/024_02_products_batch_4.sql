-- ============================================================================
-- Product Batch 4: Products 301 to 400
-- ============================================================================


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red satin dhothi pant thin border', 'red-satin-dhothi-pant-thin-border', 'PANT-63', 100.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PANT-63' OR (slug = 'red-satin-dhothi-pant-thin-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue polyster dhothi pant', 'blue-polyster-dhothi-pant', 'PANT-62', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PANT-62' OR (slug = 'blue-polyster-dhothi-pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black small seq pant', 'black-small-seq-pant', 'PANT-61', 150.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PANT-61' OR (slug = 'black-small-seq-pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White brocade sunfleet pant', 'white-brocade-sunfleet-pant', 'PANT-60', 300.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PANT-60' OR (slug = 'white-brocade-sunfleet-pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold tissue sleeveless coat', 'gold-tissue-sleeveless-coat', 'OCT-44', 75.00, 18, 18, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-44' OR (slug = 'gold-tissue-sleeveless-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange long sleeveless coat', 'orange-long-sleeveless-coat', 'OCT-43', 75.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-43' OR (slug = 'orange-long-sleeveless-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold small sequence sleeveless coat', 'gold-small-sequence-sleeveless-coat', 'OCT-42', 75.00, 18, 18, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-42' OR (slug = 'gold-small-sequence-sleeveless-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red gold sequence full sleeve Jacket', 'red-gold-sequence-full-sleeve-jacket', 'OCT-41', 225.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-41' OR (slug = 'red-gold-sequence-full-sleeve-jacket' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yello/Red Brocaed green', 'yellored-brocaed-green', 'BHN-36/54', 1500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-36/54' OR (slug = 'yellored-brocaed-green' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange/Vadamulla', 'orangevadamulla', 'BHN-35/6', 1200.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-35/6' OR (slug = 'orangevadamulla' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red Gold old', 'red-gold-old', 'BHN-34/22', 450.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-34/22' OR (slug = 'red-gold-old' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Bottle green dot/Purple', 'bottle-green-dotpurple', 'BHN-30/14', 1300.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-30/14' OR (slug = 'bottle-green-dotpurple' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Navy Blue dot Majenta', 'navy-blue-dot-majenta', 'BHN-30/13', 1300.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-30/13' OR (slug = 'navy-blue-dot-majenta' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Chilli Red green + KH parts', 'chilli-red-green-kh-parts', 'BHN-32/28', 1500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-32/28' OR (slug = 'chilli-red-green-kh-parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Merron dark green + KH parts', 'merron-dark-green-kh-parts', 'BHN-32/27', 1500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-32/27' OR (slug = 'merron-dark-green-kh-parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Viloet and Merroon', 'viloet-and-merroon', 'BHN-37/5', 1500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-37/5' OR (slug = 'viloet-and-merroon' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Ink Blue', 'ink-blue', 'BHN-37/3', 800.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-37/3' OR (slug = 'ink-blue' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Royal blue Majenta + KH parts', 'royal-blue-majenta-kh-parts', 'BHN-34/36', 1500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-34/36' OR (slug = 'royal-blue-majenta-kh-parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'kIilipacha Purple', 'kiilipacha-purple', 'BHN-34/35', 1300.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-34/35' OR (slug = 'kiilipacha-purple' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Wine Offwhite', 'wine-offwhite', 'BHN-34/34', 650.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-34/34' OR (slug = 'wine-offwhite' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red Blue Green', 'red-blue-green', 'BHN-36/14', 500.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-36/14' OR (slug = 'red-blue-green' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'SKY BLUE SEQUENCE MEDIUM', 'sky-blue-sequence-medium', 'SHAWL-40', 30.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-40' OR (slug = 'sky-blue-sequence-medium' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'SKY BLUE NET', 'sky-blue-net', 'SHAWL-39', 30.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-39' OR (slug = 'sky-blue-net' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'BLUE/GOLD BORDER', 'bluegold-border', 'SHAWL-38', 30.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-38' OR (slug = 'bluegold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GREEN/BLUE BORDER SMALL', 'greenblue-border-small', 'SHAWL-37', 30.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-37' OR (slug = 'greenblue-border-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GREEN/BLUE BORDER', 'greenblue-border', 'SHAWL-36', 30.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-36' OR (slug = 'greenblue-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GREEN NET/ GOLD DOT MEDIUM', 'green-net-gold-dot-medium', 'SHAWL-35', 30.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-35' OR (slug = 'green-net-gold-dot-medium' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GREEN/GOLD BORDER SMALL', 'greengold-border-small', 'SHAWL-34', 30.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-34' OR (slug = 'greengold-border-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GREEN/GOLD BORDER LARGE', 'greengold-border-large', 'SHAWL-33', 30.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-33' OR (slug = 'greengold-border-large' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GREEN NET/GOLD BORDER MEDIUM', 'green-netgold-border-medium', 'SHAWL-32', 30.00, 13, 13, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-32' OR (slug = 'green-netgold-border-medium' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'ORANGE/GOLD BORDER LARGE', 'orangegold-border-large', 'SHAWL-31', 30.00, 16, 16, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-31' OR (slug = 'orangegold-border-large' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'ORANGE /GOLD BORDER MEDIUM', 'orange-gold-border-medium', 'SHAWL-30', 30.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-30' OR (slug = 'orange-gold-border-medium' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED EMBROIDERY', 'red-embroidery', 'SHAWL-29', 30.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-29' OR (slug = 'red-embroidery' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED/GOLD EMBROIDERY MEDIUM', 'redgold-embroidery-medium', 'SHAWL-28', 30.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-28' OR (slug = 'redgold-embroidery-medium' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED/GOLD DOT SMALL', 'redgold-dot-small', 'SHAWL-27', 30.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-27' OR (slug = 'redgold-dot-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED NET/BIG DOT SMALL SIZE', 'red-netbig-dot-small-size', 'SHAWL-26', 30.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-26' OR (slug = 'red-netbig-dot-small-size' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED/GOLD BORDER', 'redgold-border', 'SHAWL-25', 30.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-25' OR (slug = 'redgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED PLAIN NET', 'red-plain-net', 'SHAWL-24', 30.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-24' OR (slug = 'red-plain-net' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED/SILVER BORDER', 'redsilver-border', 'SHAWL-23', 30.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-23' OR (slug = 'redsilver-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED PLAIN', 'red-plain', 'SHAWL-22', 30.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-22' OR (slug = 'red-plain' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'WHITE/SILVER BORDER MEDIUM', 'whitesilver-border-medium', 'SHAWL-21', 30.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-21' OR (slug = 'whitesilver-border-medium' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'WHITE NET', 'white-net', 'SHAWL-20', 30.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-20' OR (slug = 'white-net' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'WHITE PLAIN', 'white-plain', 'SHAWL-19', 30.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-19' OR (slug = 'white-plain' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'BLACK/GREEN BORDER', 'blackgreen-border', 'SHAWL-18', 30.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-18' OR (slug = 'blackgreen-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'BLACK/SMALL DOT', 'blacksmall-dot', 'SHAWL-17', 30.00, 13, 13, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-17' OR (slug = 'blacksmall-dot' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'BLACK/GOLD BORDER', 'blackgold-border', 'SHAWL-16', 30.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-16' OR (slug = 'blackgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'PLAIN MAJENTA', 'plain-majenta', 'SHAWL-15', 30.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-15' OR (slug = 'plain-majenta' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'MAGENTA GOLD EMBROIDERY', 'magenta-gold-embroidery', 'SHAWL-14', 30.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-14' OR (slug = 'magenta-gold-embroidery' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'MAJENTA DOT MEDIUM', 'majenta-dot-medium', 'SHAWL-13', 30.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-13' OR (slug = 'majenta-dot-medium' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'MAJENTA SMALL', 'majenta-small', 'SHAWL-12', 30.00, 13, 13, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-12' OR (slug = 'majenta-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'MAJENTA BORDER EMBROIDERY', 'majenta-border-embroidery', 'SHAWL-11', 30.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-11' OR (slug = 'majenta-border-embroidery' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD EMBROIDERY', 'gold-embroidery', 'SHAWL-10', 30.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-10' OR (slug = 'gold-embroidery' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD NET DOT SEQUENCE', 'gold-net-dot-sequence', 'SHAWL-9', 30.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-9' OR (slug = 'gold-net-dot-sequence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD NET MIRROR', 'gold-net-mirror', 'SHAWL-8', 30.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-8' OR (slug = 'gold-net-mirror' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD NET', 'gold-net', 'SHAWL-7', 30.00, 16, 16, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-7' OR (slug = 'gold-net' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD/GOLD SATIN', 'goldgold-satin', 'SHAWL-6', 30.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-6' OR (slug = 'goldgold-satin' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD/GOLD BORDER', 'goldgold-border', 'SHAWL-5', 30.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-5' OR (slug = 'goldgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD/BLACK BORDER', 'goldblack-border', 'SHAWL-4', 30.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-4' OR (slug = 'goldblack-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD /PEARL', 'gold-pearl', 'SHAWL-3', 30.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-3' OR (slug = 'gold-pearl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD BIG DOTS', 'gold-big-dots', 'SHAWL-2', 30.00, 38, 38, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-2' OR (slug = 'gold-big-dots' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'shawl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD SEQUENCE DOT', 'gold-sequence-dot', 'SHAWL-1', 30.00, 15, 15, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SHAWL-1' OR (slug = 'gold-sequence-dot' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow full sequence', 'yellow-full-sequence', 'TOP-65', 75.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-65' OR (slug = 'yellow-full-sequence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pink full seq top long', 'pink-full-seq-top-long', 'TOP-64', 125.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-64' OR (slug = 'pink-full-seq-top-long' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold full seq top long', 'gold-full-seq-top-long', 'TOP-63', 125.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-63' OR (slug = 'gold-full-seq-top-long' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black net gold dot', 'black-net-gold-dot', 'TOP-62', 125.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-62' OR (slug = 'black-net-gold-dot' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pista gree gold border', 'pista-gree-gold-border', 'TOP-61', 100.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-61' OR (slug = 'pista-gree-gold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red seq top gold border', 'red-seq-top-gold-border', 'TOP-60', 100.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-60' OR (slug = 'red-seq-top-gold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red satin black design neck top', 'red-satin-black-design-neck-top', 'TOP-59', 100.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-59' OR (slug = 'red-satin-black-design-neck-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue plain with gold border XL', 'blue-plain-with-gold-border-xl', 'TOP-58', 100.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-58' OR (slug = 'blue-plain-with-gold-border-xl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pink with gold border XL', 'pink-with-gold-border-xl', 'TOP-57', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-57' OR (slug = 'pink-with-gold-border-xl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green with gold border XL', 'green-with-gold-border-xl', 'TOP-56', 100.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-56' OR (slug = 'green-with-gold-border-xl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red with gold border XL', 'red-with-gold-border-xl', 'TOP-55', 100.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-55' OR (slug = 'red-with-gold-border-xl' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Plain red with border', 'plain-red-with-border', 'TOP-54', 75.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-54' OR (slug = 'plain-red-with-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Plain red blouse(No brocade)', 'plain-red-blouseno-brocade', 'TOP-53', 75.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-53' OR (slug = 'plain-red-blouseno-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue check brocade thiruvatira blouse', 'blue-check-brocade-thiruvatira-blouse', 'TOP-52', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-52' OR (slug = 'blue-check-brocade-thiruvatira-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green check brocadeThiruvathira blouse', 'green-check-brocadethiruvathira-blouse', 'TOP-51', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-51' OR (slug = 'green-check-brocadethiruvathira-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta brocade blouse', 'majenta-brocade-blouse', 'TOP-50', 100.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-50' OR (slug = 'majenta-brocade-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue brocade blouse', 'blue-brocade-blouse', 'TOP-49', 100.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-49' OR (slug = 'blue-brocade-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange velvet', 'orange-velvet', 'TOP-48', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-48' OR (slug = 'orange-velvet' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pista green blouse', 'pista-green-blouse', 'TOP-47', 100.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-47' OR (slug = 'pista-green-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red white flower', 'red-white-flower', 'TOP-46', 75.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-46' OR (slug = 'red-white-flower' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black dot small', 'black-dot-small', 'TOP-45', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-45' OR (slug = 'black-dot-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta brocade', 'majenta-brocade', 'TOP-44', 100.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-44' OR (slug = 'majenta-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White/Red dot', 'whitered-dot', 'TOP-43', 50.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-43' OR (slug = 'whitered-dot' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GREEN/YELLOW DOT PUFF', 'greenyellow-dot-puff', 'TOP-42', 40.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-42' OR (slug = 'greenyellow-dot-puff' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'BLUE GOLD', 'blue-gold', 'TOP-41', 100.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-41' OR (slug = 'blue-gold' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'ORANGE FULL SLEEVE', 'orange-full-sleeve', 'TOP-40', 75.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-40' OR (slug = 'orange-full-sleeve' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD FULL', 'gold-full', 'TOP-39', 75.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-39' OR (slug = 'gold-full' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'SILVER/BLACK', 'silverblack', 'TOP-38', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-38' OR (slug = 'silverblack' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'BLACK/GOLD', 'blackgold', 'TOP-37', 125.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-37' OR (slug = 'blackgold' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RAJASTANI BLOUSE', 'rajastani-blouse', 'TOP-36', 100.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-36' OR (slug = 'rajastani-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'MAJENTA/GREEN', 'majentagreen', 'TOP-35', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-35' OR (slug = 'majentagreen' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'MAJENTA/BLUE', 'majentablue', 'TOP-34', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-34' OR (slug = 'majentablue' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GREEN SEQUENCE', 'green-sequence', 'TOP-33', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-33' OR (slug = 'green-sequence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GREEN MIRROR', 'green-mirror', 'TOP-32', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-32' OR (slug = 'green-mirror' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'BLACK PUFF', 'black-puff', 'TOP-31', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-31' OR (slug = 'black-puff' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'LIGHT YELLOW PUFF', 'light-yellow-puff', 'TOP-30', 100.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-30' OR (slug = 'light-yellow-puff' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'YELLOW PUFF', 'yellow-puff', 'TOP-29', 75.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-29' OR (slug = 'yellow-puff' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'BLUE/PINK', 'bluepink', 'TOP-28', 75.00, 15, 15, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-28' OR (slug = 'bluepink' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'VIOLET', 'violet', 'TOP-27', 75.00, 13, 13, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-27' OR (slug = 'violet' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));
