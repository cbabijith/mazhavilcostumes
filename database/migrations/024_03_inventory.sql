-- CREATE PRODUCT INVENTORY RECORDS
-- ============================================================================

INSERT INTO product_inventory (id, product_id, branch_id, quantity, available_quantity, created_at, updated_at)
SELECT gen_random_uuid(), p.id, p.branch_id, p.quantity, p.available_quantity, NOW(), NOW()
FROM products p
WHERE p.store_id = '9403fc00-1042-4770-a64b-08f196a58457'::uuid
  AND p.created_at >= NOW() - INTERVAL '1 hour'
  AND NOT EXISTS (SELECT 1 FROM product_inventory pi WHERE pi.product_id = p.id);

