-- Migration: Add RLS policies for cleaning_records table
--
-- Root cause: RLS was enabled on cleaning_records but with ZERO policies,
-- which blocked ALL operations (insert, select, update, delete) via the
-- anon client used by BaseRepository. This caused cleaning record creation
-- to silently fail during order creation.
--
-- Fix: Add permissive policies for both authenticated and anon roles,
-- matching the pattern used by other admin tables in this project.

-- Allow all operations for authenticated users
CREATE POLICY "Allow all for authenticated users"
  ON cleaning_records
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Allow all operations for anon key (BaseRepository uses anon client server-side)
CREATE POLICY "Allow all for anon"
  ON cleaning_records
  FOR ALL
  TO anon
  USING (true)
  WITH CHECK (true);
