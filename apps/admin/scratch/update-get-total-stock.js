const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Manually parse env file
const envPath = path.join(__dirname, '../.env.local');
if (fs.existsSync(envPath)) {
  const content = fs.readFileSync(envPath, 'utf8');
  content.split('\n').forEach(line => {
    const match = line.match(/^\s*([\w.-]+)\s*=\s*(.*)?\s*$/);
    if (match) {
      const key = match[1];
      let value = match[2] || '';
      value = value.trim();
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      } else if (value.startsWith("'") && value.endsWith("'")) {
        value = value.substring(1, value.length - 1);
      }
      process.env[key] = value;
    }
  });
}

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function run() {
  console.log('Reading migration file...');
  const sqlPath = path.join(__dirname, '../../../database/migrations/041_get_total_stock_rpc.sql');
  const sql = fs.readFileSync(sqlPath, 'utf8');

  console.log('Deploying updated get_total_stock function...');
  const { data, error } = await supabase.rpc('run_sql', {
    query: sql
  });

  if (error) {
    console.error('Failed to run migration:', error.message);
  } else {
    console.log('Migration successful!', data);
  }
}

run();
