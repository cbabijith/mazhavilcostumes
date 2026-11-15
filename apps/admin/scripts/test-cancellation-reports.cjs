/**
 * Business/revenue/GST cancellation regressions against the real report service.
 * In-memory reads only; no live database or environment access.
 * @module scripts/test-cancellation-reports
 */
const assert = require('node:assert/strict');
const { test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const ts = require('typescript');

function setup() {
  const order={id:'order-1',invoice_number:'TEST-1',status:'ongoing',payment_status:'paid',total_amount:600,
    amount_paid:600,gst_amount:30,store_id:'store-1',branch_id:'branch-1',created_at:'2026-11-10T04:00:00Z',
    updated_at:'2026-11-10T04:00:00Z',start_date:'2026-11-10',damage_charges_total:0,late_fee:0,customer:{name:'Example'}};
  const payment=(type,amount,date='2026-11-10T04:00:00Z')=>({order,amount,payment_mode:'cash',payment_type:type,payment_date:date,created_at:date});
  const rows={orders:[order],payments:[payment('advance',600)],settings:[{key:'invoice_prefix',value:'TEST'}],
    order_items:[{id:'item-1',order,gst_percentage:5,base_amount:570,gst_amount:30,subtotal:600,quantity:1,product:{name:'Costume'}}]};
  const value=(row,field)=>field.split('.').reduce((v,key)=>v?.[key],row);
  const db={from(table){
    assert.ok(Object.hasOwn(rows,table));
    const predicates=[];let single=false;
    return {
      select(){return this;}, order(){return this;},
      eq(f,v){predicates.push(r=>value(r,f)===v);return this;},
      neq(f,v){predicates.push(r=>value(r,f)!==v);return this;},
      not(f,op,v){assert.equal(op,'eq');return this.neq(f,v);},
      gt(f,v){predicates.push(r=>value(r,f)>v);return this;},
      gte(f,v){predicates.push(r=>Date.parse(value(r,f))>=Date.parse(v));return this;},
      lte(f,v){predicates.push(r=>Date.parse(value(r,f))<=Date.parse(v));return this;},
      in(f,vs){predicates.push(r=>vs.includes(value(r,f)));return this;},
      or(){predicates.push(r=>r.damage_charges_total>0||r.late_fee>0);return this;},
      single(){single=true;return this;},
      then(resolve,reject){const data=rows[table].filter(r=>predicates.every(p=>p(r)));return Promise.resolve({data:single?data[0]:data,error:null}).then(resolve,reject);},
    };
  }};
  const filename=path.resolve(__dirname,'../services/reportService.ts');
  const code=ts.transpileModule(fs.readFileSync(filename,'utf8'),{compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2022}}).outputText;
  const loaded={exports:{}};
  new Function('require','module','exports',code)(name=>{
    if(name==='@/lib/supabase/server')return {createAdminClient:()=>db};
    assert.equal(name,'./settingsService');return {settingsService:{getIsGSTEnabled:async()=>({success:true,data:true})}};
  },loaded,loaded.exports);
  return {service:new loaded.exports.ReportService(),order,rows,payment};
}

for(const refund of [0,125.25,600]){
  test(`cancelled rental with refund ${refund}: business, cash, refund due and GST agree`,async()=>{
    const {service,order,rows,payment}=setup();
    const metrics=()=>service.getUnifiedRevenueMetrics('2026-11-10','2026-11-10','branch-1','store-1');
    const gst=()=>service.getGSTFilingReport({from_date:'2026-11-10',to_date:'2026-11-10'});
    assert.equal((await metrics()).total_booking_sales,600);
    assert.equal((await metrics()).total_gst_collected,30);
    assert.equal((await gst()).total_gst,30);
    order.status='cancelled';order.amount_paid=600-refund;
    if(refund)rows.payments.push(payment('refund',refund));
    const after=await metrics();
    assert.equal(after.total_booking_sales,0);
    assert.equal(after.total_received,600);
    assert.equal(after.total_refunded,refund);
    assert.equal(after.total_cash_collection,600-refund);
    assert.equal(after.total_cash,600-refund);
    assert.equal(after.cancelled_total,600-refund);
    assert.equal(after.summary[0].cancelled_revenue,600-refund);
    assert.equal(after.refund_due,600-refund);
    assert.equal(after.revenue_due,0);
    assert.equal(after.total_gst_collected,0);
    assert.equal((await gst()).total_gst,0);
    assert.equal((await gst()).details.length,0);
    assert.equal(order.gst_amount,30); // Reporting never destroys original invoice tax.
    order.payment_status='refund_waived';
    assert.equal((await metrics()).refund_due,0);
    assert.equal((await metrics()).total_cash_collection,600-refund);
  });
}

test('refund in a later period is negative cash on its own date without phantom GST or sales',async()=>{
  const {service,order,rows,payment}=setup();
  order.status='cancelled';order.amount_paid=0;
  rows.payments.push(payment('refund',600,'2026-11-11T04:00:00Z'));
  const metrics=await service.getUnifiedRevenueMetrics('2026-11-11','2026-11-11','branch-1','store-1');
  assert.equal(metrics.total_cash_collection,-600);
  assert.equal(metrics.total_refunded,600);
  assert.equal(metrics.total_booking_sales,0);
  assert.equal(metrics.total_gst_collected,0);
});

test('refund-due scope excludes another store and another branch',async()=>{
  const {service,order}=setup();order.status='cancelled';
  assert.equal((await service.getUnifiedRevenueMetrics('2026-11-10','2026-11-10','branch-2','store-1')).refund_due,0);
  assert.equal((await service.getUnifiedRevenueMetrics('2026-11-10','2026-11-10',null,'store-2')).refund_due,0);
});
