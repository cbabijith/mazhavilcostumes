/**
 * Loading regressions against production repositories/services with offline data.
 * Run: node scripts/test-loading-performance.cjs
 * @module scripts/test-loading-performance
 */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');
const ts = require('typescript');

/** Compile a module with explicitly supplied dependencies; live access is blocked. */
function load(relative, dependencies) {
  const filename = path.resolve(__dirname, '..', relative);
  const compiled = ts.transpileModule(fs.readFileSync(filename, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
    fileName: filename,
  }).outputText;
  const loadedModule = { exports: {} };
  new Function('require', 'module', 'exports', compiled)(id => {
    assert.ok(Object.hasOwn(dependencies, id), `Unmocked dependency: ${id}`);
    return dependencies[id];
  }, loadedModule, loadedModule.exports);
  return loadedModule.exports;
}

class BaseRepository {
  handleResponse(response) {
    return { data: response.error ? null : response.data, error: response.error, success: !response.error };
  }
  async executeOperation(fn) { return this.handleResponse(await fn()); }
}

/** Scoped product rows, with PostgREST's default 1,000-row response ceiling. */
function categoryFixture(failPage = false) {
  const rows = Array.from({ length: 2505 }, (_, i) => ({
    id: i, category_id: i % 2 ? 'costume' : null,
    branch_id: i % 3 ? 'branch' : null, store_id: 'store', deleted_at: null,
  }));
  rows.push({ ...rows[0], id: 2505, deleted_at: 'deleted' });
  rows.push({ ...rows[0], id: 2506, branch_id: 'other' });
  rows.push({ ...rows[0], id: 2507, store_id: 'other' });
  const requests = [];
  const { CategoryRepository } = load('repository/categoryRepository.ts', {
    './supabaseClient': { BaseRepository }, '@/domain': {},
  });
  const repository = new CategoryRepository();
  repository.client = { from(table) {
    assert.equal(table, 'products');
    return {
      predicates: [], start: 0, end: 999,
      select(columns) { assert.equal(columns, 'category_id'); return this; },
      is(key, value) { this.predicates.push(row => row[key] === value); return this; },
      eq(key, value) { this.predicates.push(row => row[key] === value); return this; },
      or(value) {
        assert.equal(value, 'branch_id.eq.branch,branch_id.is.null');
        this.predicates.push(row => row.branch_id === 'branch' || row.branch_id === null);
        return this;
      },
      order(key) { assert.equal(key, 'id'); return this; },
      range(start, end) { this.start = start; this.end = end; return this; },
      then(resolve, reject) {
        requests.push(this.start);
        const filtered = rows.filter(row => this.predicates.every(fn => fn(row)));
        return Promise.resolve(failPage && this.start > 0
          ? { data: null, error: { message: 'page failed' } }
          : { data: filtered.slice(this.start, this.end + 1), count: filtered.length, error: null }
        ).then(resolve, reject);
      },
    };
  } };
  return { repository, requests };
}

test('counts page beyond 1000 rows, include shared products, and exclude deleted/other scopes', async () => {
  const { repository, requests } = categoryFixture();
  const result = await repository.findProductCategoryReferences('branch', 'store');
  assert.equal(result.success, true);
  assert.equal(result.data.length, 2505);
  assert.deepEqual(requests, [0, 1000, 2000]);
  const { CategoryService } = load('services/categoryService.ts', {
    '@/repository': { categoryRepository: {
      findAll: async () => ({ success: true, data: [{ id: 'costume' }, { id: 'empty' }] }),
      findProductCategoryReferences: async () => result,
    } }, '@/domain': {}, '@/lib/shared-utils': {},
  });
  const counts = await new CategoryService().getProductCounts('branch', 'store');
  assert.deepEqual(counts.data, { counts: { costume: 1252, empty: 0 }, total: 2505 });
});

test('a failed later page fails counts instead of publishing incomplete totals', async () => {
  const { repository } = categoryFixture(true);
  const result = await repository.findProductCategoryReferences('branch', 'store');
  assert.equal(result.success, false);
  assert.equal(result.data, null);
});

test('mobile product pages skip unused stock RPC while default callers retain it', async () => {
  const { ProductRepository } = load('repository/productRepository.ts', {
    './supabaseClient': { BaseRepository }, '@/domain': {},
  });
  const repository = new ProductRepository();
  let stockCalls = 0;
  repository.client = { rpc: async () => { stockCalls++; return { data: 8 }; } };
  repository.buildQuery = () => ({
    is() { return this; },
    then(resolve, reject) { return Promise.resolve({ data: [], count: 0, error: null }).then(resolve, reject); },
  });
  const mobile = await repository.findAll({ include_total_stock: false });
  assert.equal(stockCalls, 0);
  assert.equal(mobile.data.total_stock, undefined);
  const web = await repository.findAll();
  assert.equal(stockCalls, 1);
  assert.equal(web.data.total_stock, 8);
});

/** Empty DB responses keep financial calculations in production code intact. */
function analyticsFixture() {
  let calls = 0;
  let release;
  const gate = new Promise(resolve => { release = resolve; });
  const query = new Proxy({}, { get(target, key) {
    if (key === 'then') return (resolve, reject) => Promise.resolve({ data: [], count: 0 }).then(resolve, reject);
    return () => query;
  } });
  const { DashboardService } = load('services/dashboardService.ts', {
    '@/lib/supabase/server': { createAdminClient: () => ({ from: () => query, rpc: () => query }) },
    'date-fns': require('date-fns'),
    './reportService': { reportService: { getUnifiedRevenueMetrics: async () => {
      calls++;
      await gate;
      return { dailyTrends: [], total_amount_collection: 42, total_booking_sales: 50 };
    } } },
  });
  return { service: new DashboardService(), release, calls: () => calls };
}

const dates = ['2026-10-01', '2026-10-20', '2026-09-01', '2026-09-20'].map(value => new Date(value));

test('concurrent analytics shares computation and keeps branches isolated', async () => {
  const fixture = analyticsFixture();
  const first = fixture.service.getMetrics(...dates, 'one', 'store');
  const second = fixture.service.getMetrics(...dates, 'one', 'store');
  assert.equal(fixture.calls(), 2); // current and previous period, only once each
  fixture.release();
  const [a, b] = await Promise.all([first, second]);
  assert.equal(a, b);
  assert.equal(a.revenuePacing.current, 42);
  await fixture.service.getMetrics(...dates, 'one', 'store');
  assert.equal(fixture.calls(), 2);
  await fixture.service.getMetrics(...dates, 'two', 'store');
  assert.equal(fixture.calls(), 4);
});

test('mutation invalidation prevents pending analytics from refilling stale cache', async () => {
  const fixture = analyticsFixture();
  const first = fixture.service.getMetrics(...dates, 'one', 'store');
  fixture.service.clearCache();
  fixture.release();
  await first;
  await fixture.service.getMetrics(...dates, 'one', 'store');
  assert.equal(fixture.calls(), 4);
});
