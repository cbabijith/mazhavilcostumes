-- ============================================================================
-- Migration 014: Damage Assessment System
-- Creates the damage_assessments table for post-return damage tracking.
-- Each damaged unit gets an individual assessment row so admin can decide
-- whether the unit is reusable or should be written off from stock.
-- ============================================================================

CREATE TABLE IF NOT EXISTS damage_assessments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  order_item_id UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  unit_index INTEGER NOT NULL,  -- 1-based index for each damaged unit
  decision VARCHAR(20) DEFAULT 'pending' CHECK (decision IN ('reuse', 'not_reuse', 'pending')),
  notes TEXT,
  assessed_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  assessed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(order_item_id, unit_index)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_damage_assessments_order_id ON damage_assessments(order_id);
CREATE INDEX IF NOT EXISTS idx_damage_assessments_product_id ON damage_assessments(product_id);
CREATE INDEX IF NOT EXISTS idx_damage_assessments_decision ON damage_assessments(decision);
CREATE INDEX IF NOT EXISTS idx_damage_assessments_order_item_id ON damage_assessments(order_item_id);

-- Trigger for updated_at
CREATE TRIGGER update_damage_assessments_updated_at BEFORE UPDATE ON damage_assessments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
