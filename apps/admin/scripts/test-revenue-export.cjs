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
      invoice_number: i === 0 ? null : `MAZ-2627-${String(i).padStart(4, '0')}`,
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
  return {
    ...useRevenueReport(), GET, urls, errors,
    fetchRevenuePage: async ({ filters, branchId, storeId }) => {
      const params = new URLSearchParams({ fromDate: filters.from_date, toDate: filters.to_date });
      if (filters.page) params.set('page', String(filters.page));
      if (filters.limit) params.set('limit', String(filters.limit));
      if (filters.status?.length) params.set('statusFilter', filters.status.join(','));
      if (filters.payment_mode) params.set('paymentMode', filters.payment_mode);
      if (branchId) params.set('branchId', branchId);
      if (storeId) params.set('storeId', storeId);
      return (await (await GET(new Request(`http://localhost/api/reports/revenue?${params}`))).json()).data;
    },
  };
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
  const invoices = new Map(matching.map(p => [p.order.id, p.order.invoice_number]));
  for (const row of all) assert.equal(row.invoice_number, invoices.get(row.order_id));
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

test('existing revenue endpoint keeps its pagination defaults and 500-row cap', async () => {
  const api = setup(fixtures(1201));
  const base = 'http://localhost/api/reports/revenue?fromDate=2026-09-18&toDate=2026-09-30';
  for (const [query, expectedLength] of [['page=0', 50], ['page=-1', 50], ['page=abc', 50], ['limit=0', 50], ['limit=501', 500], ['limit=NaN', 50]]) {
    const response = await api.GET(new Request(`${base}&${query}`));
    assert.equal(response.status, 200);
    assert.equal((await response.json()).data.details.length, expectedLength);
  }
  const json = await (await api.GET(new Request(base))).json();
  assert.equal(json.data.details.length, 50);
  assert.equal(json.data.total_details_count, 1201);
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
  let excel;
  const link = { click() {} };
  const XLSX = require('xlsx');
  const { jsPDF } = require('jspdf');
  const { exportToPDF, exportToExcel } = load('lib/exportUtils.ts', {
    jspdf: { __esModule: true, default: function (options) {
      const doc = new jsPDF(options);
      doc.save = () => { pdf = doc; };
      return doc;
    } },
    'jspdf-autotable': require('jspdf-autotable'),
    xlsx: XLSX,
  }, {
    document: { createElement: () => link, body: { appendChild() {}, removeChild() {} } },
    URL: { createObjectURL: blob => { excel = blob; return 'blob:test'; }, revokeObjectURL() {} },
  });
  const columns = [
    { header: 'Date', key: 'date', format: 'date' },
    { header: 'Invoice Number', key: 'invoice_number' },
    { header: 'Customer', key: 'customer_name' },
    { header: 'Type', key: 'payment_type' },
    { header: 'Payment Mode', key: 'payment_mode' },
    { header: 'Amount', key: 'amount', format: 'currency' },
    { header: 'Order Status', key: 'status' },
  ];
  await exportToPDF(rows, columns, 'Revenue Report', 'test');
  await exportToExcel(rows, columns, 'test');
  const pdfText = pdf.output();
  const workbook = XLSX.read(await excel.arrayBuffer(), { type: 'array', cellStyles: true, cellNF: true });
  const sheet = workbook.Sheets.Report;
  const excelRows = XLSX.utils.sheet_to_json(sheet);
  assert.ok(pdf.getNumberOfPages() > 1);
  assert.equal(link.download, 'test.xlsx');
  assert.equal(excel.type, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  assert.equal(excelRows.length, 198);
  assert.equal(sheet.A2.t, 'n');
  assert.equal(sheet.A2.z, 'dd/mm/yyyy');
  assert.equal(XLSX.utils.format_cell(sheet.A2), '18/09/2026');
  assert.ok(sheet['!cols'][0].wch >= 14, 'Date column must fit the complete date');
  assert.equal(sheet.F2.t, 'n', 'Amounts stay numeric for Excel totals');
  assert.equal(sheet.F2.z, '#,##0.00');
  for (const row of rows) {
    const entry = excelRows.find(entry => entry.Customer === row.customer_name);
    assert.equal(entry?.['Invoice Number'] || null, row.invoice_number);
    if (row.invoice_number) assert.ok(pdfText.includes(row.invoice_number), `PDF missing ${row.invoice_number}`);
    assert.ok(!pdfText.includes(row.order_id));
    assert.ok(pdfText.includes(row.customer_name), `PDF missing ${row.customer_name}`);
    assert.ok(excelRows.some(entry => entry.Customer === row.customer_name), `Excel missing ${row.customer_name}`);
  }
});

test('Excel keeps calendar dates, blank/invalid values and identifiers without coercion', async () => {
  const XLSX = require('xlsx');
  let blob;
  const { exportToExcel } = load('lib/exportUtils.ts', { xlsx: XLSX }, {
    document: { createElement: () => ({ click() {} }), body: { appendChild() {}, removeChild() {} } },
    URL: { createObjectURL: value => { blob = value; return 'blob:test'; }, revokeObjectURL() {} },
  });
  await exportToExcel([
    { date: '2026-09-18', amount: '123456.78', percent: 12.5, id: '00123', name: '=SUM(A1:A2)' },
    { date: '2026-09-30', amount: 0, percent: 0, id: '00000' },
    { date: null, amount: null },
    { date: '', amount: '' },
    { date: 'not-a-date', amount: 'unknown' },
    { date: '1899-01-01' },
  ], [
    { header: 'Date', key: 'date', format: 'date' },
    { header: 'Amount', key: 'amount', format: 'currency' },
    { header: 'Rate', key: 'percent', format: 'percent' },
    { header: 'Order', key: 'id' },
    { header: 'Customer', key: 'name' },
  ], 'dates');
  const sheet = XLSX.read(await blob.arrayBuffer(), { type: 'array', cellStyles: true, cellNF: true }).Sheets.Report;
  assert.equal(XLSX.utils.format_cell(sheet.A2), '18/09/2026');
  assert.equal(XLSX.utils.format_cell(sheet.A3), '30/09/2026');
  assert.equal(XLSX.utils.format_cell(sheet.B2), '123,456.78');
  assert.equal(XLSX.utils.format_cell(sheet.C2), '12.5%');
  assert.equal(sheet.B3.v, 0);
  assert.equal(sheet.D2.v, '00123');
  assert.equal(sheet.D2.t, 's');
  assert.equal(sheet.E2.v, '=SUM(A1:A2)');
  assert.equal(sheet.E2.f, undefined);
  for (const address of ['A4', 'A5', 'B4', 'B5']) assert.equal(sheet[address].v, '');
  assert.equal(sheet.A6.v, 'not-a-date');
  assert.equal(sheet.B6.v, 'unknown');
  assert.equal(sheet.A7.t, 's', 'Unsupported dates must not become negative Excel serials');
});

/** Execute the production page handler with observable download/state adapters. */
function pageExport(overrides = {}) {
  const filename = path.resolve(__dirname, '..', 'app/dashboard/reports/page.tsx');
  const source = ts.createSourceFile(filename, fs.readFileSync(filename, 'utf8'), ts.ScriptTarget.Latest, true, ts.ScriptKind.TSX);
  let handler;
  const visit = node => {
    if (ts.isVariableDeclaration(node) && node.name.getText(source) === 'handleExport') handler = node.initializer;
    ts.forEachChild(node, visit);
  };
  visit(source);
  assert.ok(handler, 'Report export handler exists');
  const calls = [];
  const states = [];
  const errors = [];
  const capture = name => (...args) => calls.push({ name, args });
  const context = {
    REPORT_LIST: ['revenue', 'todays-revenue', 'gst-filing', 'damage-report'].map(id => ({ id, name: id })),
    selectedReport: 'revenue',
    exporting: false, loading: false,
    setExporting: value => states.push(value),
    setError: value => errors.push(value),
    reportSummary: {},
    sortedData: [{ period: 'summary' }],
    gstDetails: fixtures(50),
    getExportColumns: () => [{ key: 'period', header: 'Period' }],
    filters: request.filters,
    selectedBranchId: request.branchId,
    storeId: request.storeId,
    exportToPDF: capture('pdf'),
    exportToExcel: capture('excel'),
    exportGstFilingToPDF: capture('gst-pdf'),
    exportGstFilingToExcel: capture('gst-excel'),
    buildGstPayload: () => ({ invoices: fixtures(198), summary: [], totals: {} }),
    ...overrides,
  };
  const code = ts.transpileModule(`module.exports = ${handler.getText(source)};`, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 },
  }).outputText;
  const compiled = { exports: {} };
  new Function(...Object.keys(context), 'module', code)(...Object.values(context), compiled);
  return { handleExport: compiled.exports, calls, states, errors };
}

test('page PDF/Excel buttons export the complete fetched dataset instead of the visible 50 rows', async () => {
  for (const format of ['pdf', 'excel']) {
    const api = setup(fixtures(198));
    const page = pageExport({ fetchAllRevenueDetails: api.fetchAllRevenueDetails });
    await page.handleExport(format);
    assert.equal(page.calls.length, 1);
    assert.equal(page.calls[0].name, format);
    assert.equal(page.calls[0].args[0].length, 198);
    assert.deepEqual(page.states, [true, false]);
    assert.deepEqual(page.errors, [null]);
  }
});

test('page handles fetch, PDF and asynchronous Excel failures without an unhandled rejection', async () => {
  const failedFetch = pageExport({ fetchAllRevenueDetails: async () => { throw new Error('Cannot load transactions'); } });
  await failedFetch.handleExport('pdf');
  assert.deepEqual(failedFetch.calls, []);
  assert.deepEqual(failedFetch.errors, [null, 'Cannot load transactions']);
  assert.deepEqual(failedFetch.states, [true, false]);

  const failedPdf = pageExport({
    fetchAllRevenueDetails: async () => [],
    exportToPDF: async () => { throw new Error('Cannot generate PDF'); },
  });
  await failedPdf.handleExport('pdf');
  assert.deepEqual(failedPdf.errors, [null, 'Cannot generate PDF']);
  assert.deepEqual(failedPdf.states, [true, false]);

  const failedExcel = pageExport({
    fetchAllRevenueDetails: async () => [],
    exportToExcel: async () => { throw new Error('Cannot generate Excel'); },
  });
  await failedExcel.handleExport('excel');
  assert.deepEqual(failedExcel.errors, [null, 'Cannot generate Excel']);
  assert.deepEqual(failedExcel.states, [true, false]);
});

test('existing GST filing exports retain the complete register and dedicated generators', async () => {
  for (const format of ['pdf', 'excel']) {
    const page = pageExport({ selectedReport: 'gst-filing' });
    await page.handleExport(format);
    assert.equal(page.calls.length, 1);
    assert.equal(page.calls[0].name, `gst-${format}`);
    assert.equal(page.calls[0].args[0].invoices.length, 198);
    assert.equal(page.calls[0].args[1], 'GST_Filing_2026-09-18_to_2026-09-30');
    assert.deepEqual(page.states, [true, false]);
  }
});

test('existing damage-report export still uses its own rows and columns', async () => {
  const rows = [{ order_id: 'damaged-order' }];
  const columns = [{ key: 'order_id', header: 'Order' }];
  const page = pageExport({ selectedReport: 'damage-report', sortedData: rows, getExportColumns: () => columns });
  await page.handleExport('pdf');
  assert.equal(page.calls[0].args[0], rows);
  assert.equal(page.calls[0].args[1], columns);
  assert.deepEqual(page.errors, [null]);
});
