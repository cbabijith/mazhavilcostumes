const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Load env from storefront manually
const envPath = path.join(__dirname, '../../storefront/.env.local');
if (fs.existsSync(envPath)) {
  const content = fs.readFileSync(envPath, 'utf8');
  content.split('\n').forEach(line => {
    const trimmed = line.trim();
    if (trimmed && !trimmed.startsWith('#')) {
      const parts = trimmed.split('=');
      if (parts.length >= 2) {
        const key = parts[0].trim();
        const val = parts.slice(1).join('=').trim();
        // Remove surrounding quotes if any
        const cleanVal = val.replace(/^["']|["']$/g, '');
        process.env[key] = cleanVal;
      }
    }
  });
}

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase URL or Key');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
  console.log('Fetching total products count...');
  const { count, error } = await supabase
    .from('products')
    .select('*', { count: 'exact', head: true });
  
  if (error) {
    console.error('Error:', error);
  } else {
    console.log('Total active and inactive products in DB:', count);
  }

  console.log('\nFetching categories count...');
  const { data: categories, error: catError } = await supabase.from('categories').select('*');
  if (catError) {
    console.error('Error fetching categories:', catError);
  } else {
    console.log(`Total categories: ${categories.length}`);
    const mainCats = categories.filter(c => !c.parent_id);
    const subCats = categories.filter(c => c.parent_id && !mainCats.some(mc => mc.id === c.parent_id));
    const subsubCats = categories.filter(c => c.parent_id && !mainCats.some(mc => mc.id === c.parent_id) && !subCats.some(sc => sc.id === c.parent_id));
    console.log(`- Main categories: ${mainCats.length}`);
    console.log(`- Sub categories: ${categories.length - mainCats.length}`);
  }

  console.log('\nFetching sample products and their category relations...');
  const { data: products, error: prodError } = await supabase
    .from('products')
    .select('id, name, category_id, subcategory_id, subvariant_id, is_active')
    .limit(10);
  
  if (prodError) {
    console.error('Error fetching products:', prodError);
  } else {
    console.log('Sample Products:');
    console.table(products);
  }
}

run();
