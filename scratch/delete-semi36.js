const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function deleteDuplicate() {
  const duplicateId = '1cd325f8-31e3-4cf0-824b-9cddc4ba379b';
  console.log(`Purging duplicate product ID: ${duplicateId}...`);

  // Delete from child tables first if any (e.g. product_inventory)
  const { error: invErr } = await supabase
    .from('product_inventory')
    .delete()
    .eq('product_id', duplicateId);

  if (invErr) {
    console.error("Error clearing inventory for duplicate:", invErr);
    return;
  }

  // Delete product
  const { error: prodErr } = await supabase
    .from('products')
    .delete()
    .eq('id', duplicateId);

  if (prodErr) {
    console.error("Error deleting product:", prodErr);
    return;
  }

  console.log("Success! Legacy duplicate ₹400.00 product has been safely purged from the database.");
}

deleteDuplicate();
