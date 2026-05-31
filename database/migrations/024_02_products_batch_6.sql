-- ============================================================================
-- Product Batch 6: Products 501 to 600
-- ============================================================================


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green / White', 'green-white', 'SKIRT-71', 125.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-71' OR (slug = 'green-white' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'blue/White', 'bluewhite', 'SKIRT-70', 125.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-70' OR (slug = 'bluewhite' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Multi colour', 'multi-colour', 'SKIRT-69', 150.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-69' OR (slug = 'multi-colour' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Purple Gold dot', 'purple-gold-dot', 'SKIRT-68', 125.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-68' OR (slug = 'purple-gold-dot' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta flower skirt', 'majenta-flower-skirt', 'SKIRT-67C', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-67C' OR (slug = 'majenta-flower-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta embroidery skirt', 'majenta-embroidery-skirt', 'SKIRT-67B', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-67B' OR (slug = 'majenta-embroidery-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Purple embroidery skirt', 'purple-embroidery-skirt', 'SKIRT-67A', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-67A' OR (slug = 'purple-embroidery-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green embroidery skirt', 'green-embroidery-skirt', 'SKIRT-67', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-67' OR (slug = 'green-embroidery-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange net/Bluefreen sequence border', 'orange-netbluefreen-sequence-border', 'SKIRT-66', 150.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-66' OR (slug = 'orange-netbluefreen-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Sky blue satin/Gold satin border', 'sky-blue-satingold-satin-border', 'SKIRT-65', 150.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-65' OR (slug = 'sky-blue-satingold-satin-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White dot net/ Red border', 'white-dot-net-red-border', 'SKIRT-64', 125.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-64' OR (slug = 'white-dot-net-red-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green net/ Blue gold sequence border', 'green-net-blue-gold-sequence-border', 'SKIRT-63', 150.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-63' OR (slug = 'green-net-blue-gold-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red dot net/Blue gold border', 'red-dot-netblue-gold-border', 'SKIRT-62', 175.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-62' OR (slug = 'red-dot-netblue-gold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue sequence/ Mayilpeeli skirt', 'blue-sequence-mayilpeeli-skirt', 'SKIRT-61', 225.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-61' OR (slug = 'blue-sequence-mayilpeeli-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White flower net gold sequence border', 'white-flower-net-gold-sequence-border', 'SKIRT-60', 125.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-60' OR (slug = 'white-flower-net-gold-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red net/Blue small', 'red-netblue-small', 'SKIRT-59', 150.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-59' OR (slug = 'red-netblue-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green blue slit', 'green-blue-slit', 'SKIRT-58', 100.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-58' OR (slug = 'green-blue-slit' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Multi colour slt skirt', 'multi-colour-slt-skirt', 'SKIRT-57', 125.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-57' OR (slug = 'multi-colour-slt-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue net/Majenta gold border', 'blue-netmajenta-gold-border', 'SKIRT-56', 200.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-56' OR (slug = 'blue-netmajenta-gold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red net self design/Blue bprder', 'red-net-self-designblue-bprder', 'SKIRT-55', 100.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-55' OR (slug = 'red-net-self-designblue-bprder' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta net/ Green Small', 'majenta-net-green-small', 'SKIRT-54', 150.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-54' OR (slug = 'majenta-net-green-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Sky blue net dot/Gold sequence border', 'sky-blue-net-dotgold-sequence-border', 'SKIRT-53', 200.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-53' OR (slug = 'sky-blue-net-dotgold-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green net gold dot/Gold border', 'green-net-gold-dotgold-border', 'SKIRT-52', 175.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-52' OR (slug = 'green-net-gold-dotgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold banyancloth/Green seq Border', 'gold-banyanclothgreen-seq-border', 'SKIRT-51', 200.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-51' OR (slug = 'gold-banyanclothgreen-seq-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Copper sulphate/Full sequence border', 'copper-sulphatefull-sequence-border', 'SKIRT-50', 250.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-50' OR (slug = 'copper-sulphatefull-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Peacock bluegold print/Gold border', 'peacock-bluegold-printgold-border', 'SKIRT-49', 200.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-49' OR (slug = 'peacock-bluegold-printgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Plain black/Gold Border', 'plain-blackgold-border', 'SKIRT-48', 200.00, 15, 15, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-48' OR (slug = 'plain-blackgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red seq design/ small sequence border', 'red-seq-design-small-sequence-border', 'SKIRT-47', 225.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-47' OR (slug = 'red-seq-design-small-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta banyan cloth/Slit longborder', 'majenta-banyan-clothslit-longborder', 'SKIRT-46', 175.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-46' OR (slug = 'majenta-banyan-clothslit-longborder' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta full sequence/Gold border', 'majenta-full-sequencegold-border', 'SKIRT-45', 250.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-45' OR (slug = 'majenta-full-sequencegold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Dark green/Majenta baniyan cloth', 'dark-greenmajenta-baniyan-cloth', 'SKIRT-44', 200.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-44' OR (slug = 'dark-greenmajenta-baniyan-cloth' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Light pink/Gold sequence border', 'light-pinkgold-sequence-border', 'SKIRT-43', 300.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-43' OR (slug = 'light-pinkgold-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta net/ manbgo design border small', 'majenta-net-manbgo-design-border-small', 'SKIRT-42', 250.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-42' OR (slug = 'majenta-net-manbgo-design-border-small' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black gold embroidery/Red border', 'black-gold-embroideryred-border', 'SKIRT-41', 275.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-41' OR (slug = 'black-gold-embroideryred-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow net small dot/Blue seq border', 'yellow-net-small-dotblue-seq-border', 'SKIRT-40', 250.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-40' OR (slug = 'yellow-net-small-dotblue-seq-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta dot/Gold border', 'majenta-dotgold-border', 'SKIRT-39', 200.00, 15, 15, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-39' OR (slug = 'majenta-dotgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Peacock skirt', 'peacock-skirt', 'SKIRT-38', 250.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-38' OR (slug = 'peacock-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red net/ Red embroidery border', 'red-net-red-embroidery-border', 'SKIRT-37', 200.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-37' OR (slug = 'red-net-red-embroidery-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Royal blue net/Gold miror border', 'royal-blue-netgold-miror-border', 'SKIRT-36', 250.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-36' OR (slug = 'royal-blue-netgold-miror-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Royal blue full seq gold/Majenta border', 'royal-blue-full-seq-goldmajenta-border', 'SKIRT-35', 275.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-35' OR (slug = 'royal-blue-full-seq-goldmajenta-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow net/Mirror border', 'yellow-netmirror-border', 'SKIRT-34', 275.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-34' OR (slug = 'yellow-netmirror-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Peach emroidery/Black border', 'peach-emroideryblack-border', 'SKIRT-33', 300.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-33' OR (slug = 'peach-emroideryblack-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red net/Blue sequence border', 'red-netblue-sequence-border', 'SKIRT-32', 250.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-32' OR (slug = 'red-netblue-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Royal blue embroidery/Red sequence border', 'royal-blue-embroideryred-sequence-border', 'SKIRT-31', 275.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-31' OR (slug = 'royal-blue-embroideryred-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Sky blue silver sequence/Silver border', 'sky-blue-silver-sequencesilver-border', 'SKIRT-30', 300.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-30' OR (slug = 'sky-blue-silver-sequencesilver-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green sequence/Red Border', 'green-sequencered-border', 'SKIRT-29', 275.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-29' OR (slug = 'green-sequencered-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red round embroidery/ Sequence border', 'red-round-embroidery-sequence-border', 'SKIRT-28', 275.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-28' OR (slug = 'red-round-embroidery-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red full gold dot/gold sequence border', 'red-full-gold-dotgold-sequence-border', 'SKIRT-27', 300.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-27' OR (slug = 'red-full-gold-dotgold-sequence-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow net/Red diamond border', 'yellow-netred-diamond-border', 'SKIRT-26', 200.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-26' OR (slug = 'yellow-netred-diamond-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Plain green net/Gold Border', 'plain-green-netgold-border', 'SKIRT-25', 200.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-25' OR (slug = 'plain-green-netgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold dot/Gold border', 'gold-dotgold-border', 'SKIRT-24', 250.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-24' OR (slug = 'gold-dotgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majebta Embroidery border', 'majebta-embroidery-border', 'SKIRT-23', 300.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-23' OR (slug = 'majebta-embroidery-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta net/Mango design border', 'majenta-netmango-design-border', 'SKIRT-22', 300.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-22' OR (slug = 'majenta-netmango-design-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red gold mirror/2 line border', 'red-gold-mirror2-line-border', 'SKIRT-21', 250.00, 13, 13, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-21' OR (slug = 'red-gold-mirror2-line-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White gold design', 'white-gold-design', 'SKIRT-20', 250.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-20' OR (slug = 'white-gold-design' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow Green Border', 'yellow-green-border', 'SKIRT-19', 200.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-19' OR (slug = 'yellow-green-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black dot skirt', 'black-dot-skirt', 'SKIRT-18', 250.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-18' OR (slug = 'black-dot-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue net/Gold Majenta square design', 'blue-netgold-majenta-square-design', 'SKIRT-17', 300.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-17' OR (slug = 'blue-netgold-majenta-square-design' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kilipacha gold dot/Gold border', 'kilipacha-gold-dotgold-border', 'SKIRT-16', 200.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-16' OR (slug = 'kilipacha-gold-dotgold-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange flower net skirt', 'orange-flower-net-skirt', 'SKIRT-15', 250.00, 14, 14, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-15' OR (slug = 'orange-flower-net-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta/Gold triangle design', 'majentagold-triangle-design', 'SKIRT-14', 300.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-14' OR (slug = 'majentagold-triangle-design' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kilipacha/Majenta border', 'kilipachamajenta-border', 'SKIRT-13', 200.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-13' OR (slug = 'kilipachamajenta-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red stripes', 'red-stripes', 'SKIRT-12', 350.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-12' OR (slug = 'red-stripes' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'WHITE/GOLD', 'whitegold', 'SKIRT-11', 200.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-11' OR (slug = 'whitegold' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED/GREEN', 'redgreen', 'SKIRT-9', 200.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-9' OR (slug = 'redgreen' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'BLUE/GOLD', 'bluegold', 'SKIRT-8', 150.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-8' OR (slug = 'bluegold' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White silver sequence skirt', 'white-silver-sequence-skirt', 'SKIRT-7', 200.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-7' OR (slug = 'white-silver-sequence-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD/GOLD', 'goldgold', 'SKIRT-6', 200.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-6' OR (slug = 'goldgold' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'WHITE/GOLD', 'whitegold', 'SKIRT-5', 300.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-5' OR (slug = 'whitegold' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'YELLOW', 'yellow', 'SKIRT-4', 300.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-4' OR (slug = 'yellow' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED/PINK', 'redpink', 'SKIRT-3', 250.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-3' OR (slug = 'redpink' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'GOLD/BLACK', 'goldblack', 'SKIRT-2', 250.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-2' OR (slug = 'goldblack' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'RED/WHITE', 'redwhite', 'SKIRT-1', 250.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SKIRT-1' OR (slug = 'redwhite' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue/ Orange Skirt BH', 'blue-orange-skirt-bh', 'SEMI-36', 400.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-36' OR (slug = 'blue-orange-skirt-bh' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue Majenta/Renga pooja KG', 'blue-majentarenga-pooja-kg', 'SEMI-35', 350.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-35' OR (slug = 'blue-majentarenga-pooja-kg' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Violet/Majenta brocade', 'violetmajenta-brocade', 'SEMI-34', 400.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-34' OR (slug = 'violetmajenta-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Sky blue/ Majenta BH', 'sky-blue-majenta-bh', 'SEMI-33', 400.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-33' OR (slug = 'sky-blue-majenta-bh' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Peacock blue/Red skirt BH', 'peacock-bluered-skirt-bh', 'SEMI-32', 450.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-32' OR (slug = 'peacock-bluered-skirt-bh' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green skirt/Majenta brocade BH', 'green-skirtmajenta-brocade-bh', 'SEMI-31', 400.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-31' OR (slug = 'green-skirtmajenta-brocade-bh' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gteen skirt/Red parts BH', 'gteen-skirtred-parts-bh', 'SEMI-30', 500.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-30' OR (slug = 'gteen-skirtred-parts-bh' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue skirt/ Green Manichithra thazhu', 'blue-skirt-green-manichithra-thazhu', 'SEMI-29', 500.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-29' OR (slug = 'blue-skirt-green-manichithra-thazhu' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Vadamulla surf blue Renga pooja model', 'vadamulla-surf-blue-renga-pooja-model', 'SEMI-28', 450.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-28' OR (slug = 'vadamulla-surf-blue-renga-pooja-model' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Neriyathu skirt half saree', 'neriyathu-skirt-half-saree', 'SEMI-27', 400.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-27' OR (slug = 'neriyathu-skirt-half-saree' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kilipaha dot skirt,Red blouse', 'kilipaha-dot-skirtred-blouse', 'SEMI-26', 500.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-26' OR (slug = 'kilipaha-dot-skirtred-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Violet skirt green brocade skirt BH', 'violet-skirt-green-brocade-skirt-bh', 'SEMI-25', 600.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-25' OR (slug = 'violet-skirt-green-brocade-skirt-bh' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pista green violet brocade skirt model BH', 'pista-green-violet-brocade-skirt-model-bh', 'SEMI-24', 600.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-24' OR (slug = 'pista-green-violet-brocade-skirt-model-bh' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue Majenta brocade skirt model BH', 'blue-majenta-brocade-skirt-model-bh', 'SEMI-23', 600.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-23' OR (slug = 'blue-majenta-brocade-skirt-model-bh' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red blue skirt model BH', 'red-blue-skirt-model-bh', 'SEMI-22', 550.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-22' OR (slug = 'red-blue-skirt-model-bh' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black and Gold snake dance type Old', 'black-and-gold-snake-dance-type-old', 'SEMI-21', 350.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-21' OR (slug = 'black-and-gold-snake-dance-type-old' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Brown/Black border, yellow blouse', 'brownblack-border-yellow-blouse', 'SEMI-20', 300.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-20' OR (slug = 'brownblack-border-yellow-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Brown/Majenta skirt', 'brownmajenta-skirt', 'SEMI-19', 300.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-19' OR (slug = 'brownmajenta-skirt' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange skirt/ Green blouse', 'orange-skirt-green-blouse', 'SEMI-18', 300.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-18' OR (slug = 'orange-skirt-green-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta skir/ Green blouse', 'majenta-skir-green-blouse', 'SEMI-17', 300.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-17' OR (slug = 'majenta-skir-green-blouse' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange satin/ Blue semi', 'orange-satin-blue-semi', 'SEMI-16', 450.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-16' OR (slug = 'orange-satin-blue-semi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue satin/Orange semi', 'blue-satinorange-semi', 'SEMI-15', 450.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-15' OR (slug = 'blue-satinorange-semi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Merroon Kannagi set', 'merroon-kannagi-set', 'SEMI-14', 650.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-14' OR (slug = 'merroon-kannagi-set' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Ash/Majenta saree model', 'ashmajenta-saree-model', 'SEMI-13', 600.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-13' OR (slug = 'ashmajenta-saree-model' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pista green/Violet brocade semi', 'pista-greenviolet-brocade-semi', 'SEMI-12', 600.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-12' OR (slug = 'pista-greenviolet-brocade-semi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Full red saree type semi', 'full-red-saree-type-semi', 'SEMI-11', 500.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-11' OR (slug = 'full-red-saree-type-semi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'semi-classical' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red/Blue check semi', 'redblue-check-semi', 'SEMI-10', 500.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'SEMI-10' OR (slug = 'redblue-check-semi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));
