const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkCatalog() {
  const { data: products, error } = await supabase
    .from('products')
    .select('sku');

  if (error) {
    console.error("Error fetching catalog:", error);
    return;
  }

  const skuPrefixes = {};
  products?.forEach(p => {
    const prefix = p.sku?.split('-')[0] || 'No Prefix';
    skuPrefixes[prefix] = (skuPrefixes[prefix] || 0) + 1;
  });

  console.log("All SKU Prefixes and counts:");
  console.log(skuPrefixes);
}

checkCatalog();
