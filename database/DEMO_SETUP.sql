-- ============================================================================
-- DEMO DATABASE SETUP — Rentocostume (Training Environment)
-- ============================================================================
-- Run this ENTIRE script in your new Supabase project's SQL Editor.
-- It creates all tables, RLS policies, functions, triggers, seed data,
-- and prepares the demo for training.
--
-- PREREQUISITE:
--   1. Create a user in Supabase Dashboard → Authentication → Users → Add user
--      Email: demo@gmail.com
--      Password: admin123
--   2. Copy that user's UUID from the dashboard
--   3. Replace 'REPLACE_WITH_DEMO_USER_UUID' below with that UUID
--   4. Run this entire script in SQL Editor
-- ============================================================================

-- === EXTENSIONS ===
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. TABLES
-- ============================================================================

CREATE TABLE public.stores (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  name varchar(255) NOT NULL,
  slug varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  phone varchar(20),
  address text,
  logo_url text,
  subscription_status varchar(50) DEFAULT 'trial',
  is_active boolean DEFAULT true,
  gstin varchar(20),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.branches (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  store_id uuid NOT NULL,
  name varchar(255) NOT NULL,
  address text NOT NULL,
  phone varchar(20),
  is_main boolean DEFAULT false,
  is_active boolean DEFAULT true,
  created_by uuid,
  created_at_branch_id uuid,
  updated_by uuid,
  updated_at_branch_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.staff (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  store_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  user_id uuid,
  name varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  phone varchar(20),
  role varchar(50) NOT NULL,
  is_active boolean DEFAULT true,
  can_give_product_discount boolean DEFAULT false,
  can_give_order_discount boolean DEFAULT false,
  created_by uuid,
  created_at_branch_id uuid,
  updated_by uuid,
  updated_at_branch_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  name varchar(255) NOT NULL,
  slug varchar(255) NOT NULL,
  description text,
  image_url text,
  parent_id uuid,
  store_id uuid,
  is_global boolean DEFAULT true,
  is_active boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_by uuid,
  created_at_branch_id uuid,
  updated_by uuid,
  updated_at_branch_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  deleted_at timestamp with time zone,
  gst_percentage numeric(5,2) DEFAULT 5.00,
  has_buffer boolean DEFAULT true
);

CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  store_id uuid NOT NULL,
  category_id uuid,
  subcategory_id uuid,
  subvariant_id uuid,
  branch_id uuid,
  name varchar(255) NOT NULL,
  slug varchar(255) NOT NULL,
  description text,
  sku varchar(100),
  barcode varchar(100),
  price_per_day numeric(10,2) NOT NULL,
  quantity integer NOT NULL DEFAULT 0,
  available_quantity integer NOT NULL DEFAULT 0,
  images jsonb DEFAULT '[]'::jsonb,
  sizes text[] DEFAULT ARRAY[]::text[],
  colors text[] DEFAULT ARRAY[]::text[],
  material varchar(50),
  weight numeric(10,2),
  gemstones text[] DEFAULT ARRAY[]::text[],
  metal_purity varchar(50),
  is_active boolean DEFAULT true,
  is_featured boolean DEFAULT false,
  track_inventory boolean DEFAULT true,
  low_stock_threshold integer DEFAULT 5,
  total_rentals integer DEFAULT 0,
  total_revenue numeric(10,2) DEFAULT 0,
  avg_rating numeric(3,2) DEFAULT 0,
  reviews_count integer DEFAULT 0,
  last_rented_at timestamp with time zone,
  created_by uuid,
  created_at_branch_id uuid,
  updated_by uuid,
  updated_at_branch_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  purchase_price numeric(10,2) DEFAULT 0,
  deleted_at timestamp with time zone
);

CREATE TABLE public.product_inventory (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  product_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  quantity integer NOT NULL DEFAULT 0,
  available_quantity integer NOT NULL DEFAULT 0,
  low_stock_threshold integer DEFAULT 5,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.customers (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  name varchar(255) NOT NULL,
  email varchar(255),
  phone varchar(20) NOT NULL,
  alt_phone varchar(20),
  address text,
  gstin varchar(20),
  photo_url varchar(255),
  id_type varchar(50),
  id_number varchar(100),
  id_documents jsonb DEFAULT '[]'::jsonb,
  created_by uuid,
  created_at_branch_id uuid,
  updated_by uuid,
  updated_at_branch_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.orders (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  store_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  customer_id uuid NOT NULL,
  pickup_branch_id uuid,
  status varchar(50) NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  event_date date,
  pickup_time time without time zone,
  return_time time without time zone,
  subtotal numeric(10,2) NOT NULL DEFAULT 0,
  gst_amount numeric(10,2) NOT NULL DEFAULT 0,
  gst_percentage numeric(5,2) DEFAULT 0,
  total_amount numeric(10,2) NOT NULL DEFAULT 0,
  amount_paid numeric(10,2) DEFAULT 0.00,
  payment_status varchar(20) DEFAULT 'pending',
  advance_amount numeric(10,2) DEFAULT 0.00,
  advance_collected boolean DEFAULT false,
  advance_payment_method varchar(20),
  advance_collected_at timestamp with time zone,
  late_fee numeric(10,2) DEFAULT 0,
  discount numeric(10,2) DEFAULT 0,
  damage_charges_total numeric(10,2) DEFAULT 0,
  delivery_method varchar(50),
  delivery_address text,
  pickup_address text,
  notes text,
  created_by uuid,
  created_at_branch_id uuid,
  updated_by uuid,
  updated_at_branch_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  discount_type varchar(10) DEFAULT 'flat',
  cancellation_reason text,
  cancelled_by uuid,
  cancelled_at timestamp with time zone,
  has_priority_cleaning boolean DEFAULT false,
  has_stock_conflict boolean DEFAULT false,
  conflict_details jsonb DEFAULT '[]'::jsonb,
  is_late boolean DEFAULT false
);

CREATE TABLE public.order_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity integer NOT NULL,
  price_per_day numeric(10,2) NOT NULL,
  subtotal numeric(10,2) DEFAULT 0,
  condition_rating varchar(20),
  damage_description text,
  damage_charges numeric(10,2) DEFAULT 0,
  is_returned boolean DEFAULT false,
  returned_at timestamp with time zone,
  returned_quantity integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  discount numeric(10,2) DEFAULT 0,
  discount_type varchar(10) DEFAULT 'flat',
  gst_percentage numeric(5,2) DEFAULT 0,
  base_amount numeric(10,2) DEFAULT 0,
  gst_amount numeric(10,2) DEFAULT 0,
  damaged_quantity integer DEFAULT 0
);

CREATE TABLE public.order_reservations (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id uuid NOT NULL,
  product_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  quantity integer NOT NULL,
  reserved_from date NOT NULL,
  reserved_to date NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.order_status_history (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id uuid NOT NULL,
  status varchar(50) NOT NULL,
  notes text,
  changed_by uuid,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.payments (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id uuid NOT NULL,
  payment_type varchar(20) NOT NULL,
  amount numeric(10,2) NOT NULL,
  payment_mode varchar(50) NOT NULL,
  transaction_id varchar(100),
  payment_date timestamp with time zone DEFAULT now(),
  notes text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.cleaning_records (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  product_id uuid NOT NULL,
  order_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  quantity integer NOT NULL,
  status varchar(50) DEFAULT 'pending',
  priority varchar(50) DEFAULT 'normal',
  priority_order_id uuid,
  started_at timestamp with time zone,
  completed_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  expected_return_date date,
  store_id uuid
);

CREATE TABLE public.damage_assessments (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id uuid NOT NULL,
  order_item_id uuid NOT NULL,
  product_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  unit_index integer NOT NULL,
  decision varchar(20) DEFAULT 'pending',
  notes text,
  assessed_by uuid,
  assessed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.banners (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  store_id uuid,
  title varchar(255),
  subtitle text,
  description text,
  call_to_action varchar(255),
  web_image_url text NOT NULL,
  mobile_image_url text,
  redirect_type varchar(50),
  redirect_target_id uuid,
  redirect_url text,
  banner_type varchar(20) DEFAULT 'hero',
  position varchar(20),
  is_active boolean DEFAULT true,
  priority integer DEFAULT 0,
  start_date date,
  end_date date,
  alt_text text,
  created_by uuid,
  created_at_branch_id uuid,
  updated_by uuid,
  updated_at_branch_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.settings (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  store_id uuid NOT NULL,
  key varchar(100) NOT NULL,
  value text NOT NULL,
  updated_by uuid,
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.audit_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id uuid,
  entity_type varchar(100) NOT NULL,
  entity_id uuid NOT NULL,
  action varchar(50) NOT NULL,
  old_values jsonb,
  new_values jsonb,
  ip_address varchar(50),
  user_agent text,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.customer_enquiries (
  id uuid NOT NULL DEFAULT uuid_generate_v4() PRIMARY KEY,
  product_query varchar(255) NOT NULL,
  customer_name varchar(255),
  customer_phone varchar(20),
  notes text,
  logged_by uuid,
  branch_id uuid,
  store_id uuid,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.gallery (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid REFERENCES public.stores(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  sort_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_by uuid REFERENCES public.staff(id) ON DELETE SET NULL,
  created_at_branch_id uuid REFERENCES public.branches(id) ON DELETE SET NULL,
  updated_by uuid REFERENCES public.staff(id) ON DELETE SET NULL,
  updated_at_branch_id uuid REFERENCES public.branches(id) ON DELETE SET NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- ============================================================================
-- 2. FOREIGN KEYS
-- ============================================================================

ALTER TABLE public.branches ADD CONSTRAINT branches_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.staff ADD CONSTRAINT staff_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.staff ADD CONSTRAINT staff_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.staff ADD CONSTRAINT staff_created_at_branch_id_fkey FOREIGN KEY (created_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.staff ADD CONSTRAINT staff_updated_at_branch_id_fkey FOREIGN KEY (updated_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.branches ADD CONSTRAINT fk_branches_created_by FOREIGN KEY (created_by) REFERENCES public.staff(id);
ALTER TABLE public.branches ADD CONSTRAINT fk_branches_created_at_branch_id FOREIGN KEY (created_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.branches ADD CONSTRAINT fk_branches_updated_by FOREIGN KEY (updated_by) REFERENCES public.staff(id);
ALTER TABLE public.branches ADD CONSTRAINT fk_branches_updated_at_branch_id FOREIGN KEY (updated_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.staff ADD CONSTRAINT fk_staff_created_by FOREIGN KEY (created_by) REFERENCES public.staff(id);
ALTER TABLE public.staff ADD CONSTRAINT fk_staff_updated_by FOREIGN KEY (updated_by) REFERENCES public.staff(id);
ALTER TABLE public.categories ADD CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(id);
ALTER TABLE public.categories ADD CONSTRAINT categories_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.categories ADD CONSTRAINT categories_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.staff(id);
ALTER TABLE public.categories ADD CONSTRAINT categories_created_at_branch_id_fkey FOREIGN KEY (created_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.categories ADD CONSTRAINT categories_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.staff(id);
ALTER TABLE public.categories ADD CONSTRAINT categories_updated_at_branch_id_fkey FOREIGN KEY (updated_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.products ADD CONSTRAINT products_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.products ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);
ALTER TABLE public.products ADD CONSTRAINT products_subcategory_id_fkey FOREIGN KEY (subcategory_id) REFERENCES public.categories(id);
ALTER TABLE public.products ADD CONSTRAINT products_subvariant_id_fkey FOREIGN KEY (subvariant_id) REFERENCES public.categories(id);
ALTER TABLE public.products ADD CONSTRAINT products_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.products ADD CONSTRAINT products_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.staff(id);
ALTER TABLE public.products ADD CONSTRAINT products_created_at_branch_id_fkey FOREIGN KEY (created_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.products ADD CONSTRAINT products_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.staff(id);
ALTER TABLE public.products ADD CONSTRAINT products_updated_at_branch_id_fkey FOREIGN KEY (updated_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.product_inventory ADD CONSTRAINT product_inventory_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
ALTER TABLE public.product_inventory ADD CONSTRAINT product_inventory_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.customers ADD CONSTRAINT customers_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.staff(id);
ALTER TABLE public.customers ADD CONSTRAINT customers_created_at_branch_id_fkey FOREIGN KEY (created_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.customers ADD CONSTRAINT customers_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.staff(id);
ALTER TABLE public.customers ADD CONSTRAINT customers_updated_at_branch_id_fkey FOREIGN KEY (updated_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.orders ADD CONSTRAINT orders_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.orders ADD CONSTRAINT orders_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.orders ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE public.orders ADD CONSTRAINT orders_pickup_branch_id_fkey FOREIGN KEY (pickup_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.orders ADD CONSTRAINT orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.staff(id);
ALTER TABLE public.orders ADD CONSTRAINT orders_created_at_branch_id_fkey FOREIGN KEY (created_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.orders ADD CONSTRAINT orders_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.staff(id);
ALTER TABLE public.orders ADD CONSTRAINT orders_updated_at_branch_id_fkey FOREIGN KEY (updated_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.orders ADD CONSTRAINT orders_cancelled_by_fkey FOREIGN KEY (cancelled_by) REFERENCES public.staff(id) ON DELETE SET NULL;
ALTER TABLE public.order_items ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);
ALTER TABLE public.order_items ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
ALTER TABLE public.order_status_history ADD CONSTRAINT order_status_history_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);
ALTER TABLE public.order_status_history ADD CONSTRAINT order_status_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.staff(id);
ALTER TABLE public.order_reservations ADD CONSTRAINT order_reservations_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);
ALTER TABLE public.order_reservations ADD CONSTRAINT order_reservations_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
ALTER TABLE public.order_reservations ADD CONSTRAINT order_reservations_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.payments ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);
ALTER TABLE public.payments ADD CONSTRAINT payments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.staff(id);
ALTER TABLE public.cleaning_records ADD CONSTRAINT cleaning_records_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
ALTER TABLE public.cleaning_records ADD CONSTRAINT cleaning_records_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);
ALTER TABLE public.cleaning_records ADD CONSTRAINT cleaning_records_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.cleaning_records ADD CONSTRAINT cleaning_records_priority_order_id_fkey FOREIGN KEY (priority_order_id) REFERENCES public.orders(id);
ALTER TABLE public.cleaning_records ADD CONSTRAINT cleaning_records_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.damage_assessments ADD CONSTRAINT damage_assessments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);
ALTER TABLE public.damage_assessments ADD CONSTRAINT damage_assessments_order_item_id_fkey FOREIGN KEY (order_item_id) REFERENCES public.order_items(id);
ALTER TABLE public.damage_assessments ADD CONSTRAINT damage_assessments_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
ALTER TABLE public.damage_assessments ADD CONSTRAINT damage_assessments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.damage_assessments ADD CONSTRAINT damage_assessments_assessed_by_fkey FOREIGN KEY (assessed_by) REFERENCES public.staff(id);
ALTER TABLE public.banners ADD CONSTRAINT banners_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.banners ADD CONSTRAINT banners_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.staff(id);
ALTER TABLE public.banners ADD CONSTRAINT banners_created_at_branch_id_fkey FOREIGN KEY (created_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.banners ADD CONSTRAINT banners_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.staff(id);
ALTER TABLE public.banners ADD CONSTRAINT banners_updated_at_branch_id_fkey FOREIGN KEY (updated_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.settings ADD CONSTRAINT settings_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.settings ADD CONSTRAINT settings_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.staff(id);
ALTER TABLE public.audit_logs ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.staff(id);
ALTER TABLE public.customer_enquiries ADD CONSTRAINT customer_enquiries_logged_by_fkey FOREIGN KEY (logged_by) REFERENCES public.staff(id);
ALTER TABLE public.customer_enquiries ADD CONSTRAINT customer_enquiries_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.customer_enquiries ADD CONSTRAINT customer_enquiries_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);

-- ============================================================================
-- 3. UNIQUE CONSTRAINTS & INDEXES
-- ============================================================================

CREATE UNIQUE INDEX stores_slug_key ON public.stores USING btree (slug);
CREATE UNIQUE INDEX stores_email_key ON public.stores USING btree (email);
CREATE UNIQUE INDEX categories_slug_key ON public.categories USING btree (slug);
CREATE UNIQUE INDEX customers_phone_key ON public.customers USING btree (phone);
CREATE UNIQUE INDEX staff_email_key ON public.staff USING btree (email);
CREATE UNIQUE INDEX product_inventory_product_id_branch_id_key ON public.product_inventory USING btree (product_id, branch_id);
CREATE UNIQUE INDEX products_store_id_slug_key ON public.products USING btree (store_id, slug);
CREATE UNIQUE INDEX settings_store_id_key_key ON public.settings USING btree (store_id, key);
CREATE UNIQUE INDEX damage_assessments_order_item_id_unit_index_key ON public.damage_assessments USING btree (order_item_id, unit_index);
CREATE UNIQUE INDEX idx_products_barcode_unique ON public.products USING btree (lower((barcode)::text)) WHERE ((barcode IS NOT NULL) AND ((barcode)::text <> ''::text));

-- Performance indexes
CREATE INDEX idx_branches_created_by ON public.branches USING btree (created_by);
CREATE INDEX idx_categories_store_id ON public.categories USING btree (store_id);
CREATE INDEX idx_categories_parent_id ON public.categories USING btree (parent_id);
CREATE INDEX idx_categories_slug ON public.categories USING btree (slug);
CREATE INDEX idx_categories_not_deleted ON public.categories USING btree (id) WHERE (deleted_at IS NULL);
CREATE INDEX idx_products_store_id ON public.products USING btree (store_id);
CREATE INDEX idx_products_category_id ON public.products USING btree (category_id);
CREATE INDEX idx_products_slug ON public.products USING btree (slug);
CREATE INDEX idx_products_is_active ON public.products USING btree (is_active);
CREATE INDEX idx_products_is_featured ON public.products USING btree (is_featured);
CREATE INDEX idx_products_branch_id ON public.products USING btree (branch_id);
CREATE INDEX idx_products_not_deleted ON public.products USING btree (id) WHERE (deleted_at IS NULL);
CREATE INDEX idx_product_inventory_product_id ON public.product_inventory USING btree (product_id);
CREATE INDEX idx_product_inventory_branch_id ON public.product_inventory USING btree (branch_id);
CREATE INDEX idx_orders_store_id ON public.orders USING btree (store_id);
CREATE INDEX idx_orders_customer_id ON public.orders USING btree (customer_id);
CREATE INDEX idx_orders_status ON public.orders USING btree (status);
CREATE INDEX idx_orders_dates ON public.orders USING btree (start_date, end_date);
CREATE INDEX idx_orders_branch_id ON public.orders USING btree (branch_id);
CREATE INDEX idx_orders_created_at ON public.orders USING btree (created_at);
CREATE INDEX idx_orders_start_date ON public.orders USING btree (start_date);
CREATE INDEX idx_orders_end_date ON public.orders USING btree (end_date);
CREATE INDEX idx_orders_is_late ON public.orders USING btree (is_late) WHERE (is_late = true);
CREATE INDEX idx_orders_stock_conflict ON public.orders USING btree (has_stock_conflict) WHERE (has_stock_conflict = true);
CREATE INDEX idx_orders_cancelled_by ON public.orders USING btree (cancelled_by);
CREATE INDEX idx_orders_cancelled_at ON public.orders USING btree (cancelled_at);
CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);
CREATE INDEX idx_order_items_product_id ON public.order_items USING btree (product_id);
CREATE INDEX idx_order_reservations_product ON public.order_reservations USING btree (product_id);
CREATE INDEX idx_order_reservations_branch ON public.order_reservations USING btree (branch_id);
CREATE INDEX idx_order_reservations_date_range ON public.order_reservations USING btree (reserved_from, reserved_to);
CREATE INDEX idx_payments_order_id ON public.payments USING btree (order_id);
CREATE INDEX idx_payments_payment_type ON public.payments USING btree (payment_type);
CREATE INDEX idx_payments_payment_date ON public.payments USING btree (payment_date);
CREATE INDEX idx_staff_user_id ON public.staff USING btree (user_id);
CREATE INDEX idx_banners_store_id ON public.banners USING btree (store_id);
CREATE INDEX idx_banners_is_active ON public.banners USING btree (is_active);
CREATE INDEX idx_banners_priority ON public.banners USING btree (priority);
CREATE INDEX idx_banners_banner_type ON public.banners USING btree (banner_type);
CREATE INDEX idx_settings_store_id ON public.settings USING btree (store_id);
CREATE INDEX idx_audit_logs_entity ON public.audit_logs USING btree (entity_type, entity_id);
CREATE INDEX idx_audit_logs_user_id ON public.audit_logs USING btree (user_id);
CREATE INDEX idx_audit_logs_created_at ON public.audit_logs USING btree (created_at);
CREATE INDEX idx_cleaning_product ON public.cleaning_records USING btree (product_id);
CREATE INDEX idx_cleaning_status ON public.cleaning_records USING btree (status);
CREATE INDEX idx_cleaning_priority ON public.cleaning_records USING btree (priority);
CREATE INDEX idx_cleaning_branch ON public.cleaning_records USING btree (branch_id);
CREATE INDEX idx_cleaning_order ON public.cleaning_records USING btree (order_id);
CREATE INDEX idx_cleaning_expected_return ON public.cleaning_records USING btree (product_id, expected_return_date);
CREATE INDEX idx_damage_assessments_order_id ON public.damage_assessments USING btree (order_id);
CREATE INDEX idx_damage_assessments_product_id ON public.damage_assessments USING btree (product_id);
CREATE INDEX idx_damage_assessments_decision ON public.damage_assessments USING btree (decision);
CREATE INDEX idx_damage_assessments_order_item_id ON public.damage_assessments USING btree (order_item_id);

-- ============================================================================
-- 4. HELPER FUNCTIONS (RLS)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_user_branch_id()
RETURNS UUID AS $$
  SELECT branch_id FROM staff WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public;

CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
  SELECT role FROM staff WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 FROM staff
    WHERE user_id = auth.uid()
    AND role IN ('super_admin', 'admin')
  );
$$ LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 FROM staff
    WHERE user_id = auth.uid()
    AND role = 'super_admin'
  );
$$ LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public;

CREATE OR REPLACE FUNCTION public.is_manager_or_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS(
    SELECT 1 FROM staff
    WHERE user_id = auth.uid()
    AND role IN ('super_admin', 'admin', 'manager')
  );
$$ LANGUAGE SQL SECURITY DEFINER STABLE
SET search_path = public;

-- ============================================================================
-- 5. ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cleaning_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.damage_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_enquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gallery ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 6. RLS POLICIES
-- ============================================================================

-- Stores
CREATE POLICY "stores_select_authenticated" ON public.stores FOR SELECT TO authenticated USING (true);
CREATE POLICY "stores_anon_select" ON public.stores FOR SELECT TO anon USING (is_active = true);
CREATE POLICY "stores_authenticated_select" ON public.stores FOR SELECT TO authenticated USING (true);

-- Branches
CREATE POLICY "branches_select_authenticated" ON public.branches FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR id = get_user_branch_id());

-- Staff
CREATE POLICY "staff_select_authenticated" ON public.staff FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR user_id = auth.uid());

-- Categories
CREATE POLICY "categories_select_authenticated" ON public.categories FOR SELECT TO authenticated USING (true);
CREATE POLICY "categories_anon_select" ON public.categories FOR SELECT TO anon USING (is_active = true);
CREATE POLICY "categories_authenticated_select" ON public.categories FOR SELECT TO authenticated USING (true);

-- Products
CREATE POLICY "products_select_authenticated" ON public.products FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR branch_id = get_user_branch_id() OR branch_id IS NULL);
CREATE POLICY "products_anon_select" ON public.products FOR SELECT TO anon USING (is_active = true);

-- Product Inventory
CREATE POLICY "product_inventory_select_authenticated" ON public.product_inventory FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR branch_id = get_user_branch_id());

-- Orders
CREATE POLICY "orders_select_authenticated" ON public.orders FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR branch_id = get_user_branch_id());

-- Order Items
CREATE POLICY "order_items_select_authenticated" ON public.order_items FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.orders WHERE public.orders.id = public.order_items.order_id
    AND (is_super_admin() OR is_admin() OR public.orders.branch_id = get_user_branch_id())
  ));

-- Banners
CREATE POLICY "banners_anon_select" ON public.banners FOR SELECT TO anon USING (is_active = true);

-- Gallery
CREATE POLICY "gallery_anon_select" ON public.gallery FOR SELECT TO anon USING (is_active = true);
CREATE POLICY "gallery_authenticated_select" ON public.gallery FOR SELECT TO authenticated USING (true);
CREATE POLICY "gallery_authenticated_all" ON public.gallery FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "gallery_anon_all" ON public.gallery FOR ALL TO anon USING (true) WITH CHECK (true);

-- Customers (RLS policies from migration 035)
CREATE POLICY "customers_select_authenticated" ON public.customers FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR created_at_branch_id = get_user_branch_id());
CREATE POLICY "customers_insert_authenticated" ON public.customers FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "customers_update_authenticated" ON public.customers FOR UPDATE TO authenticated WITH CHECK (true);
CREATE POLICY "customers_delete_authenticated" ON public.customers FOR DELETE TO authenticated USING (true);

-- Cleaning Records RLS
CREATE POLICY "cleaning_records_select_authenticated" ON public.cleaning_records FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR branch_id = get_user_branch_id());
CREATE POLICY "cleaning_records_insert_authenticated" ON public.cleaning_records FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "cleaning_records_update_authenticated" ON public.cleaning_records FOR UPDATE TO authenticated WITH CHECK (true);

-- Damage Assessments RLS
CREATE POLICY "damage_assessments_select_authenticated" ON public.damage_assessments FOR SELECT TO authenticated
  USING (is_super_admin() OR is_admin() OR branch_id = get_user_branch_id());
CREATE POLICY "damage_assessments_insert_authenticated" ON public.damage_assessments FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "damage_assessments_update_authenticated" ON public.damage_assessments FOR UPDATE TO authenticated WITH CHECK (true);

-- Revoke execute from PUBLIC on security functions
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_super_admin() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_manager_or_admin() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.get_user_role() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.get_user_branch_id() FROM PUBLIC;

-- ============================================================================
-- 7. TRIGGERS
-- ============================================================================

-- updated_at trigger function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to all tables
CREATE TRIGGER update_stores_updated_at BEFORE UPDATE ON public.stores FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON public.branches FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_staff_updated_at BEFORE UPDATE ON public.staff FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_product_inventory_updated_at BEFORE UPDATE ON public.product_inventory FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON public.order_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_order_reservations_updated_at BEFORE UPDATE ON public.order_reservations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_cleaning_records_updated_at BEFORE UPDATE ON public.cleaning_records FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_damage_assessments_updated_at BEFORE UPDATE ON public.damage_assessments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_banners_updated_at BEFORE UPDATE ON public.banners FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_settings_updated_at BEFORE UPDATE ON public.settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_gallery_updated_at BEFORE UPDATE ON public.gallery FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Late flag trigger
CREATE OR REPLACE FUNCTION public.calculate_late_flag()
RETURNS TRIGGER AS $$
BEGIN
  NEW.is_late := (
    (NEW.end_date IS NOT NULL) AND
    (NEW.end_date < CURRENT_DATE) AND
    (NEW.status IN ('ongoing', 'in_use', 'delivered'))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_late_flag ON public.orders;
CREATE TRIGGER trigger_update_late_flag
BEFORE INSERT OR UPDATE OF end_date, status ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.calculate_late_flag();

-- ============================================================================
-- 8. RPC FUNCTIONS
-- ============================================================================

-- Dashboard metrics (with branch filter support)
CREATE OR REPLACE FUNCTION public.get_operational_dashboard_metrics(
  p_today_start TIMESTAMPTZ,
  p_today_end TIMESTAMPTZ,
  p_today_date DATE,
  p_yesterday_date DATE,
  p_tomorrow_date DATE,
  p_next_5_days_date DATE,
  p_branch_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_todays_bookings INT;
  v_todays_delivery_total INT;
  v_todays_delivery_done INT;
  v_todays_return_total INT;
  v_todays_return_done INT;
  v_prepare_deliveries INT;
  v_pending_deliveries INT;
  v_pending_returns INT;
  v_revenue_due_count INT;
  v_revenue_due_amount DECIMAL(12, 2);
  v_priority_cleaning JSONB;
BEGIN
  SELECT COALESCE(COUNT(*), 0) INTO v_todays_bookings
  FROM public.orders
  WHERE created_at >= p_today_start AND created_at <= p_today_end 
    AND status != 'cancelled'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  SELECT COALESCE(COUNT(*), 0) INTO v_todays_delivery_total
  FROM public.orders
  WHERE start_date = p_today_date 
    AND status != 'cancelled'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  SELECT COALESCE(COUNT(*), 0) INTO v_todays_delivery_done
  FROM public.orders
  WHERE start_date = p_today_date 
    AND status IN ('ongoing', 'in_use', 'delivered', 'partial', 'returned', 'completed', 'flagged')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  SELECT COALESCE(COUNT(*), 0) INTO v_todays_return_total
  FROM public.orders
  WHERE end_date = p_today_date 
    AND status != 'cancelled'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  SELECT COALESCE(COUNT(*), 0) INTO v_todays_return_done
  FROM public.orders
  WHERE end_date = p_today_date 
    AND status IN ('returned', 'completed', 'flagged')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  SELECT COALESCE(COUNT(*), 0) INTO v_prepare_deliveries
  FROM public.orders
  WHERE start_date >= p_tomorrow_date AND start_date <= p_next_5_days_date 
    AND status IN ('scheduled', 'pending', 'confirmed')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  SELECT COALESCE(COUNT(*), 0) INTO v_pending_deliveries
  FROM public.orders
  WHERE start_date < p_today_date 
    AND status IN ('scheduled', 'pending', 'confirmed')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  SELECT COALESCE(COUNT(*), 0) INTO v_pending_returns
  FROM public.orders
  WHERE end_date < p_today_date 
    AND status IN ('ongoing', 'in_use')
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  SELECT COALESCE(COUNT(*), 0), COALESCE(SUM(GREATEST(0, total_amount - amount_paid)), 0.00)
  INTO v_revenue_due_count, v_revenue_due_amount
  FROM public.orders
  WHERE status IN ('returned', 'partial', 'flagged') 
    AND payment_status != 'paid'
    AND (p_branch_id IS NULL OR branch_id = p_branch_id);

  SELECT COALESCE(JSONB_AGG(t), '[]'::jsonb) INTO v_priority_cleaning
  FROM (
    SELECT 
      cr.id, cr.product_id, cr.quantity, cr.expected_return_date, 
      cr.priority_order_id, cr.notes,
      JSONB_BUILD_OBJECT('name', p.name) AS product
    FROM public.cleaning_records cr
    LEFT JOIN public.products p ON cr.product_id = p.id
    WHERE cr.status IN ('scheduled', 'pending') 
      AND cr.priority = 'urgent'
      AND (p_branch_id IS NULL OR p.branch_id = p_branch_id)
    ORDER BY cr.expected_return_date ASC
    LIMIT 10
  ) t;

  RETURN JSONB_BUILD_OBJECT(
    'todaysBookings', v_todays_bookings,
    'todaysDeliveryTotal', v_todays_delivery_total,
    'todaysDeliveryDone', v_todays_delivery_done,
    'todaysReturnTotal', v_todays_return_total,
    'todaysReturnDone', v_todays_return_done,
    'prepareDeliveries', v_prepare_deliveries,
    'pendingDeliveries', v_pending_deliveries,
    'pendingReturns', v_pending_returns,
    'revenueDueCount', v_revenue_due_count,
    'revenueDueAmount', v_revenue_due_amount,
    'priorityCleaning', v_priority_cleaning
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dead stock function
CREATE OR REPLACE FUNCTION public.get_dead_stock(
  p_ninety_days_ago TIMESTAMPTZ, 
  p_branch_id UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  name VARCHAR,
  days_idle INT,
  value DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id, p.name,
    GREATEST(0, EXTRACT(DAY FROM (NOW() - p.created_at))::INT) as days_idle,
    p.price_per_day as value
  FROM public.products p
  WHERE p.is_active = true 
    AND p.deleted_at IS NULL
    AND (p_branch_id IS NULL OR p.branch_id = p_branch_id)
    AND EXTRACT(DAY FROM (NOW() - p.created_at)) >= 90
    AND p.id NOT IN (
      SELECT DISTINCT oi.product_id 
      FROM public.order_items oi
      INNER JOIN public.orders o ON oi.order_id = o.id
      WHERE o.created_at >= p_ninety_days_ago 
        AND o.status != 'cancelled'
        AND (p_branch_id IS NULL OR o.branch_id = p_branch_id)
    )
  ORDER BY days_idle DESC, value DESC
  LIMIT 5;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 9. SEED DATA
-- ============================================================================

-- Store
INSERT INTO public.stores (name, slug, email, phone, address, is_active, subscription_status)
VALUES (
  'Rentocostume',
  'Rentocostume-costumes',
  'Rentocostumedancecostumes01@gmail.com',
  '+919447923234',
  'Karamana Main Road, near QRS, Prem Nagar, Karamana, Thiruvananthapuram, Kerala 695002',
  true,
  'active'
)
ON CONFLICT (slug) DO NOTHING;

-- Main Branch
INSERT INTO public.branches (store_id, name, address, phone, is_main, is_active)
SELECT
  id, 'Main Branch',
  'Karamana Main Road, near QRS, Prem Nagar, Karamana, Thiruvananthapuram, Kerala 695002',
  '+919447923234', true, true
FROM public.stores WHERE slug = 'Rentocostume-costumes'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 10. DEMO SUPER ADMIN
-- ============================================================================
-- Step 1: Create staff record with NULL user_id (runs now)
-- Step 2: After creating demo@gmail.com in Supabase Auth, run the UPDATE
--         at the bottom of this script to link the auth user
-- ============================================================================

INSERT INTO public.staff (
  store_id, branch_id, user_id, name, email, phone, role, is_active,
  can_give_product_discount, can_give_order_discount
)
SELECT
  s.id, b.id,
  NULL,   -- will be linked after creating auth user (see UPDATE at bottom)
  'Demo Admin',
  'demo@gmail.com',
  '+919999999999',
  'super_admin',
  true,
  true,
  true
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
WHERE s.slug = 'Rentocostume-costumes';

-- ============================================================================
-- 11. DEFAULT SETTINGS
-- ============================================================================

INSERT INTO public.settings (store_id, key, value)
SELECT id, 'gst_percentage', '18.00' FROM public.stores WHERE slug = 'Rentocostume-costumes'
ON CONFLICT (store_id, key) DO NOTHING;

INSERT INTO public.settings (store_id, key, value)
SELECT id, 'invoice_prefix', 'INV-' FROM public.stores WHERE slug = 'Rentocostume-costumes'
ON CONFLICT (store_id, key) DO NOTHING;

INSERT INTO public.settings (store_id, key, value)
SELECT id, 'payment_terms', 'Payment must be made before or at the time of delivery. Security deposit is refundable upon return of items in good condition.'
FROM public.stores WHERE slug = 'Rentocostume-costumes'
ON CONFLICT (store_id, key) DO NOTHING;

INSERT INTO public.settings (store_id, key, value)
SELECT id, 'authorized_signature', 'Authorized Signatory' FROM public.stores WHERE slug = 'Rentocostume-costumes'
ON CONFLICT (store_id, key) DO NOTHING;

-- ============================================================================
-- 12. DEMO CATEGORIES (3-Level Hierarchy)
-- ============================================================================

-- Level 1: Main Categories
INSERT INTO public.categories (name, slug, description, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Bharatanatyam', 'bharatanatyam', 'Bharatanatyam dance costumes', id, true, true, 1, 5.00, true
FROM public.stores WHERE slug = 'Rentocostume-costumes';

INSERT INTO public.categories (name, slug, description, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Mohiniyattam', 'mohiniyattam', 'Mohiniyattam dance costumes', id, true, true, 2, 5.00, true
FROM public.stores WHERE slug = 'Rentocostume-costumes';

INSERT INTO public.categories (name, slug, description, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Kathakali', 'kathakali', 'Kathakali dance costumes', id, true, true, 3, 5.00, true
FROM public.stores WHERE slug = 'Rentocostume-costumes';

INSERT INTO public.categories (name, slug, description, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Kuchipudi', 'kuchipudi', 'Kuchipudi dance costumes', id, true, true, 4, 5.00, true
FROM public.stores WHERE slug = 'Rentocostume-costumes';

INSERT INTO public.categories (name, slug, description, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Accessories', 'accessories', 'Dance accessories and jewelry', id, true, true, 5, 5.00, false
FROM public.stores WHERE slug = 'Rentocostume-costumes';

-- Level 2: Sub Categories (under Bharatanatyam)
INSERT INTO public.categories (name, slug, description, parent_id, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Costumes', 'bharatanatyam-costumes', 'Bharatanatyam costumes', c.id, s.id, true, true, 1, 5.00, true
FROM public.categories c, public.stores s
WHERE c.slug = 'bharatanatyam' AND s.slug = 'Rentocostume-costumes';

INSERT INTO public.categories (name, slug, description, parent_id, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Jewelry', 'bharatanatyam-jewelry', 'Bharatanatyam jewelry sets', c.id, s.id, true, true, 2, 5.00, false
FROM public.categories c, public.stores s
WHERE c.slug = 'bharatanatyam' AND s.slug = 'Rentocostume-costumes';

-- Level 2: Sub Categories (under Mohiniyattam)
INSERT INTO public.categories (name, slug, description, parent_id, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Costumes', 'mohiniyattam-costumes', 'Mohiniyattam costumes', c.id, s.id, true, true, 1, 5.00, true
FROM public.categories c, public.stores s
WHERE c.slug = 'mohiniyattam' AND s.slug = 'Rentocostume-costumes';

-- Level 2: Sub Categories (under Accessories)
INSERT INTO public.categories (name, slug, description, parent_id, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Earrings', 'earrings', 'Dance earrings', c.id, s.id, true, true, 1, 5.00, false
FROM public.categories c, public.stores s
WHERE c.slug = 'accessories' AND s.slug = 'Rentocostume-costumes';

INSERT INTO public.categories (name, slug, description, parent_id, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Necklaces', 'necklaces', 'Dance necklaces', c.id, s.id, true, true, 2, 5.00, false
FROM public.categories c, public.stores s
WHERE c.slug = 'accessories' AND s.slug = 'Rentocostume-costumes';

-- Level 3: Variants (under Bharatanatyam Costumes)
INSERT INTO public.categories (name, slug, description, parent_id, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Adult', 'bharatanatyam-costumes-adult', 'Adult size Bharatanatyam costumes', c.id, s.id, true, true, 1, 5.00, true
FROM public.categories c, public.stores s
WHERE c.slug = 'bharatanatyam-costumes' AND s.slug = 'Rentocostume-costumes';

INSERT INTO public.categories (name, slug, description, parent_id, store_id, is_active, is_global, sort_order, gst_percentage, has_buffer)
SELECT 'Kids', 'bharatanatyam-costumes-kids', 'Kids size Bharatanatyam costumes', c.id, s.id, true, true, 2, 5.00, true
FROM public.categories c, public.stores s
WHERE c.slug = 'bharatanatyam-costumes' AND s.slug = 'Rentocostume-costumes';

-- ============================================================================
-- 13. DEMO PRODUCTS
-- ============================================================================

INSERT INTO public.products (store_id, category_id, branch_id, name, slug, description, price_per_day, quantity, available_quantity, sizes, colors, material, is_active, is_featured, track_inventory, low_stock_threshold, purchase_price)
SELECT
  s.id, c.id, b.id,
  'Bharatanatyam Premium Silk Costume Set',
  'bharatanatyam-premium-silk-costume-set',
  'Premium quality silk Bharatanatyam costume with traditional designs. Includes blouse, skirt, and fan.',
  500.00, 5, 5,
  ARRAY['S', 'M', 'L', 'XL'],
  ARRAY['Red', 'Green', 'Blue', 'Maroon'],
  'Silk',
  true, true, true, 2, 15000.00
FROM public.stores s, public.categories c, public.branches b
WHERE s.slug = 'Rentocostume-costumes' AND c.slug = 'bharatanatyam-costumes-adult' AND b.is_main = true;

INSERT INTO public.products (store_id, category_id, branch_id, name, slug, description, price_per_day, quantity, available_quantity, sizes, colors, material, is_active, is_featured, track_inventory, low_stock_threshold, purchase_price)
SELECT
  s.id, c.id, b.id,
  'Bharatanatyam Kids Costume Set',
  'bharatanatyam-kids-costume-set',
  'Comfortable cotton-silk blend costume for children. Ages 5-12.',
  300.00, 8, 7,
  ARRAY['XS', 'S', 'M'],
  ARRAY['Red', 'Green', 'Pink'],
  'Cotton Silk',
  true, false, true, 3, 8000.00
FROM public.stores s, public.categories c, public.branches b
WHERE s.slug = 'Rentocostume-costumes' AND c.slug = 'bharatanatyam-costumes-kids' AND b.is_main = true;

INSERT INTO public.products (store_id, category_id, branch_id, name, slug, description, price_per_day, quantity, available_quantity, sizes, colors, material, is_active, is_featured, track_inventory, low_stock_threshold, purchase_price)
SELECT
  s.id, c.id, b.id,
  'Mohiniyattam White Silk Costume',
  'mohiniyattam-white-silk-costume',
  'Traditional white and gold Mohiniyattam costume. Hand-woven silk with golden border.',
  450.00, 3, 3,
  ARRAY['S', 'M', 'L'],
  ARRAY['White', 'Off-White'],
  'Silk',
  true, true, true, 1, 12000.00
FROM public.stores s, public.categories c, public.branches b
WHERE s.slug = 'Rentocostume-costumes' AND c.slug = 'mohiniyattam-costumes' AND b.is_main = true;

INSERT INTO public.products (store_id, category_id, branch_id, name, slug, description, price_per_day, quantity, available_quantity, sizes, colors, material, is_active, is_featured, track_inventory, low_stock_threshold, purchase_price, gemstones, metal_purity, weight)
SELECT
  s.id, c.id, b.id,
  'Temple Jewelry Necklace Set',
  'temple-jewelry-necklace-set',
  'Traditional temple jewelry necklace set with matching earrings. Gold-plated with ruby and emerald stones.',
  200.00, 4, 4,
  ARRAY['Free Size'],
  ARRAY['Gold'],
  'Brass',
  true, true, true, 2, 5000.00,
  ARRAY['Ruby', 'Emerald'],
  '22K Gold Plated',
  150.00
FROM public.stores s, public.categories c, public.branches b
WHERE s.slug = 'Rentocostume-costumes' AND c.slug = 'necklaces' AND b.is_main = true;

INSERT INTO public.products (store_id, category_id, branch_id, name, slug, description, price_per_day, quantity, available_quantity, sizes, colors, material, is_active, is_featured, track_inventory, low_stock_threshold, purchase_price, gemstones, metal_purity, weight)
SELECT
  s.id, c.id, b.id,
  'Bharatanatyam Dancer Earrings',
  'bharatanatyam-dancer-earrings',
  'Traditional jhumka earrings for Bharatanatyam dancers. Gold-plated with pearl drops.',
  100.00, 10, 9,
  ARRAY['Free Size'],
  ARRAY['Gold'],
  'Brass',
  true, false, true, 3, 2000.00,
  ARRAY['Pearl'],
  '22K Gold Plated',
  50.00
FROM public.stores s, public.categories c, public.branches b
WHERE s.slug = 'Rentocostume-costumes' AND c.slug = 'earrings' AND b.is_main = true;

INSERT INTO public.products (store_id, category_id, branch_id, name, slug, description, price_per_day, quantity, available_quantity, sizes, colors, material, is_active, is_featured, track_inventory, low_stock_threshold, purchase_price)
SELECT
  s.id, c.id, b.id,
  'Kathakali Full Costume Set',
  'kathakali-full-costume-set',
  'Complete Kathakali costume including headgear, face paint supplies, and traditional attire.',
  800.00, 2, 2,
  ARRAY['Free Size'],
  ARRAY['Multi'],
  'Mixed Materials',
  true, true, true, 1, 25000.00
FROM public.stores s, public.categories c, public.branches b
WHERE s.slug = 'Rentocostume-costumes' AND c.slug = 'kathakali' AND b.is_main = true;

INSERT INTO public.products (store_id, category_id, branch_id, name, slug, description, price_per_day, quantity, available_quantity, sizes, colors, material, is_active, is_featured, track_inventory, low_stock_threshold, purchase_price)
SELECT
  s.id, c.id, b.id,
  'Kuchipudi Traditional Costume',
  'kuchipudi-traditional-costume',
  'Traditional Kuchipudi dance costume with fan and border work.',
  400.00, 4, 4,
  ARRAY['S', 'M', 'L', 'XL'],
  ARRAY['Red', 'Green'],
  'Silk',
  true, false, true, 2, 10000.00
FROM public.stores s, public.categories c, public.branches b
WHERE s.slug = 'Rentocostume-costumes' AND c.slug = 'kuchipudi' AND b.is_main = true;

-- ============================================================================
-- 14. PRODUCT INVENTORY
-- ============================================================================

INSERT INTO public.product_inventory (product_id, branch_id, quantity, available_quantity, low_stock_threshold)
SELECT p.id, b.id, p.quantity, p.available_quantity, p.low_stock_threshold
FROM public.products p, public.branches b
WHERE b.is_main = true AND b.store_id = (SELECT id FROM public.stores WHERE slug = 'Rentocostume-costumes')
ON CONFLICT (product_id, branch_id) DO NOTHING;

-- ============================================================================
-- 15. DEMO CUSTOMERS
-- ============================================================================

INSERT INTO public.customers (name, phone, email, address)
VALUES
  ('Rajesh Kumar', '+919847001001', 'rajesh@example.com', 'Trivandrum, Kerala'),
  ('Lakshmi Nair', '+919847001002', 'lakshmi@example.com', 'Kochi, Kerala'),
  ('Arun Menon', '+919847001003', 'arun@example.com', 'Kollam, Kerala'),
  ('Priya Pillai', '+919847001004', 'priya@example.com', 'Trivandrum, Kerala'),
  ('Suresh Krishnan', '+919847001005', 'suresh@example.com', 'Alappuzha, Kerala');

-- ============================================================================
-- 16. DEMO ORDERS (Various Statuses)
-- ============================================================================

DO $$
DECLARE
    v_store_id UUID;
    v_branch_id UUID;
    v_customer_id UUID;
    v_product_1 UUID;
    v_product_2 UUID;
    v_product_3 UUID;
    v_order_id UUID;
    i INT;
    v_status VARCHAR;
    v_payment_status VARCHAR;
    v_start_date DATE;
    v_end_date DATE;
    v_total_amount DECIMAL(10,2);
    v_amount_paid DECIMAL(10,2);
BEGIN
    SELECT id INTO v_store_id FROM public.stores LIMIT 1;
    SELECT id INTO v_branch_id FROM public.branches WHERE store_id = v_store_id LIMIT 1;
    
    SELECT id INTO v_product_1 FROM public.products WHERE is_active = true LIMIT 1;
    SELECT id INTO v_product_2 FROM public.products WHERE is_active = true AND id != v_product_1 LIMIT 1;
    SELECT id INTO v_product_3 FROM public.products WHERE is_active = true AND id NOT IN (v_product_1, v_product_2) LIMIT 1;
    
    IF v_product_2 IS NULL THEN v_product_2 := v_product_1; END IF;
    IF v_product_3 IS NULL THEN v_product_3 := v_product_1; END IF;

    IF v_store_id IS NULL OR v_branch_id IS NULL OR v_product_1 IS NULL THEN
        RAISE EXCEPTION 'Database pre-requisites missing. Please verify you have at least one store, branch, and active product.';
    END IF;

    SELECT id INTO v_customer_id FROM public.customers LIMIT 1;

    FOR i IN 1..21 LOOP
        v_order_id := uuid_generate_v4();
        
        CASE (i % 7)
            WHEN 0 THEN
                v_status := 'scheduled';
                v_payment_status := 'pending';
                v_start_date := CURRENT_DATE + (i * 2);
                v_end_date := v_start_date + 3;
                v_total_amount := 1500.00;
                v_amount_paid := 0.00;
            WHEN 1 THEN
                v_status := 'completed';
                v_payment_status := 'paid';
                v_start_date := CURRENT_DATE - (i * 3) - 5;
                v_end_date := v_start_date + 4;
                v_total_amount := 2400.00;
                v_amount_paid := 2400.00;
            WHEN 2 THEN
                v_status := 'ongoing';
                v_payment_status := 'partial';
                v_start_date := CURRENT_DATE - 1;
                v_end_date := CURRENT_DATE + 2;
                v_total_amount := 1800.00;
                v_amount_paid := 800.00;
            WHEN 3 THEN
                v_status := 'ongoing';
                v_payment_status := 'pending';
                v_start_date := CURRENT_DATE - 10;
                v_end_date := CURRENT_DATE - 3;
                v_total_amount := 1200.00;
                v_amount_paid := 0.00;
            WHEN 4 THEN
                v_status := 'returned';
                v_payment_status := 'partial';
                v_start_date := CURRENT_DATE - 8;
                v_end_date := CURRENT_DATE - 4;
                v_total_amount := 3000.00;
                v_amount_paid := 1500.00;
            WHEN 5 THEN
                v_status := 'flagged';
                v_payment_status := 'pending';
                v_start_date := CURRENT_DATE - 5;
                v_end_date := CURRENT_DATE - 1;
                v_total_amount := 1600.00;
                v_amount_paid := 0.00;
            WHEN 6 THEN
                v_status := 'cancelled';
                v_payment_status := 'pending';
                v_start_date := CURRENT_DATE + 12;
                v_end_date := v_start_date + 2;
                v_total_amount := 900.00;
                v_amount_paid := 0.00;
        END CASE;

        INSERT INTO public.orders (
            id, store_id, branch_id, customer_id, status, 
            start_date, end_date, subtotal, total_amount, amount_paid, 
            payment_status, notes
        ) VALUES (
            v_order_id, v_store_id, v_branch_id, v_customer_id, v_status,
            v_start_date, v_end_date, v_total_amount, v_total_amount, v_amount_paid,
            v_payment_status, '[DEMO] ' || UPPER(v_status) || ' Scenario Order #' || i
        );

        INSERT INTO public.order_items (
            order_id, product_id, quantity, price_per_day, subtotal
        ) VALUES (
            v_order_id, 
            CASE (i % 3)
                WHEN 0 THEN v_product_1
                WHEN 1 THEN v_product_2
                ELSE v_product_3
            END,
            1, 
            v_total_amount / 3.00, 
            v_total_amount
        );

        IF v_status IN ('completed', 'returned') THEN
            UPDATE public.order_items 
            SET is_returned = true, returned_quantity = quantity, returned_at = (v_end_date::timestamp)
            WHERE order_id = v_order_id;
        END IF;

    END LOOP;
END $$;

-- ============================================================================
-- 17. DEMO BANNERS
-- ============================================================================

INSERT INTO public.banners (store_id, title, subtitle, web_image_url, banner_type, is_active, priority, position, call_to_action, redirect_type, alt_text)
SELECT id, 'Welcome to Rentocostume', 'Premium dance costume rentals in Trivandrum', 'https://placehold.co/1200x400?text=Rentocostume+Dance+Costumes', 'hero', true, 1, 'top', 'Browse Collection', 'url', 'Rentocostume Hero Banner'
FROM public.stores WHERE slug = 'Rentocostume-costumes';

INSERT INTO public.banners (store_id, title, subtitle, web_image_url, banner_type, is_active, priority, position, call_to_action, redirect_type, alt_text)
SELECT id, 'Bharatanatyam Special', 'Traditional costumes now available', 'https://placehold.co/1200x300?text=Bharatanatyam+Special', 'promo', true, 2, 'middle', 'View Now', 'category', 'Bharatanatyam promotional banner'
FROM public.stores WHERE slug = 'Rentocostume-costumes';

-- ============================================================================
-- DONE! 
-- ============================================================================
-- Your demo database is now ready with:
--   ✓ All 18 tables with proper schema + primary keys
--   ✓ All foreign keys and indexes
--   ✓ All RLS policies and helper functions
--   ✓ All triggers (updated_at, late_flag)
--   ✓ All RPC functions (dashboard metrics, dead stock)
--   ✓ 1 Store + 1 Branch
--   ✓ 1 Demo Super Admin (demo@gmail.com) — user_id needs linking (see below)
--   ✓ 4 Default settings
--   ✓ 12 Categories (3-level hierarchy)
--   ✓ 7 Demo Products with inventory
--   ✓ 5 Demo Customers
--   ✓ 21 Demo Orders (all statuses)
--   ✓ 2 Demo Banners
--
-- ============================================================================
-- FINAL STEP: LINK AUTH USER TO STAFF RECORD
-- ============================================================================
-- 1. Go to Supabase Dashboard → Authentication → Users → Add user
--    Email: demo@gmail.com
--    Password: admin123
-- 2. Copy the user's UUID from the dashboard
-- 3. Run the SQL below (replace the UUID):
--
--    UPDATE public.staff
--    SET user_id = 'PASTE_UUID_HERE'::UUID
--    WHERE email = 'demo@gmail.com';
--
-- 4. Verify:
--    SELECT id, name, email, role, user_id FROM staff WHERE email = 'demo@gmail.com';
--    -- user_id should NOT be null
-- ============================================================================

