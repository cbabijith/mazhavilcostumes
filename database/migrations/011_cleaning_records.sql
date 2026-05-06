-- Migration: Cleaning Tracking System
-- Creates the cleaning_records table to track products needing prep/cleaning between rentals.

CREATE TYPE cleaning_status AS ENUM ('pending', 'in_progress', 'completed');
CREATE TYPE cleaning_priority AS ENUM ('normal', 'urgent');

CREATE TABLE IF NOT EXISTS cleaning_records (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE, -- The order that returned the item
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  status cleaning_status DEFAULT 'pending',
  priority cleaning_priority DEFAULT 'normal',
  priority_order_id UUID REFERENCES orders(id) ON DELETE SET NULL, -- The Skip Gap order that needs this
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_cleaning_product ON cleaning_records(product_id);
CREATE INDEX IF NOT EXISTS idx_cleaning_status ON cleaning_records(status);
CREATE INDEX IF NOT EXISTS idx_cleaning_priority ON cleaning_records(priority);
CREATE INDEX IF NOT EXISTS idx_cleaning_branch ON cleaning_records(branch_id);
CREATE INDEX IF NOT EXISTS idx_cleaning_order ON cleaning_records(order_id);

-- Trigger for updated_at
CREATE TRIGGER update_cleaning_records_updated_at BEFORE UPDATE ON cleaning_records
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE cleaning_records IS 'Tracks products in the cleaning/prep phase between rentals';
COMMENT ON COLUMN cleaning_records.priority_order_id IS 'Reference to an upcoming Skip Gap order that requires this cleaning to be prioritized';
