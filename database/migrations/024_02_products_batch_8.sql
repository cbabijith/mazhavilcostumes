-- ============================================================================
-- Product Batch 8: Products 701 to 800
-- ============================================================================


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Velichapadu gold mediumVaal', 'velichapadu-gold-mediumvaal', 'VAAL-8', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'VAAL-8' OR (slug = 'velichapadu-gold-mediumvaal' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Asuran vaal', 'asuran-vaal', 'VAAL-7', 60.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'VAAL-7' OR (slug = 'asuran-vaal' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Heavy vaal with ura Vaal', 'heavy-vaal-with-ura-vaal', 'VAAL-6', 250.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'VAAL-6' OR (slug = 'heavy-vaal-with-ura-vaal' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Vaal with ura Vaal', 'vaal-with-ura-vaal', 'VAAL-5', 125.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'VAAL-5' OR (slug = 'vaal-with-ura-vaal' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Arivaal small Vaal', 'arivaal-small-vaal', 'VAAL-4', 50.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'VAAL-4' OR (slug = 'arivaal-small-vaal' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Velichapadu vaal Gold big Vaal', 'velichapadu-vaal-gold-big-vaal', 'VAAL-3', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'VAAL-3' OR (slug = 'velichapadu-vaal-gold-big-vaal' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Velichapadu Vaal Black Vaal', 'velichapadu-vaal-black-vaal', 'VAAL-2', 100.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'VAAL-2' OR (slug = 'velichapadu-vaal-black-vaal' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Weightless vaal Black handle Vaal', 'weightless-vaal-black-handle-vaal', 'VAAL-1', 75.00, 20, 20, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'VAAL-1' OR (slug = 'weightless-vaal-black-handle-vaal' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Butterfly wings big', 'butterfly-wings-big', 'BUTTERFLY-1', 100.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'BUTTERFLY-1' OR (slug = 'butterfly-wings-big' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Offwhite sunflower sponge', 'offwhite-sunflower-sponge', 'FLOWER-6', 75.00, 25, 25, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'FLOWER-6' OR (slug = 'offwhite-sunflower-sponge' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Big lotus majenta', 'big-lotus-majenta', 'FLOWER-5', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'FLOWER-5' OR (slug = 'big-lotus-majenta' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange sunflower face', 'orange-sunflower-face', 'FLOWER-4', 75.00, 16, 16, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'FLOWER-4' OR (slug = 'orange-sunflower-face' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Orange sunflower', 'orange-sunflower', 'FLOWER-3', 75.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'FLOWER-3' OR (slug = 'orange-sunflower' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow sunflower', 'yellow-sunflower', 'FLOWER-2', 75.00, 19, 19, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'FLOWER-2' OR (slug = 'yellow-sunflower' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Small Lotus flower', 'small-lotus-flower', 'FLOWER-1', 75.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'FLOWER-1' OR (slug = 'small-lotus-flower' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Cone shape thoppi', 'cone-shape-thoppi', 'CAP-16', 75.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-16' OR (slug = 'cone-shape-thoppi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Pala thoppi', 'pala-thoppi', 'CAP-15', 40.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-15' OR (slug = 'pala-thoppi' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue marathi cap', 'blue-marathi-cap', 'CAP-14', 100.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-14' OR (slug = 'blue-marathi-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Merroon Rajasthani cap', 'merroon-rajasthani-cap', 'CAP-13', 75.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-13' OR (slug = 'merroon-rajasthani-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green Rajasthani cap', 'green-rajasthani-cap', 'CAP-12', 75.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-12' OR (slug = 'green-rajasthani-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green red seqeunceRajasthani cap', 'green-red-seqeuncerajasthani-cap', 'CAP-11', 75.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-11' OR (slug = 'green-red-seqeuncerajasthani-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow blue sequence Rajasthani cap', 'yellow-blue-sequence-rajasthani-cap', 'CAP-10', 75.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-10' OR (slug = 'yellow-blue-sequence-rajasthani-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow red Rajasthani cap', 'yellow-red-rajasthani-cap', 'CAP-9', 75.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-9' OR (slug = 'yellow-red-rajasthani-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Majenta Marathi cap', 'majenta-marathi-cap', 'CAP-8', 75.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-8' OR (slug = 'majenta-marathi-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White Marathi cap', 'white-marathi-cap', 'CAP-7', 75.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-7' OR (slug = 'white-marathi-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Yellow Marathi cap', 'yellow-marathi-cap', 'CAP-6', 75.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-6' OR (slug = 'yellow-marathi-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Merron offwhite marathi cap', 'merron-offwhite-marathi-cap', 'CAP-5', 75.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-5' OR (slug = 'merron-offwhite-marathi-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Cow boy cap Orange', 'cow-boy-cap-orange', 'CAP-4', 75.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-4' OR (slug = 'cow-boy-cap-orange' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Cow boy cap Ash', 'cow-boy-cap-ash', 'CAP-3', 75.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-3' OR (slug = 'cow-boy-cap-ash' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'White Cap', 'white-cap', 'CAP-2', 30.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-2' OR (slug = 'white-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black cap', 'black-cap', 'CAP-1', 30.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CAP-1' OR (slug = 'black-cap' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Mayavu kombu Crown', 'mayavu-kombu-crown', 'CROWN-31', 50.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-31' OR (slug = 'mayavu-kombu-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Luttappi kombu Crown', 'luttappi-kombu-crown', 'CROWN-30', 50.00, 2, 2, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-30' OR (slug = 'luttappi-kombu-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Mul kereedam Crown', 'mul-kereedam-crown', 'CROWN-29', 75.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-29' OR (slug = 'mul-kereedam-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Cristian king crown gold', 'cristian-king-crown-gold', 'CROWN-28', 50.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-28' OR (slug = 'cristian-king-crown-gold' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Christian king crown silver', 'christian-king-crown-silver', 'CROWN-27', 50.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-27' OR (slug = 'christian-king-crown-silver' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Maveli crown cardboard', 'maveli-crown-cardboard', 'CROWN-26', 125.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-26' OR (slug = 'maveli-crown-cardboard' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Maveli crown heavy', 'maveli-crown-heavy', 'CROWN-25', 200.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-25' OR (slug = 'maveli-crown-heavy' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Asuran crown black', 'asuran-crown-black', 'CROWN-24', 75.00, 4, 4, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-24' OR (slug = 'asuran-crown-black' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Jhansi rani crown', 'jhansi-rani-crown', 'CROWN-23', 50.00, 16, 16, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-23' OR (slug = 'jhansi-rani-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green curl crown', 'green-curl-crown', 'CROWN-22', 75.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-22' OR (slug = 'green-curl-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold painted crown with stone', 'gold-painted-crown-with-stone', 'CROWN-21', 100.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-21' OR (slug = 'gold-painted-crown-with-stone' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green stone crown', 'green-stone-crown', 'CROWN-20', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-20' OR (slug = 'green-stone-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Mayil thala Crown', 'mayil-thala-crown', 'CROWN-19', 75.00, 15, 15, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-19' OR (slug = 'mayil-thala-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Ravana crown', 'ravana-crown', 'CROWN-18', 200.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-18' OR (slug = 'ravana-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Brahma crown', 'brahma-crown', 'CROWN-17', 150.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-17' OR (slug = 'brahma-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Tribal feather crown', 'tribal-feather-crown', 'CROWN-16', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-16' OR (slug = 'tribal-feather-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Crown with white stone flower Crown', 'crown-with-white-stone-flower-crown', 'CROWN-15', 75.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-15' OR (slug = 'crown-with-white-stone-flower-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Kombu crown white / Red stone', 'kombu-crown-white-red-stone', 'CROWN-14', 100.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-14' OR (slug = 'kombu-crown-white-red-stone' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Star crown white stone', 'star-crown-white-stone', 'CROWN-13', 100.00, 3, 3, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-13' OR (slug = 'star-crown-white-stone' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Krishna crown blue', 'krishna-crown-blue', 'CROWN-12', 100.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-12' OR (slug = 'krishna-crown-blue' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Krishna crown green,orange, blue mix', 'krishna-crown-greenorange-blue-mix', 'CROWN-11', 100.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-11' OR (slug = 'krishna-crown-greenorange-blue-mix' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Krishna crown yellow blue Crown', 'krishna-crown-yellow-blue-crown', 'CROWN-10', 100.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-10' OR (slug = 'krishna-crown-yellow-blue-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Andal konda gold lace Crown', 'andal-konda-gold-lace-crown', 'CROWN-9', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-9' OR (slug = 'andal-konda-gold-lace-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Andal konda stone Crown', 'andal-konda-stone-crown', 'CROWN-8', 75.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-8' OR (slug = 'andal-konda-stone-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold snake bow Crown', 'gold-snake-bow-crown', 'CROWN-7', 100.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-7' OR (slug = 'gold-snake-bow-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black flame velvet Crown', 'black-flame-velvet-crown', 'CROWN-6', 100.00, 8, 8, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-6' OR (slug = 'black-flame-velvet-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue velvet peacog with kudam design Crown', 'blue-velvet-peacog-with-kudam-design-crown', 'CROWN-5', 125.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-5' OR (slug = 'blue-velvet-peacog-with-kudam-design-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black 2 line gold lace Crown', 'black-2-line-gold-lace-crown', 'CROWN-4', 125.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-4' OR (slug = 'black-2-line-gold-lace-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black velvet bow with lekshmi print Crown', 'black-velvet-bow-with-lekshmi-print-crown', 'CROWN-3', 125.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-3' OR (slug = 'black-velvet-bow-with-lekshmi-print-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Half ring gold with Crown', 'half-ring-gold-with-crown', 'CROWN-2', 100.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-2' OR (slug = 'half-ring-gold-with-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'property' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Half ring silver Crown', 'half-ring-silver-crown', 'CROWN-1', 75.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'CROWN-1' OR (slug = 'half-ring-silver-crown' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black plain', 'black-plain', 'PARTS-41BS', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-41BS' OR (slug = 'black-plain' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Black plain', 'black-plain', 'PARTS-41HS', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-41HS' OR (slug = 'black-plain' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold dot', 'gold-dot', 'PARTS-40SF', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-40SF' OR (slug = 'gold-dot' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Gold dot', 'gold-dot', 'PARTS-40BS', 75.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-40BS' OR (slug = 'gold-dot' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue Brocade', 'blue-brocade', 'PARTS-39SF', 75.00, 14, 14, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-39SF' OR (slug = 'blue-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue Brocade', 'blue-brocade', 'PARTS-39BS', 75.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-39BS' OR (slug = 'blue-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Blue Brocade', 'blue-brocade', 'PARTS-39HS', 75.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-39HS' OR (slug = 'blue-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red Brocade', 'red-brocade', 'PARTS-38SF', 75.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-38SF' OR (slug = 'red-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red Brocade', 'red-brocade', 'PARTS-38BS', 75.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-38BS' OR (slug = 'red-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red Brocade', 'red-brocade', 'PARTS-38HS', 75.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-38HS' OR (slug = 'red-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green Brocade', 'green-brocade', 'PARTS-37SF', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-37SF' OR (slug = 'green-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green Brocade', 'green-brocade', 'PARTS-37BS', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-37BS' OR (slug = 'green-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green Brocade', 'green-brocade', 'PARTS-37HS', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-37HS' OR (slug = 'green-brocade' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red gold print', 'red-gold-print', 'PARTS-36LF', 75.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-36LF' OR (slug = 'red-gold-print' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red gold print', 'red-gold-print', 'PARTS-36BS', 75.00, 5, 5, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-36BS' OR (slug = 'red-gold-print' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red gold print', 'red-gold-print', 'PARTS-36HS', 75.00, 6, 6, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-36HS' OR (slug = 'red-gold-print' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red gold brocade glass border', 'red-gold-brocade-glass-border', 'PARTS-35SF', 75.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-35SF' OR (slug = 'red-gold-brocade-glass-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red gold brocade glass border', 'red-gold-brocade-glass-border', 'PARTS-35LF', 75.00, 11, 11, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-35LF' OR (slug = 'red-gold-brocade-glass-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red gold brocade glass border', 'red-gold-brocade-glass-border', 'PARTS-35BS', 75.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-35BS' OR (slug = 'red-gold-brocade-glass-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red gold brocade glass border', 'red-gold-brocade-glass-border', 'PARTS-35HS', 75.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-35HS' OR (slug = 'red-gold-brocade-glass-border' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Violet gold velvet seqence', 'violet-gold-velvet-seqence', 'PARTS-34SF', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-34SF' OR (slug = 'violet-gold-velvet-seqence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Violet gold velvet seqence', 'violet-gold-velvet-seqence', 'PARTS-34LF', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-34LF' OR (slug = 'violet-gold-velvet-seqence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Violet gold velvet seqence', 'violet-gold-velvet-seqence', 'PARTS-34BS', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-34BS' OR (slug = 'violet-gold-velvet-seqence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Violet gold velvet seqence', 'violet-gold-velvet-seqence', 'PARTS-34HS', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-34HS' OR (slug = 'violet-gold-velvet-seqence' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Off white gold thread HS-10 BS-7 LF-1 SF-1', 'off-white-gold-thread-hs-10-bs-7-lf-1-sf-1', 'PARTS-33SF', 75.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-33SF' OR (slug = 'off-white-gold-thread-hs-10-bs-7-lf-1-sf-1' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Off white gold thread HS-10 BS-7 LF-1 SF-1', 'off-white-gold-thread-hs-10-bs-7-lf-1-sf-1', 'PARTS-33LF', 75.00, 1, 1, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-33LF' OR (slug = 'off-white-gold-thread-hs-10-bs-7-lf-1-sf-1' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Off white gold thread HS-10 BS-7 LF-1 SF-1', 'off-white-gold-thread-hs-10-bs-7-lf-1-sf-1', 'PARTS-33BS', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-33BS' OR (slug = 'off-white-gold-thread-hs-10-bs-7-lf-1-sf-1' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Off white gold thread HS-10 BS-7 LF-1 SF-1', 'off-white-gold-thread-hs-10-bs-7-lf-1-sf-1', 'PARTS-33HS', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-33HS' OR (slug = 'off-white-gold-thread-hs-10-bs-7-lf-1-sf-1' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green gold thread HS,BS,SF-7', 'green-gold-thread-hsbssf-7', 'PARTS-32SF', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-32SF' OR (slug = 'green-gold-thread-hsbssf-7' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green gold thread HS,BS,SF-7', 'green-gold-thread-hsbssf-7', 'PARTS-32BS', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-32BS' OR (slug = 'green-gold-thread-hsbssf-7' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green gold thread HS,BS,SF-7', 'green-gold-thread-hsbssf-7', 'PARTS-32HS', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-32HS' OR (slug = 'green-gold-thread-hsbssf-7' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green velvet lace border HS-12 BS-12', 'green-velvet-lace-border-hs-12-bs-12', 'PARTS-31BS', 75.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-31BS' OR (slug = 'green-velvet-lace-border-hs-12-bs-12' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green velvet lace border HS-12 BS-12', 'green-velvet-lace-border-hs-12-bs-12', 'PARTS-31HS', 75.00, 12, 12, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-31HS' OR (slug = 'green-velvet-lace-border-hs-12-bs-12' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green flower cloth blue gold HS,BF,LF-7', 'green-flower-cloth-blue-gold-hsbflf-7', 'PARTS-30LF', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-30LF' OR (slug = 'green-flower-cloth-blue-gold-hsbflf-7' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green flower cloth blue gold HS,BF,LF-7', 'green-flower-cloth-blue-gold-hsbflf-7', 'PARTS-30BS', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-30BS' OR (slug = 'green-flower-cloth-blue-gold-hsbflf-7' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Green flower cloth blue gold HS,BF,LF-7', 'green-flower-cloth-blue-gold-hsbflf-7', 'PARTS-30HS', 75.00, 7, 7, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-30HS' OR (slug = 'green-flower-cloth-blue-gold-hsbflf-7' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red velvet kacha-13,BS-10 SF-9', 'red-velvet-kacha-13bs-10-sf-9', 'PARTS-29SF', 75.00, 9, 9, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-29SF' OR (slug = 'red-velvet-kacha-13bs-10-sf-9' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));


INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '9403fc00-1042-4770-a64b-08f196a58457'::uuid, (SELECT id FROM categories WHERE slug = 'parts' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid LIMIT 1), '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, 'Red velvet kacha-13,BS-10 SF-9', 'red-velvet-kacha-13bs-10-sf-9', 'PARTS-29BS', 75.00, 10, 10, true, true, '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'::uuid, '7671abeb-4b79-47a4-966b-384c1c26b950'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = 'PARTS-29BS' OR (slug = 'red-velvet-kacha-13bs-10-sf-9' AND store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid));
