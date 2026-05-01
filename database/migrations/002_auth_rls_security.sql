-- ============================================================================
-- Migration 002: Authentication, RLS, Security Functions, and Policies
-- Enables RLS on all tables, creates helper functions with SET search_path,
-- creates RLS policies for authenticated + anon roles, and revokes PUBLIC
-- execute grants on all SECURITY DEFINER functions.
-- ============================================================================

-- ════════════════════════════════════════════════════════════════════════════
-- 1. HELPER FUNCTIONS (with SET search_path = public for security)
-- ════════════════════════════════════════════════════════════════════════════

-- Get current user's branch_id from staff table
CREATE OR REPLACE FUNCTION public.get_user_branch_id()
RETURNS UUID AS $$
  SELECT branch_id FROM staff WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public;

-- Get current user's role from staff table
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
  SELECT role FROM staff WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public;

-- Check if current user is admin or super_admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 FROM staff
    WHERE user_id = auth.uid()
    AND role IN ('super_admin', 'admin')
  );
$$ LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public;

-- Check if current user is super_admin
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 FROM staff
    WHERE user_id = auth.uid()
    AND role = 'super_admin'
  );
$$ LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public;

-- Check if current user is manager, admin, or super_admin
CREATE OR REPLACE FUNCTION public.is_manager_or_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 FROM staff
    WHERE user_id = auth.uid()
    AND role IN ('super_admin', 'admin', 'manager')
  );
$$ LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public;


-- ════════════════════════════════════════════════════════════════════════════
-- 2. ENABLE RLS ON ALL TABLES
-- ════════════════════════════════════════════════════════════════════════════

ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;


-- ════════════════════════════════════════════════════════════════════════════
-- 3. AUTHENTICATED USER POLICIES (admin/staff login)
--    Service role bypasses RLS automatically — no policy needed for it.
-- ════════════════════════════════════════════════════════════════════════════

-- ─── Stores ────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "stores_select_authenticated" ON stores;
CREATE POLICY "stores_select_authenticated" ON stores
  FOR SELECT TO authenticated USING (true);

-- ─── Branches ──────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "branches_select_authenticated" ON branches;
CREATE POLICY "branches_select_authenticated" ON branches
  FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR id = get_user_branch_id());

-- ─── Staff ─────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "staff_select_authenticated" ON staff;
CREATE POLICY "staff_select_authenticated" ON staff
  FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR user_id = auth.uid());

-- ─── Categories ────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "categories_select_authenticated" ON categories;
CREATE POLICY "categories_select_authenticated" ON categories
  FOR SELECT TO authenticated USING (true);

-- ─── Products ──────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "products_select_authenticated" ON products;
CREATE POLICY "products_select_authenticated" ON products
  FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR branch_id = get_user_branch_id() OR branch_id IS NULL);

-- ─── Product Inventory ─────────────────────────────────────────────────────
DROP POLICY IF EXISTS "product_inventory_select_authenticated" ON product_inventory;
CREATE POLICY "product_inventory_select_authenticated" ON product_inventory
  FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR branch_id = get_user_branch_id());

-- ─── Orders ────────────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "orders_select_authenticated" ON orders;
CREATE POLICY "orders_select_authenticated" ON orders
  FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR branch_id = get_user_branch_id());

-- ─── Order Items ───────────────────────────────────────────────────────────
DROP POLICY IF EXISTS "order_items_select_authenticated" ON order_items;
CREATE POLICY "order_items_select_authenticated" ON order_items
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM orders WHERE orders.id = order_items.order_id
    AND (is_super_admin() OR is_admin() OR orders.branch_id = get_user_branch_id())
  ));


-- ════════════════════════════════════════════════════════════════════════════
-- 4. ANONYMOUS READ POLICIES (for storefront)
--    Only active records are visible to the public.
-- ════════════════════════════════════════════════════════════════════════════

-- Stores: anon can read active stores
DROP POLICY IF EXISTS "stores_anon_select" ON stores;
CREATE POLICY "stores_anon_select" ON stores
  FOR SELECT TO anon
  USING (is_active = true);

-- Also ensure authenticated users see all stores (re-declare for clarity)
DROP POLICY IF EXISTS "stores_authenticated_select" ON stores;
CREATE POLICY "stores_authenticated_select" ON stores
  FOR SELECT TO authenticated
  USING (true);

-- Categories: anon can read active categories
DROP POLICY IF EXISTS "categories_anon_select" ON categories;
CREATE POLICY "categories_anon_select" ON categories
  FOR SELECT TO anon
  USING (is_active = true);

-- Also ensure authenticated users see all categories
DROP POLICY IF EXISTS "categories_authenticated_select" ON categories;
CREATE POLICY "categories_authenticated_select" ON categories
  FOR SELECT TO authenticated
  USING (true);

-- Products: anon can read active products
DROP POLICY IF EXISTS "products_anon_select" ON products;
CREATE POLICY "products_anon_select" ON products
  FOR SELECT TO anon
  USING (is_active = true);

-- Banners: anon can read active banners
DROP POLICY IF EXISTS "banners_anon_select" ON banners;
CREATE POLICY "banners_anon_select" ON banners
  FOR SELECT TO anon
  USING (is_active = true);


-- ════════════════════════════════════════════════════════════════════════════
-- 5. REVOKE EXECUTE FROM PUBLIC on all SECURITY DEFINER functions
--    PostgreSQL grants EXECUTE to PUBLIC by default. We revoke it so these
--    internal functions cannot be called via the REST API (PostgREST).
--    Service_role bypasses this and is NOT affected.
--    RLS policies that reference these functions are also NOT affected.
-- ════════════════════════════════════════════════════════════════════════════

-- Internal RLS helper functions
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_super_admin() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_manager_or_admin() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.get_user_role() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.get_user_branch_id() FROM PUBLIC;
