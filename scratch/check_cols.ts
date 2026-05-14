
import { createClient } from '@supabase/supabase-js';

const url = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(url, key);

async function run() {
  const { data, error } = await supabase.from('payments').select('*').limit(1);
  if (data && data.length > 0) {
    console.log('Columns in payments:', Object.keys(data[0]));
  } else {
    console.log('No data in payments or error:', error);
  }
}

run();
