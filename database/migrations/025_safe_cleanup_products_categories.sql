-- e:/PROJECTS/mazhavilcostumes/database/migrations/025_safe_cleanup_products_categories.sql

BEGIN;

-- Step 1: Delete product inventory dependencies for products that are not linked to any orders or operations
DELETE FROM public.product_inventory
WHERE product_id NOT IN (
  SELECT DISTINCT product_id FROM public.order_items WHERE product_id IS NOT NULL
  UNION
  SELECT DISTINCT product_id FROM public.order_reservations WHERE product_id IS NOT NULL
  UNION
  SELECT DISTINCT product_id FROM public.cleaning_records WHERE product_id IS NOT NULL
  UNION
  SELECT DISTINCT product_id FROM public.damage_assessments WHERE product_id IS NOT NULL
);

-- Step 2: Delete products that are not linked to any orders or operations
DELETE FROM public.products
WHERE id NOT IN (
  SELECT DISTINCT product_id FROM public.order_items WHERE product_id IS NOT NULL
  UNION
  SELECT DISTINCT product_id FROM public.order_reservations WHERE product_id IS NOT NULL
  UNION
  SELECT DISTINCT product_id FROM public.cleaning_records WHERE product_id IS NOT NULL
  UNION
  SELECT DISTINCT product_id FROM public.damage_assessments WHERE product_id IS NOT NULL
);

-- Step 3: Hierarchically delete categories that have no products and no active subcategories.
-- We do this bottom-up using multiple passes to safely handle the self-referential parent-child constraints.

-- Pass 3a: Delete bottom-level variants (leaf nodes with no children) that have no remaining products
DELETE FROM public.categories
WHERE id NOT IN (
  SELECT DISTINCT category_id FROM public.products WHERE category_id IS NOT NULL
  UNION
  SELECT DISTINCT subcategory_id FROM public.products WHERE subcategory_id IS NOT NULL
  UNION
  SELECT DISTINCT subvariant_id FROM public.products WHERE subvariant_id IS NOT NULL
)
AND id NOT IN (SELECT DISTINCT parent_id FROM public.categories WHERE parent_id IS NOT NULL);

-- Pass 3b: Delete middle-level subcategories that now have no remaining children and no remaining products
DELETE FROM public.categories
WHERE id NOT IN (
  SELECT DISTINCT category_id FROM public.products WHERE category_id IS NOT NULL
  UNION
  SELECT DISTINCT subcategory_id FROM public.products WHERE subcategory_id IS NOT NULL
  UNION
  SELECT DISTINCT subvariant_id FROM public.products WHERE subvariant_id IS NOT NULL
)
AND id NOT IN (SELECT DISTINCT parent_id FROM public.categories WHERE parent_id IS NOT NULL);

-- Pass 3c: Delete top-level main categories that now have no remaining children and no remaining products
DELETE FROM public.categories
WHERE id NOT IN (
  SELECT DISTINCT category_id FROM public.products WHERE category_id IS NOT NULL
  UNION
  SELECT DISTINCT subcategory_id FROM public.products WHERE subcategory_id IS NOT NULL
  UNION
  SELECT DISTINCT subvariant_id FROM public.products WHERE subvariant_id IS NOT NULL
)
AND id NOT IN (SELECT DISTINCT parent_id FROM public.categories WHERE parent_id IS NOT NULL);

COMMIT;
