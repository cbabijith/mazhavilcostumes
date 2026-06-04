const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

const supabase = createClient(supabaseUrl, supabaseKey);

const VALID_SLUGS = [
  'bharathanattyam', 'chest-coat', 'cinematic', 'fancy-dress', 'frock', 
  'katak', 'kerala-nadanam', 'margam-kali', 'mohiniyattam', 'oppana', 
  'ornaments', 'overcoat', 'pant', 'parts', 'property', 'semi-classical', 
  'shawl', 'skirt', 'skirt-top', 'thiruvathira', 'top'
];

async function runCleanup() {
  try {
    console.log('--- Database Cleanup Started ---');

    // 1. Fetch category IDs to be deleted
    console.log('Fetching old categories...');
    const { data: oldCats, error: fetchError } = await supabase
      .from('categories')
      .select('id, name, slug')
      .not('slug', 'in', `(${VALID_SLUGS.join(',')})`);

    if (fetchError) {
      throw new Error(`Failed to fetch categories: ${fetchError.message}`);
    }

    console.log(`Found ${oldCats.length} old categories to purge.`);
    if (oldCats.length > 0) {
      const oldCatIds = oldCats.map(c => c.id);

      // 2. Unlink products
      console.log('Unlinking products from old categories...');
      
      const { error: unlinkCatErr } = await supabase
        .from('products')
        .update({ category_id: null })
        .in('category_id', oldCatIds);

      if (unlinkCatErr) console.warn('Unlink category_id warning:', unlinkCatErr.message);

      const { error: unlinkSubcatErr } = await supabase
        .from('products')
        .update({ subcategory_id: null })
        .in('subcategory_id', oldCatIds);

      if (unlinkSubcatErr) console.warn('Unlink subcategory_id warning:', unlinkSubcatErr.message);

      const { error: unlinkSubvarErr } = await supabase
        .from('products')
        .update({ subvariant_id: null })
        .in('subvariant_id', oldCatIds);

      if (unlinkSubvarErr) console.warn('Unlink subvariant_id warning:', unlinkSubvarErr.message);

      // 3. Delete categories (bottom-up: first leaf nodes, then parents)
      console.log('Deleting old subcategories / variants (first pass)...');
      const { error: delSubErr } = await supabase
        .from('categories')
        .delete()
        .in('id', oldCatIds)
        .not('parent_id', 'is', null);

      if (delSubErr) console.warn('Delete subcategories warning:', delSubErr.message);

      console.log('Deleting old main categories (second pass)...');
      const { error: delMainErr } = await supabase
        .from('categories')
        .delete()
        .in('id', oldCatIds);

      if (delMainErr) console.warn('Delete main categories warning:', delMainErr.message);
      
      console.log('Categories cleanup complete!');
    }

    // 4. Delete all customer records
    console.log('Clearing all customer records...');
    const { data: delCustomers, error: delCustErr } = await supabase
      .from('customers')
      .delete()
      .neq('id', '00000000-0000-0000-0000-000000000000'); // Delete all rows matching not-null condition

    if (delCustErr) {
      throw new Error(`Failed to clear customer records: ${delCustErr.message}`);
    }

    console.log('Successfully cleared all customer records!');
    console.log('--- Database Cleanup Completed Successfully ---');

  } catch (error) {
    console.error('CRITICAL ERROR during cleanup:', error.message);
  }
}

runCleanup();
