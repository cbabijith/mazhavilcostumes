
import { createAdminClient } from './apps/admin/lib/supabase/server';

async function check() {
  const supabase = createAdminClient();
  
  // Check payments this week
  const { data: payments, error: pError } = await supabase
    .from('payments')
    .select('id, amount, payment_date, created_at, payment_type')
    .gte('payment_date', '2026-05-11')
    .lte('payment_date', '2026-05-14');
    
  console.log('Payments by payment_date:', payments?.length, payments?.reduce((s, p) => s + Number(p.amount), 0));
  if (payments && payments.length > 0) {
    console.log('Sample payment:', payments[0]);
  }

  const { data: payments2, error: pError2 } = await supabase
    .from('payments')
    .select('id, amount, payment_date, created_at, payment_type')
    .gte('created_at', '2026-05-11T00:00:00+05:30')
    .lte('created_at', '2026-05-14T23:59:59+05:30');

  console.log('Payments by created_at:', payments2?.length, payments2?.reduce((s, p) => s + Number(p.amount), 0));
  
  // Check orders this week
  const { data: orders, error: oError } = await supabase
    .from('orders')
    .select('id, total_amount, created_at')
    .gte('created_at', '2026-05-11T00:00:00+05:30')
    .lte('created_at', '2026-05-14T23:59:59+05:30');

  console.log('Orders by created_at:', orders?.length, orders?.reduce((s, o) => s + Number(o.total_amount), 0));
}

check();
