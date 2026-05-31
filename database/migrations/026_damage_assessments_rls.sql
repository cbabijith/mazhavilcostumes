-- ============================================================================
-- Migration 026: Enable RLS and Policies for damage_assessments
-- Enables Row Level Security on the damage_assessments table and sets up
-- permissive policies for both authenticated and anon roles, matching the
-- standard pattern used by other admin dashboard tables.
-- ============================================================================

-- Enable Row Level Security
ALTER TABLE public.damage_assessments ENABLE ROW LEVEL SECURITY;

-- Allow all operations for authenticated users
CREATE POLICY "Allow all for authenticated users"
  ON public.damage_assessments
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Allow all operations for anon key (BaseRepository uses anon client server-side)
CREATE POLICY "Allow all for anon"
  ON public.damage_assessments
  FOR ALL
  TO anon
  USING (true)
  WITH CHECK (true);
