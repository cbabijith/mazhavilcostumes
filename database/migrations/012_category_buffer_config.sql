-- Migration 012: Category Buffer Configuration
-- Adds a toggle to categories to enable or disable the mandatory 1-day cleaning buffer.

ALTER TABLE categories
ADD COLUMN has_buffer BOOLEAN DEFAULT TRUE;

-- Add comment
COMMENT ON COLUMN categories.has_buffer IS 'If TRUE, products in this category require a 1-day cleaning buffer between rentals. If FALSE, they can be rented back-to-back.';
