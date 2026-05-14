
import { createAdminClient } from '../apps/admin/lib/supabase/server';

async function testAvailability() {
  const supabase = createAdminClient();
  
  // 1. Find Ornaments category
  const { data: category } = await supabase
    .from('categories')
    .select('*')
    .ilike('name', 'Ornaments')
    .single();
    
  console.log('Category:', category?.name, 'has_buffer:', category?.has_buffer);

  if (!category) return;

  // 2. Find the product from the screenshot
  const { data: product } = await supabase
    .from('products')
    .select('*, category:category_id(*)')
    .ilike('name', '%White stone head set%')
    .single();

  console.log('Product:', product?.name, 'ID:', product?.id);
  console.log('Product Category Join Type:', Array.isArray(product?.category) ? 'Array' : 'Object');
  console.log('Product Category Buffer Setting:', (product?.category as any)?.has_buffer);

  if (!product) return;

  // 3. Check for existing orders for this product
  const { data: items } = await supabase
    .from('order_items')
    .select('*, orders!inner(*)')
    .eq('product_id', product.id)
    .in('orders.status', ['pending', 'confirmed', 'scheduled', 'ongoing', 'in_use', 'late_return', 'partial', 'flagged', 'returned']);

  console.log('Found', items?.length, 'active orders');
  if (items) {
    items.forEach(item => {
      const order = (item as any).orders;
      console.log(`- Order #${order.id.substring(0,8)}: ${order.start_date} to ${order.end_date} (${order.status}) Qty: ${item.quantity}`);
    });
  }

  // 4. Try to simulate a booking for the next day
  // If an order ends on '2024-05-15', try to book on '2024-05-16'
}

testAvailability().catch(console.error);
