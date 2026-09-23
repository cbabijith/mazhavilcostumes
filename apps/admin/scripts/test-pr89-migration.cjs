/**
 * Execute migration 045 twice against disposable PostgreSQL (PGlite).
 * Pass the path to an installed @electric-sql/pglite package as argv[2].
 * No production configuration or database is accessed.
 * @module scripts/test-pr89-migration
 */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');
const { PGlite } = require(process.argv[2] || '@electric-sql/pglite');

test('migration repairs phantom orders, is repeatable and preserves real dues', async () => {
  const db = new PGlite();
  try {
    await db.exec(`
      CREATE TABLE orders (
        id int PRIMARY KEY, status text, payment_status text, total_amount numeric(12,2), amount_paid numeric(12,2),
        created_at timestamptz DEFAULT '2026-09-01', updated_at timestamptz,
        start_date date DEFAULT '2026-09-01', end_date date DEFAULT '2026-09-02', branch_id uuid
      );
      CREATE TABLE order_items (order_id int REFERENCES orders(id), quantity int, returned_quantity int);
      CREATE TABLE order_status_history (order_id int, status text, notes text);
      CREATE TABLE products (id int, name text, branch_id uuid);
      CREATE TABLE cleaning_records (
        id int, product_id int, quantity int, expected_return_date date, priority_order_id int, notes text, status text, priority text
      );
      CREATE FUNCTION get_operational_dashboard_metrics(timestamptz,timestamptz,date,date,date,date)
        RETURNS jsonb LANGUAGE sql AS $$ SELECT '{}'::jsonb $$;
      INSERT INTO orders (id,status,payment_status,total_amount,amount_paid,branch_id) VALUES
        (1,'returned','partial',100,100,'00000000-0000-0000-0000-000000000001'),
        (2,'ongoing','paid',100,100,'00000000-0000-0000-0000-000000000001'),
        (3,'in_use','partial',100,40,'00000000-0000-0000-0000-000000000001'),
        (4,'returned','partial',100,40,'00000000-0000-0000-0000-000000000001'),
        (5,'returned','refund_waived',100,0,'00000000-0000-0000-0000-000000000001'),
        (6,'partial','partial',100,200,'00000000-0000-0000-0000-000000000001'),
        (7,'returned','partial',100,80,'00000000-0000-0000-0000-000000000002');
      INSERT INTO order_items VALUES (1,1,1),(2,1,1),(3,2,1),(4,1,1),(5,1,1),(6,1,1),(7,1,1);
      INSERT INTO products VALUES (1,'Test costume','00000000-0000-0000-0000-000000000001');
      INSERT INTO cleaning_records VALUES (1,1,1,'2026-09-03',4,'Test','scheduled','urgent');
    `);
    const migration = fs.readFileSync(path.resolve(__dirname, '../../../database/migrations/045_payment_status_consistency.sql'), 'utf8');
    await db.exec(migration);
    const firstHistory = await db.query('SELECT * FROM order_status_history ORDER BY order_id,status');
    await db.exec(migration);
    assert.deepEqual((await db.query('SELECT * FROM order_status_history ORDER BY order_id,status')).rows, firstHistory.rows);
    const repaired = (await db.query('SELECT id,status,payment_status FROM orders ORDER BY id')).rows;
    assert.deepEqual(repaired.filter((row) => [1,2,6].includes(row.id)).map((row) => [row.status,row.payment_status]),
      [['completed','paid'],['completed','paid'],['completed','paid']]);
    assert.equal(repaired.find((row) => row.id === 5).payment_status, 'refund_waived');
    const overloads = await db.query("SELECT pronargs FROM pg_proc WHERE proname='get_operational_dashboard_metrics'");
    assert.deepEqual(overloads.rows.map((row) => row.pronargs), [7]);

    // The trigger corrects an inconsistent flag on subsequent writes.
    await db.exec("UPDATE orders SET payment_status='partial' WHERE id=1");
    assert.equal((await db.query('SELECT payment_status FROM orders WHERE id=1')).rows[0].payment_status, 'paid');

    // Simulate stale external data: the RPC must trust balance/item quantities.
    await db.exec(`
      ALTER TABLE orders DISABLE TRIGGER normalize_orders_payment_status;
      UPDATE orders SET status='flagged', payment_status='partial' WHERE id=1;
      UPDATE orders SET status='in_use' WHERE id=2;
      UPDATE orders SET payment_status='paid' WHERE id=4;
      ALTER TABLE orders ENABLE TRIGGER normalize_orders_payment_status;
    `);
    const metrics = async (branch) => (await db.query(`
      SELECT get_operational_dashboard_metrics('2026-09-03','2026-09-03 23:59:59','2026-09-03',
        '2026-09-02','2026-09-04','2026-09-08',$1::uuid) AS metrics
    `, [branch])).rows[0].metrics;
    const all = await metrics(null);
    assert.equal(all.revenueDueCount, 2);
    assert.equal(all.revenueDueAmount, 80);
    assert.equal(all.pendingReturns, 1);
    assert.equal(all.priorityCleaning[0].product.name, 'Test costume');
    const branch = await metrics('00000000-0000-0000-0000-000000000001');
    assert.equal(branch.revenueDueCount, 1);
    assert.equal(branch.revenueDueAmount, 60);
    assert.equal(branch.priorityCleaning.length, 1);
  } finally {
    await db.close();
  }
});
