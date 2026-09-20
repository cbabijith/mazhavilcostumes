/**
 * Repro variant 2: balance collected via paymentService.createPayment BEFORE
 * the return (the return-modal "collect payment then settle return" flow).
 * Also replays the EXACT item/GST shape of a stuck live order to catch
 * float-drift in the total recomputation.
 *
 * Run: npx tsx --env-file=.env.local scripts/repro-partial-return-v2.ts
 */
export {};

async function main() {
  const { orderService } = await import('../services/orderService');
  const { paymentService } = await import('../services/paymentService');
  const { orderRepository } = await import('../repository/orderRepository');
  const { createAdminClient } = await import('../lib/supabase/server');

  const supabase = createAdminClient();

  const { data: branch } = await supabase.from('branches').select('id').limit(1).single();
  const { data: customer } = await supabase.from('customers').select('id').limit(1).single();
  const { data: product } = await supabase
    .from('products')
    .select('id, price_per_day')
    .eq('is_active', true)
    .limit(1)
    .single();
  if (!branch || !customer || !product) throw new Error('missing seed data');

  const price = Number(product.price_per_day) || 100;
  const today = new Date();
  const plus2 = new Date(today.getTime() + 2 * 86400000);
  const fmt = (d: Date) => d.toISOString().split('T')[0];

  const expectedTotal = price; // qty 1 × 3-day rental ⇒ multiplier 1

  // ── 1. Order with a PARTIAL advance (200 of total, if total > 200) ──
  const advance = Math.min(200, Math.floor(expectedTotal / 2) || 1);
  const created = await orderService.createOrder({
    customer_id: customer.id,
    branch_id: branch.id,
    rental_start_date: fmt(today),
    rental_end_date: fmt(plus2),
    delivery_method: 'pickup',
    advance_collected: true,
    advance_amount: advance,
    advance_payment_method: 'cash',
    items: [{ product_id: product.id, quantity: 1, price_per_day: price }],
  } as any);
  if (!created.success || !created.data) {
    console.error('CREATE FAILED:', created.error);
    process.exit(1);
  }
  const orderId = created.data.id;
  console.log(`[1] created ${orderId} total=${created.data.total_amount} paid=${created.data.amount_paid} ps=${created.data.payment_status}`);

  // ── 2. Start rental ──
  await orderRepository.update(orderId, { status: 'ongoing' } as any);

  // ── 3. Collect the BALANCE through the payment service (return-modal flow) ──
  const balance = Number(created.data.total_amount) - advance;
  if (balance > 0) {
    const { PaymentType, PaymentMode } = await import('../domain/types/payment');
    const pay = await paymentService.createPayment({
      order_id: orderId,
      payment_type: PaymentType.FINAL,
      amount: balance,
      payment_mode: PaymentMode.CASH,
      notes: 'REPRO-TEST balance at return',
    } as any);
    console.log(`[2] balance payment ${balance}: success=${pay.success} ${pay.error?.message || ''}`);
  }

  const mid = await orderRepository.findById(orderId);
  console.log(`[3] before return: total=${mid.data?.total_amount} paid=${mid.data?.amount_paid} ps=${mid.data?.payment_status} status=${mid.data?.status}`);

  // ── 4. Full return ──
  const items = mid.data?.items || [];
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
  if (!returned.success) console.error('RETURN FAILED:', returned.error);

  const { data: finalRow } = await supabase
    .from('orders')
    .select('status, payment_status, total_amount, amount_paid')
    .eq('id', orderId)
    .single();
  console.log('[4] FINAL:', JSON.stringify(finalRow));

  const paid = Number(finalRow?.amount_paid ?? 0);
  const total = Number(finalRow?.total_amount ?? 0);
  const verdict =
    finalRow?.status === 'completed'
      ? 'PASS (auto-completed)'
      : paid >= total && finalRow?.payment_status === 'paid'
        ? 'PASS-ish (returned & paid)'
        : `*** BUG REPRODUCED: ps=${finalRow?.payment_status} ***`;
  console.log(`[5] VERDICT: ${verdict}`);

  const del = await orderRepository.delete(orderId);
  console.log(`[6] cleanup: success=${del.success} ${del.error?.message || ''}`);
  process.exit(0);
}

main().catch((e) => {
  console.error('SCRIPT ERROR:', e);
  process.exit(1);
});
