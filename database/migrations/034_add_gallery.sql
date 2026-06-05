-- ============================================================================
-- Migration 034: Create Costume Gallery Table and Policies
-- Creates the public.gallery table, enables RLS, and sets up select policies
-- for anonymous and authenticated users, matching the standard monorepo pattern.
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.gallery (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES public.staff(id) ON DELETE SET NULL,
  created_at_branch_id UUID REFERENCES public.branches(id) ON DELETE SET NULL,
  updated_by UUID REFERENCES public.staff(id) ON DELETE SET NULL,
  updated_at_branch_id UUID REFERENCES public.branches(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.gallery ENABLE ROW LEVEL SECURITY;

-- Allow public read of active gallery items (for storefront)
DROP POLICY IF EXISTS "gallery_anon_select" ON public.gallery;
CREATE POLICY "gallery_anon_select" ON public.gallery
  FOR SELECT TO anon
  USING (is_active = true);

-- Allow authenticated users to view all gallery items (for admin panel)
DROP POLICY IF EXISTS "gallery_authenticated_select" ON public.gallery;
CREATE POLICY "gallery_authenticated_select" ON public.gallery
  FOR SELECT TO authenticated
  USING (true);

-- Allow all operations for authenticated users (admin dashboard CRUD)
DROP POLICY IF EXISTS "gallery_authenticated_all" ON public.gallery;
CREATE POLICY "gallery_authenticated_all" ON public.gallery
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

-- Allow all operations for anon role (BaseRepository uses anon client server-side in some contexts)
DROP POLICY IF EXISTS "gallery_anon_all" ON public.gallery;
CREATE POLICY "gallery_anon_all" ON public.gallery
  FOR ALL TO anon
  USING (true)
  WITH CHECK (true);

-- Add updated_at trigger
CREATE OR REPLACE TRIGGER update_gallery_updated_at
  BEFORE UPDATE ON public.gallery
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
