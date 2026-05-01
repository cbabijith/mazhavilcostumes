-- ============================================================================
-- Migration 003: Seed Store and Main Branch
-- Creates the Mazhavil Costumes store and its main branch.
-- This MUST run before creating the super admin (004).
-- ============================================================================

-- Create the store
INSERT INTO stores (name, slug, email, phone, address, is_active, subscription_status)
VALUES (
  'Mazhavil Costumes',
  'mazhavil-costumes',
  'mazhavildancecostumes01@gmail.com',        -- ← Update with real email
  '+919447923234',                      -- ← Update with real phone
  'Karamana Main Road, near QRS, Prem Nagar, Karamana, Thiruvananthapuram, Kerala 695002',         -- ← Update with real address
  true,
  'active'
)
ON CONFLICT (slug) DO NOTHING;

-- Create the main branch
INSERT INTO branches (store_id, name, address, phone, is_main, is_active)
SELECT
  id,
  'Main Branch',
  'Karamana Main Road, near QRS, Prem Nagar, Karamana, Thiruvananthapuram, Kerala 695002',                -- ← Update with real address
  '+919447923234',                      -- ← Update with real phone
  true,
  true
FROM stores
WHERE slug = 'mazhavil-costumes'
ON CONFLICT DO NOTHING;
