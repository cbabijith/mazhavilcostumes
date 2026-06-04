const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkProduct() {
  console.log('Querying for product containing SEMI-2...');
  
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .or('name.ilike.%SEMI-2%,slug.ilike.%SEMI-2%,barcode.ilike.%SEMI-2%,sku.ilike.%SEMI-2%');
    
  if (error) {
    console.error('Error:', error);
    return;
  }
  
  console.log('Matched products:', data.length);
  if (data.length > 0) {
    data.forEach((p, idx) => {
      console.log(`\nProduct #${idx + 1}:`);
      console.log('ID:', p.id);
      console.log('Name:', p.name);
      console.log('Slug:', p.slug);
      console.log('Barcode:', p.barcode);
      console.log('SKU:', p.sku);
      console.log('Quantity:', p.quantity);
      console.log('Is Active:', p.is_active);
      console.log('Deleted At:', p.deleted_at);
    });
  } else {
    console.log('No products found matching SEMI-2.');
  }
}

checkProduct();
