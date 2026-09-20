/**
 * Verify the invoice PDF props carry the GSTIN from the settings store.
 * (PDF text is glyph-subset encoded, so we assert on the component props —
 * TallyInvoicePDF renders companyGstin as "GSTIN: ..." whenever non-empty.)
 * Run: npx tsx --env-file=.env.local scripts/test-invoice-gstin.ts
 */
export {};

async function main() {
  const { invoiceService } = await import('../services/invoiceService');
  const { orderService } = await import('../services/orderService');
  const { createAdminClient } = await import('../lib/supabase/server');

  const supabase = createAdminClient();
  const { data: order } = await supabase
    .from('orders')
    .select('id, invoice_number')
    .eq('status', 'completed')
    .limit(1)
    .single();
  if (!order) {
    console.log('no completed order available to test against');
    process.exit(2);
  }
  console.log(`order: ${order.invoice_number} (${order.id})`);

  // generateInvoice runs the FULL pipeline (order fetch + settings + props +
  // renderToBuffer). We assert both the rendered buffer and the props.
  const { buffer } = await invoiceService.generateInvoice(order.id, 'final');
  const pdfOk = buffer.length > 1000;
  console.log(`  [${pdfOk ? 'PASS' : 'FAIL'}] invoice PDF renders (${buffer.length} bytes)`);

  // Props check (private method — same pipeline generateInvoice uses)
  const orderResult = await orderService.getOrderById(order.id);
  const settings: any = await (invoiceService as any).getInvoiceSettings();
  const props: any = await (invoiceService as any).buildInvoiceProps(
    orderResult.data, 'final', 'TEST-1', '20/09/2026', [], settings, [],
  );
  const gstinOk = props.companyGstin === '32ATOPS2936C1ZO';
  console.log(`  [${gstinOk ? 'PASS' : 'FAIL'}] PDF props.companyGstin = ${props.companyGstin}`);
  console.log(`  company block: name=${props.companyName} gstin=${props.companyGstin}`);

  process.exit(pdfOk && gstinOk ? 0 : 1);
}

main().catch((e) => { console.error('SCRIPT ERROR:', e); process.exit(1); });
