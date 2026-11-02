/**
 * Reproduction script: does the CURRENT code leave payment_status='partial'
 * on a fully-paid order after a return?
 *
 * Flow exercised (exactly what staff does in the UI):
 *   1. createOrder            — advance == total (fully paid at creation)
 *   2. orderRepository.update — start rental (scheduled → ongoing)
 *   3. processOrderReturn     — full return, no damage, no discount
 *   4. inspect final row      — status / payment_status / amount_paid
 *
 * Cleanup: the test order is deleted at the end (soft check — we print the id
 * so it can be removed manually if deletion fails).
 *
 * Run: npx tsx --env-file=.env.local scripts/repro-partial-return.ts
 */
export {};

async function main() {
  const { orderService } = await import('../services/orderService');
  const { orderRepository } = await import('../repository/orderRepository');
  const { createAdminClient } = await import('../lib/supabase/server');

  const supabase = createAdminClient();

  // ── Find a real branch + customer + product to build a valid order ──
  const { data: branch } = await supabase.from('branches').select('id').limit(1).single();
  const { data: customer } = await supabase.from('customers').select('id').limit(1).single();
  const { data: product } = await supabase
    .from('products')
    .select('id, price_per_day')
    .eq('is_active', true)
    .limit(1)
    .single();

  if (!branch || !customer || !product) {
    throw new Error('Missing seed data: need at least one branch, customer, active product');
  }

  const price = Number(product.price_per_day) || 100;

  // ── 1. Create the order with a FULL advance (advance == expected total) ──
  // Rental: 3 days → pricingMultiplier = max(1, 3-2) = 1 → total = price * 1 * 1
  const today = new Date();
  const plus2 = new Date(today.getTime() + 2 * 86400000);
  const fmt = (d: Date) => d.toISOString().split('T')[0];

  const expectedTotal = price; // qty 1, 3-day rental ⇒ multiplier 1

  const created = await orderService.createOrder({
    customer_id: customer.id,
    branch_id: branch.id,
    rental_start_date: fmt(today),
    rental_end_date: fmt(plus2),
    delivery_method: 'pickup',
    advance_collected: true,
    advance_amount: expectedTotal, // FULL payment up front
    advance_payment_method: 'cash',
    items: [{ product_id: product.id, quantity: 1, price_per_day: price }],
  } as any);

  if (!created.success || !created.data) {
    console.error('CREATE FAILED:', created.error);
    process.exit(1);
  }
  const orderId = created.data.id;
  console.log(`[1] created order ${orderId} total=${created.data.total_amount} paid=${created.data.amount_paid} payment_status=${created.data.payment_status}`);

  // ── 2. Start the rental (scheduled → ongoing) ──
  await orderRepository.update(orderId, { status: 'ongoing' } as any);
  const ongoing = await orderRepository.findById(orderId);
  console.log(`[2] started rental: status=${ongoing.data?.status} total=${ongoing.data?.total_amount} paid=${ongoing.data?.amount_paid} payment_status=${ongoing.data?.payment_status}`);

  // ── 3. Process a full return (all items, excellent, no fees) ──
  const items = ongoing.data?.items || [];
  const returned = await orderService.processOrderReturn(orderId, {
    order_id: orderId,
    notes: 'REPRO-TEST full return',
    items: items.map((i: any) => ({
      item_id: i.id,
      returned_quantity: i.quantity,
      condition_rating: 'excellent',
      damage_description: '',
      damage_charges: 0,
      damaged_quantity: 0,
    })),
    late_fee: 0,
    discount: 0,
  } as any);

  if (!returned.success) {
    console.error('RETURN FAILED:', returned.error);
  }

  // ── 4. Inspect the final row straight from the DB ──
  const { data: finalRow } = await supabase
    .from('orders')
    .select('id, invoice_number, status, payment_status, total_amount, amount_paid')
    .eq('id', orderId)
    .single();

  console.log('[3] FINAL ROW:', JSON.stringify(finalRow, null, 2));

  const paid = Number(finalRow?.amount_paid ?? 0);
  const total = Number(finalRow?.total_amount ?? 0);
  const verdict =
    finalRow?.status === 'completed'
      ? 'PASS (auto-completed)'
      : paid >= total && finalRow?.payment_status === 'paid'
        ? 'PASS-ish (returned & paid)'
        : '*** BUG REPRODUCED: fully paid order left payment_status=' + finalRow?.payment_status + ' ***';
  console.log(`[4] VERDICT: ${verdict}`);

  // ── 5. Cleanup: delete the test order (cascades to items/payments/history) ──
  const del = await orderRepository.delete(orderId);
  console.log(`[5] cleanup delete: success=${del.success} ${del.error?.message || ''} (order id for manual cleanup: ${orderId})`);
  process.exit(0);
}

main().catch((e) => {
  console.error('SCRIPT ERROR:', e);
  process.exit(1);
});
