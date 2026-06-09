-- ============================================================================
-- Mazhavil Costumes - Latest Database Schema (Exported from Live Supabase)
-- Generated on 2026-06-05
-- ============================================================================

-- === TABLES ===
CREATE TABLE public.audit_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
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

CREATE TABLE public.banners (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
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
  banner_type varchar(20) DEFAULT 'hero'::character varying,
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

CREATE TABLE public.branches (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
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

CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
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

CREATE TABLE public.cleaning_records (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  product_id uuid NOT NULL,
  order_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  quantity integer NOT NULL,
  status varchar(50) DEFAULT 'pending'::character varying,
  priority varchar(50) DEFAULT 'normal'::character varying,
  priority_order_id uuid,
  started_at timestamp with time zone,
  completed_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  expected_return_date date,
  store_id uuid
);

CREATE TABLE public.customer_enquiries (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  product_query varchar(255) NOT NULL,
  customer_name varchar(255),
  customer_phone varchar(20),
  notes text,
  logged_by uuid,
  branch_id uuid,
  store_id uuid,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.customers (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
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

CREATE TABLE public.damage_assessments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  order_id uuid NOT NULL,
  order_item_id uuid NOT NULL,
  product_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  unit_index integer NOT NULL,
  decision varchar(20) DEFAULT 'pending'::character varying,
  notes text,
  assessed_by uuid,
  assessed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.order_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
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
  discount_type varchar(10) DEFAULT 'flat'::character varying,
  gst_percentage numeric(5,2) DEFAULT 0,
  base_amount numeric(10,2) DEFAULT 0,
  gst_amount numeric(10,2) DEFAULT 0,
  damaged_quantity integer DEFAULT 0
);

CREATE TABLE public.order_reservations (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
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
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  order_id uuid NOT NULL,
  status varchar(50) NOT NULL,
  notes text,
  changed_by uuid,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.orders (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
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
  payment_status varchar(20) DEFAULT 'pending'::character varying,
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
  discount_type varchar(10) DEFAULT 'flat'::character varying,
  cancellation_reason text,
  cancelled_by uuid,
  cancelled_at timestamp with time zone,
  has_priority_cleaning boolean DEFAULT false,
  has_stock_conflict boolean DEFAULT false,
  conflict_details jsonb DEFAULT '[]'::jsonb,
  is_late boolean DEFAULT false
);

CREATE TABLE public.payments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
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

CREATE TABLE public.product_inventory (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  product_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  quantity integer NOT NULL DEFAULT 0,
  available_quantity integer NOT NULL DEFAULT 0,
  low_stock_threshold integer DEFAULT 5,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
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
  metal_purity varchar(10),
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

CREATE TABLE public.settings (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  store_id uuid NOT NULL,
  key varchar(100) NOT NULL,
  value text NOT NULL,
  updated_by uuid,
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.staff (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  store_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  user_id uuid,
  name varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  phone varchar(20),
  role varchar(50) NOT NULL,
  is_active boolean DEFAULT true,
  created_by uuid,
  created_at_branch_id uuid,
  updated_by uuid,
  updated_at_branch_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.stores (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name varchar(255) NOT NULL,
  slug varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  phone varchar(20),
  address text,
  logo_url text,
  subscription_status varchar(50) DEFAULT 'trial'::character varying,
  is_active boolean DEFAULT true,
  gstin varchar(20),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- === FOREIGN KEYS ===
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
ALTER TABLE public.banners ADD CONSTRAINT banners_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.banners ADD CONSTRAINT banners_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.staff(id);
ALTER TABLE public.banners ADD CONSTRAINT banners_created_at_branch_id_fkey FOREIGN KEY (created_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.banners ADD CONSTRAINT banners_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.staff(id);
ALTER TABLE public.banners ADD CONSTRAINT banners_updated_at_branch_id_fkey FOREIGN KEY (updated_at_branch_id) REFERENCES public.branches(id);
ALTER TABLE public.settings ADD CONSTRAINT settings_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.settings ADD CONSTRAINT settings_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.staff(id);
ALTER TABLE public.audit_logs ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.staff(id);
ALTER TABLE public.orders ADD CONSTRAINT orders_cancelled_by_fkey FOREIGN KEY (cancelled_by) REFERENCES public.staff(id);
ALTER TABLE public.customer_enquiries ADD CONSTRAINT customer_enquiries_logged_by_fkey FOREIGN KEY (logged_by) REFERENCES public.staff(id);
ALTER TABLE public.customer_enquiries ADD CONSTRAINT customer_enquiries_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.customer_enquiries ADD CONSTRAINT customer_enquiries_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.cleaning_records ADD CONSTRAINT cleaning_records_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);
ALTER TABLE public.cleaning_records ADD CONSTRAINT cleaning_records_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.cleaning_records ADD CONSTRAINT cleaning_records_priority_order_id_fkey FOREIGN KEY (priority_order_id) REFERENCES public.orders(id);
ALTER TABLE public.cleaning_records ADD CONSTRAINT cleaning_records_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores(id);
ALTER TABLE public.damage_assessments ADD CONSTRAINT damage_assessments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);
ALTER TABLE public.damage_assessments ADD CONSTRAINT damage_assessments_order_item_id_fkey FOREIGN KEY (order_item_id) REFERENCES public.order_items(id);
ALTER TABLE public.damage_assessments ADD CONSTRAINT damage_assessments_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
ALTER TABLE public.damage_assessments ADD CONSTRAINT damage_assessments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);
ALTER TABLE public.damage_assessments ADD CONSTRAINT damage_assessments_assessed_by_fkey FOREIGN KEY (assessed_by) REFERENCES public.staff(id);

-- === INDEXES ===
CREATE UNIQUE INDEX damage_assessments_order_item_id_unit_index_key ON public.damage_assessments USING btree (order_item_id, unit_index);
CREATE INDEX idx_damage_assessments_order_id ON public.damage_assessments USING btree (order_id);
CREATE INDEX idx_damage_assessments_product_id ON public.damage_assessments USING btree (product_id);
CREATE INDEX idx_damage_assessments_decision ON public.damage_assessments USING btree (decision);
CREATE INDEX idx_damage_assessments_order_item_id ON public.damage_assessments USING btree (order_item_id);
CREATE INDEX idx_branches_created_by ON public.branches USING btree (created_by);
CREATE INDEX idx_branches_created_at_branch_id ON public.branches USING btree (created_at_branch_id);
CREATE INDEX idx_order_reservations_product ON public.order_reservations USING btree (product_id);
CREATE INDEX idx_order_reservations_branch ON public.order_reservations USING btree (branch_id);
CREATE INDEX idx_order_reservations_date_range ON public.order_reservations USING btree (reserved_from, reserved_to);
CREATE INDEX idx_order_reservations_order ON public.order_reservations USING btree (order_id);
CREATE UNIQUE INDEX product_inventory_product_id_branch_id_key ON public.product_inventory USING btree (product_id, branch_id);
CREATE INDEX idx_product_inventory_product_id ON public.product_inventory USING btree (product_id);
CREATE INDEX idx_product_inventory_branch_id ON public.product_inventory USING btree (branch_id);
CREATE UNIQUE INDEX customers_phone_key ON public.customers USING btree (phone);
CREATE INDEX idx_customers_created_by ON public.customers USING btree (created_by);
CREATE INDEX idx_customers_created_at_branch_id ON public.customers USING btree (created_at_branch_id);
CREATE INDEX idx_categories_store_id ON public.categories USING btree (store_id);
CREATE INDEX idx_categories_parent_id ON public.categories USING btree (parent_id);
CREATE INDEX idx_categories_slug ON public.categories USING btree (slug);
CREATE INDEX idx_categories_created_by ON public.categories USING btree (created_by);
CREATE INDEX idx_categories_created_at_branch_id ON public.categories USING btree (created_at_branch_id);
CREATE UNIQUE INDEX categories_slug_key ON public.categories USING btree (slug);
CREATE INDEX idx_categories_not_deleted ON public.categories USING btree (id) WHERE (deleted_at IS NULL);
CREATE INDEX idx_payments_order_id ON public.payments USING btree (order_id);
CREATE INDEX idx_payments_payment_type ON public.payments USING btree (payment_type);
CREATE INDEX idx_payments_payment_date ON public.payments USING btree (payment_date);
CREATE INDEX idx_banners_store_id ON public.banners USING btree (store_id);
CREATE INDEX idx_banners_is_active ON public.banners USING btree (is_active);
CREATE INDEX idx_banners_priority ON public.banners USING btree (priority);
CREATE INDEX idx_banners_banner_type ON public.banners USING btree (banner_type);
CREATE UNIQUE INDEX settings_store_id_key_key ON public.settings USING btree (store_id, key);
CREATE INDEX idx_settings_store_id ON public.settings USING btree (store_id);
CREATE INDEX idx_settings_key ON public.settings USING btree (key);
CREATE INDEX idx_staff_user_id ON public.staff USING btree (user_id);
CREATE INDEX idx_staff_created_by ON public.staff USING btree (created_by);
CREATE INDEX idx_staff_created_at_branch_id ON public.staff USING btree (created_at_branch_id);
CREATE UNIQUE INDEX staff_email_key ON public.staff USING btree (email);
CREATE INDEX idx_audit_logs_entity ON public.audit_logs USING btree (entity_type, entity_id);
CREATE INDEX idx_audit_logs_user_id ON public.audit_logs USING btree (user_id);
CREATE INDEX idx_audit_logs_created_at ON public.audit_logs USING btree (created_at);
CREATE INDEX idx_orders_store_id ON public.orders USING btree (store_id);
CREATE INDEX idx_orders_customer_id ON public.orders USING btree (customer_id);
CREATE INDEX idx_orders_status ON public.orders USING btree (status);
CREATE INDEX idx_orders_dates ON public.orders USING btree (start_date, end_date);
CREATE INDEX idx_orders_branch_id ON public.orders USING btree (branch_id);
CREATE INDEX idx_orders_delivery_method ON public.orders USING btree (delivery_method);
CREATE INDEX idx_orders_created_by ON public.orders USING btree (created_by);
CREATE INDEX idx_orders_created_at_branch_id ON public.orders USING btree (created_at_branch_id);
CREATE INDEX idx_orders_cancelled_by ON public.orders USING btree (cancelled_by);
CREATE INDEX idx_orders_cancelled_at ON public.orders USING btree (cancelled_at);
CREATE INDEX idx_orders_stock_conflict ON public.orders USING btree (has_stock_conflict) WHERE (has_stock_conflict = true);
CREATE INDEX idx_orders_created_at ON public.orders USING btree (created_at);
CREATE INDEX idx_orders_start_date ON public.orders USING btree (start_date);
CREATE INDEX idx_orders_end_date ON public.orders USING btree (end_date);
CREATE INDEX idx_orders_is_late ON public.orders USING btree (is_late) WHERE (is_late = true);
CREATE INDEX idx_products_store_id ON public.products USING btree (store_id);
CREATE UNIQUE INDEX products_store_id_slug_key ON public.products USING btree (store_id, slug);
CREATE INDEX idx_products_category_id ON public.products USING btree (category_id);
CREATE INDEX idx_products_slug ON public.products USING btree (slug);
CREATE INDEX idx_products_is_active ON public.products USING btree (is_active);
CREATE INDEX idx_products_is_featured ON public.products USING btree (is_featured);
CREATE INDEX idx_products_branch_id ON public.products USING btree (branch_id);
CREATE INDEX idx_products_created_by ON public.products USING btree (created_by);
CREATE INDEX idx_products_created_at_branch_id ON public.products USING btree (created_at_branch_id);
CREATE UNIQUE INDEX idx_products_barcode_unique ON public.products USING btree (lower((barcode)::text)) WHERE ((barcode IS NOT NULL) AND ((barcode)::text <> ''::text));
CREATE INDEX idx_products_not_deleted ON public.products USING btree (id) WHERE (deleted_at IS NULL);
CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);
CREATE INDEX idx_order_items_product_id ON public.order_items USING btree (product_id);
CREATE INDEX idx_order_items_condition_rating ON public.order_items USING btree (condition_rating);
CREATE UNIQUE INDEX stores_slug_key ON public.stores USING btree (slug);
CREATE UNIQUE INDEX stores_email_key ON public.stores USING btree (email);
CREATE INDEX idx_cleaning_product ON public.cleaning_records USING btree (product_id);
CREATE INDEX idx_cleaning_status ON public.cleaning_records USING btree (status);
CREATE INDEX idx_cleaning_priority ON public.cleaning_records USING btree (priority);
CREATE INDEX idx_cleaning_branch ON public.cleaning_records USING btree (branch_id);
CREATE INDEX idx_cleaning_order ON public.cleaning_records USING btree (order_id);
CREATE INDEX idx_cleaning_expected_return ON public.cleaning_records USING btree (product_id, expected_return_date);
