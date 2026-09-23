/**
 * PR #89 regressions: executes the actual services/API with in-memory
 * repositories. No environment files, live database, or network are used.
 * Run: node scripts/test-pr89-regressions.cjs
 * @module scripts/test-pr89-regressions
 */
const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const ts = require('typescript');
const root = path.resolve(__dirname, '..');

/** Compile a production module with only explicitly supplied dependencies. */
function load(file, dependencies = {}) {
  const filename = path.join(root, file);
  const code = ts.transpileModule(fs.readFileSync(filename, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020, jsx: ts.JsxEmit.ReactJSX, esModuleInterop: true },
    fileName: filename,
  }).outputText;
  const compiledModule = { exports: {} };
  new Function('require', 'module', 'exports', code)((id) => {
    assert.ok(Object.hasOwn(dependencies, id), `Unexpected dependency (network access blocked): ${id}`);
    return dependencies[id];
  }, compiledModule, compiledModule.exports);
  return compiledModule.exports;
}

const domain = Object.assign({}, ...['order', 'payment', 'settings', 'cleaning', 'damageAssessment']
  .map((name) => load(`domain/types/${name}.ts`)));
const ok = (data) => ({ success: true, data, error: null });
const failure = { success: false, data: null, error: { message: 'Simulated storage failure', code: 'DB_ERROR' } };
class RepositoryError extends Error {
  constructor(message, code) { super(message); this.code = code; }
}

function setupSettings() {
  const records = new Map();
  let legacyGstin = null;
  const repository = {
    findByStoreAndKey: async (store, key) => ok(records.has(`${store}:${key}`) ? { value: records.get(`${store}:${key}`) } : null),
    getStoreGstin: async () => ok(legacyGstin),
    upsert: async (store, key, value) => { records.set(`${store}:${key}`, value); return ok({ value, store_id: store }); },
  };
  const settingsModule = load('services/settingsService.ts', {
    '@/repository': { settingsRepository: repository, RepositoryError }, '@/domain': domain,
  });
  return { ...settingsModule, records, repository, setLegacy: (value) => { legacyGstin = value; } };
}

test('GSTIN validation, precedence, clearing, store scope and error propagation', async (t) => {
  const { SettingsService, records, repository, setLegacy } = setupSettings();
  const service = new SettingsService();
  service.setStoreId('store-a');
  await t.test('unset uses Mazhavil default', async () => assert.equal((await service.getGstNumber()).data, domain.DEFAULT_GST_NUMBER));
  setLegacy('32ABCDE1234F1Z5');
  await t.test('legacy store GSTIN precedes the default', async () => assert.equal((await service.getGstNumber()).data, '32ABCDE1234F1Z5'));
  await t.test('normalizes lowercase and whitespace through generic setter', async () => {
    assert.equal((await service.setValue(domain.SettingKey.GST_NUMBER, ' 32atops2936c1zo ')).success, true);
    assert.equal((await service.getGstNumber()).data, domain.DEFAULT_GST_NUMBER);
  });
  await t.test('rejects malformed input without changing saved value', async () => {
    for (const value of ['123', '32ATOPS2936C0ZO', '32ATOPS2936C1YO', '32ATOPS2936C1Z!']) {
      assert.equal((await service.setValue(domain.SettingKey.GST_NUMBER, value)).error.code, 'VALIDATION_ERROR');
    }
    assert.equal(records.get('store-a:gst_number'), domain.DEFAULT_GST_NUMBER);
  });
  await t.test('clearing stays empty despite legacy GSTIN', async () => {
    await service.setGstNumber('  ');
    assert.equal((await service.getGstNumber()).data, '');
  });
  await t.test('settings in another scope are never substituted or overwritten', async () => {
    service.setStoreId('store-b');
    await service.setGstNumber('32ABCDE1234F1Z5');
    assert.equal(records.get('store-a:gst_number'), '');
    assert.equal(records.get('store-b:gst_number'), '32ABCDE1234F1Z5');
  });
  await t.test('read failures do not silently print a default', async () => {
    repository.findByStoreAndKey = async () => failure;
    assert.equal((await service.getGstNumber()).success, false);
  });
});

function setupOrders(overrides = {}, payments = []) {
  let order = {
    id: 'order-1', store_id: 'store-a', branch_id: 'branch-a', status: 'in_use',
    total_amount: 100, amount_paid: 20, payment_status: 'partial',
    end_date: '2026-09-01', start_date: '2026-09-01', items: [], ...overrides,
  };
  const history = [];
  const repository = {
    findById: async () => ok(structuredClone(order)),
    update: async (_id, data) => { order = { ...order, ...data }; return ok(structuredClone(order)); },
    create: async () => ok(structuredClone(order)),
    processReturn: async () => { order.status = 'returned'; return ok(structuredClone(order)); },
    getOrderItems: async () => ok([]),
    syncOrderPriorityFlag: async () => ok(null),
    addStatusHistory: async (...args) => { history.push(args); return ok(null); },
  };
  const paymentRepository = {
    findByOrderId: async () => ok(payments),
    create: async (payment) => { payments.push(payment); return ok(payment); },
  };
  const paymentModule = {};
  const orderModule = {};
  const dependencies = {
    '@/repository': { orderRepository: repository, paymentRepository, cleaningRepository: {} },
    '@/domain': domain, '@/domain/types/order': domain, '@/domain/types/payment': domain,
    './dashboardService': { dashboardService: { clearCache() {} } },
    './settingsService': { settingsService: { getIsGSTEnabled: async () => ok(false) } },
    './damageAssessmentService': { damageAssessmentService: { getAssessmentsForOrder: async () => ok([]) } },
    './paymentService': paymentModule, './orderService': orderModule,
    '@/lib/supabase/server': { createAdminClient: () => ({ from: () => ({ select: () => ({
      in: async () => ({ data: [] }), eq: () => ({ single: async () => ({ data: { store_id: 'store-a' } }) }),
    }) }) }) },
  };
  Object.assign(paymentModule, load('services/paymentService.ts', dependencies));
  Object.assign(orderModule, load('services/orderService.ts', dependencies));
  return { ...paymentModule, ...orderModule, repository, paymentRepository, history };
}

test('returns reconcile the ledger and await completion before returning', async (t) => {
  for (const [name, overrides, ledger, expected] of [
    ['stale partial becomes paid/completed', {}, [{ amount: 100 }], ['paid', 'completed', 100]],
    ['already paid return still completes', { amount_paid: 100, payment_status: 'paid' }, [{ amount: 100 }], ['paid', 'completed', 100]],
    ['genuine dues remain returned/partial', {}, [{ amount: 40 }], ['partial', 'returned', 40]],
    ['refunds reduce the net payment', {}, [{ amount: 100 }, { amount: 25, payment_type: 'refund' }], ['partial', 'returned', 75]],
    ['missing payment does not remain paid', { amount_paid: 100, payment_status: 'paid' }, [], ['pending', 'returned', 0]],
    ['numeric strings and paise sum correctly', { total_amount: 0.3 }, [{ amount: '0.10' }, { amount: '0.20' }], ['paid', 'completed', 0.3]],
    ['waived refunds remain deliberate', { payment_status: 'refund_waived' }, [{ amount: 20 }], ['refund_waived', 'returned', 20]],
    ['zero-total orders complete', { total_amount: 0 }, [], ['paid', 'completed', 0]],
  ]) {
    await t.test(name, async () => {
      const { orderService, paymentService, history } = setupOrders(overrides, ledger);
      const result = await orderService.processOrderReturn('order-1', { items: [{ item_id: 'item-1', condition_rating: 'good' }] });
      assert.equal(result.success, true);
      assert.deepEqual([result.data.payment_status, result.data.status, result.data.amount_paid], expected);
      await paymentService.syncOrderPaymentStatus('order-1');
      assert.equal(history.length, expected[1] === 'completed' ? 1 : 0);
    });
  }
  await t.test('partial item returns are not auto-completed', async () => {
    const { orderService, repository } = setupOrders({}, [{ amount: 100 }]);
    repository.processReturn = async () => repository.update('order-1', { status: 'partial' });
    const result = await orderService.processOrderReturn('order-1', { items: [{ item_id: 'item-1', condition_rating: 'good' }] });
    assert.equal(result.data.status, 'partial');
  });
  await t.test('ledger read/write errors do not masquerade as successful settlement', async () => {
    const context = setupOrders({}, [{ amount: 100 }]);
    context.paymentRepository.findByOrderId = async () => failure;
    await assert.rejects(context.paymentService.syncOrderPaymentStatus('order-1'), /storage failure/);
    context.paymentRepository.findByOrderId = async () => ok([{ amount: 100 }]);
    context.repository.update = async () => failure;
    await assert.rejects(context.paymentService.syncOrderPaymentStatus('order-1'), /storage failure/);
  });
  await t.test('creation reconciles the advance from the actual ledger', async () => {
    const { orderService } = setupOrders({ status: 'scheduled', amount_paid: 0, payment_status: 'pending' });
    const result = await orderService.createOrder({
      customer_id: 'customer-1', branch_id: 'branch-a', rental_start_date: '2026-09-01', rental_end_date: '2026-09-01',
      advance_collected: true, advance_amount: 100, items: [{ product_id: 'product-1', quantity: 1, price_per_day: 100 }],
    });
    assert.equal(result.data.amount_paid, 100);
    assert.equal(result.data.payment_status, 'paid');
    assert.equal(result.data.status, 'scheduled');
  });
});

test('dashboard uses an explicit null branch and exposes RPC failures', async () => {
  const calls = [];
  let response = { data: { revenueDueCount: 2, revenueDueAmount: 150 }, error: null };
  const { dashboardService } = load('services/dashboardService.ts', {
    '@/lib/supabase/server': { createAdminClient: () => ({ rpc: async (name, args) => { calls.push({ name, args }); return response; } }) },
    'date-fns': require('date-fns'), './reportService': {},
  });
  await dashboardService.getOperationalMetrics();
  await dashboardService.getOperationalMetrics('branch-a');
  assert.equal(calls[0].args.p_branch_id, null);
  assert.equal(calls[1].args.p_branch_id, 'branch-a');
  response = { data: null, error: { code: 'PGRST203' } };
  await assert.rejects(dashboardService.getOperationalMetrics(), /Failed to fetch/);
});

test('settings API validates input, preserves blank GSTIN and enforces admin writes', async () => {
  const { SettingsService } = setupSettings();
  let user = { role: 'admin', store_id: 'store-a' };
  const api = load('app/api/settings/route.ts', {
    '@/services': { SettingsService }, '@/domain': domain,
    '@/lib/apiGuard': { apiGuard: async () => ({ user }) },
    '@/lib/auth': { getAuthUser: async () => user },
    '@/lib/apiResponse': load('lib/apiResponse.ts', { 'next/server': require('next/server'), zod: require('zod') }),
  });
  const request = (value) => new Request('http://localhost/api/settings', {
    method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ key: 'gst_number', value }),
  });
  assert.equal((await api.PATCH(request('invalid'))).status, 400);
  assert.equal((await api.PATCH(request(''))).status, 200);
  const response = await api.GET(new Request('http://localhost/api/settings?key=gst_number'));
  assert.equal((await response.json()).data.value, '');
  user = { ...user, role: 'staff' };
  assert.equal((await api.PATCH(request(domain.DEFAULT_GST_NUMBER))).status, 403);
});

test('invoice generation prints edited GSTIN and honors clearing in deposit/final PDFs', async () => {
  const settings = setupSettings();
  settings.setLegacy('32ABCDE1234F1Z5');
  const renderer = await import('@react-pdf/renderer');
  const React = require('react');
  const pdfModule = load('components/admin/orders/TallyInvoicePDF.tsx', {
    react: React, 'react/jsx-runtime': require('react/jsx-runtime'), '@react-pdf/renderer': renderer,
  });
  const captured = [];
  const { invoiceService } = load('services/invoiceService.ts', {
    react: React, '@react-pdf/renderer': { renderToBuffer: async (element) => { captured.push(element.props); return renderer.renderToBuffer(element); } },
    '@/services': { SettingsService: settings.SettingsService }, '@/repository': { orderRepository: { getStatusHistory: async () => ok([]) } },
    '@/lib/supabase/server': {}, './paymentService': { paymentService: { getPaymentsByOrder: async () => ok([]) } },
    './orderService': { orderService: { getOrderById: async () => ok({
      id: 'order-1', store_id: 'store-a', invoice_number: 'MAZ-TEST-1', total_amount: 100, amount_paid: 100,
      status: 'completed', items: [], store: { name: 'Mazhavil Dance Costumes', gstin: '32ABCDE1234F1Z5' },
      customer: { name: 'Test Customer', phone: '0000000000' }, start_date: '2026-09-01', end_date: '2026-09-01',
    }) } },
    '@/components/admin/orders/TallyInvoicePDF': pdfModule,
  });
  for (const value of [domain.DEFAULT_GST_NUMBER, '']) {
    settings.records.set('store-a:gst_number', value);
    for (const type of ['deposit', 'final']) {
      const result = await invoiceService.generateInvoice('order-1', type);
      assert.equal(result.buffer.subarray(0, 4).toString(), '%PDF');
      assert.equal(captured.at(-1).companyGstin, value || undefined);
    }
  }
});
