-- e:/PROJECTS/rentocostume/database/migrations/032_cleanup_old_categories_and_customers.sql

BEGIN;

-- Step 1: Unlink any products from categories that are about to be deleted
-- This prevents foreign key constraint violations
UPDATE public.products
SET 
  category_id = NULL
WHERE category_id IN (
  SELECT id FROM public.categories 
  WHERE slug NOT IN (
    'bharathanattyam', 'chest-coat', 'cinematic', 'fancy-dress', 'frock', 
    'katak', 'kerala-nadanam', 'margam-kali', 'mohiniyattam', 'oppana', 
    'ornaments', 'overcoat', 'pant', 'parts', 'property', 'semi-classical', 
    'shawl', 'skirt', 'skirt-top', 'thiruvathira', 'top'
  )
);

UPDATE public.products
SET 
  subcategory_id = NULL
WHERE subcategory_id IN (
  SELECT id FROM public.categories 
  WHERE slug NOT IN (
    'bharathanattyam', 'chest-coat', 'cinematic', 'fancy-dress', 'frock', 
    'katak', 'kerala-nadanam', 'margam-kali', 'mohiniyattam', 'oppana', 
    'ornaments', 'overcoat', 'pant', 'parts', 'property', 'semi-classical', 
    'shawl', 'skirt', 'skirt-top', 'thiruvathira', 'top'
  )
);

UPDATE public.products
SET 
  subvariant_id = NULL
WHERE subvariant_id IN (
  SELECT id FROM public.categories 
  WHERE slug NOT IN (
    'bharathanattyam', 'chest-coat', 'cinematic', 'fancy-dress', 'frock', 
    'katak', 'kerala-nadanam', 'margam-kali', 'mohiniyattam', 'oppana', 
    'ornaments', 'overcoat', 'pant', 'parts', 'property', 'semi-classical', 
    'shawl', 'skirt', 'skirt-top', 'thiruvathira', 'top'
  )
);

-- Step 2: Delete old categories not in the official list of product02csv.csv
-- We do this bottom-up (first children, then parents) to handle self-referential foreign keys safely
-- First pass: delete leaf subcategories/variants that have parent_id and are not in list
DELETE FROM public.categories
WHERE slug NOT IN (
  'bharathanattyam', 'chest-coat', 'cinematic', 'fancy-dress', 'frock', 
  'katak', 'kerala-nadanam', 'margam-kali', 'mohiniyattam', 'oppana', 
  'ornaments', 'overcoat', 'pant', 'parts', 'property', 'semi-classical', 
  'shawl', 'skirt', 'skirt-top', 'thiruvathira', 'top'
)
AND id NOT IN (SELECT DISTINCT parent_id FROM public.categories WHERE parent_id IS NOT NULL);

-- Second pass: delete main/parent categories that are not in list
DELETE FROM public.categories
WHERE slug NOT IN (
  'bharathanattyam', 'chest-coat', 'cinematic', 'fancy-dress', 'frock', 
  'katak', 'kerala-nadanam', 'margam-kali', 'mohiniyattam', 'oppana', 
  'ornaments', 'overcoat', 'pant', 'parts', 'property', 'semi-classical', 
  'shawl', 'skirt', 'skirt-top', 'thiruvathira', 'top'
);

-- Step 3: Safely delete all customer records
-- Cascade is used to clear any dependent tables if they exist
TRUNCATE public.customers CASCADE;

COMMIT;
