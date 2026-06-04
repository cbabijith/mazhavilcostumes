const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function findSemi36Records() {
  console.log("Checking SEMI-36 records in products table...");
  const { data: products, error } = await supabase
    .from('products')
    .select('id, name, sku, barcode, price_per_day, purchase_price, quantity, is_active, created_at, categories:category_id(name, slug)')
    .or("name.eq.SEMI-36,sku.eq.SEMI-36,barcode.eq.SEMI-36");

  if (error) {
    console.error("Error:", error);
    return;
  }

  console.log(`Found ${products.length} records related to SEMI-36 in the DB:`);
  products.forEach((p, idx) => {
    console.log(`\n[Product #${idx + 1}]`);
    console.log(`  ID: ${p.id}`);
    console.log(`  Name (Code): ${p.name}`);
    console.log(`  SKU (Desc): ${p.sku}`);
    console.log(`  Barcode: ${p.barcode}`);
    console.log(`  Rent Price: ₹${p.price_per_day}`);
    console.log(`  Purchase/MRP Price: ₹${p.purchase_price ?? 0}`);
    console.log(`  Quantity: ${p.quantity}`);
    console.log(`  Active: ${p.is_active}`);
    console.log(`  Created At: ${p.created_at}`);
    console.log(`  Category: ${p.categories?.name} (${p.categories?.slug})`);
  });
}

findSemi36Records();
