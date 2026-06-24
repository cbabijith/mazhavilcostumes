/**
 * API Performance Test Script
 *
 * Run: pnpm tsx scripts/test-api-performance.ts
 *
 * Tests all major API endpoints and reports:
 * - Response time per endpoint
 * - Pass/fail against latency budget
 * - Warnings for slow endpoints
 *
 * Prerequisites:
 * - Admin dev server running on http://localhost:3001
 * - Set x-bypass-auth header to skip auth in development
 *
 * @module scripts/test-api-performance
 */

const BASE_URL = process.env.API_BASE_URL || 'http://localhost:3001';
const AUTH_HEADER = { 'x-bypass-auth': 'true' };

// Latency budgets (ms) — adjust based on your requirements
const BUDGETS = {
  fast: 100,   // List endpoints, simple CRUD
  medium: 300, // Aggregation, search, availability
  slow: 1000,  // Reports, complex joins
};

interface TestResult {
  endpoint: string;
  method: string;
  status: number;
  durationMs: number;
  budget: number;
  pass: boolean;
  responseSize?: number;
}

const tests: { name: string; method: string; path: string; budget: number; body?: any }[] = [
  // List endpoints (should be fast)
  { name: 'Orders List', method: 'GET', path: '/api/orders?limit=10', budget: BUDGETS.fast },
  { name: 'Products List', method: 'GET', path: '/api/products?limit=10', budget: BUDGETS.fast },
  { name: 'Categories List', method: 'GET', path: '/api/categories', budget: BUDGETS.fast },
  { name: 'Branches List', method: 'GET', path: '/api/branches', budget: BUDGETS.fast },
  { name: 'Customers List', method: 'GET', path: '/api/customers?limit=10', budget: BUDGETS.fast },

  // Detail endpoints
  { name: 'Order Detail', method: 'GET', path: '/api/orders/00000000-0000-0000-0000-000000000000', budget: BUDGETS.fast },

  // Medium endpoints
  { name: 'Availability Check', method: 'POST', path: '/api/orders/check-availability', budget: BUDGETS.medium, body: {
    items: [{ product_id: '00000000-0000-0000-0000-000000000000', quantity: 1 }],
    start_date: '2026-07-01',
    end_date: '2026-07-05',
  }},

  // Dashboard (aggregation — may be slow)
  { name: 'Dashboard Overview', method: 'GET', path: '/api/dashboard/overview', budget: BUDGETS.slow },
];

async function runTest(test: typeof tests[0]): Promise<TestResult> {
  const start = performance.now();

  try {
    const options: RequestInit = {
      method: test.method,
      headers: { 'Content-Type': 'application/json', ...AUTH_HEADER },
    };
    if (test.body) {
      options.body = JSON.stringify(test.body);
    }

    const response = await fetch(`${BASE_URL}${test.path}`, options);
    const duration = Math.round(performance.now() - start);
    const text = await response.text();
    const size = new Blob([text]).size;

    return {
      endpoint: test.name,
      method: test.method,
      status: response.status,
      durationMs: duration,
      budget: test.budget,
      pass: duration <= test.budget && response.status < 500,
      responseSize: size,
    };
  } catch (err) {
    const duration = Math.round(performance.now() - start);
    return {
      endpoint: test.name,
      method: test.method,
      status: 0,
      durationMs: duration,
      budget: test.budget,
      pass: false,
    };
  }
}

async function main() {
  console.log('\n🚀 API Performance Test');
  console.log(`   Base URL: ${BASE_URL}`);
  console.log(`   Tests: ${tests.length}`);
  console.log('   ' + '─'.repeat(70));
  console.log('');

  const results: TestResult[] = [];

  // Run tests sequentially (to avoid contention affecting results)
  for (const test of tests) {
    const result = await runTest(test);
    results.push(result);

    const status = result.pass ? '✅' : '❌';
    const sizeStr = result.responseSize ? `${(result.responseSize / 1024).toFixed(1)}KB` : '—';
    console.log(
      `  ${status} ${result.endpoint.padEnd(25)} ${result.method.padEnd(5)} ${String(result.durationMs).padStart(5)}ms  (budget: ${result.budget}ms)  ${sizeStr.padStart(8)}  ${result.status}`
    );
  }

  // Summary
  const passed = results.filter(r => r.pass).length;
  const failed = results.length - passed;
  const avgTime = Math.round(results.reduce((sum, r) => sum + r.durationMs, 0) / results.length);
  const maxTime = Math.max(...results.map(r => r.durationMs));

  console.log('');
  console.log('   ' + '─'.repeat(70));
  console.log(`  Results: ${passed} passed, ${failed} failed`);
  console.log(`  Average: ${avgTime}ms  |  Slowest: ${maxTime}ms`);
  console.log('');

  if (failed > 0) {
    console.log('  ⚠️  Slow endpoints:');
    for (const r of results.filter(r => !r.pass)) {
      console.log(`     • ${r.endpoint}: ${r.durationMs}ms (budget: ${r.budget}ms)`);
    }
    console.log('');
  }

  process.exit(failed > 0 ? 1 : 0);
}

main().catch(console.error);
