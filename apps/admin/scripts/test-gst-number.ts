/**
 * GSTIN service-layer test: validation + persistence round-trip.
 * Run: npx tsx --env-file=.env.local scripts/test-gst-number.ts
 */
export {};

async function main() {
  const { settingsService } = await import('../services/settingsService');
  const GSTIN = '32ATOPS2936C1ZO';

  const results: Array<[string, boolean, string]> = [];

  // 1. getGstNumber returns the stored default
  const got = await settingsService.getGstNumber();
  results.push(['getGstNumber returns value', got.success && got.data === GSTIN, `data=${got.data}`]);

  // 2. Invalid GSTIN rejected
  const bad = await settingsService.setGstNumber('NOT-A-GSTIN');
  results.push(['invalid GSTIN rejected', !bad.success && bad.error?.code === 'VALIDATION_ERROR', JSON.stringify(bad.error?.message).slice(0, 60)]);

  // 3. Wrong-length / lowercase accepted but normalized to uppercase
  const lower = await settingsService.setGstNumber('32atops2936c1zo');
  results.push(['lowercase normalized + accepted', lower.success, '']);
  const afterLower = await settingsService.getGstNumber();
  results.push(['stored uppercase', afterLower.data === GSTIN, `data=${afterLower.data}`]);

  // 4. Empty string allowed (explicit removal)
  const empty = await settingsService.setGstNumber('');
  results.push(['empty allowed (removal)', empty.success, '']);
  const afterEmpty = await settingsService.getGstNumber();
  results.push(['empty round-trips as ""', afterEmpty.data === '', `data=${afterEmpty.data}`]);

  // 5. Restore the default
  const restore = await settingsService.setGstNumber(GSTIN);
  const afterRestore = await settingsService.getGstNumber();
  results.push(['restored to default', restore.success && afterRestore.data === GSTIN, `data=${afterRestore.data}`]);

  // 6. Invoice settings include gstNumber
  const { invoiceService } = await import('../services/invoiceService');
  const settings: any = await (invoiceService as any).getInvoiceSettings();
  results.push(['invoice settings carry gstNumber', settings.gstNumber === GSTIN, `gstNumber=${settings.gstNumber}`]);

  let failed = 0;
  for (const [name, pass, detail] of results) {
    console.log(`  [${pass ? 'PASS' : 'FAIL'}] ${name}${detail ? ' — ' + detail : ''}`);
    if (!pass) failed++;
  }
  console.log(failed === 0 ? 'RESULT: ALL PASS' : `RESULT: ${failed} FAILURE(S)`);
  process.exit(failed === 0 ? 0 : 1);
}

main().catch((e) => { console.error('SCRIPT ERROR:', e); process.exit(1); });
