const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkProducts() {
  console.log("Checking products...");
  const { data: products, error } = await supabase
    .from('products')
    .select(`
      id,
      name,
      sku,
      barcode,
      branch_id,
      is_active,
      deleted_at,
      product_inventory (
        id,
        branch_id,
        quantity,
        available_quantity
      )
    `)
    .ilike('sku', 'SEMI-%')
    .order('sku', { ascending: true });

  if (error) {
    console.error("Error querying products:", error);
    return;
  }

  console.log(`Found ${products?.length || 0} products starting with SEMI:`);
  products?.forEach(p => {
    console.log(`SKU: ${p.sku} | Name: ${p.name} | Active: ${p.is_active} | Deleted: ${!!p.deleted_at} | Branch: ${p.branch_id}`);
    p.product_inventory.forEach(inv => {
      console.log(`  -> Inv Branch: ${inv.branch_id} | Qty: ${inv.quantity} | Avail: ${inv.available_quantity}`);
    });
  });
}

checkProducts();
