/**
 * Revenue pagination/export regressions using production hooks, API and service.
 * Fixtures replace database access; no environment files or network are used.
 * Run: node scripts/test-revenue-export.cjs
 * @module scripts/test-revenue-export
 */
const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const ts = require('typescript');

/** Compile a production module with only explicitly allowed dependencies. */
function load(file, dependencies = {}, globals = {}) {
  const filename = path.resolve(__dirname, '..', file);
  const code = ts.transpileModule(fs.readFileSync(filename, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020, esModuleInterop: true },
    fileName: filename,
  }).outputText;
  const compiled = { exports: {} };
  const blockedFetch = () => { throw new Error('Live network access is blocked'); };
  new Function('require', 'module', 'exports', 'fetch', 'document', 'URL', code)((id) => {
    assert.ok(Object.hasOwn(dependencies, id), `Unexpected dependency: ${id}`);
    return dependencies[id];
  }, compiled, compiled.exports, globals.fetch || blockedFetch, globals.document, globals.URL || URL);
  return compiled.exports;
}

const request = {
  type: 'revenue',
  filters: { from_date: '2026-09-18', to_date: '2026-09-30', page: 3, limit: 50 },
  branchId: 'branch-a',
  storeId: 'store-a',
};

/** Create payments with tied dates, mixed statuses/modes and refunds. */
function fixtures(count) {
  return Array.from({ length: count }, (_, i) => ({
    id: `payment-${String(i).padStart(5, '0')}`,
    amount: 100,
    payment_mode: i % 3 === 0 ? 'cash' : 'upi',
    payment_type: i % 5 === 0 ? 'refund' : 'advance',
    payment_date: '2026-09-18T05:30:00Z',
    order: {
      id: `order-${String(i).padStart(5, '0')}`,
      branch_id: 'branch-a', store_id: 'store-a',
      status: i % 2 === 0 ? 'completed' : 'ongoing',
      customer: { name: `Customer-${String(i).padStart(5, '0')}` },
    },
  }));
}

/** In-memory query executor with filtering, ordering, exact counts and ranges. */
function database(rows) {
  const value = (row, field) => field.split('.').reduce((item, key) => item[key], row);
  return { from(table) {
    assert.equal(table, 'payments');
    const predicates = [];
    const ordering = [];
    let start = 0;
    let end = 49;
    return {
      select() { return this; },
      gte(field, date) { predicates.push(row => Date.parse(value(row, field)) >= Date.parse(date)); return this; },
      lte(field, date) { predicates.push(row => Date.parse(value(row, field)) <= Date.parse(date)); return this; },
      eq(field, expected) { predicates.push(row => value(row, field) === expected); return this; },
      in(field, expected) { predicates.push(row => expected.includes(value(row, field))); return this; },
      order(field, options) { ordering.push({ field, ...options }); return this; },
      range(from, to) { start = from; end = to; return this; },
      then(resolve, reject) {
        const matching = rows.filter(row => predicates.every(predicate => predicate(row)));
        matching.sort((a, b) => {
          for (const { field, ascending } of ordering) {
            const comparison = String(value(a, field)).localeCompare(String(value(b, field)));
            if (comparison) return ascending ? comparison : -comparison;
          }
          return 0;
        });
        return Promise.resolve({ data: matching.slice(start, end + 1), count: matching.length, error: null }).then(resolve, reject);
      },
    };
  } };
}

/** Wire the actual report service and route to a hook using fixture-only fetch. */
function setup(rows, intercept) {
  const { ReportService } = load('services/reportService.ts', {
    '@/lib/supabase/server': { createAdminClient: () => database(rows) },
    './settingsService': {},
  });
  const service = new ReportService();
  service.getUnifiedRevenueMetrics = async () => ({ summary: [] });
  const responses = {
    apiSuccess: data => Response.json({ success: true, data }),
    apiBadRequest: message => Response.json({ success: false, error: { message } }, { status: 400 }),
    apiInternalError: message => Response.json({ success: false, error: { message } }, { status: 500 }),
  };
  const { GET } = load('app/api/reports/revenue/route.ts', {
    '@/services': { reportService: service },
    '@/lib/apiResponse': responses,
    '@/lib/apiGuard': { apiGuard: async () => ({ user: { store_id: 'store-a' } }) },
  });
  const urls = [];
  const errors = [];
  const { useRevenueReport } = load('hooks/useRevenueReport.ts', {
    '@tanstack/react-query': { useMutation: options => ({
      mutateAsync: async args => {
        try { return await options.mutationFn(args); }
        catch (error) { options.onError(error); throw error; }
      },
    }) },
    '@/stores': { useAppStore: selector => selector({ showError: (...args) => errors.push(args) }) },
  }, { fetch: async relative => {
    const url = new URL(relative, 'http://localhost');
    urls.push(url);
    const intercepted = await intercept?.(url, urls.length);
    return intercepted || GET(new Request(url));
  } });
  return { ...useRevenueReport(), GET, urls, errors };
}

test('198 matching transactions: table pages are distinct and exports start at page one', async () => {
  const matching = fixtures(198);
  const excluded = fixtures(3);
  excluded[0].payment_date = '2026-10-01T00:00:00+05:30';
  excluded[1].order.branch_id = 'branch-b';
  excluded[2].order.store_id = 'store-b';
  const api = setup([...matching, ...excluded]);
  const first = await api.fetchRevenuePage({ ...request, filters: { ...request.filters, page: 1 } });
  const second = await api.fetchRevenuePage({ ...request, filters: { ...request.filters, page: 2 } });
  const last = await api.fetchRevenuePage({ ...request, filters: { ...request.filters, page: 4 } });
  assert.equal(first.total_details_count, 198);
  assert.equal(first.details.length, 50);
  assert.equal(second.details.length, 50);
  assert.equal(last.details.length, 48);
  assert.equal(new Set([...first.details, ...second.details].map(row => row.order_id)).size, 100);
  const all = await api.fetchAllRevenueDetails(request);
  assert.equal(all.length, 198);
  assert.equal(new Set(all.map(row => row.order_id)).size, 198);
  assert.equal(api.urls.at(-1).searchParams.get('page'), '1');
  assert.ok(all.filter(row => row.payment_type === 'refund').every(row => row.amount === -100));
});

test('status/payment filters apply before counts and pagination', async () => {
  const api = setup(fixtures(1201));
  const filtered = { ...request, filters: { ...request.filters, page: 1, status: ['completed'], payment_mode: 'cash' } };
  const page = await api.fetchRevenuePage(filtered);
  const all = await api.fetchAllRevenueDetails(filtered);
  assert.equal(page.total_details_count, 201);
  assert.equal(page.details.length, 50);
  assert.equal(all.length, 201);
  assert.ok(all.every(row => row.status === 'completed' && row.payment_mode === 'cash'));
});

test('exports collect more than 1,000 transactions without duplicates or missing pages', async () => {
  const api = setup(fixtures(1201));
  const all = await api.fetchAllRevenueDetails(request);
  assert.equal(all.length, 1201);
  assert.equal(new Set(all.map(row => row.order_id)).size, 1201);
  assert.deepEqual(api.urls.map(url => url.searchParams.get('page')), ['1', '2', '3']);
  for (const url of api.urls) {
    assert.equal(url.searchParams.get('fromDate'), '2026-09-18');
    assert.equal(url.searchParams.get('toDate'), '2026-09-30');
    assert.equal(url.searchParams.get('branchId'), 'branch-a');
    assert.equal(url.searchParams.get('storeId'), 'store-a');
  }
});

test('empty results complete without looping', async () => {
  const api = setup([]);
  assert.deepEqual(await api.fetchAllRevenueDetails(request), []);
  assert.equal(api.urls.length, 1);
});

test('later failures and incomplete/changed responses reject the export and notify', async () => {
  for (const response of [
    { status: 500, body: { success: false, error: { message: 'Simulated failure' } } },
    { status: 200, body: { success: true, data: { total_details_count: 1201, details: [] } } },
    { status: 200, body: { success: true, data: { total_details_count: 1202, details: [] } } },
  ]) {
    const api = setup(fixtures(1201), (_url, calls) => calls === 2 ? Response.json(response.body, { status: response.status }) : null);
    await assert.rejects(api.fetchAllRevenueDetails(request), /Simulated failure|could not be loaded completely/);
    assert.equal(api.errors.length, 1);
    assert.equal(api.urls.length, 2);
  }
});

test('revenue endpoint rejects invalid pagination and keeps default 50-row pages', async () => {
  const api = setup(fixtures(198));
  const base = 'http://localhost/api/reports/revenue?fromDate=2026-09-18&toDate=2026-09-30';
  for (const query of ['page=0', 'page=-1', 'page=1.5', 'page=abc', 'limit=0', 'limit=501', 'limit=NaN']) {
    assert.equal((await api.GET(new Request(`${base}&${query}`))).status, 400);
  }
  const json = await (await api.GET(new Request(base))).json();
  assert.equal(json.data.details.length, 50);
  assert.equal(json.data.total_details_count, 198);
});

test("Today's Revenue exports use its fixed endpoint and response envelope", async () => {
  const rows = fixtures(601).map(row => ({ order_id: row.order.id }));
  const api = setup([], url => {
    assert.equal(url.pathname, '/api/reports/todays-revenue');
    assert.equal(url.searchParams.get('status'), 'completed');
    assert.equal(url.searchParams.get('payment_mode'), 'upi');
    const offset = (Number(url.searchParams.get('page')) - 1) * Number(url.searchParams.get('limit'));
    return Response.json({ success: true, data: { rows: { total_details_count: rows.length, details: rows.slice(offset, offset + 500) } } });
  });
  const all = await api.fetchAllRevenueDetails({ type: 'todays-revenue', filters: { status: ['completed'], payment_mode: 'upi' } });
  assert.deepEqual(all, rows);
});

test('actual PDF and Excel exporters contain all 198 fetched transactions', async () => {
  const api = setup(fixtures(198));
  const rows = await api.fetchAllRevenueDetails(request);
  let pdf;
  let csv;
  const { jsPDF } = require('jspdf');
  const { exportToPDF, exportToExcel } = load('lib/exportUtils.ts', {
    jspdf: { __esModule: true, default: function (options) {
      const doc = new jsPDF(options);
      doc.save = () => { pdf = doc; };
      return doc;
    } },
    'jspdf-autotable': require('jspdf-autotable'),
  }, {
    document: { createElement: () => ({ click() {} }), body: { appendChild() {}, removeChild() {} } },
    URL: { createObjectURL: blob => { csv = blob; return 'blob:test'; }, revokeObjectURL() {} },
  });
  const columns = [
    { header: 'Date', key: 'date', format: 'date' },
    { header: 'Order ID', key: 'order_id' },
    { header: 'Customer', key: 'customer_name' },
    { header: 'Type', key: 'payment_type' },
    { header: 'Payment Mode', key: 'payment_mode' },
    { header: 'Amount', key: 'amount', format: 'currency' },
    { header: 'Order Status', key: 'status' },
  ];
  await exportToPDF(rows, columns, 'Revenue Report', 'test');
  exportToExcel(rows, columns, 'test');
  const pdfText = pdf.output();
  const csvText = await csv.text();
  assert.ok(pdf.getNumberOfPages() > 1);
  assert.equal(csvText.trim().split('\n').length, 199);
  for (const row of rows) {
    assert.ok(pdfText.includes(row.customer_name), `PDF missing ${row.customer_name}`);
    assert.ok(csvText.includes(row.customer_name), `Excel missing ${row.customer_name}`);
  }
});
