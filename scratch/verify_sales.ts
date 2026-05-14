import { createAdminClient } from '../apps/admin/lib/supabase/server';

async function verifySales() {
  const supabase = createAdminClient();
  const branchId = '7671abeb-4b79-47a4-966b-384c1c26b950';
  const start = '2026-05-11T00:00:00+05:30';
  const end = '2026-05-14T23:59:59+05:30';

  const { data, error } = await supabase
    .from('orders')
    .select('id, total_amount, status, created_at')
    .eq('branch_id', branchId)
    .gte('created_at', start)
    .lte('created_at', end)
    .neq('status', 'cancelled');

  if (error) {
    console.error('Error:', error);
    return;
  }

  const total = data.reduce((sum, o) => sum + Number(o.total_amount || 0), 0);
  console.log('--- SALES VERIFICATION ---');
  console.log('Branch:', branchId);
  console.log('Period:', start, 'to', end);
  console.log('Order Count:', data.length);
  console.log('Total Sales:', total);
  console.log('Orders:', data.map(o => `${o.id.substring(0,8)}: ${o.total_amount} (${o.status})`));
}

verifySales();
