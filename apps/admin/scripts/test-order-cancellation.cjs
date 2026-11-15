/**
 * Execute cancellation SQL in disposable PostgreSQL and check production schemas.
 * No environment files, application server or live database are accessed.
 * Run: node scripts/test-order-cancellation.cjs <path-to-@electric-sql/pglite>
 * @module scripts/test-order-cancellation
 */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');
const { PGlite } = require(process.argv[2] || '@electric-sql/pglite');
const ts = require('typescript');
const root = path.resolve(__dirname, '../../..');
const id = number => `00000000-0000-0000-0000-${String(number).padStart(12, '0')}`;

/** Load only explicitly permitted production modules, blocking live imports. */
function load(file, dependencies) {
  const filename = path.resolve(__dirname, '..', file);
  const code = ts.transpileModule(fs.readFileSync(filename, 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true }, fileName: filename,
  }).outputText;
  const loaded = { exports: {} };
  new Function('require', 'module', 'exports', code)(name => {
    assert.ok(Object.hasOwn(dependencies, name), `Blocked dependency: ${name}`);
    return dependencies[name];
  }, loaded, loaded.exports);
  return loaded.exports;
}

/** Start with actual table definitions so columns and defaults match the repository. */
async function setup({ legacy = false } = {}) {
  const db = new PGlite();
  const schema = fs.readFileSync(path.join(root, 'database/latest_full_schema.sql'), 'utf8');
  const names = ['branches', 'orders', 'order_items', 'payments', 'staff', 'products', 'product_inventory', 'order_status_history', 'order_reservations', 'cleaning_records'];
  await db.exec(`CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role;
    CREATE FUNCTION uuid_generate_v4() RETURNS uuid LANGUAGE sql AS $$ SELECT gen_random_uuid() $$;`);
  for (const name of names) {
    const definition = schema.match(new RegExp(`CREATE TABLE public\\.${name} \\([\\s\\S]*?\\n\\);`));
    assert.ok(definition, `Missing table ${name}`);
    await db.exec(definition[0]);
  }
  await db.exec(`
    ALTER TABLE orders ADD PRIMARY KEY(id);
    ALTER TABLE payments ADD CONSTRAINT payment_order_fk FOREIGN KEY(order_id) REFERENCES orders(id);
    ALTER TABLE orders ADD COLUMN invoice_number text;
    INSERT INTO branches(id,store_id,name,address,is_main)
      VALUES ('${id(2)}','${id(1)}','Main','Test address',true),
        ('${id(3)}','${id(1)}','Other','Test address',false);
    INSERT INTO staff(id,store_id,branch_id,name,email,role,is_active)
      VALUES ('${id(10)}','${id(1)}','${id(2)}','Staff','staff@example.test','staff',true),
        ('${id(11)}','${id(1)}','${id(3)}','Other branch','other@example.test','staff',true),
        ('${id(12)}','${id(1)}','${id(3)}','Admin','admin@example.test','admin',true),
        ('${id(13)}','${id(9)}','${id(2)}','Other store','store@example.test','admin',true);
    INSERT INTO products(id,store_id,name,slug,price_per_day,quantity,available_quantity)
      VALUES ('${id(20)}','${id(1)}','Costume','test-costume',100,10,6);
    INSERT INTO product_inventory(product_id,branch_id,quantity,available_quantity)
      VALUES ('${id(20)}','${id(2)}',10,6), ('${id(20)}','${id(3)}',10,10);
    INSERT INTO orders(id,store_id,branch_id,customer_id,status,start_date,end_date,total_amount,amount_paid,gst_amount,invoice_number)
      VALUES ('${id(30)}','${id(1)}','${id(2)}','${id(40)}','ongoing','2026-11-10','2026-11-12',600,600,30,'TEST-CANCEL');
    INSERT INTO order_items(id,order_id,product_id,quantity,price_per_day,returned_quantity)
      VALUES ('${id(50)}','${id(30)}','${id(20)}',5,100,1);
    INSERT INTO payments(id,order_id,payment_type,amount,payment_mode)
      VALUES ('${id(60)}','${id(30)}','advance',400,'cash'),('${id(61)}','${id(30)}','final',200,'upi');
    INSERT INTO order_reservations(order_id,product_id,branch_id,quantity,reserved_from,reserved_to)
      VALUES ('${id(30)}','${id(20)}','${id(2)}',5,'2026-11-10','2026-11-12');
    INSERT INTO cleaning_records(order_id,product_id,branch_id,quantity,status)
      VALUES ('${id(30)}','${id(20)}','${id(2)}',4,'scheduled'),('${id(30)}','${id(20)}','${id(2)}',1,'in_progress');
  `);
  const migration = fs.readFileSync(path.join(root, 'database/migrations/046_atomic_order_cancellation.sql'), 'utf8');
  await db.exec(migration);
  await db.exec(migration); // Deployment is repeatable.
  if (!legacy) {
    const fix = fs.readFileSync(path.join(root, 'database/migrations/047_cancellation_global_stock.sql'), 'utf8');
    await db.exec(fix);
    await db.exec(fix);
  }
  return db;
}

async function cancel(db, { staff = 10, amount = 0, mode = 'cash', reason = 'Event cancelled', returned = true } = {}) {
  return (await db.query('SELECT cancel_order($1,$2,$3,$4,$5,$6) AS result', [id(30),id(staff),reason,amount,mode,returned])).rows[0].result;
}
async function snapshot(db) {
  const result = {};
  for (const table of ['orders','order_items','products','product_inventory','payments','order_status_history','order_reservations','cleaning_records']) {
    result[table] = (await db.query(`SELECT * FROM ${table} ORDER BY id`)).rows;
  }
  return result;
}

test('ongoing cancellation restores only outstanding units, records partial refund and staff, and retries once', async () => {
  const db = await setup();
  try {
    const before = await snapshot(db);
    const order = await cancel(db, { amount: 125.25, mode: 'upi' });
    assert.equal(order.status, 'cancelled');
    assert.equal(order.amount_paid, 474.75);
    assert.notEqual(order.payment_status, 'refund_waived');
    assert.equal(order.cancelled_by, id(10));
    assert.equal(order.cancellation_reason, 'Event cancelled');
    assert.equal(order.total_amount, 600);
    assert.equal(order.gst_amount, 30);
    const after = await snapshot(db);
    assert.equal(after.products[0].available_quantity, 10);
    assert.deepEqual(after.product_inventory.map(row => row.available_quantity).sort(), [10,10]);
    assert.equal(after.order_items[0].returned_quantity, 5);
    assert.equal(after.order_reservations.length, 0);
    assert.equal(after.cleaning_records.length, 1); // Existing cleaning still needed.
    assert.equal(after.cleaning_records[0].status, 'in_progress');
    assert.deepEqual(after.payments.filter(row => row.payment_type !== 'refund'), before.payments);
    assert.equal(after.payments.filter(row => row.payment_type === 'refund').length, 1);
    assert.equal(after.order_status_history[0].changed_by, id(10));
    await Promise.all([cancel(db, { amount: 125.25 }), cancel(db, { amount: 125.25 })]);
    assert.deepEqual(await snapshot(db), after);
  } finally { await db.close(); }
});

test('full refund clears paid balance; zero refund preserves refund due', async () => {
  for (const amount of [0, 600]) {
    const db = await setup();
    try {
      const order = await cancel(db, { amount });
      assert.equal(order.amount_paid, 600 - amount);
      const rows = (await db.query("SELECT * FROM payments WHERE payment_type='refund'")).rows;
      assert.equal(rows.length, amount ? 1 : 0);
    } finally { await db.close(); }
  }
});

test('scheduled cancellation does not restore stock never dispatched', async () => {
  const db = await setup();
  try {
    await db.exec("UPDATE orders SET status='scheduled'");
    await cancel(db, { returned: false });
    assert.equal((await db.query('SELECT available_quantity FROM products')).rows[0].available_quantity, 6);
  } finally { await db.close(); }
});

test('invalid reasons/refunds, missing return confirmation, wrong scope and terminal states write nothing', async () => {
  const db = await setup();
  try {
    const before = await snapshot(db);
    for (const input of [{reason:'  '},{amount:-1},{amount:601},{amount:0.001},{amount:10,mode:'card'},{returned:false},{staff:11},{staff:13}]) {
      await assert.rejects(cancel(db, input));
      assert.deepEqual(await snapshot(db), before);
    }
    for (const status of ['completed','returned','partial','flagged']) {
      await db.query('UPDATE orders SET status=$1',[status]);
      const terminalBefore = await snapshot(db);
      await assert.rejects(cancel(db));
      assert.deepEqual(await snapshot(db), terminalBefore);
    }
  } finally { await db.close(); }
});

test('stock or refund insert failure rolls back the entire cancellation', async () => {
  for (const failRefund of [false,true]) {
    const db = await setup();
    try {
      if (failRefund) await db.exec("ALTER TABLE payments ADD CONSTRAINT reject_refund CHECK(payment_type <> 'refund')");
      else await db.query('DELETE FROM product_inventory WHERE branch_id=$1',[id(2)]);
      const before = await snapshot(db);
      await assert.rejects(cancel(db, {amount:100}));
      assert.deepEqual(await snapshot(db),before);
    } finally { await db.close(); }
  }
});

test('ledger mismatch fails closed and admin can act in another assigned branch', async () => {
  const db = await setup();
  try {
    await db.exec('UPDATE orders SET amount_paid=650');
    const before=await snapshot(db);
    await assert.rejects(cancel(db));
    assert.deepEqual(await snapshot(db),before);
    await db.exec('UPDATE orders SET amount_paid=600');
    assert.equal((await cancel(db,{staff:12})).cancelled_by,id(12));
    const permissions=(await db.query(`SELECT has_function_privilege('authenticated','cancel_order(uuid,uuid,text,numeric,text,boolean)','EXECUTE') AS client,
      has_function_privilege('service_role','cancel_order(uuid,uuid,text,numeric,text,boolean)','EXECUTE') AS server`)).rows[0];
    assert.deepEqual(permissions,{client:false,server:true});
  } finally { await db.close(); }
});

test('outstanding damaged units and invalid return counts never become available stock', async () => {
  const db = await setup();
  try {
    await db.exec("UPDATE order_items SET condition_rating='damaged',damaged_quantity=2");
    let before = await snapshot(db);
    await assert.rejects(cancel(db));
    assert.deepEqual(await snapshot(db), before);
    await db.exec('UPDATE order_items SET returned_quantity=6');
    before = await snapshot(db);
    await assert.rejects(cancel(db));
    assert.deepEqual(await snapshot(db), before);
    await db.exec('UPDATE order_items SET returned_quantity=1,damaged_quantity=1');
    // The damaged returned unit remains unavailable; only four usable units
    // are restored from this cancellation.
    await db.exec('UPDATE products SET available_quantity=5');
    await db.query('UPDATE product_inventory SET available_quantity=5 WHERE branch_id=$1', [id(2)]);
    await cancel(db);
    assert.equal((await db.query('SELECT available_quantity FROM products')).rows[0].available_quantity, 9);
    assert.equal((await db.query('SELECT damaged_quantity FROM order_items')).rows[0].damaged_quantity, 1);
  } finally { await db.close(); }
});

test('PATCH schema retains refunds and cancellation service validates before repository writes', async () => {
  const domainTypes = load('domain/types/order.ts', {});
  const schemas=load('domain/schemas/order.schema.ts', {'zod':require('zod'),'../types/order':domainTypes});
  const body={status:'cancelled',cancellation_reason:'  Event cancelled  ',refund_amount:12.25,refund_payment_mode:'cash',stock_returned:true};
  assert.equal(schemas.UpdateOrderSchema.parse(body).refund_amount,12.25);
  assert.equal(schemas.UpdateOrderSchema.safeParse({refund_amount:10}).success,false);
  assert.equal(schemas.CancelOrderSchema.parse(body).cancellation_reason,'Event cancelled');
  let writes=0;let invalidations=0;
  const {OrderCancellationService}=load('services/orderCancellationService.ts', {
    '@/domain':schemas,
    '@/repository':{orderRepository:{cancelOrder:async()=>{writes++;return {success:true,data:{id:id(30)},error:null};}}},
    './dashboardService':{dashboardService:{clearCache:()=>invalidations++}},
    '@supabase/supabase-js':require('@supabase/supabase-js'),
  });
  const service=new OrderCancellationService();
  for (const invalid of [{...body,cancellation_reason:''},{...body,refund_amount:-1},{...body,refund_payment_mode:undefined},{...body,total_amount:0}]) {
    assert.equal((await service.cancelOrder(id(30),invalid,id(10))).success,false);
  }
  assert.equal((await service.cancelOrder(id(30),body,null)).success,false);
  assert.equal(writes,0);
  assert.equal((await service.cancelOrder(id(30),body,id(10))).success,true);
  assert.equal(writes,1);assert.equal(invalidations,1);
});


test('046 reproduces missing main inventory failure; 047 changes no rows and permits global-only stock', async () => {
  const db = await setup({ legacy: true });
  try {
    // Match the failed live order shape without touching the live database.
    await db.exec(`DELETE FROM product_inventory; DELETE FROM payments;
      UPDATE orders SET amount_paid=0,total_amount=700;
      UPDATE order_items SET quantity=1,returned_quantity=0;
      UPDATE products SET quantity=1,available_quantity=0;`);
    const before = await snapshot(db);
    await assert.rejects(cancel(db), /Branch stock is missing or inconsistent/);
    assert.deepEqual(await snapshot(db), before);
    const fix = fs.readFileSync(path.join(root, 'database/migrations/047_cancellation_global_stock.sql'), 'utf8');
    await db.exec(fix);
    await db.exec(fix);
    assert.deepEqual(await snapshot(db), before); // Applying the migration writes no business data.
    const order = await cancel(db);
    assert.equal(order.status, 'cancelled');
    assert.equal(order.amount_paid, 0);
    assert.equal(order.total_amount, 700);
    const after = await snapshot(db);
    assert.equal(after.products[0].available_quantity, 1);
    assert.equal(after.order_items[0].returned_quantity, 1);
    assert.equal(after.product_inventory.length, 0);
    assert.deepEqual(after.payments, before.payments);
    await cancel(db);
    assert.deepEqual(await snapshot(db), after);
  } finally { await db.close(); }
});

test('global-only main stock preserves earlier returns, refunds once and supports assigned main products', async () => {
  const db = await setup();
  try {
    await db.exec('DELETE FROM product_inventory');
    await db.query('UPDATE products SET branch_id=$1', [id(2)]);
    const before = await snapshot(db);
    await cancel(db, { amount: 125.25 });
    const after = await snapshot(db);
    assert.equal(after.products[0].available_quantity, 10);
    assert.equal(after.order_items[0].returned_quantity, 5);
    assert.deepEqual(after.payments.filter(row => row.payment_type !== 'refund'), before.payments);
    assert.equal(Number(after.orders[0].amount_paid), 474.75);
    assert.equal(after.payments.filter(row => row.payment_type === 'refund').length, 1);
    await cancel(db, { amount: 125.25 });
    assert.deepEqual(await snapshot(db), after);
  } finally { await db.close(); }
});

test('missing main inventory never bypasses existing corrupt branch stock or another branch/store', async () => {
  const changes = [
    'UPDATE product_inventory SET available_quantity=quantity',
    'UPDATE product_inventory SET available_quantity=-1',
    `DELETE FROM product_inventory WHERE branch_id='${id(2)}'`,
    'DELETE FROM product_inventory; UPDATE branches SET is_main=false',
    `DELETE FROM product_inventory; UPDATE products SET branch_id='${id(3)}'`,
    `DELETE FROM product_inventory; UPDATE products SET store_id='${id(9)}'`,
    `DELETE FROM product_inventory; UPDATE branches SET store_id='${id(9)}'`,
    'DELETE FROM product_inventory; UPDATE products SET available_quantity=quantity',
    'DELETE FROM product_inventory; UPDATE products SET available_quantity=-1',
  ];
  const db = await setup();
  try {
    for (const change of changes) {
      await db.exec('BEGIN');
      await db.exec(change);
      const before = await snapshot(db);
      await db.exec('SAVEPOINT cancellation_test');
      await assert.rejects(cancel(db, { amount: 100 }), /stock is (missing or )?inconsistent/);
      await db.exec('ROLLBACK TO SAVEPOINT cancellation_test');
      assert.deepEqual(await snapshot(db), before);
      await db.exec('ROLLBACK');
    }
  } finally { await db.close(); }
});
