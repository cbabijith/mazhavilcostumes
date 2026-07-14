-- ============================================================================
-- Migration 042: Soft Delete Support for Staff
-- Adds deleted_at column to staff table.
-- ============================================================================

-- Add deleted_at to staff
ALTER TABLE public.staff ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Index to efficiently filter out soft-deleted rows
CREATE INDEX IF NOT EXISTS idx_staff_not_deleted ON public.staff(id) WHERE deleted_at IS NULL;
