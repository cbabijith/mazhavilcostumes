import csv
import re

# Configuration - UPDATE THESE
STORE_ID = '9403fc00-1042-4770-a64b-08f196a58457'
BRANCH_ID = '7671abeb-4b79-47a4-966b-384c1c26b950'
CREATED_BY = '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0'  # Updated with actual user_id

# Category slug mapping
category_slug_map = {
    'Frock': 'frock',
    'Cinematic': 'cinematic',
    'Semi Classical': 'semi-classical',
    'Top': 'top',
    'Overcoat': 'overcoat',
    'Skirt Top': 'skirt-top',
    'Skirt': 'skirt',
    'Parts': 'parts',
    'Pant': 'pant',
    'Property': 'property',
    'Chest coat': 'chest-coat',
    'Katak': 'katak',
    'Shawl': 'shawl',
    'Bharathanattyam': 'bharathanattyam'
}

def generate_slug(name):
    """Generate URL-friendly slug from name"""
    slug = name.lower()
    slug = re.sub(r'[^a-z0-9\s-]', '', slug)
    slug = re.sub(r'\s+', '-', slug)
    slug = re.sub(r'-+', '-', slug)
    slug = slug.strip('-')
    return slug

def escape_sql_string(s):
    """Escape single quotes for SQL"""
    return s.replace("'", "''")

# Read CSV and generate SQL
results = []

with open('apps/admin/docs/product_csv.csv', 'r', encoding='utf-8') as file:
    # Skip first row (it's a duplicate header)
    next(file)
    reader = csv.DictReader(file)
    
    for row in reader:
        # Skip if it's the header row
        code = row.get('Code', '').strip()
        if not code or code == 'Code':
            continue
        
        name = row.get('Name', '').strip()
        category = row.get('Category', '').strip()
        rent = float(row.get('Rent', '0').strip()) if row.get('Rent') else 0.00
        qty = int(row.get('Qty', '0').strip()) if row.get('Qty') else 0
        
        category_slug = category_slug_map.get(category, generate_slug(category))
        product_slug = generate_slug(name)
        
        insert_sql = f"""INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT gen_random_uuid(), '{STORE_ID}'::uuid, (SELECT id FROM categories WHERE slug = '{category_slug}' AND store_id = '{STORE_ID}'::uuid LIMIT 1), '{BRANCH_ID}'::uuid, '{escape_sql_string(name)}', '{product_slug}', '{code}', {rent:.2f}, {qty}, {qty}, true, true, '{CREATED_BY}'::uuid, '{BRANCH_ID}'::uuid, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE sku = '{code}' OR (slug = '{product_slug}' AND store_id = '{STORE_ID}'::uuid));"""
        
        results.append(insert_sql)

# Generate the complete SQL file
sql_content = f"""-- ============================================================================
-- Migration 024: Import Products from CSV
-- Complete SQL file with {len(results)} products
-- 
-- INSTRUCTIONS:
-- 1. Update v_created_by UUID with your actual user_id (line 11)
-- 2. Run this entire script in Supabase SQL Editor
-- ============================================================================

-- Set variables - UPDATE v_created_by WITH YOUR ACTUAL USER_ID
DO $$
DECLARE
  v_store_id UUID := '{STORE_ID}';
  v_branch_id UUID := '{BRANCH_ID}';
  v_created_by UUID := '{CREATED_BY}';
BEGIN
  -- Create categories if they don't exist (using INSERT ... WHERE NOT EXISTS)
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Bharathanattyam', 'bharathanattyam', v_store_id, true, true, 1, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'bharathanattyam' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Skirt Top', 'skirt-top', v_store_id, true, true, 2, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'skirt-top' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Top', 'top', v_store_id, true, true, 3, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'top' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Property', 'property', v_store_id, true, true, 4, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'property' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Parts', 'parts', v_store_id, true, true, 5, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'parts' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Skirt', 'skirt', v_store_id, true, true, 6, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'skirt' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Pant', 'pant', v_store_id, true, true, 7, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'pant' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Overcoat', 'overcoat', v_store_id, true, true, 8, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'overcoat' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Semi Classical', 'semi-classical', v_store_id, true, true, 9, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'semi-classical' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Cinematic', 'cinematic', v_store_id, true, true, 10, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'cinematic' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Shawl', 'shawl', v_store_id, true, true, 11, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'shawl' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Chest coat', 'chest-coat', v_store_id, true, true, 12, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'chest-coat' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Frock', 'frock', v_store_id, true, true, 13, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'frock' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Katak', 'katak', v_store_id, true, true, 14, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'katak' AND store_id = v_store_id);
END $$;

-- ============================================================================
-- INSERT ALL PRODUCTS ({len(results)} total)
-- ============================================================================

"""

# Split into two parts: first 500 and remaining
part1_results = results[:500]
part2_results = results[500:]

# Generate Part 1 SQL file (first 500 products)
sql_content_part1 = f"""-- ============================================================================
-- Migration 024 Part 1: Import First 500 Products from CSV
-- Complete SQL file with {len(part1_results)} products
-- 
-- INSTRUCTIONS:
-- 1. Update v_created_by UUID with your actual user_id (line 11)
-- 2. Run this entire script in Supabase SQL Editor
-- ============================================================================

-- Set variables - UPDATE v_created_by WITH YOUR ACTUAL USER_ID
DO $$
DECLARE
  v_store_id UUID := '{STORE_ID}';
  v_branch_id UUID := '{BRANCH_ID}';
  v_created_by UUID := '{CREATED_BY}';
BEGIN
  -- Create categories if they don't exist (using INSERT ... WHERE NOT EXISTS)
  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Bharathanattyam', 'bharathanattyam', v_store_id, true, true, 1, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'bharathanattyam' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Skirt Top', 'skirt-top', v_store_id, true, true, 2, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'skirt-top' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Top', 'top', v_store_id, true, true, 3, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'top' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Property', 'property', v_store_id, true, true, 4, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'property' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Parts', 'parts', v_store_id, true, true, 5, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'parts' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Skirt', 'skirt', v_store_id, true, true, 6, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'skirt' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Pant', 'pant', v_store_id, true, true, 7, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'pant' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Overcoat', 'overcoat', v_store_id, true, true, 8, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'overcoat' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Semi Classical', 'semi-classical', v_store_id, true, true, 9, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'semi-classical' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Cinematic', 'cinematic', v_store_id, true, true, 10, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'cinematic' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Shawl', 'shawl', v_store_id, true, true, 11, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'shawl' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Chest coat', 'chest-coat', v_store_id, true, true, 12, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'chest-coat' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Frock', 'frock', v_store_id, true, true, 13, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'frock' AND store_id = v_store_id);

  INSERT INTO categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  SELECT gen_random_uuid(), 'Katak', 'katak', v_store_id, true, true, 14, v_created_by, v_branch_id, NOW(), NOW()
  WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'katak' AND store_id = v_store_id);
END $$;

-- ============================================================================
-- INSERT FIRST 500 PRODUCTS
-- ============================================================================

"""

sql_content_part1 += "\n\n".join(part1_results)

sql_content_part1 += f"""

-- ============================================================================
-- CREATE PRODUCT INVENTORY RECORDS FOR PART 1
-- ============================================================================

INSERT INTO product_inventory (id, product_id, branch_id, quantity, available_quantity, created_at, updated_at)
SELECT gen_random_uuid(), p.id, p.branch_id, p.quantity, p.available_quantity, NOW(), NOW()
FROM products p
WHERE p.store_id = '{STORE_ID}'::uuid
  AND p.created_at >= NOW() - INTERVAL '1 hour'
  AND NOT EXISTS (SELECT 1 FROM product_inventory pi WHERE pi.product_id = p.id);
"""

# Generate Part 2 SQL file (remaining products)
sql_content_part2 = f"""-- ============================================================================
-- Migration 024 Part 2: Import Remaining Products from CSV
-- Complete SQL file with {len(part2_results)} products
-- 
-- INSTRUCTIONS:
-- 1. Run this entire script in Supabase SQL Editor AFTER Part 1
-- ============================================================================

-- ============================================================================
-- INSERT REMAINING PRODUCTS ({len(part2_results)} total)
-- ============================================================================

"""

sql_content_part2 += "\n\n".join(part2_results)

sql_content_part2 += f"""

-- ============================================================================
-- CREATE PRODUCT INVENTORY RECORDS FOR PART 2
-- ============================================================================

INSERT INTO product_inventory (id, product_id, branch_id, quantity, available_quantity, created_at, updated_at)
SELECT gen_random_uuid(), p.id, p.branch_id, p.quantity, p.available_quantity, NOW(), NOW()
FROM products p
WHERE p.store_id = '{STORE_ID}'::uuid
  AND p.created_at >= NOW() - INTERVAL '1 hour'
  AND NOT EXISTS (SELECT 1 FROM product_inventory pi WHERE pi.product_id = p.id);
"""

# Write Part 1 file
with open('database/migrations/024_import_products_part1.sql', 'w', encoding='utf-8') as f:
    f.write(sql_content_part1)

# Write Part 2 file
with open('database/migrations/024_import_products_part2.sql', 'w', encoding='utf-8') as f:
    f.write(sql_content_part2)

print(f"Generated Part 1 SQL file with {len(part1_results)} products")
print("File saved to: database/migrations/024_import_products_part1.sql")
print(f"Generated Part 2 SQL file with {len(part2_results)} products")
print("File saved to: database/migrations/024_import_products_part2.sql")
