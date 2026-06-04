const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function simulateSearch() {
  const query = 'semi';
  console.log(`Simulating search for "${query}"...`);
  
  let selectQuery = supabase
    .from('products')
    .select(`
      id,
      name,
      slug,
      sku,
      barcode,
      price_per_day,
      available_quantity,
      branch_id,
      is_active,
      deleted_at,
      categories:category_id(id, name, slug)
    `)
    .is('deleted_at', null);

  const normalizedQuery = query.trim().replace(/\s+/g, '-');
  selectQuery = selectQuery.or(`name.ilike.%${query}%,slug.ilike.%${query}%,sku.ilike.%${query}%,barcode.ilike.%${query}%`);

  const { data, error } = await selectQuery.limit(20);

  if (error) {
    console.error("Error:", error);
    return;
  }

  console.log(`Found ${data.length} search results:`);
  data.forEach((p, idx) => {
    console.log(`[${idx + 1}] ID: ${p.id} | Name (code): ${p.name} | SKU (desc): ${p.sku} | Barcode: ${p.barcode} | Branch: ${p.branch_id}`);
  });
}

simulateSearch();
