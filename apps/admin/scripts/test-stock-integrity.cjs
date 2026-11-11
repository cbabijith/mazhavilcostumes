/**
 * Stock integrity regressions against actual production PostgreSQL functions.
 * Run with PGLITE_PATH pointing to the disposable PGlite installation.
 * @module scripts/test-stock-integrity
 */
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {test,before,after,beforeEach}=require('node:test');
const {createDb,reset,snapshot,rpc,id,root}=require('./helpers/stock-test-db.cjs');
let db;
before(async()=>{db=await createDb();});
after(async()=>{await db.close();});
beforeEach(async()=>{await reset(db);});
const product=(patch={},inventory=null,removed=[])=>rpc(db,'update_product_stock_safe',{id:id(20),patch,inventory,removed});
const update=(patch={},items=null,order=30,staff=10)=>rpc(db,'update_order_stock_safe',{id:id(order),patch,items,staff:id(staff)});
const item=(qty=9,productId=20)=>({product_id:id(productId),quantity:qty,price_per_day:100,original_price_per_day:100,subtotal:qty*100,base_amount:qty*100,gst_amount:0,gst_percentage:0});
const returned=(qty=9,overrides={})=>({item_id:id(50),returned_quantity:qty,condition_rating:'good',...overrides});
const receive=(items=[returned()],other={})=>rpc(db,'return_order_stock_safe',{id:id(30),data:{items,...other},staff:id(10)});
async function stock(){return (await db.query('SELECT quantity,available_quantity FROM products WHERE id=$1',[id(20)])).rows[0];}
async function rejectsUnchanged(action,pattern){const before=await snapshot(db);await assert.rejects(action,pattern);assert.deepEqual(await snapshot(db),before);}

test('reproduces old product-edit reset from 30 total to 39 available, with no historical backfill',async()=>{
 const legacy=await createDb({migrate:false});
 try {
  await reset(legacy);
  await legacy.exec('UPDATE products SET available_quantity=quantity; UPDATE products SET available_quantity=available_quantity+9');
  assert.equal((await legacy.query('SELECT available_quantity FROM products')).rows[0].available_quantity,39);
  const before=await snapshot(legacy);
  const migration=fs.readFileSync(path.join(root,'database/migrations/048_stock_integrity.sql'),'utf8');
  await legacy.exec(migration);await legacy.exec(migration);
  await legacy.exec(fs.readFileSync(path.join(root,'database/migrations/049_stock_bounds.sql'),'utf8'));
  assert.deepEqual(await snapshot(legacy),before);
  await assert.rejects(legacy.exec('UPDATE products SET available_quantity=40'),/products_stock_bounds/);
 }finally{await legacy.close();}
});
test('editing name or old-client availability preserves rented stock; nine returns finish at 30',async()=>{
 await product({name:'Renamed',quantity:30,available_quantity:30});assert.deepEqual(await stock(),{quantity:30,available_quantity:21});
 await receive();assert.deepEqual(await stock(),{quantity:30,available_quantity:30});
});
test('increasing/decreasing totals changes available only by the quantity delta',async()=>{
 await product({quantity:35,available_quantity:35});assert.deepEqual(await stock(),{quantity:35,available_quantity:26});
 await product({quantity:28});assert.deepEqual(await stock(),{quantity:28,available_quantity:19});
 await rejectsUnchanged(()=>product({quantity:8}),/unavailable/);
});
test('branch edits preserve unavailable units and reject shrinking below them',async()=>{
 await product({},[{branch_id:id(2),quantity:35}]);
 assert.equal((await db.query('SELECT available_quantity FROM product_inventory')).rows[0].available_quantity,26);
 await rejectsUnchanged(()=>product({name:'Must roll back'},[{branch_id:id(2),quantity:8}]),/unavailable/);
});
test('new branch allocation includes already-dispatched units; unavailable allocation cannot be removed',async()=>{
 await db.exec('DELETE FROM product_inventory');await product({},[{branch_id:id(2),quantity:30}]);
 const allocation=(await db.query('SELECT * FROM product_inventory')).rows[0];assert.equal(allocation.available_quantity,21);
 await rejectsUnchanged(()=>product({},null,[allocation.id]),/unavailable/);
});
test('global-only main stock supports normal returns',async()=>{
 await db.exec('DELETE FROM product_inventory');await receive();assert.equal((await stock()).available_quantity,30);
});
test('starting rental is atomic and retried starts cannot deduct twice',async()=>{
 await reset(db,{available:30,status:'scheduled'});
 await Promise.all([update({status:'ongoing'}),update({status:'ongoing'})]);
 assert.equal((await stock()).available_quantity,21);
 assert.equal((await db.query('SELECT * FROM order_status_history')).rows.length,1);
});
test('insufficient stock rejects start without clamping or changing order status',async()=>{
 await reset(db,{total:5,available:5,rented:9,status:'scheduled'});
 await rejectsUnchanged(()=>update({status:'ongoing'}),/insufficient/);
});
test('dispatched quantity edits apply only the delta and failures roll back all order fields',async()=>{
 await update({notes:'size change'},[item(11)]);assert.equal((await stock()).available_quantity,19);
 await update({},[item(7)]);assert.equal((await stock()).available_quantity,23);
 await rejectsUnchanged(()=>update({notes:'bad change'},[item(31)]),/insufficient/);
});
test('editing items and dispatching in the same transaction deducts the final quantities once',async()=>{
 await reset(db,{available:30,status:'scheduled'});await update({status:'ongoing'},[item(12)]);
 assert.equal((await stock()).available_quantity,18);
});
test('empty item edit retains all lines and does not change stock',async()=>{
 await update({notes:'No item change'},[]);assert.equal((await stock()).available_quantity,21);
 assert.equal((await db.query('SELECT * FROM order_items')).rows.length,1);
});
test('partial return and completed retry restore each piece once, including extra-discount retries',async()=>{
 await receive([returned(4)],{late_fee:20,discount:25});assert.equal((await stock()).available_quantity,25);
 const before=await snapshot(db);await receive([returned(4)],{late_fee:20,discount:25});assert.deepEqual(await snapshot(db),before);
 await Promise.all([receive(),receive()]);assert.equal((await stock()).available_quantity,30);
 assert.equal((await db.query('SELECT discount FROM orders')).rows[0].discount,'25.00');
});
test('simultaneous return calls for different orders sharing a product do not lose increments',async()=>{
 await db.exec(`INSERT INTO orders SELECT (jsonb_populate_record(o,jsonb_build_object('id','${id(31)}'))).* FROM orders o;
 INSERT INTO order_items(id,order_id,product_id,quantity,price_per_day) VALUES('${id(51)}','${id(31)}','${id(20)}',2,100);
 UPDATE products SET available_quantity=19;UPDATE product_inventory SET available_quantity=19;`);
 await Promise.all([receive(),rpc(db,'return_order_stock_safe',{id:id(31),data:{items:[{...returned(2),item_id:id(51)}]},staff:id(10)})]);
 assert.equal((await stock()).available_quantity,30);
});
test('returned quantities cannot go backwards, exceed rented counts, repeat item IDs or target another order',async()=>{
 await receive([returned(3)]);
 for(const items of [[returned(2)],[returned(10)],[returned(4),returned(4)],[{...returned(1),item_id:id(999)}],[returned(3.5)]]) await rejectsUnchanged(()=>receive(items),/return|Return|Duplicate|integer/);
});
test('missing or full branch stock rolls back global stock, returns, charges and history',async()=>{
 await db.exec('UPDATE product_inventory SET available_quantity=quantity');
 await rejectsUnchanged(()=>receive(undefined,{late_fee:50,discount:25}),/Branch stock/);
});
test('a failure after stock restoration rolls back every item and order write',async()=>{
 await db.exec("ALTER TABLE order_status_history ADD CONSTRAINT reject_return_history CHECK(status NOT IN ('returned','partial'))");
 try{await rejectsUnchanged(()=>receive(),/reject_return_history/);}finally{await db.exec('ALTER TABLE order_status_history DROP CONSTRAINT reject_return_history');}
});
test('deletion restores only outstanding stock; retry and failed delete never restore twice',async()=>{
 await receive([returned(3)]);
 await db.exec("ALTER TABLE orders ADD COLUMN prevent_delete boolean; CREATE FUNCTION reject_delete_fixture() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'fixture delete failed'; END $$; CREATE TRIGGER reject_delete_fixture BEFORE DELETE ON orders FOR EACH ROW EXECUTE FUNCTION reject_delete_fixture()");
 try{await rejectsUnchanged(()=>rpc(db,'delete_order_stock_safe',{id:id(30),staff:id(10)}),/fixture delete failed/);}finally{await db.exec('DROP TRIGGER reject_delete_fixture ON orders; DROP FUNCTION reject_delete_fixture(); ALTER TABLE orders DROP COLUMN prevent_delete');}
 await rpc(db,'delete_order_stock_safe',{id:id(30),staff:id(10)});await rpc(db,'delete_order_stock_safe',{id:id(30),staff:id(10)});
 assert.equal((await stock()).available_quantity,30);
});
test('all direct product/branch writes are bounded by the database',async()=>{
 for(const table of ['products','product_inventory']) for(const assignment of ['available_quantity=31','available_quantity=-1','quantity=20']) await assert.rejects(db.exec(`UPDATE ${table} SET ${assignment}`),/stock_bounds/);
});
test('unchanged payment amounts, original discounts, additional charges and prior damage survive return',async()=>{
 await db.exec('UPDATE orders SET total_amount=1025,discount=100,damage_charges_total=20,late_fee=30');
 const o=await receive([returned(9,{condition_rating:'damaged',damage_charges:40,damaged_quantity:1})],{late_fee:50,discount:25});
 assert.equal(o.total_amount,1060);assert.equal(o.damage_charges_total,60);assert.equal(o.discount,125);assert.equal(o.amount_paid,100);
});
test('later good returns preserve previously recorded damage fees and counts',async()=>{
 await receive([returned(4,{condition_rating:'damaged',damage_charges:60,damaged_quantity:1})]);
 await receive();const row=(await db.query('SELECT * FROM order_items')).rows[0];assert.equal(row.damage_charges,'60.00');assert.equal(row.damaged_quantity,1);
});
test('cancellation remains atomic and compatible with the stock bounds',async()=>{
 const result=await rpc(db,'cancel_order',{id:id(30),staff:id(10),reason:'Program cancelled',amount:0,mode:null,returned:true}).catch(e=>e);
 // The fixture has amount_paid=100 but no receipt: retain the ledger guard.
 assert.match(result.message,/Payment ledger/);assert.equal((await stock()).available_quantity,21);
 await db.exec('UPDATE orders SET amount_paid=0');
 const order=await rpc(db,'cancel_order',{id:id(30),staff:id(10),reason:'Program cancelled',amount:0,mode:null,returned:true});
 assert.equal(order.status,'cancelled');assert.equal((await stock()).available_quantity,30);
});
test('stock functions deny public execution and scope staff to their own branch',async()=>{
 const permissions=(await db.query("SELECT has_function_privilege('anon','return_order_stock_safe(uuid,jsonb,uuid)','EXECUTE') client,has_function_privilege('service_role','return_order_stock_safe(uuid,jsonb,uuid)','EXECUTE') server")).rows[0];
 assert.deepEqual(permissions,{client:false,server:true});
 await db.query('UPDATE staff SET branch_id=$1',[id(3)]);await rejectsUnchanged(()=>receive(),/authorized/);
});

test('branch-only inventory adjustments preserve unavailable stock and serialize increments',async()=>{
 await rpc(db,'update_branch_inventory_stock_safe',{id:id(21),patch:{quantity:35,available_quantity:35},adjustment:null});
 assert.equal((await db.query('SELECT available_quantity FROM product_inventory')).rows[0].available_quantity,26);
 await Promise.all([1,1].map(adjustment=>rpc(db,'update_branch_inventory_stock_safe',{id:id(21),patch:{},adjustment})));
 const inv=(await db.query('SELECT * FROM product_inventory')).rows[0];assert.equal(inv.quantity,37);assert.equal(inv.available_quantity,28);
 await rejectsUnchanged(()=>rpc(db,'update_branch_inventory_stock_safe',{id:id(21),patch:{},adjustment:-30}),/unavailable/);
});
