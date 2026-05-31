-- ============================================================================
-- Product Batch 3: Products 201 to 300
-- ============================================================================


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yello net /Gold lace border', 'yello-net-gold-lace-border', 'PANT-67', 125.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PANT-67' OR (slug = 'yello-net-gold-lace-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta net patiyala with blue gold seq border', 'majenta-net-patiyala-with-blue-gold-seq-border', 'PANT-66', 150.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PANT-66' OR (slug = 'majenta-net-patiyala-with-blue-gold-seq-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Sky blue dot net majenta velvet border', 'sky-blue-dot-net-majenta-velvet-border', 'SKIRT-83', 200.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-83' OR (slug = 'sky-blue-dot-net-majenta-velvet-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red net gold seq border', 'red-net-gold-seq-border', 'SKIRT-82', 200.00, 14, 14, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-82' OR (slug = 'red-net-gold-seq-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Off whiteflower design long top', 'off-whiteflower-design-long-top', 'TOP-72', 100.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-72' OR (slug = 'off-whiteflower-design-long-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red white polka dot top', 'red-white-polka-dot-top', 'TOP-71', 100.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-71' OR (slug = 'red-white-polka-dot-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black puff sleevesmall top', 'black-puff-sleevesmall-top', 'TOP-70', 100.00, 15, 15, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-70' OR (slug = 'black-puff-sleevesmall-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green brocade puff short top', 'green-brocade-puff-short-top', 'TOP-69', 125.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-69' OR (slug = 'green-brocade-puff-short-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold puff sleeve long top', 'gold-puff-sleeve-long-top', 'TOP-68', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-68' OR (slug = 'gold-puff-sleeve-long-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Full plain blackLong top', 'full-plain-blacklong-top', 'TOP-67', 125.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-67' OR (slug = 'full-plain-blacklong-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold satin sleeveless top king', 'gold-satin-sleeveless-top-king', 'TOP-66', 100.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'TOP-66' OR (slug = 'gold-satin-sleeveless-top-king' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red seq gold border sleeveless coat', 'red-seq-gold-border-sleeveless-coat', 'OCT-49', 100.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-49' OR (slug = 'red-seq-gold-border-sleeveless-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange seq short sleeve shirt', 'orange-seq-short-sleeve-shirt', 'OCT-48', 125.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-48' OR (slug = 'orange-seq-short-sleeve-shirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White silver small seq coat KG size', 'white-silver-small-seq-coat-kg-size', 'OCT-47', 75.00, 14, 14, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-47' OR (slug = 'white-silver-small-seq-coat-kg-size' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White silver small se sleeveless overcoat', 'white-silver-small-se-sleeveless-overcoat', 'OCT-46', 125.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-46' OR (slug = 'white-silver-small-se-sleeveless-overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'overcoat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White silver big seq sleeveless coat', 'white-silver-big-seq-sleeveless-coat', 'OCT-45', 150.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'OCT-45' OR (slug = 'white-silver-big-seq-sleeveless-coat' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White pleated pant & saree net dot no blouse', 'white-pleated-pant-saree-net-dot-no-blouse', 'SEMI-40', 1000.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-40' OR (slug = 'white-pleated-pant-saree-net-dot-no-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black red dot kids', 'black-red-dot-kids', 'SKTP-13', 275.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-13' OR (slug = 'black-red-dot-kids' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black silver peach sequence', 'black-silver-peach-sequence', 'SKTP-83', 275.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-83' OR (slug = 'black-silver-peach-sequence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black plain & seq velvet mix long fan only', 'black-plain-seq-velvet-mix-long-fan-only', 'PARTS-48LF', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-48LF' OR (slug = 'black-plain-seq-velvet-mix-long-fan-only' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta net round design border', 'majenta-net-round-design-border', 'PARTS-45LF', 100.00, 17, 17, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-45LF' OR (slug = 'majenta-net-round-design-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Light Orange with orange round seq border', 'light-orange-with-orange-round-seq-border', 'PARTS-47BS', 75.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-47BS' OR (slug = 'light-orange-with-orange-round-seq-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta net round design border', 'majenta-net-round-design-border', 'PARTS-45SF', 75.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-45SF' OR (slug = 'majenta-net-round-design-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black Velvet Seq LF', 'black-velvet-seq-lf', 'PARTS-52LF', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-52LF' OR (slug = 'black-velvet-seq-lf' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Merroon Velvet Kacha', 'merroon-velvet-kacha', 'PARTS-51HS', 100.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-51HS' OR (slug = 'merroon-velvet-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Merroon Velvet Kachs LF', 'merroon-velvet-kachs-lf', 'PARTS-51LF', 100.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-51LF' OR (slug = 'merroon-velvet-kachs-lf' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Merroon Velvet Kacha BS', 'merroon-velvet-kacha-bs', 'PARTS-51BS', 100.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-51BS' OR (slug = 'merroon-velvet-kacha-bs' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Dark Blue Light Blue check saree semi', 'dark-blue-light-blue-check-saree-semi', 'SEMI-39', 1200.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-39' OR (slug = 'dark-blue-light-blue-check-saree-semi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green Blue check mode; semi', 'green-blue-check-mode-semi', 'SEMI-38', 1200.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-38' OR (slug = 'green-blue-check-mode-semi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Violet Majenta Saree model semi', 'violet-majenta-saree-model-semi', 'SEMI-37', 1250.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-37' OR (slug = 'violet-majenta-saree-model-semi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Lavender light violet Tutu Skirt', 'lavender-light-violet-tutu-skirt', 'SKIRT-81', 175.00, 15, 15, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-81' OR (slug = 'lavender-light-violet-tutu-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pink Polka dot tutu skirt', 'pink-polka-dot-tutu-skirt', 'SKIRT-80', 175.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-80' OR (slug = 'pink-polka-dot-tutu-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'yellow net Sunflower  skirt small', 'yellow-net-sunflower-skirt-small', 'SKIRT-79', 175.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-79' OR (slug = 'yellow-net-sunflower-skirt-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Royal blue net gold dot skirt with Gold border', 'royal-blue-net-gold-dot-skirt-with-gold-border', 'SKIRT-78', 225.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-78' OR (slug = 'royal-blue-net-gold-dot-skirt-with-gold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Lion', 'lion', 'CUTOUT-3', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CUTOUT-3' OR (slug = 'lion' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kaala', 'kaala', 'CUTOUT-2', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CUTOUT-2' OR (slug = 'kaala' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Elephant front view', 'elephant-front-view', 'CUTOUT-1', 250.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CUTOUT-1' OR (slug = 'elephant-front-view' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Charka', 'charka', 'CHARKA-1', 100.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CHARKA-1' OR (slug = 'charka' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'New Thrishur Kavadi', 'new-thrishur-kavadi', 'KAVADI-4', 125.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KAVADI-4' OR (slug = 'new-thrishur-kavadi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Bamboo pookooda', 'bamboo-pookooda', 'POOKOODA-4', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'POOKOODA-4' OR (slug = 'bamboo-pookooda' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black wire', 'black-wire', 'POOKOODA-3', 75.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'POOKOODA-3' OR (slug = 'black-wire' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Light weight Oval', 'light-weight-oval', 'POOKOODA-2', 75.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'POOKOODA-2' OR (slug = 'light-weight-oval' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red black velvet kudam', 'red-black-velvet-kudam', 'KUDAM-4', 125.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'KUDAM-4' OR (slug = 'red-black-velvet-kudam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta green blue red mix', 'majenta-green-blue-red-mix', 'POMSTICK-3', 25.00, 38, 38, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'POMSTICK-3' OR (slug = 'majenta-green-blue-red-mix' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Silver', 'silver', 'POMSTICK-2', 30.00, 20, 20, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'POMSTICK-2' OR (slug = 'silver' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold', 'gold', 'POMSTICK-1', 30.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'POMSTICK-1' OR (slug = 'gold' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Narasimham Mask', 'narasimham-mask', 'MASK-10', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'MASK-10' OR (slug = 'narasimham-mask' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Halloween Mask', 'halloween-mask', 'MASK-9', 40.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'MASK-9' OR (slug = 'halloween-mask' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Light weight veena', 'light-weight-veena', 'VEENA-4', 250.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'VEENA-4' OR (slug = 'light-weight-veena' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Butterfly wings Pink', 'butterfly-wings-pink', 'BUTTERFLY-3', 30.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BUTTERFLY-3' OR (slug = 'butterfly-wings-pink' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Butterfly wings white', 'butterfly-wings-white', 'BUTTERFLY-2', 30.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BUTTERFLY-2' OR (slug = 'butterfly-wings-white' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'New Krishna stone kettu crown', 'new-krishna-stone-kettu-crown', 'CROWN-36', 100.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-36' OR (slug = 'new-krishna-stone-kettu-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Swathi Thirunal crown', 'swathi-thirunal-crown', 'CROWN-35', 250.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-35' OR (slug = 'swathi-thirunal-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Mayilpeeli crown', 'mayilpeeli-crown', 'CROWN-34', 100.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-34' OR (slug = 'mayilpeeli-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black velvet 5 kombu crown', 'black-velvet-5-kombu-crown', 'CROWN-33', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-33' OR (slug = 'black-velvet-5-kombu-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gandharva crown', 'gandharva-crown', 'CROWN-32', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-32' OR (slug = 'gandharva-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'bharathanattyam' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Vadamally Light Orange', 'vadamally-light-orange', 'BHN-36/5', 350.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BHN-36/5' OR (slug = 'vadamally-light-orange' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Ping seq top/silver pant', 'ping-seq-topsilver-pant', 'CINE-31', 300.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CINE-31' OR (slug = 'ping-seq-topsilver-pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red shimmer pant top', 'red-shimmer-pant-top', 'CINE-30', 325.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CINE-30' OR (slug = 'red-shimmer-pant-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pink shirt blue trouser tie', 'pink-shirt-blue-trouser-tie', 'CINE-29', 250.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CINE-29' OR (slug = 'pink-shirt-blue-trouser-tie' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pink shirt blue trouser tie', 'pink-shirt-blue-trouser-tie', 'CINE-28', 300.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CINE-28' OR (slug = 'pink-shirt-blue-trouser-tie' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red velvet black work top pant', 'red-velvet-black-work-top-pant', 'CINE-27', 350.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CINE-27' OR (slug = 'red-velvet-black-work-top-pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Offwhite shimmer cloth pant top', 'offwhite-shimmer-cloth-pant-top', 'CINE-26', 350.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CINE-26' OR (slug = 'offwhite-shimmer-cloth-pant-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Silver seq pant/Gold seq sleeveless top', 'silver-seq-pantgold-seq-sleeveless-top', 'CINE-25', 300.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CINE-25' OR (slug = 'silver-seq-pantgold-seq-sleeveless-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'cinematic' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold seq pant/Gold top', 'gold-seq-pantgold-top', 'CINE-24', 275.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CINE-24' OR (slug = 'gold-seq-pantgold-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue Rajasthani', 'blue-rajasthani', 'SKTP-82', 600.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-82' OR (slug = 'blue-rajasthani' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Merrron Rajasthani', 'merrron-rajasthani', 'SKTP-81', 600.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-81' OR (slug = 'merrron-rajasthani' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red Gujarati small', 'red-gujarati-small', 'SKTP-80', 400.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-80' OR (slug = 'red-gujarati-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red flaired Rajasthani', 'red-flaired-rajasthani', 'SKTP-79', 600.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-79' OR (slug = 'red-flaired-rajasthani' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White skirt Rajasthani set', 'white-skirt-rajasthani-set', 'SKTP-78', 600.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-78' OR (slug = 'white-skirt-rajasthani-set' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White skirt Rajasthani set', 'white-skirt-rajasthani-set', 'SKTP-77', 600.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-77' OR (slug = 'white-skirt-rajasthani-set' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta skirt yellow blouse', 'majenta-skirt-yellow-blouse', 'SKTP-76', 600.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-76' OR (slug = 'majenta-skirt-yellow-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black red Rajasthani blaack blouse', 'black-red-rajasthani-blaack-blouse', 'SKTP-75', 600.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-75' OR (slug = 'black-red-rajasthani-blaack-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold big seq top skirt', 'gold-big-seq-top-skirt', 'SKTP-74', 275.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-74' OR (slug = 'gold-big-seq-top-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pink shirt bluejean cloth skirt bow tie', 'pink-shirt-bluejean-cloth-skirt-bow-tie', 'SKTP-73', 300.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-73' OR (slug = 'pink-shirt-bluejean-cloth-skirt-bow-tie' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White net sjirtGold big seq top,gloves', 'white-net-sjirtgold-big-seq-topgloves', 'SKTP-72', 300.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-72' OR (slug = 'white-net-sjirtgold-big-seq-topgloves' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red white dot skirt white blouse', 'red-white-dot-skirt-white-blouse', 'SKTP-71', 100.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-71' OR (slug = 'red-white-dot-skirt-white-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue net skirt white seq top (KG)', 'blue-net-skirt-white-seq-top-kg', 'SKTP-70', 225.00, 21, 21, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-70' OR (slug = 'blue-net-skirt-white-seq-top-kg' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue Rajasthani', 'blue-rajasthani', 'SKTP-69', 350.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-69' OR (slug = 'blue-rajasthani' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt-top' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow Rajasthani', 'yellow-rajasthani', 'SKTP-68', 400.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKTP-68' OR (slug = 'yellow-rajasthani' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow velvet seq kacha', 'yellow-velvet-seq-kacha', 'PARTS-49HS', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-49HS' OR (slug = 'yellow-velvet-seq-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Light Orange with orange round seq border', 'light-orange-with-orange-round-seq-border', 'PARTS-47SF', 75.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-47SF' OR (slug = 'light-orange-with-orange-round-seq-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Light Orange with orange round seq border', 'light-orange-with-orange-round-seq-border', 'PARTS-47LF', 75.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-47LF' OR (slug = 'light-orange-with-orange-round-seq-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Light Orange with orange round seq border', 'light-orange-with-orange-round-seq-border', 'PARTS-47HS', 75.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-47HS' OR (slug = 'light-orange-with-orange-round-seq-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Copper sulphate blue brocade', 'copper-sulphate-blue-brocade', 'PARTS-46LF', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-46LF' OR (slug = 'copper-sulphate-blue-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Copper sulphate blue brocade', 'copper-sulphate-blue-brocade', 'PARTS-46BS', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-46BS' OR (slug = 'copper-sulphate-blue-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Copper sulphate blue brocade', 'copper-sulphate-blue-brocade', 'PARTS-46HS', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-46HS' OR (slug = 'copper-sulphate-blue-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta net round design border', 'majenta-net-round-design-border', 'PARTS-45BS', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-45BS' OR (slug = 'majenta-net-round-design-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta net round design border', 'majenta-net-round-design-border', 'PARTS-45HS', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-45HS' OR (slug = 'majenta-net-round-design-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta velvet sequence Kacha', 'majenta-velvet-sequence-kacha', 'PARTS-44SF', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-44SF' OR (slug = 'majenta-velvet-sequence-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta velvet sequence Kacha', 'majenta-velvet-sequence-kacha', 'PARTS-44BS', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-44BS' OR (slug = 'majenta-velvet-sequence-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta velvet sequence Kacha', 'majenta-velvet-sequence-kacha', 'PARTS-44HS', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-44HS' OR (slug = 'majenta-velvet-sequence-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue violet sequence kacha', 'blue-violet-sequence-kacha', 'PARTS-43SF', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-43SF' OR (slug = 'blue-violet-sequence-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue violet sequence kacha', 'blue-violet-sequence-kacha', 'PARTS-43BS', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-43BS' OR (slug = 'blue-violet-sequence-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue violet sequence kacha', 'blue-violet-sequence-kacha', 'PARTS-43HS', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-43HS' OR (slug = 'blue-violet-sequence-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold Brocade Kacha', 'gold-brocade-kacha', 'PARTS-42SF', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-42SF' OR (slug = 'gold-brocade-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold Brocade Kacha', 'gold-brocade-kacha', 'PARTS-42BS', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-42BS' OR (slug = 'gold-brocade-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold Brocade Kacha', 'gold-brocade-kacha', 'PARTS-42HS', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-42HS' OR (slug = 'gold-brocade-kacha' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange satin dhothi pant', 'orange-satin-dhothi-pant', 'PANT-65', 150.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PANT-65' OR (slug = 'orange-satin-dhothi-pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White satin dhothi pant', 'white-satin-dhothi-pant', 'PANT-64', 100.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PANT-64' OR (slug = 'white-satin-dhothi-pant' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));
