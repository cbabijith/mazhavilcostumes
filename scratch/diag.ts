
import { createClient } from '@supabase/supabase-js';

const url = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(url, key);

async function run() {
  const { data: branches, error: bErr } = await supabase.from('branches').select('id, name');
  console.log('Branches:', branches);

  const { data: counts, error: cErr } = await supabase.rpc('get_branch_order_counts');
  // If RPC doesn't exist, try raw query via select
  if (cErr) {
    const { data: orders } = await supabase.from('orders').select('branch_id');
    const bCounts: any = {};
    orders?.forEach((o: any) => {
      bCounts[o.branch_id] = (bCounts[o.branch_id] || 0) + 1;
    });
    console.log('Order Counts per Branch ID:', bCounts);
  }
}

run();
