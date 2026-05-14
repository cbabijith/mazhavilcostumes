
import { createAdminClient } from '../apps/admin/lib/supabase/server';

async function inspectData() {
  const supabase = createAdminClient();
  
  console.log('--- Orders Branch IDs ---');
  const { data: orders, error: ordersError } = await supabase
    .from('orders')
    .select('branch_id')
    .limit(100);
    
  if (ordersError) {
    console.error('Error fetching orders:', ordersError);
  } else {
    const branches = [...new Set(orders.map(o => o.branch_id))];
    console.log('Unique Branch IDs in Orders:', branches);
  }
  
  console.log('\n--- Branches Table ---');
  const { data: allBranches, error: branchError } = await supabase
    .from('branches')
    .select('id, name');
    
  if (branchError) {
    console.error('Error fetching branches:', branchError);
  } else {
    console.log('Branches in DB:', allBranches);
  }
}

inspectData();
