import { createClient } from '../apps/admin/lib/supabase/server';

async function checkPaymentStatus() {
  const supabase = createClient();
  
  const { data: orders, error } = await supabase
    .from('orders')
    .select('id, total_amount, amount_paid, payment_status, status')
    .gt('amount_paid', 0)
    .lt('amount_paid', supabase.rpc('total_amount')) // This might not work in JS client easily
    .limit(5);

  if (error) {
    // Fallback simple query
    const { data: allOrders } = await supabase
      .from('orders')
      .select('id, total_amount, amount_paid, payment_status, status')
      .limit(20);
    
    console.log('Sample Orders:', allOrders?.map(o => ({
      id: o.id.substring(0,8),
      total: o.total_amount,
      paid: o.amount_paid,
      status: o.status,
      payStatus: o.payment_status,
      isPartial: o.amount_paid > 0 && o.amount_paid < o.total_amount
    })));
    return;
  }

  console.log('Orders with partial payments:', orders);
}

checkPaymentStatus();
