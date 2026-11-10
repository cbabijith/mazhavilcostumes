/**
 * Render cancellation actions and exercise staff authorization with real schemas.
 * Hooks and repositories are isolated; no environment or live database is used.
 * @module scripts/test-cancellation-staff
 */
const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const ts = require('typescript');
const React = require('react');
const { renderToStaticMarkup } = require('react-dom/server');

/** Load production code while rejecting every unlisted dependency. */
function load(relative, dependencies = {}) {
  const filename = path.resolve(__dirname, '..', relative);
  const code = ts.transpileModule(fs.readFileSync(filename, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022,
      jsx: ts.JsxEmit.ReactJSX, esModuleInterop: true }, fileName: filename,
  }).outputText;
  const loadedModule = { exports: {} };
  new Function('require', 'module', 'exports', code)(name => {
    assert.ok(Object.hasOwn(dependencies, name), `Blocked dependency: ${name}`);
    return dependencies[name];
  }, loadedModule, loadedModule.exports);
  return loadedModule.exports;
}

const orderTypes = load('domain/types/order.ts');
const paymentTypes = load('domain/types/payment.ts');
const schemas = load('domain/schemas/order.schema.ts', {
  zod: require('zod'), '../types/order': orderTypes,
});
const staff = { id: 'user', staff_id: 'staff-1', branch_id: 'branch-1', store_id: 'store-1', role: 'staff' };

/** Keep real React rendering while replacing visual primitives only. */
function primitive(tag) {
  return ({ children, title, disabled, asChild, href }) => asChild
    ? React.Children.only(children)
    : React.createElement(tag, { title, disabled, href }, children);
}

const visualDependencies = {
  react: React, 'react/jsx-runtime': require('react/jsx-runtime'),
  'date-fns': require('date-fns'), 'lucide-react': new Proxy({}, { get: () => () => null }),
  'next/navigation': { useRouter: () => ({ push() {}, back() {} }) },
  '@/components/ui/button': { Button: primitive('button') },
  '@/lib/shared-utils': { formatCurrency: amount => `INR ${amount}` },
};

const baseOrder = { id: 'order-1', invoice_number: 'TEST-CANCEL', status: 'ongoing',
  start_date: '2026-11-10', end_date: '2026-11-12', created_at: '2026-11-10T04:00:00Z',
  total_amount: 600, amount_paid: 600, payment_status: 'paid', subtotal: 600,
  discount: 0, late_fee: 0, items: [], customer: { name: 'Example' } };

test('shared order list renders Cancel Order for active rentals and hides it for completed orders', () => {
  const { default: OrderRow } = load('components/admin/orders/OrderRow.tsx', {
    ...visualDependencies, 'next/link': primitive('a'), '@/domain': orderTypes,
    '@/components/ui/badge': { Badge: primitive('span') },
    './OrderStatusBadge': () => null,
  });
  for (const status of ['pending', 'confirmed', 'scheduled', 'delivered', 'ongoing', 'in_use', 'completed', 'cancelled']) {
    const html = renderToStaticMarkup(React.createElement(OrderRow, {
      order: { ...baseOrder, status }, selected: false, onToggleSelect() {}, onCancel() {},
    }));
    assert.equal(html.includes('title="Cancel Order"'), !['completed', 'cancelled'].includes(status), status);
  }
});

test('staff order details render ongoing cancellation without an admin-only condition', () => {
  let currentOrder = baseOrder;
  const hooks = {
    useOrder: () => ({ data: { success: true, data: currentOrder }, isLoading: false }),
    useOrderStatusHistory: () => ({ data: { data: [] } }),
    useOrderPayments: () => ({ data: [], isLoading: false }),
    useUpdateOrder: () => ({ updateOrder() {}, mutateAsync: async () => ({ success: true }) }),
  };
  for (const name of ['useProcessOrderReturn', 'useCreatePayment', 'useUpdatePayment',
    'useDeletePayment', 'useLookupProductByBarcode', 'useUpdateOrderItemDamage', 'useSetOrderDiscount']) {
    hooks[name] = () => ({});
  }
  const { default: Details } = load('components/admin/OrderDetailsView.tsx', {
    ...visualDependencies, '@/hooks': hooks,
    '@/stores': { useAppStore: selector => selector({ user: staff }),
      useAppSelectors: { showSuccess: () => () => {}, showError: () => () => {} } },
    '@/components/ui/input': { Input: primitive('input') },
    '@/components/ui/label': { Label: primitive('label') },
    '@/components/admin/Modal': () => null,
    '@/components/admin/orders': { OrderCancelModal: () => null },
    '@/domain/types/order': orderTypes, '@/domain/types/payment': paymentTypes,
    'next/dynamic': () => () => null,
  });
  for (const status of ['ongoing', 'in_use', 'delivered']) {
    currentOrder = { ...baseOrder, status };
    const html = renderToStaticMarkup(React.createElement(Details, { orderId: baseOrder.id }));
    assert.match(html, /Cancel Order/);
  }
});

test('real API guard accepts staff and cancellation uses isolated authenticated staff contexts', async () => {
  const nextServer = require('next/server');
  const permissions = load('lib/permissions.ts');
  const guard = load('lib/apiGuard.ts', {
    'next/server': nextServer, '@/lib/auth': { getAuthUser: async request => request.staff },
    '@/lib/permissions': permissions,
  });
  const response = load('lib/apiResponse.ts', { 'next/server': nextServer });
  const calls = [];
  class OrderService {
    setUserContext(staffId, branchId) { this.staffId = staffId; this.branchId = branchId; }
    async updateOrder(id, data) {
      await new Promise(resolve => setImmediate(resolve));
      calls.push({ id, data, staffId: this.staffId, branchId: this.branchId });
      return { success: true, data: { id, status: 'cancelled' } };
    }
  }
  const { PATCH } = load('app/api/orders/[id]/route.ts', {
    '@/services': { OrderService, orderService: {}, settingsService: { setStoreId() {} } },
    '@/lib/apiGuard': guard, '@/domain': schemas, '@/lib/apiResponse': response,
  });
  const payload = { status: 'cancelled', cancellation_reason: 'Event cancelled',
    refund_amount: 125.25, refund_payment_mode: 'cash', stock_returned: true, cancelled_by: 'spoofed' };
  const request = person => ({ staff: person, headers: new Headers(), json: async () => payload });
  const results = await Promise.all([
    PATCH(request(staff), { params: Promise.resolve({ id: 'order-1' }) }),
    PATCH(request({ ...staff, staff_id: 'staff-2' }), { params: Promise.resolve({ id: 'order-2' }) }),
  ]);
  assert.deepEqual(results.map(r => r.status), [200, 200]);
  assert.deepEqual(calls.map(c => c.staffId), ['staff-1', 'staff-2']);
  assert.equal(calls[0].data.refund_amount, 125.25);
  assert.equal(calls[0].data.cancelled_by, undefined);
  const denied = await PATCH(request(null), { params: Promise.resolve({ id: 'order-1' }) });
  assert.equal(denied.status, 401);
  assert.equal(calls.length, 2);
});
