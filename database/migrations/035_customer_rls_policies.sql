-- ============================================================================
-- Migration 035: Customer RLS Policies
-- Enables authenticated role (staff/managers) to read, insert, and update 
-- customer records. This fixes the issue where customer name, phone, and 
-- address show up as "Unknown" in client apps due to RLS blocks.
-- ============================================================================

-- Ensure RLS is enabled on the customers table
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- 1. SELECT: Allow authenticated users to view customer details
DROP POLICY IF EXISTS "Allow authenticated read access" ON public.customers;
CREATE POLICY "Allow authenticated read access" ON public.customers
  FOR SELECT TO authenticated USING (true);

-- 2. INSERT: Allow authenticated users to create customer records
DROP POLICY IF EXISTS "Allow authenticated insert access" ON public.customers;
CREATE POLICY "Allow authenticated insert access" ON public.customers
  FOR INSERT TO authenticated WITH CHECK (true);

-- 3. UPDATE: Allow authenticated users to edit customer records
DROP POLICY IF EXISTS "Allow authenticated update access" ON public.customers;
CREATE POLICY "Allow authenticated update access" ON public.customers
  FOR UPDATE TO authenticated USING (true);
