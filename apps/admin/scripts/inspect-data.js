import fs from 'fs';
import { createClient } from '@supabase/supabase-js';

// Read .env.local manually
const envText = fs.readFileSync('apps/admin/.env.local', 'utf-8');
const env = {};
envText.split('\n').forEach(line => {
  const match = line.match(/^\s*([^#=]+)\s*=\s*(.*)\s*$/);
  if (match) {
    let val = match[2].trim();
    if (val.startsWith('"') && val.endsWith('"')) {
      val = val.substring(1, val.length - 1);
    }
    env[match[1]] = val;
  }
});

const supabase = createClient(
  env.NEXT_PUBLIC_SUPABASE_URL,
  env.SUPABASE_SERVICE_ROLE_KEY
);

async function run() {
  console.log('--- BRANCHES ---');
  const { data: branches } = await supabase.from('branches').select('id, name, is_main');
  console.log(branches);

  console.log('--- TARGET PRODUCT ---');
  const { data: products } = await supabase
    .from('products')
    .select('id, name, quantity, available_quantity, branch_id')
    .ilike('name', '%Gold 3 side head set%');
  console.log(products);

  if (products && products.length > 0) {
    const targetProduct = products[0];
    console.log('--- PRODUCT INVENTORY FOR PRODUCT ---');
    const { data: inventory } = await supabase
      .from('product_inventory')
      .select('id, branch_id, quantity, available_quantity')
      .eq('product_id', targetProduct.id);
    console.log(inventory);
  }
}

run();
