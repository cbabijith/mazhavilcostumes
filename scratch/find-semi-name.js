const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function findSemi1ByName() {
  console.log("Searching for product where name = 'SEMI-1'...");
  const { data: products, error } = await supabase
    .from('products')
    .select('id, name, sku, barcode, is_active, deleted_at, category_id, categories:category_id(name, slug)')
    .eq('name', 'SEMI-1');

  if (error) {
    console.error("Error:", error);
    return;
  }

  console.log(`Found ${products.length} records:`);
  products.forEach(p => {
    console.log(p);
  });
}

findSemi1ByName();
