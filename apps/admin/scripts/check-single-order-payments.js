const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');

// Manually parse .env.local
const envPath = path.join(__dirname, '..', '.env.local');
const envContent = fs.readFileSync(envPath, 'utf8');
const env = {};
envContent.split('\n').forEach(line => {
  const match = line.match(/^\s*([\w.-]+)\s*=\s*(.*)?\s*$/);
  if (match) {
    const key = match[1];
    let value = match[2] || '';
    if (value.length > 0 && value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    } else if (value.length > 0 && value.startsWith("'") && value.endsWith("'")) {
      value = value.substring(1, value.length - 1);
    }
    env[key] = value.trim();
  }
});

const supabase = createClient(
  env.NEXT_PUBLIC_SUPABASE_URL || '',
  env.SUPABASE_SERVICE_ROLE_KEY || ''
);

async function run() {
  const targetOrderId = '2c635ff3-82e4-4f68-adb7-f7bbfa97f2cb';
  console.log(`Checking database records for order ID: ${targetOrderId}`);
  
  // 1. Get the order details
  const { data: order, error: oErr } = await supabase
    .from('orders')
    .select('*')
    .eq('id', targetOrderId)
    .single();

  if (oErr) {
    console.error('Error fetching order:', oErr);
    return;
  }

  console.log('\nOrder details from DB:');
  console.log({
    id: order.id,
    invoice_number: order.invoice_number,
    status: order.status,
    total_amount: order.total_amount,
    amount_paid: order.amount_paid,
    payment_status: order.payment_status,
    advance_amount: order.advance_amount,
    advance_collected: order.advance_collected
  });

  // 2. Get payments for this order directly
  const { data: payments, error: pErr } = await supabase
    .from('payments')
    .select('*')
    .eq('order_id', targetOrderId);

  if (pErr) {
    console.error('Error fetching payments:', pErr);
    return;
  }

  console.log(`\nPayments found in payments table directly: ${payments.length}`);
  console.log(JSON.stringify(payments, null, 2));

  // 3. Find if there are any other payments in the db
  console.log('\nChecking all payments currently in DB (first 100) to see if we can find this order ID anywhere:');
  const { data: allPayments, error: apErr } = await supabase
    .from('payments')
    .select('id, order_id, amount, payment_type')
    .limit(100);

  if (apErr) {
    console.error('Error fetching all payments:', apErr);
    return;
  }

  const matches = allPayments.filter(p => p.order_id === targetOrderId);
  console.log(`Matching payments in top 100: ${matches.length}`);
}

run();
