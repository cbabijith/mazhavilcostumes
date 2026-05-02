-- ============================================================================
-- Migration 008: Soft Delete Support for Products and Categories
-- Adds deleted_at column and updates indexes to exclude soft-deleted rows.
-- ============================================================================

-- Add deleted_at to categories
ALTER TABLE categories ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Add deleted_at to products
ALTER TABLE products ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Partial indexes to efficiently filter out soft-deleted rows
CREATE INDEX IF NOT EXISTS idx_categories_not_deleted ON categories(id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_products_not_deleted ON products(id) WHERE deleted_at IS NULL;
