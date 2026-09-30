/**
 * Order return adjustment regressions against the production repository method.
 * Uses an in-memory Supabase substitute; no environment files, network or live DB.
 * Run: node scripts/test-order-return-adjustments.cjs
 * @module scripts/test-order-return-adjustments
 */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');
const ts = require('typescript');

/** Load the production repository with database imports explicitly blocked. */
function loadRepository() {
  const filename = path.resolve(__dirname, '../repository/orderRepository.ts');
  const compiled = ts.transpileModule(fs.readFileSync(filename, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
    fileName: filename,
  }).outputText;
  class BaseRepository {
    handleResponse(response) {
      return { data: response.error ? null : response.data, error: response.error, success: !response.error };
    }
  }
  const loaded = { exports: {} };
  new Function('require', 'module', 'exports', compiled)((id) => {
    assert.equal(id, './supabaseClient', `Unexpected dependency; network blocked: ${id}`);
    return { BaseRepository };
  }, loaded, loaded.exports);
  return loaded.exports.OrderRepository;
}

const OrderRepository = loadRepository();

/** Provide mutable rows and a small query builder for the actual return flow. */
function setup(orderOverrides = {}, itemOverrides = [], failSnapshotTable = null) {
  const order = {
    id: 'order-1', status: 'ongoing', branch_id: 'branch-1', total_amount: 1000,
    discount: 0, late_fee: 0, damage_charges_total: 0, amount_paid: 0,
    ...orderOverrides,
  };
  const items = (itemOverrides.length ? itemOverrides : [{}]).map((item, index) => ({
    id: `item-${index + 1}`, order_id: order.id, product_id: 'product-1',
    quantity: 2, returned_quantity: 0, condition_rating: 'excellent',
    damage_charges: 0, base_amount: 1000, gst_amount: 0, ...item,
  }));
  const rows = {
    orders: [order], order_items: items, order_status_history: [],
    products: [{ id: 'product-1', available_quantity: 5 }],
    product_inventory: [{ product_id: 'product-1', branch_id: 'branch-1', available_quantity: 5 }],
  };
  const writes = [];
  const reads = new Map();
  const repository = new OrderRepository();
  repository.client = {
    from(table) {
      assert.ok(Object.hasOwn(rows, table), `Unexpected table: ${table}`);
      return {
        operation: 'select', columns: '*', filters: [], payload: null, isSingle: false,
        select(columns = '*') { this.columns = columns; return this; },
        update(payload) { this.operation = 'update'; this.payload = payload; return this; },
        insert(payload) { this.operation = 'insert'; this.payload = payload; return this; },
        eq(column, value) { this.filters.push((row) => row[column] === value); return this; },
        in(column, values) { this.filters.push((row) => values.includes(row[column])); return this; },
        single() { this.isSingle = true; return this; },
        then(resolve, reject) {
          try {
            const selected = rows[table].filter((row) => this.filters.every((filter) => filter(row)));
            if (this.operation === 'select') {
              const count = (reads.get(table) || 0) + 1;
              reads.set(table, count);
              if (table === failSnapshotTable && count === 1) {
                return Promise.resolve({ data: null, error: { message: 'Snapshot failed', code: 'DB_ERROR' } }).then(resolve, reject);
              }
            } else {
              writes.push({ table, operation: this.operation, payload: structuredClone(this.payload) });
              if (this.operation === 'insert') {
                rows[table].push(structuredClone(this.payload));
              } else {
                selected.forEach((row) => Object.assign(row, this.payload));
              }
            }
            if (this.isSingle && selected.length !== 1) {
              return Promise.resolve({ data: null, error: { message: 'Row not found', code: 'PGRST116' } }).then(resolve, reject);
            }
            const projected = selected.map((row) => {
              const fields = this.columns.split(',').map((column) => column.trim());
              return Object.assign(fields.includes('*') ? structuredClone(row) : {},
                Object.fromEntries(fields.filter((column) => column !== '*').map((column) => {
                const key = column.trim();
                return key === 'orders(branch_id)'
                  ? ['orders', { branch_id: order.branch_id }]
                  : [key, row[key]];
              })));
            });
            return Promise.resolve({ data: this.isSingle ? projected[0] : projected, error: null }).then(resolve, reject);
          } catch (error) {
            return Promise.reject(error).then(resolve, reject);
          }
        },
      };
    },
  };
  return { repository, order, items, rows, writes };
}

/** Submit one item assessment using cumulative returned quantity. */
function returnItem(itemId = 'item-1', returnedQuantity = 2, damage = 0) {
  return { item_id: itemId, returned_quantity: returnedQuantity,
    condition_rating: damage > 0 ? 'damaged' : 'excellent', damage_charges: damage,
    damaged_quantity: damage > 0 ? 1 : 0 };
}

test('return retains discounted saved rental, extra charge and order-level damage', async () => {
  // Rental 1000 - original discount 100 + extra charge 75 + damage 20 + late 30.
  const state = setup({ total_amount: 1025, discount: 100, damage_charges_total: 20, late_fee: 30 });
  const result = await state.repository.processReturn('order-1', {
    items: [returnItem('item-1', 2, 40)], late_fee: 50, discount: 25,
  });
  assert.equal(result.success, true);
  assert.equal(state.order.total_amount, 1060);
  assert.equal(state.order.damage_charges_total, 60);
  assert.equal(state.order.late_fee, 50);
  assert.equal(state.order.discount, 125);
  assert.equal(state.order.status, 'flagged');
});

test('omitted late fee preserves the existing fee', async () => {
  const state = setup({ total_amount: 1100, late_fee: 100 });
  await state.repository.processReturn('order-1', { items: [returnItem()] });
  assert.equal(state.order.late_fee, 100);
  assert.equal(state.order.total_amount, 1100);
});

test('explicit zero late fee clears the fee without altering rental', async () => {
  const state = setup({ total_amount: 1100, late_fee: 100 });
  await state.repository.processReturn('order-1', { items: [returnItem()], late_fee: 0 });
  assert.equal(state.order.late_fee, 0);
  assert.equal(state.order.total_amount, 1000);
});

test('saved discount is not applied again and return discount is applied once', async () => {
  const state = setup({ total_amount: 900, discount: 100 });
  await state.repository.processReturn('order-1', { items: [returnItem()], discount: 25 });
  assert.equal(state.order.total_amount, 875);
  assert.equal(state.order.discount, 125);
});

test('replaces prior item damage while retaining separate order-level damage', async () => {
  const state = setup({ total_amount: 1100, damage_charges_total: 80, late_fee: 20 }, [
    { damage_charges: 50, returned_quantity: 1, condition_rating: 'damaged' },
  ]);
  await state.repository.processReturn('order-1', { items: [returnItem('item-1', 2, 75)], late_fee: 20 });
  assert.equal(state.order.damage_charges_total, 105);
  assert.equal(state.order.total_amount, 1125);
});

test('partial and repeated returns preserve charges without adding fees or stock twice', async () => {
  const state = setup({ total_amount: 1070, damage_charges_total: 20, late_fee: 50 });
  await state.repository.processReturn('order-1', { items: [returnItem('item-1', 1)], late_fee: 75, discount: 25 });
  assert.equal(state.order.status, 'partial');
  assert.equal(state.order.total_amount, 1070);
  assert.equal(state.order.discount, 25);
  await state.repository.processReturn('order-1', { items: [returnItem()], late_fee: 75 });
  await state.repository.processReturn('order-1', { items: [returnItem()], late_fee: 75 });
  assert.equal(state.order.total_amount, 1070);
  assert.equal(state.order.late_fee, 75);
  assert.equal(state.order.damage_charges_total, 20);
  assert.equal(state.order.discount, 25);
  assert.equal(state.rows.products[0].available_quantity, 7);
  assert.equal(state.rows.product_inventory[0].available_quantity, 7);
});

test('partial request keeps other item assessments in total damage', async () => {
  const state = setup({ total_amount: 1060, damage_charges_total: 60 }, [
    { quantity: 1 },
    { quantity: 1, returned_quantity: 1, damage_charges: 40, condition_rating: 'damaged' },
  ]);
  await state.repository.processReturn('order-1', { items: [returnItem('item-1', 1, 30)] });
  assert.equal(state.order.damage_charges_total, 90);
  assert.equal(state.order.total_amount, 1090);
});

test('numeric strings and paise keep rounded financial totals', async () => {
  const state = setup({ total_amount: '0.30', late_fee: '0.10', damage_charges_total: '0.10', discount: '0.10' }, [
    { damage_charges: '0.10' },
  ]);
  await state.repository.processReturn('order-1', { items: [returnItem('item-1', 2, 0.20)], late_fee: 0.20, discount: 0.05 });
  assert.equal(state.order.total_amount, 0.45);
  assert.equal(state.order.damage_charges_total, 0.20);
  assert.equal(state.order.discount, 0.15);
});

for (const table of ['orders', 'order_items']) {
  test(`failed ${table} snapshot prevents financial or inventory writes`, async () => {
    const state = setup({}, [], table);
    const result = await state.repository.processReturn('order-1', { items: [returnItem()] });
    assert.equal(result.success, false);
    assert.equal(result.error.code, 'DB_ERROR');
    assert.deepEqual(state.writes, []);
  });
}

/** Complete assessment DTO used by individual damage saves. */
function assessment(damage = 0) {
  return { condition_rating: damage > 0 ? 'damaged' : 'excellent',
    damage_description: damage > 0 ? 'Replacement assessment' : null,
    damage_charges: damage, damaged_quantity: damage > 0 ? 1 : 0 };
}

test('unchanged Good assessment retains discount, late fee, extra and order damage', async () => {
  const state = setup({ total_amount: 1045, discount: 100, late_fee: 50, damage_charges_total: 20 });
  const result = await state.repository.updateOrderItemDamage('item-1', assessment());
  assert.equal(result.success, true);
  assert.equal(result.data.damage_charges, 0);
  assert.equal(state.order.total_amount, 1045);
  assert.equal(state.order.discount, 100);
  assert.equal(state.order.late_fee, 50);
  assert.equal(state.order.damage_charges_total, 20);
});

test('individual damage replacement preserves original discount and separate charges', async () => {
  // Base 1000 - discount 100 + extra 75 + late 50 + total damage 100.
  const state = setup({ total_amount: 1125, discount: 100, late_fee: 50, damage_charges_total: 100 }, [
    { damage_charges: 70, condition_rating: 'damaged' },
  ]);
  const result = await state.repository.updateOrderItemDamage('item-1', assessment(90));
  assert.equal(result.success, true);
  assert.equal(result.data.damage_charges, 90);
  assert.equal(state.order.damage_charges_total, 120);
  assert.equal(state.order.total_amount, 1145);
  assert.equal(state.order.discount, 100);
  assert.equal(state.order.late_fee, 50);
  await state.repository.updateOrderItemDamage('item-1', assessment(90));
  assert.equal(state.order.damage_charges_total, 120);
  assert.equal(state.order.total_amount, 1145);
});

test('marking damaged item Good removes only its assessment fee', async () => {
  const state = setup({ total_amount: 1125, discount: 100, late_fee: 50, damage_charges_total: 100 }, [
    { damage_charges: 70, condition_rating: 'damaged' },
  ]);
  await state.repository.updateOrderItemDamage('item-1', assessment());
  assert.equal(state.order.damage_charges_total, 30);
  assert.equal(state.order.total_amount, 1055);
  assert.equal(state.order.discount, 100);
  assert.equal(state.order.late_fee, 50);
});

test('damage save includes untouched item assessments', async () => {
  const state = setup({ total_amount: 1080, damage_charges_total: 80 }, [
    { damage_charges: 20, condition_rating: 'damaged' },
    { damage_charges: 40, condition_rating: 'damaged' },
  ]);
  await state.repository.updateOrderItemDamage('item-1', assessment(30));
  assert.equal(state.order.damage_charges_total, 90);
  assert.equal(state.order.total_amount, 1090);
});

test('missing damage item returns an error without writing order or inventory', async () => {
  const state = setup();
  const result = await state.repository.updateOrderItemDamage('missing-item', assessment(30));
  assert.equal(result.success, false);
  assert.equal(result.error.code, 'PGRST116');
  assert.deepEqual(state.writes, []);
});

for (const table of ['orders', 'order_items']) {
  test(`failed ${table} damage snapshot prevents assessment changes`, async () => {
    const state = setup({}, [], table);
    const result = await state.repository.updateOrderItemDamage('item-1', assessment(30));
    assert.equal(result.success, false);
    assert.equal(result.error.code, 'DB_ERROR');
    assert.deepEqual(state.writes, []);
  });
}

test('return financial updates preserve deliberate refund waiver', async () => {
  const state = setup({ payment_status: 'refund_waived', amount_paid: 1000 });
  await state.repository.processReturn('order-1', { items: [returnItem()], late_fee: 25 });
  assert.equal(state.order.total_amount, 1025);
  assert.equal(state.order.payment_status, 'refund_waived');
});

test('individual damage updates preserve deliberate refund waiver', async () => {
  const state = setup({ payment_status: 'refund_waived', amount_paid: 1000 });
  await state.repository.updateOrderItemDamage('item-1', assessment(25));
  assert.equal(state.order.total_amount, 1025);
  assert.equal(state.order.payment_status, 'refund_waived');
});

/** Execute the web component's actual preview expressions and late-fee payload. */
function loadWebPreview() {
  const filename = path.resolve(__dirname, '../components/admin/OrderDetailsView.tsx');
  const source = ts.createSourceFile(filename, fs.readFileSync(filename, 'utf8'),
    ts.ScriptTarget.Latest, true, ts.ScriptKind.TSX);
  const names = new Set(['calculatedItemDamage', 'orderLevelDamage', 'calculatedDamage',
    'originalOrderTotalBeforeReturn', 'projected_total', 'displayLateFee', 'displayDamageCharges']);
  const declarations = [];
  let payloadLateFee;
  function visit(node) {
    if (ts.isVariableDeclaration(node) && ts.isIdentifier(node.name)) {
      if (names.has(node.name.text)) {
        declarations.push(`const ${node.getText(source)};`);
        names.delete(node.name.text);
      }
      if (node.name.text === 'returnPayload' && ts.isObjectLiteralExpression(node.initializer)) {
        const property = node.initializer.properties.find((entry) =>
          ts.isPropertyAssignment(entry) && entry.name.getText(source) === 'late_fee');
        payloadLateFee = property?.initializer.getText(source);
      }
    }
    ts.forEachChild(node, visit);
  }
  visit(source);
  assert.equal(names.size, 0, 'Production web preview declarations must be present');
  assert.ok(payloadLateFee, 'Production web return must submit a late fee');
  const code = ts.transpileModule(`${declarations.join('\n')}
    return { calculatedDamage, projected_total, displayLateFee, displayDamageCharges,
      submittedLateFee: (${payloadLateFee}) };`, {
    compilerOptions: { target: ts.ScriptTarget.ES2022 },
  }).outputText;
  return new Function('order', 'returnItems', 'lateFee', 'discount', 'isReturnable', code);
}

test('web preview and request agree with server cumulative fee and saved damage contract', async () => {
  const state = setup({ total_amount: 1125, discount: 100, late_fee: 50, damage_charges_total: 100 }, [
    { damage_charges: 70, condition_rating: 'damaged' },
  ]);
  const preview = loadWebPreview()({ ...state.order, items: state.items },
    { 'item-1': { damage_fee: 90 } }, 25, 20, true);
  assert.equal(preview.calculatedDamage, 120);
  assert.equal(preview.displayDamageCharges, 120);
  assert.equal(preview.displayLateFee, 75);
  assert.equal(preview.submittedLateFee, 75);
  assert.equal(preview.projected_total, 1150);
  await state.repository.processReturn('order-1', {
    items: [returnItem('item-1', 2, 90)], late_fee: preview.submittedLateFee, discount: 20,
  });
  assert.equal(state.order.total_amount, preview.projected_total);
});

test('web on-time return with no new fee retains existing late fee and extra charge', async () => {
  const state = setup({ total_amount: 1045, discount: 100, late_fee: 50, damage_charges_total: 20 });
  const preview = loadWebPreview()({ ...state.order, items: state.items },
    { 'item-1': { damage_fee: 0 } }, 0, 0, true);
  assert.equal(preview.displayLateFee, 50);
  assert.equal(preview.submittedLateFee, 50);
  assert.equal(preview.projected_total, 1045);
  await state.repository.processReturn('order-1', { items: [returnItem()], late_fee: preview.submittedLateFee });
  assert.equal(state.order.total_amount, preview.projected_total);
});
