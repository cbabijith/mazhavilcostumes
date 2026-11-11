/**
 * Disposable PostgreSQL fixtures for inventory regressions.
 * Loads production SQL only; never loads environment files or connects remotely.
 * @module scripts/helpers/stock-test-db
 */
const fs = require('node:fs');
const path = require('node:path');
const { PGlite } = require(process.env.PGLITE_PATH || '@electric-sql/pglite');
const root = path.resolve(__dirname, '../../../..');
const id = n => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const tables = ['branches','staff','products','product_inventory','orders','order_items','payments','order_status_history','order_reservations','cleaning_records'];
/** Create a disposable database with production table definitions and functions. */
async function createDb({ migrate = true } = {}) {
  const db = new PGlite();
  const schema = fs.readFileSync(path.join(root, 'database/latest_full_schema.sql'),'utf8');
  await db.exec(`CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role;
    CREATE FUNCTION uuid_generate_v4() RETURNS uuid LANGUAGE sql AS $$ SELECT gen_random_uuid() $$;`);
  for (const table of tables) {
    const start = schema.indexOf(`CREATE TABLE public.${table} (`);
    const end = schema.indexOf('\n);',start)+4;
    await db.exec(schema.slice(start,end));
    await db.exec(`ALTER TABLE ${table} ADD PRIMARY KEY(id)`);
  }
  await db.exec(`ALTER TABLE orders ADD COLUMN invoice_number text;
    ALTER TABLE order_items ADD COLUMN original_price_per_day numeric;
    ALTER TABLE order_items ADD FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE;
    ALTER TABLE order_status_history ADD FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE;
    ALTER TABLE product_inventory ADD FOREIGN KEY(product_id) REFERENCES products(id);
    ALTER TABLE product_inventory ADD UNIQUE(product_id,branch_id);`);
  for (const file of ['046_atomic_order_cancellation.sql','047_cancellation_global_stock.sql',...(migrate?['048_stock_integrity.sql','049_stock_bounds.sql']:[])]) {
    await db.exec(fs.readFileSync(path.join(root,'database/migrations',file),'utf8'));
  }
  return db;
}
/** Reset a fixture with a dispatched product and two usable branches. */
async function reset(db, { total=30, available=21, rented=9, returned=0, status='ongoing', paid=100 }={}) {
  await db.exec(`TRUNCATE ${tables.join(',')} CASCADE;
    INSERT INTO branches(id,store_id,name,address,is_main) VALUES('${id(2)}','${id(1)}','Main','Test',true),('${id(3)}','${id(1)}','Other','Test',false);
    INSERT INTO staff(id,store_id,branch_id,name,email,role,is_active) VALUES('${id(10)}','${id(1)}','${id(2)}','Staff','staff@example.test','staff',true);
    INSERT INTO products(id,store_id,name,slug,quantity,available_quantity,price_per_day) VALUES('${id(20)}','${id(1)}','FANCY-20','fancy-20',${total},${available},100);
    INSERT INTO product_inventory(id,product_id,branch_id,quantity,available_quantity) VALUES('${id(21)}','${id(20)}','${id(2)}',${total},${available});
    INSERT INTO orders(id,store_id,branch_id,customer_id,status,start_date,end_date,total_amount,amount_paid) VALUES('${id(30)}','${id(1)}','${id(2)}','${id(40)}','${status}','2026-11-11','2026-11-14',1000,${paid});
    INSERT INTO order_items(id,order_id,product_id,quantity,returned_quantity,price_per_day) VALUES('${id(50)}','${id(30)}','${id(20)}',${rented},${returned},100);`);
}
/** Read complete rows for rollback/idempotency assertions. */
async function snapshot(db) {
  const result={};
  for (const table of tables) result[table]=(await db.query(`SELECT * FROM ${table} ORDER BY id`)).rows;
  return result;
}
/** Execute a whitelisted RPC using bound parameters. */
async function rpc(db,name,args) {
  if (!['update_product_stock_safe','update_order_stock_safe','return_order_stock_safe','delete_order_stock_safe','cancel_order','update_branch_inventory_stock_safe'].includes(name)) throw Error('Unexpected RPC');
  const values=Object.values(args);
  const result=await db.query(`SELECT ${name}(${values.map((_,i)=>'$'+(i+1)).join(',')}) AS value`,values);
  return result.rows[0].value;
}
module.exports={createDb,reset,snapshot,rpc,id,root};

// Adapter keeps the existing UI/financial regression fixtures while executing
// the replacement return implementation in PostgreSQL, not a copied formula.
let returnFixtureDb;
async function returnSnapshot(rows,data) {
  returnFixtureDb ||= createDb();
  const db=await returnFixtureDb;
  const aliases=new Map([['order-1',id(30)],['product-1',id(20)],['branch-1',id(2)]]);
  rows.order_items.forEach((row,n)=>aliases.set(row.id,id(50+n)));
  const reverse=new Map([...aliases].map(([a,b])=>[b,a]));
  const map=(value,lookup)=>value instanceof Date?value.toISOString():Array.isArray(value)?value.map(v=>map(v,lookup)):value&&typeof value==='object'?Object.fromEntries(Object.entries(value).map(([k,v])=>[k,map(v,lookup)])):lookup.get(value)??value;
  const total=rows.products[0].quantity;
  await reset(db,{total,available:rows.products[0].available_quantity,rented:1,paid:0});
  const defaults=(await db.query('SELECT to_jsonb(o) value FROM orders o')).rows[0].value;
  const order={...defaults,...map(rows.orders[0],aliases)};
  await db.query('DELETE FROM order_items');await db.query('DELETE FROM orders');
  await db.query('INSERT INTO orders SELECT (jsonb_populate_record(NULL::orders,$1)).*',[order]);
  for(const i of rows.order_items){
    const data={id:id(50),order_id:id(30),product_id:id(20),quantity:2,price_per_day:100,returned_quantity:0,damaged_quantity:0,damage_charges:0,...map(i,aliases)};
    await db.query('INSERT INTO order_items SELECT (jsonb_populate_record(NULL::order_items,$1)).*',[data]);
  }
  const result=await rpc(db,'return_order_stock_safe',{id:id(30),data:map(data,aliases),staff:null});
  for(const table of ['orders','order_items','products','product_inventory','order_status_history']){
    const current=map((await db.query(`SELECT * FROM ${table} ORDER BY id`)).rows,reverse);
    for(const row of current) for(const key of ['total_amount','discount','late_fee','damage_charges_total','amount_paid','damage_charges','base_amount','gst_amount']) if(row[key]!=null)row[key]=Number(row[key]);
    if(table==='orders'||table==='order_items') current.forEach((row,n)=>Object.assign(rows[table][n]||{},row));
    else rows[table]=current;
  }
  return result;
}
async function closeReturnFixture(){if(returnFixtureDb)await(await returnFixtureDb).close();}
module.exports.returnSnapshot=returnSnapshot;
module.exports.closeReturnFixture=closeReturnFixture;
