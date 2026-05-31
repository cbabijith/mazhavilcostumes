import csv
import re
import os

def generate_slug(text):
    """Generate a clean URL slug from text"""
    text = text.lower()
    text = re.sub(r'[^a-z0-9\s-]', '', text)
    text = re.sub(r'\s+', '-', text)
    text = re.sub(r'-+', '-', text)
    return text.strip('-')

def safe_float(val):
    try:
        val = val.strip().replace(",", "")
        if not val or val == "." or val == "-":
            return 0.0
        return float(val)
    except ValueError:
        return 0.0

def safe_int(val):
    try:
        val = val.strip()
        if not val or val == "." or val == "-":
            return 0
        return int(val)
    except ValueError:
        return 0

csv_file_path = r"e:\PROJECTS\mazhavilcostumes\apps\admin\docs\product02csv.csv"
output_migration_path = r"e:\PROJECTS\mazhavilcostumes\database\migrations\031_import_products_part4.sql"

# Store distinct categories
categories = set()

# We will read the CSV rows
rows = []
with open(csv_file_path, mode='r', encoding='utf-8') as f:
    # Skip potential junk rows
    line = f.readline()
    while line and not line.startswith("Name,Description"):
        line = f.readline()
    
    # Now we parse the CSV
    reader = csv.DictReader(f, fieldnames=["Name", "Description", "Category", "GST", "Rent", "Purchase Price", "Qty"])
    
    for row in reader:
        name = row.get("Name", "").strip()
        description = row.get("Description", "").strip()
        category = row.get("Category", "").strip()
        gst = row.get("GST", "").strip()
        rent = row.get("Rent", "").strip()
        purchase_price = row.get("Purchase Price", "").strip()
        qty = row.get("Qty", "").strip()
        
        # Skip header or empty rows
        if not name or name == "Name" or name.startswith("Products"):
            continue
            
        rows.append({
            "name_code": name,
            "description": description,
            "category": category,
            "gst": gst,
            "rent": rent,
            "purchase_price": purchase_price,
            "qty": qty
        })
        if category:
            categories.add(category)

# Get remaining 249 rows (from 1500 to the end)
part4_rows = rows[1500:]

print(f"Total rows parsed: {len(rows)}")
print(f"Part 4 rows count: {len(part4_rows)}")
print(f"First product in Part 4: {part4_rows[0]['name_code']} ({part4_rows[0]['description']})")
print(f"Last product in Part 4: {part4_rows[-1]['name_code']} ({part4_rows[-1]['description']})")

# Start generating the SQL script
sql_lines = []

sql_lines.append("""-- ============================================================================
-- Migration 031: Import Final 249 Products from CSV (product02csv.csv) - Part 4
-- Purpose:   Inserts categories and the final 249 products (rows 1501 to 1749)
--            with correct prices, quantities, and inventory mappings.
-- ============================================================================

DO $$
DECLARE
  v_store_id UUID;
  v_branch_id UUID;
  v_created_by UUID;
BEGIN
  -- Get the store ID
  SELECT id INTO v_store_id FROM public.stores WHERE slug = 'mazhavil-costumes' LIMIT 1;
  
  -- Get the main branch ID
  SELECT id INTO v_branch_id FROM public.branches WHERE store_id = v_store_id AND is_main = true LIMIT 1;
  
  -- Get the super admin creator ID
  SELECT id INTO v_created_by FROM public.staff WHERE role = 'super_admin' LIMIT 1;

  IF v_store_id IS NULL OR v_branch_id IS NULL OR v_created_by IS NULL THEN
    RAISE EXCEPTION 'Failed to find store, main branch, or super admin user. Ensure seed scripts 003 and 004 have been run.';
  END IF;

  -- Create categories if they don't exist
""")

# Sort categories for deterministic output
sorted_categories = sorted(list(categories))
for idx, cat in enumerate(sorted_categories, 1):
    slug = generate_slug(cat)
    cat_escaped = cat.replace("'", "''")
    sql_lines.append(f"""  INSERT INTO public.categories (id, name, slug, store_id, is_global, is_active, sort_order, created_by, created_at_branch_id, created_at, updated_at)
  VALUES (gen_random_uuid(), '{cat_escaped}', '{slug}', v_store_id, true, true, {idx}, v_created_by, v_branch_id, NOW(), NOW())
  ON CONFLICT (slug) DO NOTHING;
""")

sql_lines.append("""END $$;

-- ════════════════════════════════════════════════════════════════════════════
-- INSERT FINAL 249 PRODUCTS (1501 to 1749)
-- ════════════════════════════════════════════════════════════════════════════
""")

# Add products
for idx, row in enumerate(part4_rows, 1501):
    name_code = row["name_code"]
    desc = row["description"]
    cat = row["category"]
    rent = safe_float(row["rent"])
    purchase = safe_float(row["purchase_price"])
    qty = safe_int(row["qty"])
    
    # Category slug
    cat_slug = generate_slug(cat)
    
    # Clean and escape product attributes
    name_escaped = name_code.replace("'", "''")
    barcode_escaped = name_code.replace("'", "''")
    
    desc_escaped = desc.replace("'", "''")
    sku_escaped = desc.replace("'", "''")
    
    # Generate slug by combining unique code and description for uniqueness
    combined_slug = f"{name_code}-{desc}"
    prod_slug = generate_slug(combined_slug)
    
    sql_lines.append(f"""-- Product #{idx}: {name_code}
INSERT INTO public.products (
  id, store_id, category_id, branch_id, name, slug, description, sku, barcode, 
  price_per_day, purchase_price, quantity, available_quantity, is_active, track_inventory, 
  created_by, created_at_branch_id, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  s.id,
  (SELECT id FROM public.categories WHERE slug = '{cat_slug}' AND store_id = s.id LIMIT 1),
  b.id,
  '{name_escaped}',
  '{prod_slug}',
  '{desc_escaped}',
  '{sku_escaped}',
  '{barcode_escaped}',
  {rent:.2f},
  {purchase:.2f},
  {qty},
  {qty},
  true,
  true,
  st.id,
  b.id,
  NOW(),
  NOW()
FROM public.stores s
JOIN public.branches b ON b.store_id = s.id AND b.is_main = true
JOIN public.staff st ON st.role = 'super_admin' AND st.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND NOT EXISTS (
    SELECT 1 FROM public.products p 
    WHERE p.barcode = '{barcode_escaped}' 
       OR (p.slug = '{prod_slug}' AND p.store_id = s.id)
  )
ON CONFLICT DO NOTHING;
""")

sql_lines.append("""
-- ════════════════════════════════════════════════════════════════════════════
-- GENERATE PRODUCT INVENTORY MAPPINGS FOR PART 4
-- ════════════════════════════════════════════════════════════════════════════

INSERT INTO public.product_inventory (
  id, product_id, branch_id, quantity, available_quantity, created_at, updated_at
)
SELECT 
  gen_random_uuid(),
  p.id,
  p.branch_id,
  p.quantity,
  p.available_quantity,
  NOW(),
  NOW()
FROM public.products p
JOIN public.stores s ON p.store_id = s.id
WHERE s.slug = 'mazhavil-costumes'
  AND p.created_at >= NOW() - INTERVAL '1 hour'
  AND NOT EXISTS (
    SELECT 1 FROM public.product_inventory pi 
    WHERE pi.product_id = p.id
  )
ON CONFLICT (product_id, branch_id) DO NOTHING;
""")

# Write migration file
os.makedirs(os.path.dirname(output_migration_path), exist_ok=True)
with open(output_migration_path, "w", encoding="utf-8") as f_out:
    f_out.write("\n".join(sql_lines))

print("Successfully wrote migration Part 4!")
