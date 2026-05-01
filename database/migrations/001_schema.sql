-- ============================================================================
-- Migration 001: Complete Schema for Mazhavil Costumes
-- Creates ALL tables, columns, indexes, and triggers in their final state.
-- Run this FIRST on a fresh Supabase project.
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ════════════════════════════════════════════════════════════════════════════
-- TABLES
-- ════════════════════════════════════════════════════════════════════════════

-- ─── Stores ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS stores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),
  address TEXT,
  logo_url TEXT,
  subscription_status VARCHAR(50) DEFAULT 'trial',
  is_active BOOLEAN DEFAULT true,
  gstin VARCHAR(20),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─── Branches ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS branches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  phone VARCHAR(20),
  is_main BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_by UUID,       -- FK added after staff table exists
  created_at_branch_id UUID,
  updated_by UUID,
  updated_at_branch_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─── Staff ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS staff (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),
  role VARCHAR(50) NOT NULL CHECK (role IN ('super_admin', 'admin', 'manager', 'staff')),
  is_active BOOLEAN DEFAULT true,
  created_by UUID,
  created_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  updated_by UUID,
  updated_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Now add staff FKs to branches (deferred due to circular reference)
ALTER TABLE branches
  ADD CONSTRAINT fk_branches_created_by FOREIGN KEY (created_by) REFERENCES staff(id) ON DELETE SET NULL,
  ADD CONSTRAINT fk_branches_created_at_branch_id FOREIGN KEY (created_at_branch_id) REFERENCES branches(id) ON DELETE SET NULL,
  ADD CONSTRAINT fk_branches_updated_by FOREIGN KEY (updated_by) REFERENCES staff(id) ON DELETE SET NULL,
  ADD CONSTRAINT fk_branches_updated_at_branch_id FOREIGN KEY (updated_at_branch_id) REFERENCES branches(id) ON DELETE SET NULL;

-- Add staff self-referencing FKs
ALTER TABLE staff
  ADD CONSTRAINT fk_staff_created_by FOREIGN KEY (created_by) REFERENCES staff(id) ON DELETE SET NULL,
  ADD CONSTRAINT fk_staff_updated_by FOREIGN KEY (updated_by) REFERENCES staff(id) ON DELETE SET NULL;

-- ─── Categories ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  image_url TEXT,
  parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  is_global BOOLEAN DEFAULT true,
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  created_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  updated_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  updated_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─── Products ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  subcategory_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  subvariant_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  description TEXT,
  sku VARCHAR(100),
  barcode VARCHAR(100),
  price_per_day DECIMAL(10, 2) NOT NULL,
  security_deposit DECIMAL(10, 2) NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0,
  available_quantity INTEGER NOT NULL DEFAULT 0,
  images JSONB DEFAULT '[]'::JSONB,
  sizes TEXT[] DEFAULT ARRAY[]::TEXT[],
  colors TEXT[] DEFAULT ARRAY[]::TEXT[],
  material VARCHAR(50) CHECK (material IN ('gold', 'silver', 'platinum', 'brass', 'copper', 'mixed')),
  weight DECIMAL(10, 2),
  gemstones TEXT[] DEFAULT ARRAY[]::TEXT[],
  metal_purity VARCHAR(10) CHECK (metal_purity IN ('24k', '22k', '18k', '14k')),
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  track_inventory BOOLEAN DEFAULT true,
  low_stock_threshold INTEGER DEFAULT 5,
  total_rentals INTEGER DEFAULT 0,
  total_revenue DECIMAL(10, 2) DEFAULT 0,
  avg_rating DECIMAL(3, 2) DEFAULT 0,
  reviews_count INTEGER DEFAULT 0,
  last_rented_at TIMESTAMP WITH TIME ZONE,
  created_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  created_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  updated_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  updated_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(store_id, slug)
);

-- ─── Product Inventory (per-branch) ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS product_inventory (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 0,
  available_quantity INTEGER NOT NULL DEFAULT 0,
  low_stock_threshold INTEGER DEFAULT 5,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(product_id, branch_id)
);

-- ─── Customers ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(20) NOT NULL,
  alt_phone VARCHAR(20),
  address TEXT,
  gstin VARCHAR(20),
  photo_url VARCHAR(255),
  id_type VARCHAR(50),
  id_number VARCHAR(100),
  id_documents JSONB DEFAULT '[]'::JSONB,
  created_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  created_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  updated_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  updated_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(phone),
  CONSTRAINT check_customer_id_type CHECK (
    id_type IS NULL OR id_type IN ('Aadhaar', 'PAN', 'Driving Licence', 'Passport', 'Others')
  )
);

-- ─── Orders ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  pickup_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  status VARCHAR(50) NOT NULL CHECK (status IN (
    'pending', 'confirmed', 'scheduled', 'delivered', 'in_use', 'ongoing',
    'partial', 'returned', 'completed', 'cancelled', 'flagged', 'late_return'
  )),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  event_date DATE,
  pickup_time TIME,
  return_time TIME,
  subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0,
  gst_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
  gst_percentage DECIMAL(5, 2) DEFAULT 0,
  security_deposit DECIMAL(10, 2) NOT NULL DEFAULT 0,
  total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
  amount_paid DECIMAL(10, 2) DEFAULT 0.00,
  payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'partial', 'paid')),
  advance_amount DECIMAL(10, 2) DEFAULT 0.00,
  advance_collected BOOLEAN DEFAULT false,
  advance_payment_method VARCHAR(20),
  advance_collected_at TIMESTAMPTZ,
  late_fee DECIMAL(10, 2) DEFAULT 0,
  discount DECIMAL(10, 2) DEFAULT 0,
  damage_charges_total DECIMAL(10, 2) DEFAULT 0,
  deposit_collected BOOLEAN DEFAULT false,
  deposit_collected_at TIMESTAMP WITH TIME ZONE,
  deposit_payment_method VARCHAR(50) CHECK (deposit_payment_method IN ('cash', 'upi', 'bank_transfer', 'card', 'other')),
  deposit_returned BOOLEAN DEFAULT false,
  deposit_returned_at TIMESTAMP WITH TIME ZONE,
  delivery_method VARCHAR(50) CHECK (delivery_method IN ('pickup', 'delivery')),
  delivery_address TEXT,
  pickup_address TEXT,
  notes TEXT,
  created_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  created_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  updated_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  updated_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─── Order Items ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL,
  price_per_day DECIMAL(10, 2) NOT NULL,
  subtotal DECIMAL(10, 2) DEFAULT 0,
  condition_rating VARCHAR(20) CHECK (condition_rating IN ('excellent', 'good', 'fair', 'damaged')),
  damage_description TEXT,
  damage_charges DECIMAL(10, 2) DEFAULT 0,
  is_returned BOOLEAN DEFAULT false,
  returned_at TIMESTAMP WITH TIME ZONE,
  returned_quantity INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─── Order Status History ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_status_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  status VARCHAR(50) NOT NULL CHECK (status IN (
    'pending', 'confirmed', 'scheduled', 'delivered', 'in_use', 'ongoing',
    'partial', 'returned', 'completed', 'cancelled', 'flagged', 'late_return'
  )),
  notes TEXT,
  changed_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─── Order Reservations ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_reservations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  reserved_from DATE NOT NULL,
  reserved_to DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT valid_date_range CHECK (reserved_to >= reserved_from)
);

-- ─── Payments ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  payment_type VARCHAR(20) NOT NULL CHECK (payment_type IN ('deposit', 'advance', 'final', 'refund', 'adjustment')),
  amount DECIMAL(10, 2) NOT NULL,
  payment_mode VARCHAR(50) NOT NULL CHECK (payment_mode IN ('cash', 'upi', 'card', 'bank_transfer', 'cheque')),
  transaction_id VARCHAR(100),
  payment_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notes TEXT,
  created_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─── Banners ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS banners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  title VARCHAR(255),
  subtitle TEXT,
  description TEXT,
  call_to_action VARCHAR(255),
  web_image_url TEXT NOT NULL,
  mobile_image_url TEXT,
  redirect_type VARCHAR(50) CHECK (redirect_type IN ('none', 'category', 'subcategory', 'subvariant', 'product', 'url')),
  redirect_target_id UUID,
  redirect_url TEXT,
  banner_type VARCHAR(20) DEFAULT 'hero' CHECK (banner_type IN ('hero', 'editorial', 'split')),
  position VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  priority INTEGER DEFAULT 0,
  start_date DATE,
  end_date DATE,
  alt_text TEXT,
  created_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  created_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  updated_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  updated_at_branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─── Settings ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  key VARCHAR(100) NOT NULL,
  value TEXT NOT NULL,
  updated_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(store_id, key)
);

-- ─── Audit Logs ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES staff(id) ON DELETE SET NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id UUID NOT NULL,
  action VARCHAR(50) NOT NULL,
  old_values JSONB,
  new_values JSONB,
  ip_address VARCHAR(50),
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-- ════════════════════════════════════════════════════════════════════════════
-- INDEXES
-- ════════════════════════════════════════════════════════════════════════════

-- Staff
CREATE INDEX IF NOT EXISTS idx_staff_user_id ON staff(user_id);
CREATE INDEX IF NOT EXISTS idx_staff_created_by ON staff(created_by);
CREATE INDEX IF NOT EXISTS idx_staff_created_at_branch_id ON staff(created_at_branch_id);

-- Categories
CREATE INDEX IF NOT EXISTS idx_categories_store_id ON categories(store_id);
CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_slug ON categories(slug);
CREATE INDEX IF NOT EXISTS idx_categories_created_by ON categories(created_by);
CREATE INDEX IF NOT EXISTS idx_categories_created_at_branch_id ON categories(created_at_branch_id);

-- Products
CREATE INDEX IF NOT EXISTS idx_products_store_id ON products(store_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_slug ON products(slug);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_is_featured ON products(is_featured);
CREATE INDEX IF NOT EXISTS idx_products_branch_id ON products(branch_id);
CREATE INDEX IF NOT EXISTS idx_products_created_by ON products(created_by);
CREATE INDEX IF NOT EXISTS idx_products_created_at_branch_id ON products(created_at_branch_id);

-- Barcode unique index (case-insensitive, allows NULL/empty)
CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_unique
ON products (LOWER(barcode))
WHERE barcode IS NOT NULL AND barcode != '';

-- Product Inventory
CREATE INDEX IF NOT EXISTS idx_product_inventory_product_id ON product_inventory(product_id);
CREATE INDEX IF NOT EXISTS idx_product_inventory_branch_id ON product_inventory(branch_id);

-- Customers
CREATE INDEX IF NOT EXISTS idx_customers_created_by ON customers(created_by);
CREATE INDEX IF NOT EXISTS idx_customers_created_at_branch_id ON customers(created_at_branch_id);

-- Orders
CREATE INDEX IF NOT EXISTS idx_orders_store_id ON orders(store_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_dates ON orders(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_orders_branch_id ON orders(branch_id);
CREATE INDEX IF NOT EXISTS idx_orders_delivery_method ON orders(delivery_method);
CREATE INDEX IF NOT EXISTS idx_orders_deposit_returned ON orders(deposit_returned);
CREATE INDEX IF NOT EXISTS idx_orders_created_by ON orders(created_by);
CREATE INDEX IF NOT EXISTS idx_orders_created_at_branch_id ON orders(created_at_branch_id);

-- Order Items
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_condition_rating ON order_items(condition_rating);

-- Order Reservations
CREATE INDEX IF NOT EXISTS idx_order_reservations_product ON order_reservations(product_id);
CREATE INDEX IF NOT EXISTS idx_order_reservations_branch ON order_reservations(branch_id);
CREATE INDEX IF NOT EXISTS idx_order_reservations_date_range ON order_reservations(reserved_from, reserved_to);
CREATE INDEX IF NOT EXISTS idx_order_reservations_order ON order_reservations(order_id);

-- Payments
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_payment_type ON payments(payment_type);
CREATE INDEX IF NOT EXISTS idx_payments_payment_date ON payments(payment_date);

-- Banners
CREATE INDEX IF NOT EXISTS idx_banners_store_id ON banners(store_id);
CREATE INDEX IF NOT EXISTS idx_banners_is_active ON banners(is_active);
CREATE INDEX IF NOT EXISTS idx_banners_priority ON banners(priority);
CREATE INDEX IF NOT EXISTS idx_banners_banner_type ON banners(banner_type);

-- Branches
CREATE INDEX IF NOT EXISTS idx_branches_created_by ON branches(created_by);
CREATE INDEX IF NOT EXISTS idx_branches_created_at_branch_id ON branches(created_at_branch_id);

-- Settings
CREATE INDEX IF NOT EXISTS idx_settings_store_id ON settings(store_id);
CREATE INDEX IF NOT EXISTS idx_settings_key ON settings(key);

-- Audit Logs
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at);


-- ════════════════════════════════════════════════════════════════════════════
-- TRIGGER FUNCTION
-- ════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = public;

-- Separate trigger function for branch inventory (referenced in codebase)
CREATE OR REPLACE FUNCTION public.update_branch_inventory_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql
SET search_path = public;


-- ════════════════════════════════════════════════════════════════════════════
-- TRIGGERS (updated_at auto-update)
-- ════════════════════════════════════════════════════════════════════════════

CREATE TRIGGER update_stores_updated_at BEFORE UPDATE ON stores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON branches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_staff_updated_at BEFORE UPDATE ON staff
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_product_inventory_updated_at BEFORE UPDATE ON product_inventory
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON order_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_reservations_updated_at BEFORE UPDATE ON order_reservations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_banners_updated_at BEFORE UPDATE ON banners
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_settings_updated_at BEFORE UPDATE ON settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ════════════════════════════════════════════════════════════════════════════
-- COMMENTS
-- ════════════════════════════════════════════════════════════════════════════

COMMENT ON COLUMN orders.pickup_time IS 'Time when customer picks up the items';
COMMENT ON COLUMN orders.return_time IS 'Time when customer returns the items';
COMMENT ON COLUMN orders.pickup_branch_id IS 'Branch where items are picked up from';
COMMENT ON TABLE order_reservations IS 'Tracks inventory reservations by date range to prevent double-booking';
