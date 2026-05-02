-- 007_reports.sql — Customer enquiry log for Phase 5 reports
-- This table records manual staff-to-customer enquiries about product availability.

CREATE TABLE IF NOT EXISTS customer_enquiries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_query VARCHAR(255) NOT NULL,
  customer_name VARCHAR(255),
  customer_phone VARCHAR(20),
  notes TEXT,
  logged_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
  store_id UUID REFERENCES stores(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE customer_enquiries ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to manage enquiries
CREATE POLICY "Authenticated users can manage enquiries"
  ON customer_enquiries FOR ALL
  USING (true)
  WITH CHECK (true);
