const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function fixSemi2() {
  console.log('Fetching category ID for "semi-classical"...');
  const { data: catData, error: catError } = await supabase
    .from('categories')
    .select('id')
    .eq('slug', 'semi-classical')
    .limit(1);
    
  if (catError || !catData || catData.length === 0) {
    console.error('Failed to find semi-classical category:', catError);
    return;
  }
  
  const categoryId = catData[0].id;
  console.log('Found category ID:', categoryId);
  
  console.log('Updating product record 2b9e9016-1a77-4f4f-b4a6-7a6c3a41e797...');
  const { data, error } = await supabase
    .from('products')
    .update({
      name: 'SEMI-2',
      slug: 'semi-2-black-pantblue-back-seat',
      description: 'Black Pant/Blue back seat',
      sku: 'Black Pant/Blue back seat',
      price_per_day: 580.00,
      purchase_price: 2200.00,
      quantity: 7,
      available_quantity: 7,
      category_id: categoryId,
      updated_at: new Date().toISOString()
    })
    .eq('id', '2b9e9016-1a77-4f4f-b4a6-7a6c3a41e797')
    .select();
    
  if (error) {
    console.error('Update failed:', error);
    return;
  }
  
  console.log('Successfully updated product:', data);
}

fixSemi2();
