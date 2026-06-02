const { createClient } = require('@supabase/supabase-js');
const XLSX = require('xlsx');
const fs = require('fs');
const { randomUUID } = require('crypto');

// Configuration
const STORE_ID = '9403fc00-1042-4770-a64b-08f196a58457';
const BRANCH_ID = '7671abeb-4b79-47a4-966b-384c1c26b950';
const SUPER_ADMIN_ID = '2c0a9ba4-ef82-417a-af63-fde7c0af0fa0';

let supabaseUrl;
let supabaseServiceKey;

try {
  const envContent = fs.readFileSync('apps/admin/.env.local', 'utf8');
  const lines = envContent.split('\n');
  for (const line of lines) {
    if (line.startsWith('NEXT_PUBLIC_SUPABASE_URL=')) {
      supabaseUrl = line.split('=')[1].trim();
    }
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) {
      supabaseServiceKey = line.split('=')[1].trim();
    }
  }
} catch (e) {
  console.error("Failed to read apps/admin/.env.local", e);
  process.exit(1);
}

if (!supabaseUrl || !supabaseServiceKey) {
  console.error("Missing Supabase configuration in apps/admin/.env.local");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

function baseSlug(str) {
  return str.toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
}

function generateSlug(name, sku) {
  let namePart = baseSlug(name);
  let skuPart = baseSlug(sku);
  return `${namePart}-${skuPart}`;
}

async function main() {
  try {
    console.log("=== STEP 1: READING EXCEL FILE ===");
    const workbook = XLSX.readFile('Product with GST rent.xlsx');
    const worksheet = workbook.Sheets[workbook.SheetNames[0]];
    const rows = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
    
    console.log(`Successfully read Excel file. Total raw rows: ${rows.length}`);
    
    // We skip row 0 (title) and row 1 (headers)
    const dataRows = rows.slice(2).filter(row => {
      const code = row[0];
      const name = row[1];
      return code && String(code).trim() && name && String(name).trim();
    });
    
    console.log(`Filtered rows containing products: ${dataRows.length}`);
    
    console.log("\n=== STEP 2: CLEARING DATABASE ===");
    // Delete in proper dependency order to avoid FK errors
    const tablesToDelete = [
      'order_status_history',
      'payments',
      'damage_assessments',
      'cleaning_records',
      'order_reservations',
      'order_items',
      'orders',
      'customers',
      'product_inventory',
      'products',
      'categories'
    ];
    
    for (const table of tablesToDelete) {
      console.log(`Purging table: ${table}...`);
      const { error } = await supabase
        .from(table)
        .delete()
        .neq('id', '00000000-0000-0000-0000-000000000000');
      
      if (error) {
        throw new Error(`Failed to delete from ${table}: ${error.message}`);
      }
    }
    console.log("Database cleared successfully!");
    
    console.log("\n=== STEP 3: CREATING CATEGORIES ===");
    const uniqueCategories = [];
    const categorySlugMap = new Map(); // catName.toLowerCase() -> catId
    
    for (const row of dataRows) {
      const catName = row[2] ? String(row[2]).trim() : '';
      const gst = row[3] !== undefined ? Number(row[3]) : 5.00;
      
      if (!catName) continue;
      
      const key = catName.toLowerCase();
      if (!categorySlugMap.has(key)) {
        const catId = randomUUID();
        const slug = baseSlug(catName);
        categorySlugMap.set(key, catId);
        
        uniqueCategories.push({
          id: catId,
          name: catName,
          slug: slug,
          gst_percentage: gst,
          store_id: STORE_ID,
          is_global: true,
          is_active: true,
          created_by: SUPER_ADMIN_ID,
          created_at_branch_id: BRANCH_ID
        });
      }
    }
    
    console.log(`Inserting ${uniqueCategories.length} unique categories...`);
    const { error: catInsertErr } = await supabase
      .from('categories')
      .insert(uniqueCategories);
      
    if (catInsertErr) throw catInsertErr;
    console.log("Categories created successfully!");
    
    console.log("\n=== STEP 4: PREPARING PRODUCTS & INVENTORY ===");
    const productsToInsert = [];
    const inventoryToInsert = [];
    
    for (const row of dataRows) {
      const code = String(row[0]).trim();
      const name = String(row[1]).trim();
      const catName = row[2] ? String(row[2]).trim().toLowerCase() : '';
      const rent = row[4] !== undefined ? Number(row[4]) : 0;
      const purchasePrice = row[5] !== undefined ? Number(row[5]) : 0;
      const qty = row[6] !== undefined ? Number(row[6]) : 0;
      
      const productId = randomUUID();
      const catId = categorySlugMap.get(catName) || null;
      const slug = baseSlug(code);
      
      productsToInsert.push({
        id: productId,
        store_id: STORE_ID,
        category_id: catId,
        branch_id: BRANCH_ID,
        name: code, // Code/Name
        slug: slug,
        description: name, // Description/SKU
        sku: name, // Description/SKU
        barcode: code, // Code/Name
        price_per_day: rent,
        purchase_price: purchasePrice,
        quantity: qty,
        available_quantity: qty,
        is_active: true,
        track_inventory: true,
        created_by: SUPER_ADMIN_ID,
        created_at_branch_id: BRANCH_ID
      });
      
      inventoryToInsert.push({
        id: randomUUID(),
        product_id: productId,
        branch_id: BRANCH_ID,
        quantity: qty,
        available_quantity: qty
      });
    }
    
    console.log("\n=== STEP 5: INSERTING PRODUCTS IN BATCHES ===");
    const BATCH_SIZE = 100;
    
    for (let i = 0; i < productsToInsert.length; i += BATCH_SIZE) {
      const prodBatch = productsToInsert.slice(i, i + BATCH_SIZE);
      const invBatch = inventoryToInsert.slice(i, i + BATCH_SIZE);
      
      console.log(`Inserting products batch ${i / BATCH_SIZE + 1} (${prodBatch.length} items)...`);
      const { error: prodErr } = await supabase.from('products').insert(prodBatch);
      if (prodErr) throw prodErr;
      
      console.log(`Inserting inventory batch ${i / BATCH_SIZE + 1} (${invBatch.length} items)...`);
      const { error: invErr } = await supabase.from('product_inventory').insert(invBatch);
      if (invErr) throw invErr;
    }
    
    console.log("\n=== IMPORT COMPLETED SUCCESSFULLY! ===");
    console.log(`Total Categories Imported: ${uniqueCategories.length}`);
    console.log(`Total Products Imported: ${productsToInsert.length}`);
    
  } catch (err) {
    console.error("Migration failed:", err.message || err);
    process.exit(1);
  }
}

main();
