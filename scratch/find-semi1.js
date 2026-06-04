const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function findSemi1() {
  console.log("Searching for SEMI-1...");
  // Query with absolutely no filters
  const { data: products, error } = await supabase
    .from('products')
    .select('*')
    .eq('sku', 'SEMI-1');

  if (error) {
    console.error("Error:", error);
    return;
  }

  console.log(`Found ${products.length} records for SEMI-1:`);
  products.forEach(p => {
    console.log(p);
  });
}

findSemi1();
