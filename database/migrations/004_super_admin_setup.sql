-- ============================================================================
-- Migration 004: Super Admin Setup
-- 
-- IMPORTANT: This is a TWO-STEP process.
--
-- STEP 1 (Supabase Dashboard — do this FIRST):
--   Go to Authentication → Users → Add user
--   Create a user with email + password for the super admin.
--   Copy the user's UUID from the dashboard.
--
-- STEP 2 (SQL Editor — run the SQL below):
--   Replace the placeholders below with real values, then execute.
-- ============================================================================

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ REPLACE THESE VALUES before running:                                    │
-- │                                                                         │
-- │   YOUR_AUTH_USER_UUID  → The UUID from Supabase Auth (Step 1)           │
-- │   admin@email.com      → The admin's real email                         │
-- │   Admin Name           → The admin's real name                          │
-- │   +91XXXXXXXXXX        → The admin's real phone number                  │
-- └─────────────────────────────────────────────────────────────────────────┘

INSERT INTO staff (
  store_id,
  branch_id,
  user_id,
  name,
  email,
  phone,
  role,
  is_active
)
SELECT
  s.id,
  b.id,
  'eb613e18-572d-4468-b887-44d370bc4887'::UUID,          -- ← Replace with UUID from Step 1
  'Admin',                          -- ← Replace with real name
  'mazhavildancecostumes01@gmail.com',                     -- ← Replace with real email (must match Auth user)
  '+919447923234',                       -- ← Replace with real phone
  'super_admin',
  true
FROM stores s
JOIN branches b ON b.store_id = s.id AND b.is_main = true
WHERE s.slug = 'mazhavil-costumes';

-- ============================================================================
-- VERIFICATION: After running, check that the staff record was created:
--
--   SELECT id, name, email, role, user_id, store_id, branch_id
--   FROM staff
--   WHERE role = 'super_admin';
--
-- You should see exactly 1 row with all fields filled.
-- If user_id, store_id, or branch_id is NULL, something went wrong.
-- ============================================================================
