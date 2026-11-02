/**
 * Offline regressions for parallel auth and lightweight mobile list queries.
 * Run: node scripts/test-startup-api-performance.cjs
 * @module scripts/test-startup-api-performance
 */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');
const ts = require('typescript');

/** Compile production code with explicit mocks; never contact live services. */
function load(relative, dependencies = {}) {
  const filename = path.resolve(__dirname, '..', relative);
  const compiled = ts.transpileModule(fs.readFileSync(filename, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 }, fileName: filename,
  }).outputText;
  const loadedModule = { exports: {} };
  new Function('require', 'module', 'exports', compiled)(id => {
    assert.ok(Object.hasOwn(dependencies, id), `Unmocked dependency: ${id}`);
    return dependencies[id];
  }, loadedModule, loadedModule.exports);
  return loadedModule.exports;
}

const userId = '11111111-1111-4111-8111-111111111111';
const token = `header.${Buffer.from(JSON.stringify({ sub: userId })).toString('base64url')}.signature`;
function authFixture({ authError = false, staffError = false, verifiedId = userId } = {}) {
  const calls = [];
  let release;
  const gate = new Promise(resolve => { release = resolve; });
  const client = {
    auth: { getUser: async () => {
      calls.push('verify'); await gate;
      return { data: { user: authError ? null : { id: verifiedId, email: '', user_metadata: {} } }, error: authError };
    } },
    from(table) {
      assert.equal(table, 'staff');
      return { select() { return this; }, eq(key, value) {
        if (key === 'user_id') calls.push(value); return this;
      }, maybeSingle: async () => ({ data: { id: 'staff', role: 'staff', store_id: 'shop', branch_id: 'branch' }, error: staffError }) };
    },
  };
  const { getAuthUser } = load('lib/auth.ts', {
    '@supabase/ssr': { createServerClient: () => ({ auth: { getUser: async () => ({ data: { user: null }, error: true }) } }) },
    '@/lib/supabase/server': { createAdminClient: () => client }, react: { cache: fn => fn },
  });
  return { calls, release, run: (value = token) => getAuthUser({ headers: new Headers({ authorization: `Bearer ${value}` }) }) };
}

test('staff query overlaps verification, but identity is returned only after verification', async () => {
  const fixture = authFixture();
  let resolved = false;
  const pending = fixture.run().then(value => { resolved = true; return value; });
  await Promise.resolve();
  assert.deepEqual(fixture.calls, ['verify', userId]);
  assert.equal(resolved, false);
  fixture.release();
  assert.equal((await pending).role, 'staff');
});

for (const [name, options] of [
  ['invalid token', { authError: true }],
  ['mismatched verified identity', { verifiedId: '22222222-2222-4222-8222-222222222222' }],
  ['failed staff lookup', { staffError: true }],
]) test(`${name} cannot authorize prefetched staff data`, async () => {
  const fixture = authFixture(options);
  const pending = fixture.run(); fixture.release();
  assert.equal(await pending, null);
});

test('tokens without a usable hint query only the verified user', async () => {
  const fixture = authFixture();
  const pending = fixture.run('opaque-token');
  assert.deepEqual(fixture.calls, ['verify']);
  fixture.release();
  assert.equal((await pending).id, userId);
  assert.deepEqual(fixture.calls, ['verify', userId]);
});

class BaseRepository {
  handleResponse(response) { return { data: response.error ? null : response.data, error: response.error, success: !response.error }; }
}
function orderFixture(data, error = null) {
  const calls = [];
  const { OrderRepository } = load('repository/orderRepository.ts', { './supabaseClient': { BaseRepository } });
  const repository = new OrderRepository();
  const query = new Proxy({}, { get(_, key) {
    if (key === 'then') return (resolve, reject) => Promise.resolve({ data, error, count: data?.length ?? 0 }).then(resolve, reject);
    return (...args) => { calls.push([key, ...args]); return query; };
  } });
  repository.client = { from: table => { calls.push(['from', table]); return query; } };
  return { repository, calls };
}

test('orders return accurate embedded counts without fetching child rows', async () => {
  const { repository, calls } = orderFixture([
    { id: 'busy', item_totals: [{ count: 1501 }] }, { id: 'empty', item_totals: [{ count: 0 }] },
  ]);
  const result = await repository.findAll({ branch_id: 'branch', limit: 15 });
  assert.equal(result.success, true);
  assert.deepEqual(result.data.orders.map(order => order.item_count), [1501, 0]);
  assert.equal('item_totals' in result.data.orders[0], false);
  assert.deepEqual(calls.filter(call => call[0] === 'from'), [['from', 'orders']]);
  assert.match(calls.find(call => call[0] === 'select')[1], /item_totals:order_items\(count\)/);
  assert.ok(calls.some(call => call[0] === 'eq' && call[1] === 'branch_id' && call[2] === 'branch'));
});

test('calendar summary removes nested products while retaining overlap and branch filters', async () => {
  const { repository, calls } = orderFixture([{ id: 'order', item_totals: [{ count: 3 }] }]);
  const result = await repository.getCalendarOrders('branch', '2026-11-01', '2026-11-30', true);
  const columns = calls.find(call => call[0] === 'select')[1];
  assert.doesNotMatch(columns, /images|product:|items:order_items/);
  assert.match(columns, /item_totals:order_items\(count\)/);
  assert.equal(result.data[0].item_count, 3);
  assert.ok(calls.some(call => call.join('|') === 'eq|branch_id|branch'));
  assert.ok(calls.some(call => call.join('|') === 'lte|start_date|2026-11-30'));
  assert.ok(calls.some(call => call.join('|') === 'gte|end_date|2026-11-01'));
  calls.length = 0;
  await repository.getCalendarOrders('branch', '2026-11-01', '2026-11-30');
  assert.match(calls.find(call => call[0] === 'select')[1], /product:product_id/);
});

test('calendar rejects unauthorized branches before querying and exposes safe stage timings', async () => {
  let user = { role: 'staff', branch_id: 'mine' };
  let queries = 0;
  const { ApiTiming } = load('lib/apiTiming.ts');
  const { GET } = load('app/api/calendar/route.ts', {
    '@/lib/auth': { getAuthUser: async () => user }, '@/lib/apiTiming': { ApiTiming },
    '@/services': { orderService: { getCalendarOrders: async (...args) => {
      queries++; assert.equal(args[3], true); return { success: true, data: [] };
    } } },
    '@/lib/apiResponse': {
      apiSuccess: data => Response.json(data), apiError: (_, options) => new Response(null, { status: options?.status ?? 500 }),
      apiUnauthorized: () => new Response(null, { status: 401 }), apiBadRequest: () => new Response(null, { status: 400 }),
    },
  });
  const request = { url: 'https://example.test/api/calendar?branch_id=other&start_date=2026-11-01&end_date=2026-11-30&summary=true' };
  assert.equal((await GET(request)).status, 403);
  assert.equal(queries, 0);
  user = null;
  assert.equal((await GET(request)).status, 401);
  user = { role: 'admin' };
  const response = await GET(request);
  assert.equal(response.status, 200);
  assert.match(response.headers.get('Server-Timing'), /^auth;dur=[\d.]+, data;dur=[\d.]+, total;dur=[\d.]+$/);
  assert.equal(queries, 1);
});
