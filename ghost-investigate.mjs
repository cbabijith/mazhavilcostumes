import { createClient } from '@supabase/supabase-js';
import fs from 'fs';

const adminEnv = fs.readFileSync('./apps/admin/.env.local', 'utf8');
const getVar = (name) => {
  const m = adminEnv.match(new RegExp(`^${name}=(.*)$`, 'm'));
  return m ? m[1].trim() : null;
};
const supabase = createClient(getVar('NEXT_PUBLIC_SUPABASE_URL'), getVar('SUPABASE_SERVICE_ROLE_KEY'), {
  auth: { persistSession: false }
});

// 1. Get all orders with item counts in one shot via a left join
const { data: orders } = await supabase
  .from('orders')
  .select('id, invoice_number, status, total_amount, subtotal, gst_amount, amount_paid, created_at, updated_at, created_by, customer_id, branch_id, start_date, end_date')
  .order('created_at', { ascending: true });

// 2. Get all order_items order_ids
const { data: allItems } = await supabase
  .from('order_items')
  .select('order_id');
const orderIdsWithItems = new Set((allItems || []).map(i => i.order_id));

// 3. Identify ghosts
const ghosts = (orders || []).filter(o => !orderIdsWithItems.has(o.id));
console.log(`Total orders: ${orders?.length || 0}`);
console.log(`Orders WITH items: ${orders.length - ghosts.length}`);
console.log(`GHOST orders (no items): ${ghosts.length}\n`);

// 4. Time distribution — by day
console.log('── Ghost orders by creation date ──');
const byDay = {};
ghosts.forEach(g => {
  const day = g.created_at.slice(0, 10);
  byDay[day] = (byDay[day] || 0) + 1;
});
Object.entries(byDay).sort().forEach(([day, n]) => console.log(`  ${day}: ${n}`));

// 5. Status distribution
console.log('\n── Ghost orders by status ──');
const byStatus = {};
ghosts.forEach(g => { byStatus[g.status] = (byStatus[g.status] || 0) + 1; });
Object.entries(byStatus).sort().forEach(([s, n]) => console.log(`  ${s}: ${n}`));

// 6. Are ghosts correlated with non-zero total_amount?
console.log('\n── Ghost order total_amount distribution ──');
const zero = ghosts.filter(g => Number(g.total_amount) === 0).length;
const nonzero = ghosts.filter(g => Number(g.total_amount) > 0).length;
console.log(`  total_amount = 0: ${zero}`);
console.log(`  total_amount > 0: ${nonzero}`);
const sum = ghosts.reduce((s, g) => s + Number(g.total_amount || 0), 0);
console.log(`  Sum of ghost total_amount: ₹${sum}`);

// 7. Check related data on a sample of ghosts — payments, status history, cleaning
console.log('\n── Related data on first 5 ghosts ──');
for (const g of ghosts.slice(0, 5)) {
  const { count: payCount } = await supabase
    .from('payments').select('id', { count: 'exact', head: true }).eq('order_id', g.id);
  const { count: histCount } = await supabase
    .from('order_status_history').select('id', { count: 'exact', head: true }).eq('order_id', g.id);
  const { count: cleanCount } = await supabase
    .from('cleaning_queue').select('id', { count: 'exact', head: true }).eq('order_id', g.id);
  console.log(`  ${g.invoice_number || g.id.slice(0,8)} (${g.status}, ₹${g.total_amount}, created ${g.created_at.slice(0,10)}): payments=${payCount}, history=${histCount}, cleaning=${cleanCount}`);
}

// 8. KEY DIAGNOSTIC: Do ghosts have an invoice_number? (OrderForm creates it; manual/test might not)
console.log('\n── Do ghosts have invoice_numbers? ──');
const withInv = ghosts.filter(g => g.invoice_number).length;
console.log(`  With invoice_number: ${withInv}`);
console.log(`  Without invoice_number: ${ghosts.length - withInv}`);

// 9. Updated_at vs created_at — were ghosts edited after creation? (Suggests update deleted items)
console.log('\n── Were ghosts updated after creation? ──');
const edited = ghosts.filter(g => {
  if (!g.updated_at || !g.created_at) return false;
  const diff = new Date(g.updated_at).getTime() - new Date(g.created_at).getTime();
  return diff > 5000; // >5s difference = real edit
});
console.log(`  Ghosts edited after creation (>5s gap): ${edited.length} of ${ghosts.length}`);

// 10. Most important: are there any NORMAL orders that share a customer+date with a ghost?
// (Suggests duplicate-create race condition)
console.log('\n── Ghost vs non-ghost ratio per customer (top duplicates) ──');
const custGhosts = {};
ghosts.forEach(g => { custGhosts[g.customer_id] = (custGhosts[g.customer_id] || 0) + 1; });
const topCusts = Object.entries(custGhosts).sort((a,b) => b[1] - a[1]).slice(0, 5);
for (const [custId, gCount] of topCusts) {
  const normalCount = (orders || []).filter(o => o.customer_id === custId && orderIdsWithItems.has(o.id)).length;
  const { data: cust } = await supabase.from('customers').select('name, phone').eq('id', custId).maybeSingle();
  console.log(`  ${cust?.name || custId.slice(0,8)} (${cust?.phone || '?'}): ${gCount} ghosts vs ${normalCount} normal orders`);
}
