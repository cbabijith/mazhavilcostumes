const fs = require('fs');
const csv = require('csv-parser');

// Configuration - UPDATE THESE
const STORE_ID = '9403fc00-1042-4770-a64b-08f196a58457';
const BRANCH_ID = '7671abeb-4b79-47a4-966b-384c1c26b950';
const CREATED_BY = '1e581b42-4579-4545-9ccf-edd7100364db'; // Update with your user_id

// Category slug mapping
const categorySlugMap = {
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
};

function generateSlug(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
}

const results = [];

fs.createReadStream('apps/admin/docs/product_csv.csv')
  .pipe(csv())
  .on('data', (data) => {
    // Skip header row
    if (data.Code === 'Code') return;

    const categorySlug = categorySlugMap[data.Category] || generateSlug(data.Category);
    const productSlug = generateSlug(data.Name);

    const insertSQL = `INSERT INTO products (id, store_id, category_id, branch_id, name, slug, sku, price_per_day, quantity, available_quantity, is_active, track_inventory, created_by, created_at_branch_id, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  '${STORE_ID}'::uuid,
  (SELECT id FROM categories WHERE slug = '${categorySlug}' AND store_id = '${STORE_ID}'::uuid LIMIT 1),
  '${BRANCH_ID}'::uuid,
  '${data.Name.replace(/'/g, "''")}',
  '${productSlug}',
  '${data.Code}',
  ${parseFloat(data.Rent).toFixed(2)},
  ${parseInt(data.Qty)},
  ${parseInt(data.Qty)},
  true,
  true,
  '${CREATED_BY}'::uuid,
  '${BRANCH_ID}'::uuid,
  NOW(),
  NOW()
ON CONFLICT (sku) DO NOTHING;`;

    results.push(insertSQL);
  })
  .on('end', () => {
    // Generate the complete SQL file
    const sqlContent = `-- ============================================================================
-- Migration 024: Import Products from CSV
-- Auto-generated SQL file with ${results.length} products
-- ============================================================================

-- Insert products
${results.join('\n\n')}

-- Create product_inventory records for all newly inserted products
INSERT INTO product_inventory (id, product_id, branch_id, quantity, available_quantity, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  p.id,
  p.branch_id,
  p.quantity,
  p.available_quantity,
  NOW(),
  NOW()
FROM products p
WHERE p.store_id = '${STORE_ID}'::uuid
  AND p.created_at >= NOW() - INTERVAL '1 hour'
  AND NOT EXISTS (
    SELECT 1 FROM product_inventory pi WHERE pi.product_id = p.id
  );

RAISE NOTICE 'Successfully imported ${results.length} products';
`;

    fs.writeFileSync('database/migrations/024_import_products_complete.sql', sqlContent);
    console.log(`Generated SQL file with ${results.length} products`);
    console.log('File saved to: database/migrations/024_import_products_complete.sql');
  });
