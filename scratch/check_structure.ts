import { createClient } from '../apps/admin/lib/supabase/server';

async function checkProductStructure() {
  const supabase = createClient();
  
  // Find the Ornaments category
  const { data: category } = await supabase
    .from('categories')
    .select('id, name, has_buffer')
    .ilike('name', 'Ornaments')
    .single();
    
  console.log('Category:', category);

  if (!category) return;

  // Find a product in this category
  const { data: product } = await supabase
    .from('products')
    .select('id, name, category:category_id(has_buffer)')
    .eq('category_id', category.id)
    .limit(1)
    .single();

  console.log('Product data structure:', JSON.stringify(product, null, 2));
}

checkProductStructure().catch(console.error);
